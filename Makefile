MACHER=/usr/local/bin/macher
ZLIB=Zlib.framework/Versions/Current/lib/libz.dylib
READLINE=Readline.framework/Versions/Current/lib/libreadline.dylib
SSL=OpenSSL.framework/Versions/Current/lib/libssl.dylib
CRYPTO=OpenSSL.framework/Versions/Current/lib/libcrypto.dylib
TCL_FRAMEWORK=Frameworks/Tcl.framework
TCL_VERSION_DIR=${TCL_FRAMEWORK}/Versions/Current
TCL_LIB=${TCL_VERSION_DIR}/Tcl
TK_FRAMEWORK=Frameworks/Tk.framework
TK_VERSION_DIR=${TK_FRAMEWORK}/Versions/Current
TK_LIB=${TK_VERSION_DIR}/Tk
WISH=${TK_VERSION_DIR}/Resources/Wish.app
PYTHON_VERSION=3.13
PYTHON_LIB=Frameworks/Python.framework/Versions/${PYTHON_VERSION}/lib/python${PYTHON_VERSION}
LIB_DYNLOAD=${PYTHON_LIB}/lib-dynload
PYTHON_EXE=Frameworks/Python.framework/Versions/Current/bin/python${PYTHON_VERSION}
RESOURCES=Frameworks/Python.framework/Versions/${PYTHON_VERSION}/Resources
CONFIG=${PYTHON_LIB}/config-${PYTHON_VERSION}-darwin

all: Setup OpenSSL TclTk Python

.PHONY: Setup OpenSSL TclTk Python Tarball 

Setup: notabot.cfg
	mkdir -p Frameworks

OpenSSL:
	rm -rf OpenSSL/dist
	bash OpenSSL/build_openssl.sh
	find OpenSSL/dist/OpenSSL.framework -name '*.a' -delete
	rm -rf Frameworks/OpenSSL.framework
	mv OpenSSL/dist/OpenSSL.framework Frameworks
	${MACHER} set_id @rpath/libssl.dylib Frameworks/${SSL}
	${MACHER} edit_libpath @loader_path/libcrypto.dylib Frameworks/${SSL}
	${MACHER} set_id @rpath/libcrypto.dylib Frameworks/${CRYPTO}
<<<<<<< Updated upstream
	python3 -m notabot.sign Frameworks/OpenSSL.framework

TclTk:
	rm -rf Frameworks/Tcl.framework
	rm -rf Frameworks/Tk.framework
	rm -rf TclTk/{Frameworks,dist}
	make -C TclTk
	mv TclTk/Frameworks/* Frameworks
	python3 -m notabot.sign Frameworks/Tcl.framework
=======
	python3 -m notabot.sign Frameworks/OpenSSL.framework/Versions/Current/lib/libcrypto.dylib
	python3 -m notabot.sign Frameworks/OpenSSL.framework/Versions/Current/lib/libssl.dylib
	python3 -m notabot.sign Frameworks/OpenSSL.framework/

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
	python3 -m notabot.sign Frameworks/Tcl.framework/Versions/Current/Tcl
	python3 -m notabot.sign Frameworks/Tcl.framework
	python3 -m notabot.sign Frameworks/Tk.framework/Versions/Current/Tk
>>>>>>> Stashed changes
	python3 -m notabot.sign Frameworks/Tk.framework

Python:
	bash Python-${PYTHON_VERSION}/build_python.sh
	find Python-${PYTHON_VERSION}/dist/Python.framework -name '*.a' -delete
	rm -rf Frameworks/Python.framework
	mv Python-${PYTHON_VERSION}/dist/Python.framework Frameworks
<<<<<<< Updated upstream
=======
	python3 -m notabot.sign ${LIB_DYNLOAD}/_ssl.cpython-313-darwin.so
	python3 -m notabot.sign ${LIB_DYNLOAD}/_tkinter.cpython-313-darwin.so
>>>>>>> Stashed changes
	python3 -m notabot.sign Frameworks/Python.framework

Tarball:
	tar cfz Frameworks-${PYTHON_VERSION}.tgz Frameworks
	shasum Frameworks-${PYTHON_VERSION}.tgz > Frameworks-${PYTHON_VERSION}.sha1 
