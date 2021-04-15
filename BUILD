In order to build the frameworks you need to create directories TclTk/Tcl and TclTk/Tk
which contain the source code for the version of Tcl and Tk that you wish to use for
the frameworks.  These may be populated with the fossil open command.

In order to sign the frameworks you need to create a file DEV_ID.txt in the top level
directory.  The file should have one line which contains the codesign identity that
you will be using to sign the frameworks.

Run make in the top level directory to create all of the frameworks and move them
into the Frameworks directory.  That directory may be moved into an application
bundle as Some.app/Contents/Frameworks.