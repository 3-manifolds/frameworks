MACHER=/usr/local/bin/macher
TCL_RPATH=@loader_path/../../../../../../Tcl.framework/Versions/Current
TK_RPATH=@loader_path/../../../../../../Tk.framework/Versions/Current
TCL_FRAMEWORK=Frameworks/Tcl.framework
TCL_VERSION_DIR=${TCL_FRAMEWORK}/Versions/Current
TCL_LIB=${TCL_VERSION_DIR}/Tcl
TK_FRAMEWORK=Frameworks/Tk.framework
TK_VERSION_DIR=${TK_FRAMEWORK}/Versions/Current
TK_LIB=${TK_VERSION_DIR}/Tk
WISH="${TK_VERSION_DIR}/Resources/Wish.app"

all: Setup TclTk

.PHONY: Setup TclTk

Setup:
	mkdir -p Frameworks

TclTk:
	rm -rf ${TCL_FRAMEWORK}
	rm -rf ${TK_FRAMEWORK}
	rm -rf dist
	bash build_tcltk.sh
	mv dist/Frameworks/Tcl.framework Frameworks
	mv dist/Frameworks/Tk.framework Frameworks
	rm -r ${WISH}
	rm ${TCL_FRAMEWORK}/{PrivateHeaders,tclConfig.sh,libtclstub.a}
	chmod +w ${TCL_VERSION_DIR}/libtclstub.a
	rm ${TCL_VERSION_DIR}/libtclstub.a
	mv ${TCL_VERSION_DIR}/{tclConfig.sh,tclooConfig.sh} ${TCL_VERSION_DIR}/Resources
	rm ${TK_FRAMEWORK}/{PrivateHeaders,tkConfig.sh,libtkstub.a}
	chmod +w ${TK_VERSION_DIR}/libtkstub.a
	rm ${TK_VERSION_DIR}/libtkstub.a
	mv ${TK_VERSION_DIR}/tkConfig.sh ${TK_VERSION_DIR}/Resources
