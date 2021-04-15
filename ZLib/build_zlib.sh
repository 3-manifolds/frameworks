BASE_DIR=`pwd`
FRAMEWORK_BUILD=${BASE_DIR}/dist/ZLib.framework
VERSION=1.2
LONG_VERSION=1.2.11
LIBZ=libz.${LONG_VERSION}.dylib
SRC_DIR=zlib-${LONG_VERSION}
SRC_ARCHIVE=zlib-${LONG_VERSION}.tar.gz
RSRC_DIR=${FRAMEWORK_BUILD}/Versions/${VERSION}/Resources
URL=https://zlib.net/zlib-1.2.11.tar.gz
HASH=c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1

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
mkdir -p ${FRAMEWORK_BUILD}/Versions/${VERSION}
ln -s ${VERSION} ${FRAMEWORK_BUILD}/Versions/Current
ln -s Versions/Current/Headers ${FRAMEWORK_BUILD}/Headers
ln -s Versions/Current/Resources ${FRAMEWORK_BUILD}/Resources
ln -s include ${FRAMEWORK_BUILD}/Versions/${VERSION}/Headers
pushd ${SRC_DIR}
if [ -e Makefile ]; then
    make distclean
fi
export CFLAGS="-mmacosx-version-min=10.9"
./configure --prefix=${FRAMEWORK_BUILD}/Versions/${VERSION}
make
make install
popd
mkdir ${RSRC_DIR}
sed -e "s/%VERSION%/${VERSION}/g" -e "s/%LONG_VERSION%/${LONG_VERSION}/g" Info.plist.in > ${RSRC_DIR}/Info.plist

