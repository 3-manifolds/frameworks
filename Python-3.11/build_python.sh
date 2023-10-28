set -e
cd `dirname $0`
BASE_DIR=`pwd`
VERSION=3.11
LONG_VERSION=3.11.4
VRSN=311
SRC_DIR=python-${LONG_VERSION}
SRC_ARCHIVE=Python-${LONG_VERSION}.tgz
URL=https://www.python.org/ftp/python/${LONG_VERSION}/Python-${LONG_VERSION}.tgz
HASH=bf6ec50f2f3bfa6ffbdb385286f2c628
FRAMEWORKS=${BASE_DIR}/../Frameworks
TCL_HEADERS=${FRAMEWORKS}/Tcl.framework/Versions/8.7/Headers
TCL_LIB=${FRAMEWORKS}/Tcl.framework/Versions/8.7/Tcl
TK_HEADERS=${FRAMEWORKS}/Tk.framework/Versions/8.7/Headers
TK_LIB=${FRAMEWORKS}/Tk.framework/Versions/8.7/Tk
OPENSSL=${FRAMEWORKS}/OpenSSL.framework/Versions/Current
READLINE=${FRAMEWORKS}/Readline.framework/Versions/Current
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
    tar xfz ${SRC_ARCHIVE}
    pushd ${SRC_DIR}
#    patch -p0 < ../patches/configure.patch
#    patch -p0 < ../patches/tkinter.patch
    popd
fi
if ! [ -d dist ]; then
    mkdir dist
fi
# Create directory lib with symlinks into Frameworks
mkdir -p lib
pushd lib
rm -rf *
ln -s ../../Frameworks/Tk.framework/Versions/Current/Tk .
ln -s ../../Frameworks/Tcl.framework/Versions/Current/Tcl .
ln -s ../../Frameworks/OpenSSL.framework/Versions/Current/lib/lib* .
ln -s ../../Frameworks/Readline.framework/Versions/Current/lib/lib* .
ln -s ../../Frameworks/ZLib.framework/Versions/Current/lib/lib* .
popd
# Clean the build directory
rm -rf dist/Python.framework
pushd ${SRC_DIR}
if [ -e Makefile ]; then
    make distclean
fi
MACOSX_DEPLOYMENT_TARGET=10.9
CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.9"
CFLAGS="${CFLAGS} -I${FRAMEWORKS}/ZLib.framework/Headers"
CFLAGS="${CFLAGS} -I${FRAMEWORKS}/Readline.framework/Headers"
export CFLAGS
# Will need to add -ld_classic for XCode 15
LDFLAGS="-arch arm64 -arch x86_64"
LDFLAGS=" ${LDFLAGS} -L${FRAMEWORKS}/ZLib.framework/Versions/Current/lib"
LDFLAGS="${LDFLAGS} -L${FRAMEWORKS}/Readline.framework/Versions/Current/lib"
# limit the linker to SDK 11.0 features to prevent adding the
# LD_DYLD_CHAINED_FIXUPS and LD_DYLD_EXPORTS_TRIE load command which
# are not understood by macOS 10.14 and earlier.
LDFLAGS="${LDFLAGS} -Wl,-platform_version,macos,10.9,11.0"
export LDFLAGS
# Use our custom versions of Tcl and Tk
BUILD_RPATH=${BASE_DIR}/lib
export TCLTK_CFLAGS="-I${TCL_HEADERS} -I${TK_HEADERS}"
export TCLTK_LIBS="${TCL_LIB} ${TK_LIB} -rpath ${BASE_DIR}/lib"
export ZLIB_LIBS="-lz -L${BUILD_RPATH} -rpath ${BUILD_RPATH}"
export LIBREADLINE_LIBS="-lreadline -L${BUILD_RPATH} -rpath ${BUILD_RPATH}"
export OPENSSL_LIBS="-L${BUILD_RPATH} -lssl -lcrypt -rpath ${BUILD_RPATH}"
PREFIX=${BASE_DIR}/dist/Python.framework/Versions/${VERSION}
#
./configure \
    --prefix=${PREFIX} \
    --with-openssl=${OPENSSL} \
    --with-openssl-rpath=${BUILD_RPATH}
# Create a temporary lib dir for the build.
######
# Add the lib dir as an rpath so modules will load during the build
# patch -b -p0 < ../patches/makefile.patch
make -j4 BUILD_RPATH=${BUILD_RPATH}
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
mkdir -p ${RSRC_DIR}
sed -e "s/%VERSION%/${VERSION}/g" -e "s/%LONG_VERSION%/${LONG_VERSION}/g" Info.plist.in > ${RSRC_DIR}/Info.plist

# Replace the BUILD_RPATH with a relative rpath
FRAMEWORKS_REL=@loader_path/../../../../../..
OPENSSL_RPATH=${FRAMEWORKS_REL}/OpenSSL.framework/Versions/Current/lib
READLINE_RPATH=${FRAMEWORKS_REL}/Readline.framework/Versions/Current/lib
ZLIB_RPATH=${FRAMEWORKS_REL}/Zlib.framework/Versions/Current/lib
TCL_RPATH=${FRAMEWORKS_REL}/Tcl.framework/Versions/Current
TK_RPATH=${FRAMEWORKS_REL}/Tk.framework/Versions/Current
pushd ${PREFIX}/lib/python${VERSION}/lib-dynload
mv readline.cpython-${VRSN}-darwin_failed.so readline.cpython-${VRSN}-darwin.so 
macher clear_rpaths zlib.cpython-${VRSN}-darwin.so
macher clear_rpaths binascii.cpython-${VRSN}-darwin.so
macher clear_rpaths _ssl.cpython-${VRSN}-darwin.so
macher clear_rpaths _hashlib.cpython-${VRSN}-darwin.so
macher clear_rpaths readline.cpython-${VRSN}-darwin.so
macher add_rpath ${ZLIB_RPATH} zlib.cpython-${VRSN}-darwin.so
macher add_rpath ${ZLIB_RPATH} binascii.cpython-${VRSN}-darwin.so
macher add_rpath ${OPENSSL_RPATH} _ssl.cpython-${VRSN}-darwin.so
macher add_rpath ${OPENSSL_RPATH} _hashlib.cpython-${VRSN}-darwin.so
macher add_rpath ${READLINE_RPATH} readline.cpython-${VRSN}-darwin.so
macher add_rpath ${TCL_RPATH} _tkinter.cpython-${VRSN}-darwin.so
macher add_rpath ${TK_RPATH} _tkinter.cpython-${VRSN}-darwin.so
popd
