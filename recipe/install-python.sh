#!/bin/bash
#
# Configure, built, test, and install the Python language bindings
# for a LALSuite subpackage.
#

set -e
pushd ${SRC_DIR}

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

# build
make -j ${CPU_COUNT} -C swig
make -j ${CPU_COUNT} -C python

# install
make -j ${CPU_COUNT} -C swig install-exec-am  # swig bindings
make -j ${CPU_COUNT} -C python install  # pure-python extras

popd
