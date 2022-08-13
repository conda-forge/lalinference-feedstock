#!/bin/bash
#
# Configure, built, test, and install the Python language bindings
# for a LALSuite subpackage.
#

set -e

_make="make -j ${CPU_COUNT} V=1 VERBOSE=1"

# build python in a sub-directory using a copy of the C build
_builddir="_build${PY_VER}"
cp -r _build ${_builddir}
cd ${_builddir}

# replace package name in debug-prefix-map with source name
export CFLAGS=$(
   echo ${CFLAGS:-} |
   sed -E 's|'\/usr\/local\/src\/conda\/${PKG_NAME}'|/usr/local/src/conda/lalinference|g'
)

# only link libraries we actually use
export GSL_LIBS="-L${PREFIX}/lib -lgsl"

# configure only python bindings and pure-python extras
${SRC_DIR}/configure \
	--disable-doxygen \
	--disable-gcc-flags \
	--disable-swig-iface \
	--enable-python \
	--enable-swig-python \
	--prefix=$PREFIX \
;

# patch out dependency_libs from libtool archive to prevent overlinking
sed -i.tmp '/^dependency_libs/d' lib/lib${PKG_NAME##*-}.la

# build
${_make} -C swig LIBS=""
${_make} -C python LIBS=""

# install
${_make} -C swig install-exec  # swig bindings
${_make} -C python install  # pure-python extras
