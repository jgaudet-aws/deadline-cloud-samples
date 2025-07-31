#!/bin/sh
set -xeuo pipefail

LINUX_DIR=${SRC_DIR}/draft3/Linux/64bit

FULL_NAME=${PKG_NAME}-${PKG_VERSION}

# Move library dependencies over to lib directory
cp ${LINUX_DIR}/lib* ${PREFIX}/lib/

# Copy fonts to the fonts directory
mkdir -p ${PREFIX}/fonts
cp ${LINUX_DIR}/*.otf ${PREFIX}/fonts/

# Move Draft.so itself to site-packages folder
cp ${LINUX_DIR}/Draft.so ${SP_DIR}/

# Set the RPATH on Draft.so so it can find its dependencies in the $PREFIX/lib folder
patchelf --set-rpath '$ORIGIN/../..' ${SP_DIR}/Draft.so

# Set environment variable on activate to help Draft locate fonts within the conda package at runtime
mkdir -p $PREFIX/etc/conda/activate.d
cat <<EOF > $PREFIX/etc/conda/activate.d/$PKG_NAME-$PKG_VERSION-vars.sh
export "MAGICK_FONT_PATH=$CONDA_PREFIX/fonts"
EOF

# Clean up environment variable set above on deactivate
mkdir -p $PREFIX/etc/conda/deactivate.d
cat <<EOF > $PREFIX/etc/conda/deactivate.d/$PKG_NAME-$PKG_VERSION-vars.sh
unset MAGICK_FONT_PATH
EOF
