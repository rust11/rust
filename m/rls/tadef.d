header	tadef - cassette definitions

  type	taTint
  is	Vhgh : char		; high-order
	Vlow : char		; low order
  end

;	32-byte file header

  type	taThdr
  is	Afil : [6] char	  ; 00	; "FILNAM" - space-filled
	Atyp : [3] char	  ; 06	; "TYP" - space-filled
	Vtyp : char	  ; 11	; 'A'scii, 'B'inary 
	Ilen : taTint	  ; 12	; file length - unused
	Vseq : char	  ; 14	; tape sequence 
	Vsup : char	  ; 15	; support level: 0, 1, 2
	Adat : [6] char	  ; 16	; " 11273" - day-mon-yea
	Agen : taTint	  ; 24	; generation number
	Vatr : char	  ; 26	; attributes
	Af00 : [3] char	  ; 27	; unused
	Aetc : [3] char	  ; 32	; "ETC" - space filled
	Vf01 : [3] char	  ; 35	; unused
  end

;	first character of file name

	taSEN  := 0
	taDEL  := '$'

data	cassette hardware

	taCSR	:= 0177500	; CSR
	taBUF	:= 0177502	; buffer
	taVEC	:= 0260		; vector

  type	ctTcas
  is	Vcsw : int
	Vbuf : char
	Vf00 : char
  end

  type	ctTopr
  is	Pcas : * ctTcas
	Vuni : int
	Vsta : int
	Abuf : [130]
  end

	taMAX	:= 93000	; maximum bytes
	taMBL	:= 181		; maximum blocks

	taERR$	:= 0100000	; error
	taCRC_	:= 040000	; crc error
	taLEA_	:= 020000	; clear leader
	taWRL_	:= 010000	; write locked
	taGAP_	:= 04000	; file gap encountered
	taTIM_	:= 02000	; timing error
	taOFF_	:= 01000	; offline
	taCLR_  := 0177000	; flags to clear
				;
	taUNI$	:= 0400		; unit number (0 or 1)
	taTRA$	:= 0200		; transfer request
	taENB$	:= 0100		; interrupt enabled
	taRDY$	:= 040		; ready for command
	taLBS$	:= 020		; initiate last byte sequence
	taWFG	:= 0		; write file gap
	taWRT	:= 1	;  3	; write
	taREA	:= 2	;  5	; read
	taRVF	:= 3	;  7	; space reverse file
	taRVB	:= 4	; 11	; space reverse block
	taFWF	:= 5	; 13	; space forward file
	taFWB	:= 6	; 15	; space forward block
	taRWD	:= 7	; 17	; rewind
	taACT	:= 1		; go

end header

