#!/bin/bash
#
# Configure, build, and install the LALInference executables and the
# system configuration files.
#

set -ex

# load common options
. ${RECIPE_DIR}/common.sh

# build in a sub-directory using a copy of the C build
_builddir="_build${PY_VER}_${mpi}"
cp -r _build ${_builddir}
cd ${_builddir}

# enable cross compiling with openmpi
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" && "${mpi}" == "openmpi" ]]; then
  cp -rf ${PREFIX}/share/openmpi/*.txt ${BUILD_PREFIX}/share/openmpi/
fi

if [[ "${mpi}" != "nompi" ]]; then
  CONFIGURE_ARGS="${CONFIGURE_ARGS} --enable-mpi"
fi

# the user environment scripts embed the path that configure finds for sed,
# which must not point into the build environment as that won't exist at
# runtime, so use the bare name to find sed on the user's PATH
export SED="sed"

# configure only what we need to build executables (and man pages),
# with Python support so that the Python scripts are installed and the
# user environment scripts include the Python paths
${SRC_DIR}/configure \
  ${CONFIGURE_ARGS} \
  --disable-swig \
  --enable-python \
;

# patch out dependency_libs from libtool archive to prevent overlinking
sed -i.tmp '/^dependency_libs/d' lib/liblalinference.la

# copy in the built Python bindings from the installed Python package
# so that the Python scripts can find them when rendering manuals
# (bytecode is excluded as it was compiled from the $PREFIX sources)
if [ -d "${SP_DIR}/lalinference" ]; then
  rsync -av --exclude='__pycache__' ${SP_DIR}/lalinference python/
fi

# build
${_make} -C bin

# install binaries
${_make} install -C bin

# install system configuration files
${_make} install-sysconfDATA
