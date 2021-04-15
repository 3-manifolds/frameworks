BASE_DIR=`pwd`
FRAMEWORK_BUILD=${BASE_DIR}/dist/OpenSSL.framework
VERSION=1.1
LONG_VERSION=1.1.1i
LIBSSL=libssl.${VERSION}.dylib
LIBCRYPTO=libcrypto.${VERSION}.dylib
SRC_DIR=openssl-${LONG_VERSION}
SRC_ARCHIVE=openssl-${LONG_VERSION}.tar.gz
CNF_DIR=Versions/${VERSION}/config
RSRC_DIR=dist/OpenSSL.framework/Versions/${VERSION}/Resources
URL=https://www.openssl.org/source/${SRC_ARCHIVE}
HASH=e8be6a35fe41d10603c3cc635e93289ed00bf34b79671a3a4de64fcee00d5242

if ! [ -e ${SRC_ARCHIVE} ]; then
    curl -O ${URL}
fi
ACTUAL_HASH=`python3 ../bin/sha256.py ${SRC_ARCHIVE}`
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
export CFLAGS="-mmacosx-version-min=10.9"
./config --openssldir=/Library/Frameworks/OpenSSL.framework/Versions/${VERSION} --prefix=/Library/Frameworks/OpenSSL.framework/Versions/${VERSION}
sed -i -e 's|DESTDIR=|DESTDIR=../dist|g' Makefile
make -j6 install_runtime
make -j6 install_programs
make -j6 install_ssldirs
make -j6 install_dev
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
