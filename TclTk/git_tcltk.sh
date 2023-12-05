#!/bin/bash
set -e

if [ ! -d Tcl ]; then
    git clone https://github.com/tcltk/tcl Tcl
    cd Tcl
    git checkout main
else
    cd Tcl
    git pull
fi
cd ..

if [ ! -d Tk ]; then
    git clone https://github.com/tcltk/tk Tk
    cd Tk
    git checkout main
else
    cd Tk
    git pull
fi
