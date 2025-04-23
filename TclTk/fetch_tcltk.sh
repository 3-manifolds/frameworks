#!/bin/bash
set -e

TCL_VERSION=9.0.1
TK_VERSION=9.0.1

rm -rf Tcl Tk
mkdir Tcl Tk

TCL_ARCHIVE="tcl-core${TCL_VERSION}-src.tar.gz"
if ! [ -e ${TCL_ARCHIVE} ]; then
    curl -L -O https://prdownloads.sourceforge.net/tcl/${TCL_ARCHIVE}
    tar xf ${TCL_ARCHIVE} --directory=Tcl --strip-components=1
fi

TK_ARCHIVE="tk${TK_VERSION}-src.tar.gz"
if ! [ -e ${TK_ARCHIVE} ]; then
    curl -L -O https://prdownloads.sourceforge.net/tcl/${TK_ARCHIVE}
    tar xf ${TK_ARCHIVE} --directory=Tk --strip-components=1
fi
