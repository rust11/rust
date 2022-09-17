;???;	VUP objects should be in the library as general interface
header	vumod - vup module

  type	cmTspc
  is	Pnam : * char		; file name
	Valc : WORD		; size, if any
  end
	cmAspc : [9] cmTspc+

  type	cmTval
  is	Vval : WORD		; value
	Vchn : BYTE		; channel
	Vsel : BYTE		; selected
  end

	cmIlst : cmTval+	; /LAST=n (aka END=n)	COPY/DEV
	cmIst1 : cmTval+	; /START=n		COPY/DEV
	cmIst2 : cmTval+	; /START=n		COPY/DEV

	cmVcre : WORD+		; (future)
	cmVseg : WORD+		; /SEGMENTS=n		INIT
	cmVret : WORD+		; /REPLACE=RETAIN	INIT
	cmVext : WORD+		; /EXTENSION=n		CREATE
	cmVdrv : WORD+		; /BOOT=drv		COPY/BOOT
	cmVonl : WORD+		; /VOL=ONLY		INIT DIR
	cmVwai : WORD+		; /WAIT 
	cmVnoq : WORD+		; /NOQUERY
	cmVwrd : WORD+		; /EXTRA=n		INIT

	cmVopt : WORD+		; option flags
	cmBAD_ := BIT(0)	; /BAD			INIT DIR
	cmRST_ := BIT(1)	; /RESTORE		INIT
	cmLST_ := BIT(3)	; /LAST (aka /END)
	cmSTA_ := BIT(4)	; /START
	cmVER_ := BIT(5)	; /VERIFY 
	cmSEG_ := BIT(6)	; /SEGMENTS		INIT
	cmFOR_ := BIT(7)	; /FOREIGN		BOOT
	cmREP_ := BIT(8)	; /REPLACE		INIT
	cmEXT_ := BIT(9)	; /EXTENSION		INIT
	cmVOL_ := BIT(10)	; /VOLUMEID		INIT DIR
	cmNOB_ := BIT(11)	; /NOBOOT		SQUEEZE
	cmFIL_ := BIT(12)	; /FILES		DIR/BAD
	cmIGN_ := BIT(13)	; /IGNORE		COPY/DEVICE
	cmLOG_ := BIT(14)	; /LOG (RUST)		DIR/BAD COPY/BOOT
	cmQUE_ := BIT(15)	; /QUERY (RUST)		COPY/BOOT

  type	vuTobj
  is	Vblk : WORD		;\block  (see vuutl.r for initialisation)
	Vcnt : WORD		;|count
	Pmod : * char		;|open mode
	Pdef : * char		;|default file spec
	Pdis : * char		;/display name for messages
				;
	Pfil : *FILE		; file block
	Pbuf : * void		; transfer buffer
;	Pspc : * cmTspc		; name and allocation
	Atmp : [4] char		; temp string
	Anam : [16] char	; ascii name
  end

	vuIdev : vuTobj+
	vuIboo : vuTobj+
	vuIhom : vuTobj+
	vuIroo : vuTobj+
	vuIseg : vuTobj+
	vuIdrv : vuTobj+
	vuIbas : vuTobj+
	vuImon : vuTobj+
	vuIsrc : vuTobj+
	vuIdst : vuTobj+

	vuAboo : [] WORD+

end header
