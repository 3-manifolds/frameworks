#!/bin/bash
set -e

TK_BRANCH="main"
TCL_BRANCH="core-8-branch"

if [ ! -d Tcl ]; then
    git clone https://github.com/tcltk/tcl Tcl
    cd Tcl
    git checkout $TCL_BRANCH
else
    cd Tcl
    git pull
fi
cd ..

if [ ! -d Tk ]; then
    git clone https://github.com/tcltk/tk Tk
    cd Tk
    git checkout $TK_BRANCH
else
    cd Tk
    git pull
fi
