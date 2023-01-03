set -e
BASE_DIR=`pwd`
FRAMEWORK_BUILD=${BASE_DIR}/dist/OpenSSL.framework
VERSION=3.0
LONG_VERSION=3.0.0
LIBSSL=libssl.${VERSION}.dylib
LIBCRYPTO=libcrypto.${VERSION}.dylib
SRC_DIR=openssl-${LONG_VERSION}
SRC_ARCHIVE=openssl-${LONG_VERSION}.tar.gz
CNF_DIR=Versions/${VERSION}/config
RSRC_DIR=dist/OpenSSL.framework/Versions/${VERSION}/Resources
URL=https://www.openssl.org/source/${SRC_ARCHIVE}
HASH=59eedfcb46c25214c9bd37ed6078297b4df01d012267fe9e9eee31f61bc70536

if ! [ -e ${SRC_ARCHIVE} ]; then
    curl -O ${URL}
fi
ACTUAL_HASH=`/usr/bin/shasum -a 256 ${SRC_ARCHIVE}  | cut -f 1 -d' '`
if [[ ${ACTUAL_HASH} != ${HASH} ]]; then
    echo Invalid hash value for ${SRC_ARCHIVE}
    exit 1
fi
if ! [ -d ${SRC_ARCHIVE} ]; then
    tar xvfz ${SRC_ARCHIVE}
fi
pushd ${SRC_DIR}
if [ -e Makefile ]; then
    make distclean
fi
export CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.9"
./config --openssldir=/Library/Frameworks/OpenSSL.framework/Versions/${VERSION} --prefix=/Library/Frameworks/OpenSSL.framework/Versions/${VERSION} no-asm
sed -i '.orig' -e 's|DESTDIR=|DESTDIR=../dist|g' Makefile
# Unfortunately building with -j6 on M1 fails sporadically
make -j4 install_runtime
make -j4 install_programs
make -j4 install_ssldirs
make -j4 install_dev
popd
pushd dist/Library/Frameworks/OpenSSL.framework
ln -s ${VERSION} Versions/Current
ln -s Versions/Current/Resources Resources
ln -s Versions/Current/Headers Headers
ln -s include Versions/${VERSION}/Headers
mkdir ${CNF_DIR}
mv Versions/Current/*.cnf* ${CNF_DIR}
popd
mv dist/Library/Frameworks/OpenSSL.framework dist/OpenSSL.framework
rm -r dist/Library
mkdir ${RSRC_DIR}
sed -e "s/%VERSION%/${VERSION}/g" -e "s/%LONG_VERSION%/${LONG_VERSION}/g" Info.plist.in > ${RSRC_DIR}/Info.plist
