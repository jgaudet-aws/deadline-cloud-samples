#!/bin/sh
set -xeuo pipefail

# Get the version of Deadline from the conda package version.
DEADLINE_VERSION=${PKG_VERSION}

# The local place we'll be placing Deadline10 files
D10_INSTALL_DIR=${PREFIX}/opt/Thinkbox/Deadline10
D10_CONFIG_DIR=${PREFIX}/var/lib/Thinkbox/Deadline10

mkdir -p ${D10_INSTALL_DIR}

# Run the client installer in binaries-only mode to extract the runtime
./DeadlineClient-${DEADLINE_VERSION}-linux-x64-installer.run \
    --mode unattended \
    --prefix ${D10_INSTALL_DIR} \
    --binariesonly true

# Copy over the Thinkbox EULA and Notice files
cp ${D10_INSTALL_DIR}/ThinkboxEULA.txt ${SRC_DIR}/${PKG_NAME}_EULA.txt
cp ${D10_INSTALL_DIR}/bin/NOTICE ${SRC_DIR}/${PKG_NAME}_NOTICE.txt

# Create symlinks to the Deadline binaries we want to add to the search path
# when an environment with this conda package is activated
mkdir -p $PREFIX/bin
for BINARY in deadlinecommand deadlinecommandbg; do
    chmod a+x ${D10_INSTALL_DIR}/bin/${BINARY}
    ln -r -s ${D10_INSTALL_DIR}/bin/${BINARY} ${PREFIX}/bin/${BINARY}
done

# Create a deadline.ini file with relevant settings for an isolated conda deployment
mkdir -p ${D10_CONFIG_DIR}/workers
cat <<EOF > ${D10_CONFIG_DIR}/deadline.ini
[Deadline]
SlaveDataRoot=${D10_CONFIG_DIR}/workers
EOF

# Add environment variables on  activate to help locate Deadline 10 things within 
# the conda package install at runtime
mkdir -p $PREFIX/etc/conda/activate.d
cat <<EOF > $PREFIX/etc/conda/activate.d/$PKG_NAME-$PKG_VERSION-vars.sh
export "DEADLINE_PATH=\$CONDA_PREFIX/opt/Thinkbox/Deadline10"
export "DEADLINE_SYSTEM_PATH=\$CONDA_PREFIX/var/lib/Thinkbox"
export "DEADLINE_VERSION=$DEADLINE_VERSION"
EOF

# Clean up environment variables set above on deactivate
mkdir -p $PREFIX/etc/conda/deactivate.d
cat <<EOF > $PREFIX/etc/conda/deactivate.d/$PKG_NAME-$PKG_VERSION-vars.sh
unset DEADLINE_PATH
unset DEADLINE_SYSTEM_PATH
unset DEADLINE_VERSION
EOF
