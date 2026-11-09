#!/bin/bash
#
# Configure, build, test, and install the LALInference C libraries
# and data files.
#
# This is run once for the staging output, the results of which are
# then split into the lalinference-data and liblalinference packages;
# the python-lalinference and lalinference packages reuse the _build
# directory to avoid rebuilding the C libraries.
#

set -ex

# load common options
. ${RECIPE_DIR}/common.sh

# use out-of-tree build
mkdir -pv _build
cd _build

# configure needs a Python interpreter (even with --disable-python),
# so use the one from the build environment
export PYTHON=${BUILD_PREFIX}/bin/python

# configure
${SRC_DIR}/configure \
  ${CONFIGURE_ARGS} \
  --disable-python \
  --disable-swig-python \
  --enable-swig-iface \
;

# build
${_make}

# test
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ${_make} check
fi

# install library, headers, and data files
${_make} -C lib install

# install SWIG binding definitions and headers
${_make} -C swig install-data

# install pkg-config
${_make} install-pkgconfigDATA

# install activate/deactivate scripts for lalinference-data
# (the staging output has no meaningful PKG_NAME, so name them explicitly)
for action in activate deactivate; do
  mkdir -p ${PREFIX}/etc/conda/${action}.d
  for ext in sh csh; do
    _target="${PREFIX}/etc/conda/${action}.d/${action}-lalinference-data.${ext}"
    echo "-- Installing: ${_target}"
    cp "${RECIPE_DIR}/${action}-lalinference-data.${ext}" "${_target}"
  done
done
