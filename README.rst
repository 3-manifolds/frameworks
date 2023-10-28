Frameworks
==========

This project is a kit for building a set of relocatable frameworks
which includes a Python framework as well as frameworks needed for
basic python extensions based on external libraries.  These include
Readline.framework, Tcl.framework, Tk.framework, OpenSSL.framework,
and ZLib.framework.  There is a branch of this repo for each supported
Python version.  Pre-compiled frameworks are available as releases.

These frameworks are not signed.  If the frameworks are embedded
into an Application bundle, then each framework should be signed
after signing all of the .dylib or .so files which it contains.
Then the app itself can be signed.

Since the frameworks are not signed, the python3 executable in the
Python framework can be used when debugging Python extension modules
with lldb, which is not allowed to attach to a signed executable.
Since they are completely relocatable, they can be installed in
~/Library to make an unsigned version of python3 available whenever
needed.

Tcl/Tk
======

In order to build the frameworks you need to create directories
TclTk/Tcl and TclTk/Tk which contain the source code for the version
of Tcl and Tk that you wish to use for the frameworks.  Three ways for
this are provided via the fetch_tcltk.sh, fossil_tcltk.sh, and
git_tcltk.sh scripts in that directory.

Macher
======

In addition to the XCode command line tools, you will need::

  https://github.com/culler/macher

Building
========

Run make in the top level directory to create all of the frameworks
and move them into the Frameworks directory.  That directory may be
moved or copied into an application bundle as Some.app/Contents/Frameworks.
