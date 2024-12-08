#!/bin/bash
set -e

TCL_VERSION=9.0.0
TK_VERSION=9.0.0

mkdir Tcl Tk

curl -L -O https://prdownloads.sourceforge.net/tcl/tcl$TCL_VERSION-src.tar.gz
curl -L -O https://prdownloads.sourceforge.net/tcl/tk$TK_VERSION-src.tar.gz

tar xf tcl$TCL_VERSION-src.tar.gz --directory=Tcl --strip-components=1
tar xf tk$TK_VERSION-src.tar.gz --directory=Tk --strip-components=1
