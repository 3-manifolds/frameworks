MACHER=/usr/local/bin/macher
SSL=OpenSSL.framework/Versions/Current/lib/libssl.dylib
CRYPTO=OpenSSL.framework/Versions/Current/lib/libcrypto.dylib
TCL_FRAMEWORK=Frameworks/Tcl.framework
TCL_VERSION_DIR=${TCL_FRAMEWORK}/Versions/Current
TCL_LIB=${TCL_VERSION_DIR}/Tcl
TK_FRAMEWORK=Frameworks/Tk.framework
TK_VERSION_DIR=${TK_FRAMEWORK}/Versions/Current
TK_LIB=${TK_VERSION_DIR}/Tk
WISH=${TK_VERSION_DIR}/Resources/Wish.app
PYTHON_VERSION=3.14
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
	python3 -m notabot.sign Frameworks/OpenSSL.framework

TclTk:
	rm -rf Frameworks/Tcl.framework
	rm -rf Frameworks/Tk.framework
	rm -rf TclTk/{Frameworks,dist}
	make -C TclTk
	mv TclTk/Frameworks/* Frameworks
	python3 -m notabot.sign Frameworks/Tcl.framework
	python3 -m notabot.sign Frameworks/Tk.framework

# The pip module is left in place to make installing modules for
# a standalone app convenient.  It could be removed later for a
# savings of 6MB.
Python:
	bash Python-${PYTHON_VERSION}/build_python.sh
	find Python-${PYTHON_VERSION}/dist/Python.framework -name '*.a' -delete
	rm -rf Frameworks/Python.framework
	mv Python-${PYTHON_VERSION}/dist/Python.framework Frameworks
	python3 strip_framework.py Frameworks/Python.framework
	rm ${PYTHON_LIB}/lib-dynload/*test*
	rm -rf ${PYTHON_LIB}/{test,unittest,idle}
	rm -rf ${PYTHON_LIB}/turtle*
	rm -rf ${PYTHON_LIB}/idlelib
	rm -rf ${PYTHON_LIB}/pydoc*
	rm -rf ${PYTHON_BIN}/idle*
	rm -rf ${PYTHON_BIN}/pydoc*
	python3 -m notabot.sign Frameworks/Python.framework

Tarball:
	tar cfz Frameworks-${PYTHON_VERSION}.tgz Frameworks
	shasum Frameworks-${PYTHON_VERSION}.tgz > Frameworks-${PYTHON_VERSION}.sha1 
