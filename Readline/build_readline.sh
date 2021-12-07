BASE_DIR=`pwd`
FRAMEWORK_BUILD=${BASE_DIR}/dist/Readline.framework
VERSION=8.1
READLINE=libreadline.${VERSION}.dylib
HISTORY=libhistory.${VERSION}.dylib
SRC_DIR=readline-${VERSION}
SRC_ARCHIVE=readline-${VERSION}.tar.gz
RSRC_DIR=${FRAMEWORK_BUILD}/Versions/${VERSION}/Resources
URL=https://ftp.gnu.org/pub/gnu/readline/readline-8.1.tar.gz
HASH=f8ceb4ee131e3232226a17f51b164afc46cd0b9e6cef344be87c65962cb82b02

if ! [ -e ${SRC_ARCHIVE} ]; then
    curl -O ${URL}
fi
ACTUAL_HASH=`/usr/bin/shasum -a 256 ${SRC_ARCHIVE}  | cut -w -f 1`
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
