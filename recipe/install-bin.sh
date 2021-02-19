#!/bin/bash

set -ex

# build in a sub-directory using a copy of the python build
_builddir="_build${PY_VER}_${mpi}"
cp -r _build${PY_VER} ${_builddir}
cd ${_builddir}

# only link libraries we actually use
export GSL_LIBS="-L${PREFIX}/lib -lgsl"

# configure only python bindings and pure-python extras
${SRC_DIR}/configure \
	--disable-doxygen \
	--disable-gcc-flags \
	--disable-swig \
	--enable-help2man \
	--enable-mpi \
	--enable-openmp \
	--enable-python \
	--prefix=$PREFIX \
;

# install binaries
make -j ${CPU_COUNT} V=1 VERBOSE=1 install -C bin

# install system configuration files
make -j ${CPU_COUNT} V=1 VERBOSE=1 install-sysconfDATA
