#!/bin/bash
set -e

BRANCH="core-8-6-branch"

if [ ! -d Tcl ]; then
    git clone https://github.com/tcltk/tcl Tcl
    cd Tcl
    git checkout $BRANCH
else
    cd Tcl
    git pull
fi
cd ..

if [ ! -d Tk ]; then
    git clone https://github.com/tcltk/tk Tk
    cd Tk
    git checkout $BRANCH
else
    cd Tk
    git pull
fi
