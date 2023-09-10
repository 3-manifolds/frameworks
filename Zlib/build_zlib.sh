set -e
cd ZLib
BASE_DIR=`pwd`
FRAMEWORK_BUILD=${BASE_DIR}/dist/ZLib.framework
VERSION=1.3
LONG_VERSION=1.3
LIBZ=libz.${LONG_VERSION}.dylib
SRC_DIR=zlib-${LONG_VERSION}
SRC_ARCHIVE=zlib-${LONG_VERSION}.tar.gz
RSRC_DIR=${FRAMEWORK_BUILD}/Versions/${VERSION}/Resources
URL=https://zlib.net/zlib-1.3.tar.gz
HASH=ff0ba4c292013dbc27530b3a81e1f9a813cd39de01ca5e0f8bf355702efa593e

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
mkdir -p ${FRAMEWORK_BUILD}/Versions/${VERSION}
ln -s ${VERSION} ${FRAMEWORK_BUILD}/Versions/Current
ln -s Versions/Current/Headers ${FRAMEWORK_BUILD}/Headers
ln -s Versions/Current/Resources ${FRAMEWORK_BUILD}/Resources
ln -s include ${FRAMEWORK_BUILD}/Versions/${VERSION}/Headers
cd ${SRC_DIR}
if [ -e Makefile ]; then
    make distclean
fi
export CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.9"
./configure --prefix=${FRAMEWORK_BUILD}/Versions/${VERSION}
make
make install
cd ${BASE_DIR}
mkdir -p ${RSRC_DIR}
sed -e "s/%VERSION%/${VERSION}/g" -e "s/%LONG_VERSION%/${LONG_VERSION}/g" Info.plist.in > ${RSRC_DIR}/Info.plist

