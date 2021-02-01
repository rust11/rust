header	nedef - NE Windows/16 image definitions
include	rid:mzdef

  type	neTpro			; prologue
  is	Sdos : mzThdr		; dos MZ header
	Af00 : [28] BYTE	; unused
	Vwin : WORD		; offset to imTwin
	Vf01 : WORD		; unused
	Astb : [1] BYTE		; dos stub
  end

  type	neThdr			; NE header
  is	Vsig : WORD		; "NE" New Executable
	Vver : BYTE		; linker version
	Vrev : BYTE		; linker revision
	Oent : WORD		; neAent-neSinf 
	Lent : WORD		; #neAent
	Vf00 : LONG		; 
	Vflg : WORD		; flags -- see below
	Vaut : WORD		; Autodata segment if neAUT_
	Lhea : WORD		; Local heap size, if any
	Lstk : WORD		; stack size, except neLIB_ where SS==DS
	Vip  : LONG		; initial IP
	Vsp  : LONG		; initial SP
	Nseg : WORD		; number of neAseg entries
	Nmod : WORD		; number of neAmod entries
	Ldyn : WORD		; size of neAnon table
	Oseg : WORD		; neAseg-neSinf
	Ores : WORD		; neAres-neSinf
	Onam : WORD		; neAnam-neSinf
	Omod : WORD		; neAmod-neSinf
	Oimp : WORD		; neAimp-neSinf
	Odyn : WORD		; neAdyn-neSinf
	Vf01 : WORD		; 
	Nept : WORD		; number of moveable entry points
	Vshf : WORD		; shift count
	Nres : WORD		; number of resource segments
	Vsys : BYTE		; target operating system
	Vctl : BYTE		; control flags -- below
	Ofst : WORD		; offset, in 128 byte sectors, to fast load area
	Lfst : WORD		; size, in 128 byte sectors, of fast load area
	Af02 : [3] WORD		;
	Vwrv : BYTE		; windows revision
	Vwvr : BYTE		; windows version
  end

data	Vflg - flags

	neSIN_	:= BIT(0)	; SINGLEDATA
	neMUL_	:= BIT(1)	; MULTIPLEDATA
	neAUT_	:= (neSIN_|neMUL_) ; AUTODATA
	nePRT_	:= BIT(3)	; Protected mode program
	neOSX_	:= BIT(8)	; Not OS/2 code
	neOS2_	:= BIT(9)	; Is OS/2 code
	neSLF_	:= BIT(11)	; Initial segment self loads program
	neWAR_	:= BIT(13)	; Linker warnings
	neEMS_	:= BIT(14)	; Libraries loaded above EMS line
	neLIB_	:= BIT(15)	; Library module
				; CS:IP -> initialization routine

data	Vsys - operating system

	neUNK	:= 0		;
	neOS2	:= 1		; OS/2
	neWIN	:= 2		; Windows

data	Vctl - operating system flags

	nePRO_	:= BIT(1)	; protected mode app
	neFNT_	:= BIT(2)	; supports proportional fonts
	neFST_	:= BIT(3)	; file has fast load area
	
  type	neTnam
  is	Voff : WORD
	Vlen : WORD
	Vflg : WORD
	Vidt : WORD
	Vres : LONG
  end

  type	imTres
  is	Vidt : WORD
	Vcnt : WORD
	Vres : LONG
;;;	Ainf : [1] neTnam	; * Vcnt
  end
end header
end file
typedef struct tagOLDHEADER {
    EXEHEADER  msdosHeader;
    BYTE       breserved[28];
    WORD       winInfoOffset;
    WORD       wreserved;
    BYTE       msdosStub[1];
} OLDHEADER;

typedef struct tagEXEHEADER {
    WORD   exSignature;
    WORD   exExtraBytes;
    WORD   exPages;
    WORD   exRelocItems;
    WORD   exHeaderSize;
    WORD   exMinAlloc;
    WORD   exMaxAlloc;
    WORD   exInitSS;
    WORD   exInitSP;
    WORD   exCheckSum;
    WORD   exInitIP;
    WORD   exInitCS;
    WORD   exRelocTable;
    WORD   exOverlay;
    DWORD  reserved;   /* Not in official EXEHEADER struct */
} EXEHEADER;

typedef struct tagWININFO {
    WORD   signature;
    BYTE   linkerVersion;
    BYTE   linkerRevision;
    WORD   entryTabOffset;
    WORD   entryTabLen;
    DWORD  reserved1;
    WORD   exeFlags;
    WORD   dataSegNum;
    WORD   localHeapSize;
    WORD   stackSize;
    DWORD  cs_ip;
    DWORD  ss_sp;
    WORD   segTabEntries;
    WORD   modTabEntries;
    WORD   nonResTabSize;
    WORD   segTabOffset;
    WORD   resTabOffset;
    WORD   resNameTabOffset;
    WORD   modTabOffset;
    WORD   impTabOffset;
    WORD   nonResTabOffset;
    WORD   reserved2;
    WORD   numEntryPoints;
    WORD   shiftCount;
    WORD   numResourceSegs;
    BYTE   targetOS;
    BYTE   miscFlags;
    WORD   fastLoadOffset;
    WORD   fastLoadSize;
    WORD   reserved3;
    BYTE   winRevision;
    BYTE   winVersion;
} WININFO;

typedef struct tagTBSEGMENT {
    WORD  segDataOffset;
    WORD  segLen;
    WORD  segFlags;
    WORD  segMinSize;
} TBSEGMENT;

typedef struct tagTYPEINFO {
    WORD      rtTypeID;
    WORD      rtResourceCount;
    DWORD     rtReserved;
    NAMEINFO  rtNameInfo[1];
} TYPEINFO;

typedef struct tagNAMEINFO {
    WORD  rnOffset;
    WORD  rnLength;
    WORD  rnFlags;
    WORD  rnID;
    WORD  reserved[2];
} NAMEINFO;

typedef struct tagTBMODULE {
    WORD  moduleNameOffsets[1];
} TBMODULE;

typedef struct tagTBIMPNAME {
    BYTE  len;
    char  name[1];
} TBIMPNAME;

typedef struct tagTBENTRY {
    BYTE  numEntries;
    BYTE  entryType;
    BYTE  entryTable[1];
} TBENTRY;

typedef struct tagMOVEABLEENTRY {
    BYTE  entryFlags;
    WORD  int3f;
    BYTE  segmentNumber;
    WORD  segmentOffset;
} MOVEABLEENTRY;

typedef struct tagFIXEDENTRY {
    BYTE  flags;
    WORD  segmentOffset;
} FIXEDENTRY;

typedef struct tagTBNONRESNAME {
    BYTE  len;
    char  name[1];
    BYTE  index;
} TBNONRESNAME;

typedef struct tagRELOCATIONTABLE {
    WORD numEntries;
    RELOCATEITEM entries[1];
} RELOCATIONTABLE;

typedef struct tagRELOCATEITEM {
    BYTE  addressType;
    BYTE  relocationType;
    WORD  itemOffset;
    WORD  index;
    WORD  extra;
} RELOCATEITEM;


; type	neTwin
; is	Swif : neTwif
;	Aseg : [1] iwTseg
;	Ares : [1] iwTres
;	Anam : [1] iwTnam	; resource names
;	Amod : [1] iwTmod	; modules
;	Aimp : [1] iwTimp	; import names
;	Aent : [1] iwTent	; entry
;	Anon : [1] iwTnon	; nonresident name table
; end
