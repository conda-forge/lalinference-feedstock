#!/bin/bash
#
# Configure, built, test, and install the Python language bindings
# for a LALSuite subpackage.
#

set -e
pushd ${SRC_DIR}

# only link libraries we actually use
export GSL_LIBS="-L${PREFIX}/lib -lgsl"

# configure only python bindings and pure-python extras
./configure \
	--prefix=$PREFIX \
	--disable-doxygen \
	--disable-gcc-flags \
	--disable-swig-iface \
	--enable-help2man \
	--enable-python \
	--enable-swig-python \
	--enable-silent-rules \
;

# swig bindings
make -j ${CPU_COUNT} V=1 VERBOSE=1 -C swig
make -j ${CPU_COUNT} V=1 VERBOSE=1 -C swig install-exec-am

# python modules
make -j ${CPU_COUNT} V=1 VERBOSE=1 -C python
make -j ${CPU_COUNT} V=1 VERBOSE=1 -C python install

# python scripts
make -j ${CPU_COUNT} V=1 VERBOSE=1 -C bin bin_PROGRAMS="" dist_bin_SCRIPTS=""
make -j ${CPU_COUNT} V=1 VERBOSE=1 -C bin bin_PROGRAMS="" dist_bin_SCRIPTS="" install
