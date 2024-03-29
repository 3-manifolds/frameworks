#!/bin/bash
set -e

mkdir -p Tcl Tk

if [ ! -f Tcl.fossil ]; then
    fossil clone http://core.tcl.tk/tcl Tcl.fossil
    fossil open --workdir Tcl Tcl.fossil main
else
    fossil pull -R Tcl.fossil
    cd Tcl
    fossil update
    cd ..
fi

if [ ! -f Tk.fossil ]; then
    fossil clone http://core.tcl.tk/tk Tk.fossil
    fossil open --workdir Tk Tk.fossil main
else
    fossil pull -R Tk.fossil
    cd Tk
    fossil update
    cd ..
fi
