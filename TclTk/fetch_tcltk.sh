#!/bin/bash
set -e

TCL_VERSION=8.6.11
TK_VERSION=8.6.11.1

mkdir Tcl Tk

wget -O tcl-src.tar.gz https://prdownloads.sourceforge.net/tcl/tcl$TCL_VERSION-src.tar.gz
wget -O tk-src.tar.gz https://prdownloads.sourceforge.net/tcl/tk$TK_VERSION-src.tar.gz

tar xf tcl-src.tar.gz --directory=Tcl --strip-components=1
tar xf tk-src.tar.gz --directory=Tk --strip-components=1
