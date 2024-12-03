#!/bin/sh
set -xeuo pipefail

# The version without the build number
DEADLINE_VERSION=${PKG_VERSION}

# The local place we're installing Deadline10
D10_INSTALL_DIR=${PREFIX}/opt/Thinkbox/Deadline10
D10_CONFIG_DIR=${PREFIX}/var/lib/Thinkbox/Deadline10

mkdir -p ${D10_INSTALL_DIR}

# NOTE: This would work, but the root user requirement breaks this when building on SMF
# ./DeadlineClient-${DEADLINE_VERSION}-linux-x64-installer.run \
#     --mode unattended \
#     --prefix ${D10_INSTALL_DIR} \
#     --binariesonly true

# HACK: just copy the contents of an uploaded tarball instead of using the installer
cp -r ${SRC_DIR}/* ${D10_INSTALL_DIR}/

# Create symlinks to the Deadline commands
mkdir -p $PREFIX/bin
for BINARY in deadlinecommand deadlinecommandbg; do
    chmod a+x ${D10_INSTALL_DIR}/bin/${BINARY}
    ln -r -s ${D10_INSTALL_DIR}/bin/${BINARY} ${PREFIX}/bin/${BINARY}
done

# Create a deadline.ini file with relevant settings for isolated conda deployment
mkdir -p ${D10_CONFIG_DIR}
mkdir ${D10_CONFIG_DIR}/workers
cat <<EOF > ${D10_CONFIG_DIR}/deadline.ini
[Deadline]
SlaveDataRoot=${D10_CONFIG_DIR}/workers
EOF

# Add env vars on activate to help locate Deadline 10 things within the conda package install at runtime
mkdir -p $PREFIX/etc/conda/activate.d
cat <<EOF > $PREFIX/etc/conda/activate.d/$PKG_NAME-$PKG_VERSION-vars.sh
export "DEADLINE_PATH=\$CONDA_PREFIX/opt/Thinkbox/Deadline10"
export "DEADLINE_SYSTEM_PATH=\$CONDA_PREFIX/var/lib/Thinkbox"
export "DEADLINE_VERSION=$DEADLINE_VERSION"
EOF

# Clean up env set above on deactivate
mkdir -p $PREFIX/etc/conda/deactivate.d
cat <<EOF > $PREFIX/etc/conda/deactivate.d/$PKG_NAME-$PKG_VERSION-vars.sh
unset DEADLINE_PATH
unset DEADLINE_SYSTEM_PATH
unset DEADLINE_VERSION
EOF
