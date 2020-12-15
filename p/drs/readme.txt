DRS:README.TXT

Directories:

DRS:		Driver sources
DRB:		Driver binaries

Source Filename Conventions:

xx .mac		RT-11 etc driver source name
xxV.MAC		RUST/SJ driver source
xxP.MAC		RUST/XM and perhaps SJ driver source
xxW.MAC		RUST/SJ Windows V11 driver source
xxZ.MAC		Dummy driver for testing

Binary Filename Conventions

xx .sys		RT-11 unmapped driver source
xxX.sys		RT-11 mapped driver source
xxV.sys		RUST unmapped driver
xxP.sys		RUST/XM mapped driver
xxW.sys		RUST/SJ Windows V11 driver

P Mapped	This convention comes from sharePlus.
V Unmapped	Just a letter I grabbed
W V11		The letter after V

Better codes would be: 

U Unmapped=U
M Mapped=M
V V11

Driver Construction Conventions

DRVMAC.MLB has code macros for many common driver operations.
Many of these code macros assume that the driver facility
strings are the string literals "xx$" and "x$x".

Adjuncts:

DRVMAC.MAC	Extensive set of driver macros
MMGT.MAC	Defines memory management conditional

Driver Renaming:

0.	Backup VRT
1.	Rename all files
2.	Rename build instructions
3.	Rename kit constructions
4.	Rename HELP files 
5.	Rename other documentation
6.	Rename KMON install/load etc
7.	Rename DCL install/load etc
7.1.	Rename DCL SET 
8.	Rename bootstrap install/load.
9.	Rename CTS library device routines
10.	Rename VUP
11.	Rename FORMAT
12.	Rename HANDLE.MAC
13.	Rename DRIVER.MAC

Strategy:

0.	Look for other instances where naming is used

1.	Do all the V drivers first. Stabilize.
2.	Do the two or three W drivers.
3.	Do all the P drivers. 
	DCL LOAD/INSTALL transitionally looks for P after U.
