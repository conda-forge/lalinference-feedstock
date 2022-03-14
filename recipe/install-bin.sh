#!/bin/bash

set -ex

# build in a sub-directory using a copy of the python build
_builddir="_build${PY_VER}_${mpi}"
cp -r _build${PY_VER} ${_builddir}
cd ${_builddir}

# replace package name in debug-prefix-map with source name
export CFLAGS=$(
   echo ${CFLAGS:-} |
   sed -E 's|'\/usr\/local\/src\/conda\/${PKG_NAME}'|/usr/local/src/conda/lalinference|g'
)

# only link libraries we actually use
export GSL_LIBS="-L${PREFIX}/lib -lgsl"

# handle cross compiling
if [[ $build_platform != $target_platform ]]; then
	# help2man doesn't work when cross compiling
	CONFIGURE_ARGS="${CONFIGURE_ARGS} --disable-help2man"

	# enable cross compiling with openmpi
	if [[ "${mpi}" == "openmpi" ]]; then
		cp -rf ${PREFIX}/share/openmpi/*.txt ${BUILD_PREFIX}/share/openmpi/
	fi
fi

if [[ "${mpi}" != "nompi" ]]; then
	# only the MPI executables use OpenMP
	CONFIGURE_ARGS="${CONFIGURE_ARGS} --enable-mpi --enable-openmp"
fi

# configure only what we need to build executables (and man pages)
${SRC_DIR}/configure \
	--disable-doxygen \
	--disable-gcc-flags \
	--disable-swig \
	--enable-python \
	--prefix=$PREFIX \
	${CONFIGURE_ARGS} \
;

# install binaries
make -j ${CPU_COUNT} V=1 VERBOSE=1 install -C bin

# install system configuration files
make -j ${CPU_COUNT} V=1 VERBOSE=1 install-sysconfDATA
