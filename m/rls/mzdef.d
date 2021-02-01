header	mzdef - MZ image definitions

data	mzThdr - DOS "MZ" .EXE image header

	mzSIG := 0x5a4d		; MZ signature

  type	mzThdr
  is	Vsig : WORD		; "MZ"
	Vext : WORD		; extra bytes
	Vpag : WORD		; # 512 byte pages in file
	Vrel : WORD		; relocatable item count
	Vsiz : WORD		; header size
	Vmin : WORD		; min alloc
	Vmax : WORD		; max alloc
	Vss  : WORD		; initial SS
	Vsp  : WORD		; initial SP
	Vchk : WORD		; checksum
	Vip  : WORD		; initial IP
	Vcs  : WORD		; initial CS
	Vtab : WORD		; offset to reloc table
	Vovl : WORD		; overlay number
	Vf00 : LONG		; END OF DOS VERSION
				; (32 bytes)
	Vf01 : LONG		; NE/LE/NE EXTENSIONS
	Voem : WORD		; oem id
	Vinf : WORD		; oem info
	Af02 : [10] WORD	; unused
	Vhdr : LONG		; offset to NE/PE/... header
;sic]	Vf03 : WORD		; (NT changed Vhdr from WORD to LONG)
				; (64 bytes)
	Astb : [4] BYTE		; dos stub (need Dos)
  end
	mzDOS := 32		; DOS has 32-byte header
	mzWIN := 64		; WIN has 64-byte header

end header
end file
#define ENEWHDR     0x003CL         /* offset of new EXE header */
#define EMAGIC      0x5A4D          /* old EXE magic id:  'MZ'  */
#define NEMAGIC     0x454E          /* new EXE magic id:  'NE'  */
#define LEMAGIC		0x454C			/* linear executable */
#define LXMAGIC		0x584C			/* IBM OS/2 2.0 linear executable */
#define PEMAGIC		0x4550			/* NT portable executable */
#define W3MAGIC		0x3357			/* WIN386.EXE signature */
#define SZMAGIC		0x5A53			/* SZ -- compressed file */
