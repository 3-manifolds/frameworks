Frameworks
==========

This project is a kit for building a set of relocatable signed
frameworks suitable for inserting into an application bundle which
uses Python for the main program.  The frameworks include
Python.framework, as well as frameworks needed for basic Python
extensions based on external libraries.  These include
Readline.framework, Tcl.framework, Tk.framework, OpenSSL.framework,
and ZLib.framework.  The current version of Python used here is 3.9.


Tcl/Tk
======

In order to build the frameworks you need to create directories
TclTk/Tcl and TclTk/Tk which contain the source code for the version
of Tcl and Tk that you wish to use for the frameworks.  Two ways for
this are provided via the fetch_tcltk.sh and fossil_tcltk.sh scripts
in that directory.


Macher
======

In addition to the XCode command line tools, you will need::

  https://github.com/culler/macher


Signing
=======

In order to sign the frameworks you need to create a file DEV_ID.txt
in the top level directory.  The file should have one line which
contains the codesign identity/certificate that you will be using to
sign the frameworks.  A "self-signed" cert can be created using
KeyChain Access.


Building
========

Run make in the top level directory to create all of the frameworks
and move them into the Frameworks directory.  That directory may be
moved into an application bundle as Some.app/Contents/Frameworks.
