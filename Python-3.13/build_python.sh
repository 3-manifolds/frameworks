set -e
cd `dirname $0`
BASE_DIR=`pwd`
VERSION=3.13
LONG_VERSION=3.13.0
VRSN=313
SRC_DIR=Python-${LONG_VERSION}
SRC_ARCHIVE=Python-${LONG_VERSION}.tgz
URL=https://www.python.org/ftp/python/${LONG_VERSION}/${SRC_ARCHIVE}
HASH=c29f37220520ec6075fc37d4c62e178b
FRAMEWORKS=${BASE_DIR}/../Frameworks
TCL_HEADERS=${FRAMEWORKS}/Tcl.framework/Versions/9.0/Headers
TCL_LIB=${FRAMEWORKS}/Tcl.framework/Versions/9.0/Tcl
TK_HEADERS=${FRAMEWORKS}/Tk.framework/Versions/9.0/Headers
TK_LIB=${FRAMEWORKS}/Tk.framework/Versions/9.0/Tk
OPENSSL=${FRAMEWORKS}/OpenSSL.framework/Versions/Current
LIB_DYNLOAD=${BASE_DIR}/dist/Python.framework/Versions/Current/lib/python${VERSION}/lib-dynload
RSRC_DIR=${BASE_DIR}/dist/Python.framework/Versions/Current/Resources

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
    cd ${SRC_DIR}
    patch -p1 < ../patches/tkinter.patch
    cd ..
fi
if ! [ -d dist ]; then
    mkdir dist
fi
# Create a lib directory for the rpath trick
rm -rf lib
mkdir -p lib
ln -s ../../Frameworks/Tk.framework/Versions/Current/Tk lib
ln -s ../../Frameworks/Tcl.framework/Versions/Current/Tcl lib
ln -s ../../Frameworks/OpenSSL.framework/Versions/Current/lib/libcrypto.dylib lib
ln -s ../../Frameworks/OpenSSL.framework/Versions/Current/lib/libssl.dylib lib
BUILD_RPATH=${BASE_DIR}/lib

# Clean the build directory
rm -rf dist/Python.framework
pushd ${SRC_DIR}
if [ -e Makefile ]; then
    make distclean
fi
MACOSX_DEPLOYMENT_TARGET=10.13
CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.13"
export CFLAGS
LDFLAGS="-arch arm64 -arch x86_64"
# limit the linker to SDK 11.0 features to prevent adding the
# LD_DYLD_CHAINED_FIXUPS and LD_DYLD_EXPORTS_TRIE load command which
# are not understood by macOS 10.14 and earlier.
LDFLAGS="${LDFLAGS} -Wl,-platform_version,macos,10.13,11.0"
export LDFLAGS

# Use our custom versions of Tcl and Tk
export TCLTK_CFLAGS="-I${TCL_HEADERS} -I${TK_HEADERS}"
export TCLTK_LIBS="${TCL_LIB} ${TK_LIB} -rpath ${BASE_DIR}/lib"

# Configure
PREFIX=${BASE_DIR}/dist/Python.framework/Versions/${VERSION}
./configure --prefix=${PREFIX} \
    --with-openssl=${OPENSSL} \
    --with-openssl-rpath=${BUILD_RPATH}

# Add the lib dir as an rpath so modules will load during the build
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
#gcc -mmacosx-version-min=10.13 -install_name dist/Python.framework/Python -shared -o dist/Python.framework/Versions/${VERSION}/Python -Wl,-force_load,dist/Python.framework/Versions/${VERSION}/lib/libpython${VERSION}.a
#ln -s Versions/Current/Python dist/Python.framework/Python
mkdir -p ${RSRC_DIR}
sed -e "s/%VERSION%/${VERSION}/g" -e "s/%LONG_VERSION%/${LONG_VERSION}/g" Info.plist.in > ${RSRC_DIR}/Info.plist

# Now replace the BUILD_RPATH with a relative rpath
FRAMEWORKS_REL=@loader_path/../../../../../..
OPENSSL_RPATH=${FRAMEWORKS_REL}/OpenSSL.framework/Versions/Current/lib
TCL_RPATH=${FRAMEWORKS_REL}/Tcl.framework/Versions/Current
TK_RPATH=${FRAMEWORKS_REL}/Tk.framework/Versions/Current
pushd ${LIB_DYNLOAD}
macher clear_rpaths _ssl.cpython-${VRSN}-darwin.so
macher clear_rpaths _hashlib.cpython-${VRSN}-darwin.so
macher clear_rpaths _tkinter.cpython-${VRSN}-darwin.so
macher add_rpath ${OPENSSL_RPATH} _ssl.cpython-${VRSN}-darwin.so
macher add_rpath ${OPENSSL_RPATH} _hashlib.cpython-${VRSN}-darwin.so
macher add_rpath ${TCL_RPATH} _tkinter.cpython-${VRSN}-darwin.so
macher add_rpath ${TK_RPATH} _tkinter.cpython-${VRSN}-darwin.so
popd

