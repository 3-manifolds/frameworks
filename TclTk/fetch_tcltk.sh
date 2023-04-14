#!/bin/bash
set -e

TCL_VERSION=8.6.13
TK_VERSION=8.6.13

curl -OL https://prdownloads.sourceforge.net/tcl/tcl$TCL_VERSION-src.tar.gz
curl -OL https://prdownloads.sourceforge.net/tcl/tk$TK_VERSION-src.tar.gz

tar xf tcl$TCL_VERSION-src.tar.gz
tar xf tk$TK_VERSION-src.tar.gz

rm -rf Tcl Tk
mv tcl$TCL_VERSION Tcl
mv tk$TK_VERSION Tk
