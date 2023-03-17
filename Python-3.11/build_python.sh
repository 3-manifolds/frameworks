set -e
BASE_DIR=`pwd`
VERSION=3.11
LONG_VERSION=3.11.2
SRC_DIR=python-${LONG_VERSION}
SRC_ARCHIVE=Python-${LONG_VERSION}.tgz
URL=https://www.python.org/ftp/python/${LONG_VERSION}/Python-${LONG_VERSION}.tgz
HASH=f6b5226ccba5ae1ca9376aaba0b0f673
FRAMEWORKS=${BASE_DIR}/../Frameworks
TCL_HEADERS=${FRAMEWORKS}/Tcl.framework/Versions/8.6/Headers
TCL_LIB=${FRAMEWORKS}/Tcl.framework/Versions/8.6/Tcl
TK_HEADERS=${FRAMEWORKS}/Tk.framework/Versions/8.6/Headers
TK_LIB=${FRAMEWORKS}/Tk.framework/Versions/8.6/Tk
OPENSSL=${FRAMEWORKS}/OpenSSL.framework/Versions/3.0
RSRC_DIR=${BASE_DIR}/dist/Python.framework/Versions/${VERSION}/Resources

if ! [ -e ${SRC_ARCHIVE} ]; then
    echo Downloading ${URL}
    curl -O ${URL}
fi
ACTUAL_HASH=`md5 -q ${SRC_ARCHIVE}`
if [[ ${ACTUAL_HASH} != ${HASH} ]]; then
    echo Invalid hash value for ${SRC_ARCHIVE}
    exit 1
fi
if ! [ -d ${SRC_DIR} ]; then
    tar xvfz ${SRC_ARCHIVE}
    patch -p0 < patches/configure.patch
fi
if ! [ -d dist ]; then
    mkdir dist
fi
pushd ${SRC_DIR}
if [ -e Makefile ]; then
    make distclean
fi
MACOSX_DEPLOYMENT_TARGET=10.9
CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.9"
CFLAGS="${CFLAGS} -I${FRAMEWORKS}/ZLib.framework/Headers"
CFLAGS="${CFLAGS} -I${FRAMEWORKS}/Readline.framework/Headers"
export CFLAGS
LDFLAGS="-arch arm64 -arch x86_64"
LDFLAGS=" ${LDFLAGS} -L${FRAMEWORKS}/ZLib.framework/Versions/Current/lib"
LDFLAGS="${LDFLAGS} -L${FRAMEWORKS}/Readline.framework/Versions/Current/lib"
# limit the linker to SDK 11.0 features to prevent adding the
# LD_DYLD_CHAINED_FIXUPS and LD_DYLD_EXPORTS_TRIE load command which
# are not understood my macOS 10.14 and earlier.
LDFLAGS="${LDFLAGS} -Wl,-platform_version,macos,10.9,11.0"
export LDFLAGS
# Use our custom versions of Tck and Tk
TCLTK_CFLAGS="-I${TCL_HEADERS} -I${TK_HEADERS}"
TCLTK_LIBS="${TCL_LIB} ${TK_LIB}"
export TCLTK_CFLAGS
export TCLTK_LIBS
#
./configure \
    --prefix=${BASE_DIR}/dist/Python.framework/Versions/${VERSION}    \
    --with-openssl=${OPENSSL}
make -j4
make install
make libpython${VERSION}.dylib
popd
ln -s ${VERSION} dist/Python.framework/Versions/Current
ln -s include dist/Python.framework/Versions/${VERSION}/Headers
ln -s Versions/Current/Headers dist/Python.framework/Headers
ln -s Versions/Current/Resources dist/Python.framework/Resources
cp ${SRC_DIR}/libpython${VERSION}.dylib dist/Python.framework/Versions/${VERSION}/Python
rm -rf dist/Python.framework/Versions/${VERSION}/bin/*-config
rm -rf dist/Python.framework/Versions/${VERSION}/lib/python${VERSION}/config-${VERSION}-darwin
#gcc -mmacosx-version-min=10.9 -install_name dist/Python.framework/Python -shared -o dist/Python.framework/Versions/${VERSION}/Python -Wl,-force_load,dist/Python.framework/Versions/${VERSION}/lib/libpython${VERSION}.a
#ln -s Versions/Current/Python dist/Python.framework/Python
mkdir -p ${RSRC_DIR}
sed -e "s/%VERSION%/${VERSION}/g" -e "s/%LONG_VERSION%/${LONG_VERSION}/g" Info.plist.in > ${RSRC_DIR}/Info.plist
