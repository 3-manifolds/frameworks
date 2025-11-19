cd `dirname $0`
BASE_DIR=`pwd`
FRAMEWORK_BUILD=${BASE_DIR}/dist/OpenSSL.framework
VERSION=3.6
LONG_VERSION=3.6.0
LIBSSL=libssl.${VERSION}.dylib
LIBCRYPTO=libcrypto.${VERSION}.dylib
SRC_DIR=openssl-${LONG_VERSION}
SRC_ARCHIVE=${SRC_DIR}.tar.gz
CNF_DIR=Versions/${VERSION}/config
RSRC_DIR=dist/OpenSSL.framework/Versions/${VERSION}/Resources
URL=https://github.com/openssl/openssl/releases/download/${SRC_DIR}/${SRC_ARCHIVE}
HASH=7d041cbc65b0f907c7fcc30b2c17334cdc6f7767
if ! [ -e ${SRC_ARCHIVE} ]; then
    curl -L -O ${URL}
fi
ACTUAL_HASH=`/usr/bin/shasum ${SRC_ARCHIVE}  | cut -f 1 -d' '`
if [[ ${ACTUAL_HASH} != ${HASH} ]]; then
    echo Invalid hash value for ${SRC_DIR}.tgz
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
