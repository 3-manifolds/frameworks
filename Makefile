MACHER=/usr/local/bin/macher
ZLIB=ZLib.framework/Versions/Current/lib/libz.dylib
READLINE=Readline.framework/Versions/Current/lib/libreadline.dylib
SSL=OpenSSL.framework/Versions/Current/lib/libssl.dylib
CRYPTO=OpenSSL.framework/Versions/Current/lib/libcrypto.dylib
LIB_DYNLOAD=Python.framework/Versions/3.9/lib/python3.9/lib-dynload
OPENSSL_RPATH=@loader_path/../../../../../../OpenSSL.framework/Versions/Current/lib
READLINE_RPATH=@loader_path/../../../../../../Readline.framework/Versions/Current/lib
ZLIB_RPATH=@loader_path/../../../../../../Zlib.framework/Versions/Current/lib
TCL_RPATH=@loader_path/../../../../../../Tcl.framework/Versions/Current
TK_RPATH=@loader_path/../../../../../../Tk.framework/Versions/Current
TCL_FRAMEWORK=Frameworks/Tcl.framework
TCL_VERSION_DIR=${TCL_FRAMEWORK}/Versions/Current
TCL_LIB=${TCL_VERSION_DIR}/Tcl
TK_FRAMEWORK=Frameworks/Tk.framework
TK_VERSION_DIR=${TK_FRAMEWORK}/Versions/Current
TK_LIB=${TK_VERSION_DIR}/Tk
WISH=${TK_VERSION_DIR}/Resources/Wish.app
DEV_ID := $(shell cat DEV_ID.txt)
CS_OPTS=-v -s ${DEV_ID} --timestamp --options runtime --entitlements entitlement.plist --force
PY_CS_OPTS=-v -s ${DEV_ID} --timestamp --options runtime --force

all: Zlib Readline OpenSSL TclTk Python Sign

.PHONY: Setup Zlib Readline OpenSSL TclTk Python Sign

Setup:
	mkdir -p Frameworks

Zlib:
	cd ZLib ; \
	rm -rf dist ; \
	bash build_zlib.sh ; \
	cd ..
	rm -rf Frameworks/Zlib.framework
	mv Zlib/dist/Zlib.framework Frameworks
	${MACHER} set_id @rpath/libz.dylib Frameworks/${ZLIB}

Readline:
	cd Readline ; \
	rm -rf dist ; \
	bash build_readline.sh ; \
	cd ..
	rm -rf Frameworks/Readline.framework
	mv Readline/dist/Readline.framework Frameworks
	${MACHER} set_id @rpath/libreadline.dylib Frameworks/${READLINE}

OpenSSL:
	cd OpenSSL ; \
	rm -rf dist ; \
	bash build_openssl.sh ; \
	cd ..
	rm -rf Frameworks/OpenSSL.framework
	mv OpenSSL/dist/OpenSSL.framework Frameworks
	${MACHER} set_id @rpath/libssl.dylib Frameworks/${SSL}
	${MACHER} edit_libpath @loader_path/libcrypto.dylib Frameworks/${SSL}
	${MACHER} set_id @rpath/libcrypto.dylib Frameworks/${CRYPTO}

TclTk:
	cd TclTk ; \
	rm -rf dist ; \
	bash build_tcltk.sh ; \
	cd ..
	rm -rf ${TCL_FRAMEWORK}
	rm -rf ${TK_FRAMEWORK}
	mv TclTk/dist/Frameworks/Tcl.framework Frameworks
	mv TclTk/dist/Frameworks/Tk.framework Frameworks
	chmod +w ${TCL_LIB} ${TK_LIB}
	${MACHER} set_id @rpath/Tcl ${TCL_LIB}
	${MACHER} set_id @rpath/Tk ${TK_LIB}
	rm -rf ${WISH}
	rm ${TCL_FRAMEWORK}/{PrivateHeaders,Tcl,tclConfig.sh,libtclstub8.6.a}
	mv ${TCL_VERSION_DIR}/{tclConfig.sh,tclooConfig.sh,libtclstub8.6.a} ${TCL_VERSION_DIR}/Resources
	rm ${TK_FRAMEWORK}/{PrivateHeaders,Tk,tkConfig.sh,libtkstub8.6.a}
	mv ${TK_VERSION_DIR}/{tkConfig.sh,libtkstub8.6.a} ${TK_VERSION_DIR}/Resources

Python:
	cd Python-3.9 ; \
	rm -rf dist ; \
	bash build_python.sh ; \
	cd ..
	rm -rf Frameworks/Python.framework
	mv Python-3.9/dist/Python.framework Frameworks
	pushd Frameworks/${LIB_DYNLOAD} ; \
	mv _ssl.cpython-39-darwin_failed.so _ssl.cpython-39-darwin.so ; \
	mv _hashlib.cpython-39-darwin_failed.so _hashlib.cpython-39-darwin.so ; \
	mv readline.cpython-39-darwin_failed.so readline.cpython-39-darwin.so ; \
	mv _tkinter.cpython-39-darwin_failed.so _tkinter.cpython-39-darwin.so ; \
	${MACHER} add_rpath ${ZLIB_RPATH} zlib.cpython-39-darwin.so ; \
	${MACHER} add_rpath ${ZLIB_RPATH} binascii.cpython-39-darwin.so ; \
	${MACHER} add_rpath ${OPENSSL_RPATH} _ssl.cpython-39-darwin.so ; \
	${MACHER} add_rpath ${OPENSSL_RPATH} _hashlib.cpython-39-darwin.so ; \
	${MACHER} add_rpath ${READLINE_RPATH} readline.cpython-39-darwin.so ; \
	${MACHER} add_rpath ${TCL_RPATH} _tkinter.cpython-39-darwin.so ; \
	${MACHER} add_rpath ${TK_RPATH} _tkinter.cpython-39-darwin.so ; \
	popd

Sign:
	codesign ${CS_OPTS} `find Frameworks/Zlib.framework -type f -perm +o+x`
	codesign ${CS_OPTS} Frameworks/Zlib.framework
	codesign ${CS_OPTS} `find Frameworks/Readline.framework -type f -perm +o+x`
	codesign ${CS_OPTS} Frameworks/Readline.framework
	codesign ${CS_OPTS} `find Frameworks/OpenSSL.framework -type f -perm +o+x`
	codesign ${CS_OPTS} Frameworks/OpenSSL.framework
	codesign ${CS_OPTS} ${TCL_LIB}
	codesign ${CS_OPTS} ${TCL_FRAMEWORK}
	codesign ${CS_OPTS} ${TK_LIB}
	codesign ${CS_OPTS} ${TK_FRAMEWORK}
	codesign ${PY_CS_OPTS} `find Frameworks/Python.framework -type f -perm +o+x`
	codesign ${PY_CS_OPTS} Frameworks/Python.framework
