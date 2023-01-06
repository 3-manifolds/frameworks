set -e
cd `dirname $0`
BASE=`pwd`
export CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.9"
mkdir -p ${BASE}/dist
make -j6 -C Tcl/macosx install-embedded SUBFRAMEWORK=1 DESTDIR=${BASE}/dist \
     DYLIB_INSTALL_DIR=@executable_path/../Frameworks/Tcl.framework/Versions/8.7/Tcl
make -j6 -C Tk/macosx install-embedded SUBFRAMEWORK=1 DESTDIR=${BASE}/dist \
     DYLIB_INSTALL_DIR=@executable_path/../Frameworks/Tk.framework/Versions/8.7/Tk
cp Tcl/libtommath/tommath.h ${BASE}/dist/Frameworks/Tcl.framework/Versions/8.7/Headers
