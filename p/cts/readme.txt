CRT - C/Rider RunTime library

The Rider/C runtime library LIB:CRT.OBJ replaced the DECUS-C runtime
for RUST applications. The primary goal for CRT was to minimize the
runtime library footprint for applications. 

A second goal was to have parallel runtime libraries for RUST PDP-11
and Windows code where possible. CRT supports native C functions for
I/O and *printf/*scanf, but not much more. 

CTS: - RUST/RT-11 sources
RLS: - RUST and Windows shared sources

UPDATE.COM - compiles and assembles the library LIB:CRT.OBJ, calling:

UPDHDR.COM - translates the CTS: Rider .D header files to RIP: .H files
UPDCTS.COM - updates CTS: and some RLS: modules
UPDRLS.COM - updates RLS: modules
UPDLIB.COM - updates the library, CRT.OBJ
UPDCOP.COM - copies result files to live directories

CTS: includes modules from the following DECUS C and QSORT and DEC's
hyphenation routines.



