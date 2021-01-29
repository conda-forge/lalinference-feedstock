#!/bin/bash
#
# Configure, build, and test a LALSuite subpackage (e.g. `lal`), including
# the SWIG interface files, but without any actual language bindings
#

set -e

# use out-of-tree build
mkdir -pv _build
cd _build

# only link libraries we actually use
export GSL_LIBS="-L${PREFIX}/lib -lgsl"

# configure
${SRC_DIR}/configure \
	--disable-doxygen \
	--disable-gcc-flags \
	--disable-python \
	--disable-swig-octave \
	--disable-swig-python \
	--enable-help2man \
	--enable-mpi \
	--enable-openmp \
	--enable-swig-iface \
	--prefix="${PREFIX}" \
	${EXTRA_CONFIG_FLAGS} \
;

# build
make -j ${CPU_COUNT} V=1 VERBOSE=1

# test
make -j ${CPU_COUNT} V=1 VERBOSE=1 check
