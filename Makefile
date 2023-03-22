MACHER=/usr/local/bin/macher
ZLIB=ZLib.framework/Versions/Current/lib/libz.dylib
READLINE=Readline.framework/Versions/Current/lib/libreadline.dylib
SSL=OpenSSL.framework/Versions/Current/lib/libssl.dylib
CRYPTO=OpenSSL.framework/Versions/Current/lib/libcrypto.dylib
OPENSSL_RPATH=@loader_path/../../../../../../OpenSSL.framework/Versions/Current/lib
OPENSSL_EMB_RPATH=@loader_path/../../../Frameworks/OpenSSL.framework/Versions/Current/lib
READLINE_RPATH=@loader_path/../../../../../../Readline.framework/Versions/Current/lib
READLINE_EMB_RPATH=@loader_path/../../../Frameworks/Readline.framework/Versions/Current/lib
ZLIB_RPATH=@loader_path/../../../../../../Zlib.framework/Versions/Current/lib
ZLIB_EMB_RPATH=@loader_path/../../../Frameworks/Zlib.framework/Versions/Current/lib
TCL_RPATH=@loader_path/../../../../../../Tcl.framework/Versions/Current
TCL_EMB_RPATH=@loader_path/../../../Frameworks/Tcl.framework/Versions/Current
TK_RPATH=@loader_path/../../../../../../Tk.framework/Versions/Current
TK_EMB_RPATH=@loader_path/../../../Frameworks/Tk.framework/Versions/Current
EMB_FRAMEWORK_DIR=Frameworks/Python.framework/Versions/Current/Frameworks
TCL_FRAMEWORK=Frameworks/Tcl.framework
TCL_VERSION_DIR=${TCL_FRAMEWORK}/Versions/Current
TCL_LIB=${TCL_VERSION_DIR}/Tcl
TK_FRAMEWORK=Frameworks/Tk.framework
TK_VERSION_DIR=${TK_FRAMEWORK}/Versions/Current
TK_LIB=${TK_VERSION_DIR}/Tk
WISH=${TK_VERSION_DIR}/Resources/Wish.app
PYTHON_LIB=Frameworks/Python.framework/Versions/3.11/lib/python3.11
LIB_DYNLOAD=${PYTHON_LIB}/lib-dynload
PYTHON_EXE=Frameworks/Python.framework/Versions/Current/bin/python3.11
RESOURCES=Frameworks/Python.framework/Versions/3.11/Resources
DEV_ID := $(shell cat DEV_ID.txt)
CS_OPTS=-v -s ${DEV_ID} --timestamp --options runtime --entitlements entitlement.plist --force
PY_CS_OPTS=-v -s ${DEV_ID} --timestamp --options runtime --force
FOR_PY2APP=no
FOR_RUNNER=no

all: Setup Zlib Readline OpenSSL TclTk Python Sign Tarball

embedded: Setup Zlib Readline OpenSSL TclTk Python Sign Embed

.PHONY: Setup Zlib Readline OpenSSL TclTk Python Sign Tarball Embed

Setup:
	mkdir -p Frameworks

Zlib:
	rm -rf Zlib/dist
	bash Zlib/build_zlib.sh
	find Zlib/dist/ZLib.framework -name '*.a' -delete
	rm -rf Frameworks/Zlib.framework
	mv Zlib/dist/Zlib.framework Frameworks
	${MACHER} set_id @rpath/libz.dylib Frameworks/${ZLIB}

Readline:
	rm -rf Readline/dist
	bash Readline/build_readline.sh
	find Readline/dist/Readline.framework -name '*.a' -delete
	rm -rf Frameworks/Readline.framework
	mv Readline/dist/Readline.framework Frameworks
	${MACHER} set_id @rpath/libreadline.dylib Frameworks/${READLINE}

OpenSSL:
	rm -rf OpenSSL/dist
	bash OpenSSL/build_openssl.sh
	find OpenSSL/dist/OpenSSL.framework -name '*.a' -delete
	rm -rf Frameworks/OpenSSL.framework
	mv OpenSSL/dist/OpenSSL.framework Frameworks
	${MACHER} set_id @rpath/libssl.dylib Frameworks/${SSL}
	${MACHER} edit_libpath @loader_path/libcrypto.dylib Frameworks/${SSL}
	${MACHER} set_id @rpath/libcrypto.dylib Frameworks/${CRYPTO}

TclTk:
	rm -rf TclTk/dist
	bash TclTk/build_tcltk.sh
	find TclTk/dist/Frameworks/Tcl.framework -name '*.a' -delete
	find TclTk/dist/Frameworks/Tk.framework -name '*.a' -delete
	rm -rf ${TCL_FRAMEWORK}
	rm -rf ${TK_FRAMEWORK}
	mv TclTk/dist/Frameworks/Tcl.framework Frameworks
	mv TclTk/dist/Frameworks/Tk.framework Frameworks
	chmod +w ${TCL_LIB} ${TK_LIB}
	${MACHER} set_id @rpath/Tcl ${TCL_LIB}
	${MACHER} set_id @rpath/Tk ${TK_LIB}
	rm -rf ${WISH}
	rm ${TCL_FRAMEWORK}/{PrivateHeaders,Tcl,tclConfig.sh}
	mv ${TCL_VERSION_DIR}/{tclConfig.sh,tclooConfig.sh} ${TCL_VERSION_DIR}/Resources
	rm ${TK_FRAMEWORK}/{PrivateHeaders,Tk,tkConfig.sh}
	mv ${TK_VERSION_DIR}/tkConfig.sh ${TK_VERSION_DIR}/Resources

Python:
	rm -rf Python-3.11/dist
	bash Python-3.11/build_python.sh
	find Python-3.11/dist/Python.framework -name '*.a' -delete
ifneq ($(FOR_PY2APP),no)
	set -e ; \
	cd Python-3.11 ; \
	mv dist/Python.framework/Versions/Current/lib/python3.11/lib-dynload . ; \
	rm -rf dist/Python.framework/Versions/Current/lib/python3.11/* ; \
	mv lib-dynload dist/Python.framework/Versions/Current/lib/python3.11
endif
	rm -rf Frameworks/Python.framework
	mv Python-3.11/dist/Python.framework Frameworks
	set -e ; \
	pushd ${LIB_DYNLOAD} ; \
	mv _ssl.cpython-311-darwin_failed.so _ssl.cpython-311-darwin.so ; \
	mv _hashlib.cpython-311-darwin_failed.so _hashlib.cpython-311-darwin.so ; \
	mv readline.cpython-311-darwin_failed.so readline.cpython-311-darwin.so ; \
	mv _tkinter.cpython-311-darwin_failed.so _tkinter.cpython-311-darwin.so ; \
	${MACHER} add_rpath ${ZLIB_RPATH} zlib.cpython-311-darwin.so ; \
	${MACHER} add_rpath ${ZLIB_RPATH} binascii.cpython-311-darwin.so ; \
	${MACHER} add_rpath ${OPENSSL_RPATH} _ssl.cpython-311-darwin.so ; \
	${MACHER} add_rpath ${OPENSSL_RPATH} _hashlib.cpython-311-darwin.so ; \
	${MACHER} add_rpath ${READLINE_RPATH} readline.cpython-311-darwin.so ; \
	${MACHER} add_rpath ${TCL_RPATH} _tkinter.cpython-311-darwin.so ; \
	${MACHER} add_rpath ${TK_RPATH} _tkinter.cpython-311-darwin.so ; \
	popd
# Things that py2app wants to install, for no apparent reason
ifneq ($(FOR_RUNNER),no)
	cp -R /Library/${RESOURCES}/Python.app ${RESOURCES}
        cp -R /Library/${PYTHON_LIB}/config-3.11-darwin ${PYTHON_LIB}
endif


Sign:
	rm -rf `find Frameworks -name test`
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
ifneq ($(FOR_RUNNER),no)
	codesign ${PY_CS_OPTS} ${RESOURCES}/Python.app/Contents/MacOS/Python
	codesign ${PY_CS_OPTS} ${RESOURCES}/Python.app
endif
	codesign ${PY_CS_OPTS} `find ${LIB_DYNLOAD} -type f -perm +o+x`
	codesign ${PY_CS_OPTS} ${PYTHON_EXE}
	codesign ${PY_CS_OPTS} Frameworks/Python.framework

Tarball:
	tar cfz Frameworks.tgz Frameworks

Embed:
	mkdir ${EMB_FRAMEWORK_DIR}
	mv Frameworks/{Tcl,Tk,OpenSSL,Readline,Zlib}.framework ${EMB_FRAMEWORK_DIR}
	set -e ; \
	cd ${LIB_DYNLOAD} ; \
	macher clear_rpaths _tkinter.cpython-311-darwin.so ; \
	macher add_rpath ${TCL_EMB_RPATH} _tkinter.cpython-311-darwin.so ; \
	macher add_rpath ${TK_EMB_RPATH} _tkinter.cpython-311-darwin.so ; \
	macher clear_rpaths _ssl.cpython-311-darwin.so ; \
	macher add_rpath ${OPENSSL_EMB_RPATH} _ssl.cpython-311-darwin.so ; \
	macher clear_rpaths readline.cpython-311-darwin.so ; \
	macher add_rpath ${READLINE_EMB_RPATH} readline.cpython-311-darwin.so ; \
	macher clear_rpaths zlib.cpython-311-darwin.so ; \
	macher add_rpath ${ZLIB_EMB_RPATH} zlib.cpython-311-darwin.so
	codesign ${PY_CS_OPTS} ${LIB_DYNLOAD}/_tkinter.cpython-311-darwin.so
	codesign ${PY_CS_OPTS} ${LIB_DYNLOAD}/_ssl.cpython-311-darwin.so
	codesign ${PY_CS_OPTS} ${LIB_DYNLOAD}/readline.cpython-311-darwin.so
	codesign ${PY_CS_OPTS} ${LIB_DYNLOAD}/zlib.cpython-311-darwin.so
	codesign ${PY_CS_OPTS} Frameworks/Python.framework
