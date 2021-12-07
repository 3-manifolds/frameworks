BASE_DIR=`pwd`
VERSION=3.10
LONG_VERSION=3.10.0
SRC_DIR=python-${LONG_VERSION}
SRC_ARCHIVE=Python-${LONG_VERSION}.tgz
URL=https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz
HASH=729e36388ae9a832b01cf9138921b383
FRAMEWORKS=${BASE_DIR}/../Frameworks
TCL_HEADERS=${FRAMEWORKS}/Tcl.framework/Versions/8.6/Headers
TCL_LIB=${FRAMEWORKS}/Tcl.framework/Versions/8.6/Tcl
TK_HEADERS=${FRAMEWORKS}/Tk.framework/Versions/8.6/Headers
TK_LIB=${FRAMEWORKS}/Tk.framework/Versions/8.6/Tk
OPENSSL=${FRAMEWORKS}/OpenSSL.framework/Versions/3.0
RSRC_DIR=${BASE_DIR}/dist/Python.framework/Versions/${VERSION}/Resources

if ! [ -e ${SRC_ARCHIVE} ]; then
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
CFLAGS="-mmacosx-version-min=10.9"
CFLAGS="${CFLAGS} -I${FRAMEWORKS}/ZLib.framework/Headers"
CFLAGS="${CFLAGS} -I${FRAMEWORKS}/Readline.framework/Headers"
export CFLAGS
LDFLAGS=" -L${FRAMEWORKS}/ZLib.framework/Versions/Current/lib"
LDFLAGS="${LDFLAGS} -L${FRAMEWORKS}/Readline.framework/Versions/Current/lib"
export LDFLAGS
./configure --prefix=${BASE_DIR}/dist/Python.framework/Versions/${VERSION} --with-tcltk-includes="-I${TCL_HEADERS} -I${TK_HEADERS}" --with-tcltk-libs="${TCL_LIB} ${TK_LIB}" --with-openssl=${OPENSSL}
make -j6
make install
make libpython${VERSION}.dylib
popd
ln -s ${VERSION} dist/Python.framework/Versions/Current
ln -s include dist/Python.framework/Versions/${VERSION}/Headers
ln -s Versions/Current/Headers dist/Python.framework/Headers
ln -s Versions/Current/Resources dist/Python.framework/Resources
cp ${SRC_DIR}/libpython${VERSION}.dylib dist/Python.framework/Versions/${VERSION}/Python
#gcc -mmacosx-version-min=10.9 -install_name dist/Python.framework/Python -shared -o dist/Python.framework/Versions/${VERSION}/Python -Wl,-force_load,dist/Python.framework/Versions/${VERSION}/lib/libpython${VERSION}.a
#ln -s Versions/Current/Python dist/Python.framework/Python
mkdir -p ${RSRC_DIR}
sed -e "s/%VERSION%/${VERSION}/g" -e "s/%LONG_VERSION%/${LONG_VERSION}/g" Info.plist.in > ${RSRC_DIR}/Info.plist
