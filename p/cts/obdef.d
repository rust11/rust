header	obdef - PDP-11 object module formats

;	See documentation at the end of this module

data	obTgsd - global symbol directory entry

  type	obTgsd
  is	Anam : [2] WORD		; 2-word rad50 symbol name
	Vflg : BYTE		; symbol flags
	Vcod : BYTE		; symbol type code
	Vval : WORD		; symbol value
  end

;			    GSD
;			    |Psect
	obHGH_ := BIT(0)  ;  p- ; LOW HGH  High-speed memory	unused
	obWEA_ := BIT(0)  ; G	; STR WEA  Strong/Weak
	obLIB_ := BIT(1)  ;  p-	;     LIB  Library definition	unused
;sic]	obLBL_ := BIT(1)  ; g	; LBL EQU  Label/Equated	unused
	obOVR_ := BIT(2)  ;  P	; CON OVR  Allocation
;sic]	obNU__ := BIT(3)  ;  p-	;
;sic]	obSEC_ := BIT(3)  ;   I	;	   IsSectionEntry
	obDEF_ := BIT(3)  ; G	; REF DEF 
	obRON_ := BIT(4)  ;  p	; RW  RO   Access		unused
;sic]	obSWI_ := BIT(5) ;    I ;	   /I definition
	obREL_ := BIT(5)  ; GP	; ABS REL
	obGBL_ := BIT(6)  ; GP	; LCL GBL
	obDAT_ := BIT(7)  ;  P	; INS DAT  INS=word concatenation
				;	   INS=globals are overlay thunks

	obAS0  := 0127401 		; Rad50 ". A"
	obAS1  := 07624			; Rad50 "BS."

;    Blank CSECT:     .PSECT      ,RW,I,LCL,REL,CON
;    Named CSECT:     .PSECT name, RW,I,GBL,REL,OVR
;    ASECT:           .PSECT. ABS.,RW,I,GBL,ABS,OVR

	obBCS_ := lkREL_		; Blank Csect
	obNCS_ := lkGBL_|lkREL_|lkOVR_	; Named Csect
	obAST_ := lkGBL_|lkOVR_		; Asect

end header
end file

Preamble
========
Under RT-11 any number of bytes containing zero may precede a Formatted Binary Record.


       [  0   ]

Formatted Binary Record
========================
A formatted binary record begins with a word with the value 1.
This is followed by a word containing the length of the record.
The length includes the first two words (signature and length).


 [  0  |   1  ]
 [  length    ]
 [    ...     ]  length-4 bytes
       [check ]  RT-11 only


The data area is length-4 bytes long.


On RT-11 the record concludes with a checksum (which is ignored).
On RSX records with an odd number of bytes are padded with a 
byte containing zero.


Formatted Binary Object Record
==============================

 [  0  |   1  ]
 [  length    ]
 [ record type]
 [    ...     ] 
       [check ]  

A formatted binary object record adds a record type field to each record.

  1   GSD      Holds Global Symbol Directory information
  2   ENDGSD   Signals the end of GSD blocks in the module
  3   TXT      Holds the actual binary text of the module
  4   RLD      Holds Relocation Directory information
  5   ISD      Holds Internal Symbol Directory information
               (Not supported in RT-11)
  6   ENDMOD   Signals the end of the module
  7   LIBHDR   Holds status of a library file
  8   LIBEND   Signals end of a library file



On pass 1, get information from the global symbol blocks about
how to assign addresses and how to allocate memory.

Each data block starts with an identification code in the
first word that describes the type of information contained
in the rest of the data block:
CODE  TYPE     FUNCTION OF BLOCK


An object module must begin with a Global Symbol Directory (GSD)
block and end with an End of Module (ENDMOD) block.  Additional
GSD blocks can occur anywhere in the file, but must appear before
an End of Global Symbol Directory (ENDGSD) block.  An ENDGSD
block must appear before the ENDMOD block, and at least one
Relocation Directory (RLD) block must appear before the first
Text Information (TXT) block.  Additional RLD and TXT blocks
can appear anywhere in the file.  The Internal Symbol Directory
(ISD) block can appear anywhere in the file between the initial
GSD and ENDMOD blocks.

All program sections (PSECTs, VSECTs, and CSECTs) must be declared
by defining them in GSD blocks.  The word size of each program
section definition contains the size in bytes to be reserved
for the section.  If a program section is declared more than
once in a single object module, the linker uses the largest
declared size for that section.  All global symbols that are
defined in a given program section must appear in the GSD items
immediately following the definition item of that program section.

A special program section, called the absolute section (. ABS.),
is allocated by the linker beginning at location 0 in memory.
Immediately after the GSD item that defines the absolute section,
all global symbols that contain absolute (non-relocatable) values
must be declared.  If the size word is zero, no memory space
is allocated for the absolute section.

Global symbols that are referenced but not defined in the current
object module must also appear in GSD items.  These global
references may appear in any GSD item except the very first,
which contains the module name.  In MACRO, referenced globals
are seen in a GSD block under the . ABS. p-sect.

GSD - Get global symbol directory information for pass 1

Global Symbol Directory blocks contain all the information the
linker needs to assign addresses to global symbols and to
allocate the memory a job requires.  There are eight types of
entries that GSD blocks can contain:

	Entry type	Description
	----------      -----------
	     0          Module Name
	     1          Control Section Name (CSECT)
	     2          Internal Symbol Name
	     3          Transfer Address
	     4          Global Symbol Name
	     5          Program Section Name
	     6          Program Version Identification (IDENT)
	     7          Mapped Array Declaration (VSECT)

Each type of entry is represented by four words in the GSD data
block.  The first two words contain six Radix-50 characters.  The
third word contains a flag byte and the entry type identification.
The fourth word contains additional information about the entry.

	==================================
	|       0       |        1       |
	==================================
	|           RADIX - 50           |
	-----                        -----
	|              NAME              |
	----------------------------------
	|   ENTRY TYPE  |      FLAGS     |
	----------------------------------
	|             VALUE              |
	==================================
	|           RADIX - 50           |
	-----                        -----
	|              NAME              |
	----------------------------------
	|   ENTRY TYPE  |      FLAGS     |
	----------------------------------
	|             VALUE              |
	==================================
	                :
	                :
	==================================
	|           RADIX - 50           |
	-----                        -----
	|              NAME              |
	----------------------------------
	|   ENTRY TYPE  |      FLAGS     |
	----------------------------------
	|             VALUE              |
	==================================

TYPE 0:  Module name
Declares the name of the object module.  The name need not be
unique with respect to other object modules  because modules
are identified by file, not module name.  However, only one
module name declaration can occur in a single object module.
	-----------------------------------
	|         RADIX-50 MODULE         |
	----                           ----
	|              NAME               |
	-----------------------------------
	|        0       |        0       |
	-----------------------------------
	|                0                |
	-----------------------------------
	GO TO 1000

TYPE 1:  Control section name (CSECT)

Declares the name of a control section.  The linker converts
control sections - which include ASECTs, blank CSECTS, and
named CSECTS - to PSECTs.  For convenience, control sections
are converted as follows:
     Blank CSECT:     .PSECT     ,RW,I,LCL,REL,CON
     Named CSECT:     .PSECT     name,RW,I,GBL,REL,OVR
     ASECT:           .PSECT     . ABS.,RW,I,GBL,ABS,OVR

	----------------------------------
	|        RADIX-50 CONTROL        |
	-----                        -----
	|             NAME               |
	----------------------------------
	|       1       |     IGNORED    |
	----------------------------------
	|         MAXIMUM LENGTH         |
	----------------------------------


TYPE 2:  Internal symbol name

Declares the name of an internal symbol with respect to the
module.  Because the linker does not support internal symbol
tables, the detailed format of this entry is not defined.
If the linker encounters an internal symbol entry while
reading the GSD, it ignores it.

	----------------------------------
	|             SYMBOL             |
	-----                        -----
	|              NAME              |
	----------------------------------
	|       2       |        0       |
	----------------------------------
	|           UNDEFINED            |
	----------------------------------


TYPE 3:  Transfer address

Declares the transfer address of a module relative to
a p-sect.  The first two words of the entry define the name
of the p-sect.  The fourth word indicates the relative offset
from the beginning of that p-sect.  If no transfer address
is declared in a module, the transfer address entry must
not be included in the GSD, or else a transfer address 000001
relative to the default absolute p-sect (. ABS.) must be
specified.

	----------------------------------
	|             SYMBOL             |
	-----                        -----
	|              NAME              |
	----------------------------------
	|       3       |        0       |
	----------------------------------
	|             OFFSET             |
	----------------------------------
		               NOTE
When the p-sect is absolute, OFFSET is the actual transfer
address if it is not equal to 000001.

TYPE 4:  Global symbol name
C
C	Declares either a global reference or a definition.  All
C	definition entries must appear after the declaration of the
C	p-sect under which they are defined, and before the declaration
C	of another p-sect.  Global references can appear anywhere within
C	the GSD.
C		+--------------------------------+
C		|             SYMBOL             |
C		+---                          ---+
C		|              NAME              |
C		+--------------------------------+
C		|       4       |     FLAGS      |
C		+--------------------------------+
C		|             VALUE              |
C		+--------------------------------+
C
C	The first two words of the entry define the name of the global
C	symbol.  The flag byte declares the attributes of the symbol.
C	The fourth word contains the value of the symbol relative to
C	the p-sect under which it is defined.
C
C	The flag byte of the symbol declaration entry has the bit
C	assignments as shown in the following table.  Bits 0, 1, 2,
C	4, 6, and 7 are not used.
C
C		Bit             Meaning
C	................................................................
C		 3	Definition
C			0 = Global symbol reference
C			1 = Global symbol definition
C		 5	Relocation
C			0 = Absolute symbol value
C			1 = Relative symbol value
C	................................................................

C
C---->>	TYPE 5:  Program section name (PSECT) <<------------------------
C
C	Declares the name of a p-sect and its maximum length in the
C	module.  It also uses the flag byte to declare the attributes
C	of the p-sect.  The default attributes of the p-sect are as
C	follows:
C		.PSECT	,RW,I,LCL,REL,CON
C
C	NOTE:  The length of all absolute sections is zero
C
C	GSD records must be constructed in such a way that once a p-sect
C	name has been declared, all global symbol definitions pertaining
C	to it must appear  before another p-sect name is declared.
C	Global symbols are declared by means of symbol declaration
C	entries.  Thus the normal format is a series of p-sect names,
C	each followed by optional symbol declarations.
C
C		+--------------------------------+
C		|             P-SECT             |
C		+---                          ---+
C		|              NAME              |
C		+--------------------------------+
C		|       5       |     FLAGS      |
C		+--------------------------------+
C		|         MAXIMUM LENGTH         |
C		+--------------------------------+
C 
C	The following table shows the bit assignments of the flag byte.
C	Bits 0, 1, and 3 are not used.
C
C		Bit	Meaning
C	...............................................................
C		 2	Allocation
C			0 = P-sect references are to be concatenated with
C			    other references to the same p-sect to form the
C			    total amount of memory allocated to the section.
C			1 = P-sect references are to be overlaid.  The total
C			    amount of memory allocated to the p-sect is the
C			    size of the largest request made by individual
C			    references to the same p-sect.
C		 4	Access (not supported by RT-11 monitors)
C			0 = P-sect has read/write access.
C			1 = P-sect has read-only access.
C		 5	Relocation
C			0 = P-sect is absolute and requires no relocation.
C			1 = P-sect is relocatable and references to the
C			    control section must have a relocation bias
C			    added before they become absolute.
C		 6	Scope
C			0 = The scope of the p-sect is local.  References
C			    to the same p-sect will be collected only within
C			    the overlay segment in which the p-sect is
C			    defined.
C			1 = The scope of the p-sect is global.  References
C			    to the p-sect are collected across overlay
C			    segment boundaries.
C		 7	Type
C			0 = The p-sect contains instruction (I) references.
C			    Concatenation of this p-sect will be by word
C			    boundary.  Globals will be given overlay
C			    control blocks.
C			1 = The p-sect contains data (D) references.  Con-
C			    catentation of this p-sect will be by byte
C			    boundary.  Globals will not go through the
C			    overlay handler.
C	....................................................................
C

C
C---->>	TYPE 6:  Program version identification (IDENT) <<-------------
C
C	Declares the version of the module.  The linker saves the
C	version identification, or IDENT, of the first module that
C	declares a nonblank version.  It then includes this ident-
C	ification on the memory allocation map.
C
C	The first two words of the entry contain the version ident-
C	ification.  The linker does not use either the flag byte or
C	the fourth word because they contain no meaningful information.
C
C		+--------------------------------+
C		|             SYMBOL             |
C		+---                          ---+
C		|              NAME              |
C		+--------------------------------+
C		|       6       |        0       |
C		+--------------------------------+
C		|               0                |
C		+--------------------------------+
C

C
C---->>	TYPE 7:  Mapped array declaration (VSECT) <<--------------------
C
C	Allocates space within the mapped array area of the job's
C	memory.  The linker adds the length (in units of 32-word
C	blocks) to the job's mapped area allocation.  It rounds
C	up the total amount of memory allocated to each mapped
C	array to the nearest 256-word boundary.  The contents of
C	the flag byte are reserved and assumed to be zero.
C	(Only the FORTRAN IV produces this VSECT.)  For convenience,
C	VSECT statements are translated into PSECTs as follows:
C		.PSECT     . VIR.,RW,D,GBL,REL,CON
C	The size is equal to the number of 32-word blocks required.
C	There must never be globals under this section, which starts
C	at a base of 0.
C				NOTE
C	One additional address window is allocated whenever a mapped
C	array is declared.
C
C		----------------------------------
C		|         RADIX-50 MAPPED        |
C		-----                        -----
C		|           ARRAY NAME           |
C		----------------------------------
C		|       7       |    RESERVED    |
C		----------------------------------
C		|             LENGTH             |
C		----------------------------------




