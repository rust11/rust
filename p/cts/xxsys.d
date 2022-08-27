header	xxsys - XXRT system definitions

;	XXDP device description (*Vsydev)

  type	xxTdev
  is	Anam : [2] char		; no terminator
	Vuni : char		; ascii unit
	Vmed : char		; media code
  end

;	XXRT IOB (*Vsyiob)

	xx_iob : (*void) *void	; convert pointer to drcsr to drbuf 

  type	xxTiob
  is	Vdrbuf : word		; dr.buf - -> driver buffer
	Vdrent : word		; dr.ent - entry # in segment
	Adrfnm : [3] word	; dr.fnm - .rad50 /filnamtyp/
	Vdrsbl : word		; dr.sbl - first file block
				;
	Vdropn : word		; dr.opn - .word dr$opn 
	Vdrrst : word		; dr.rst - .word dr$rst
	Vdrtra : word		; dr.tra - .word dl$tra
	Vdrdev : word		; dr.dev - .word dr$dev
	Vdruni : byte		; dr.uni - .byte 0
	Vdrsts : byte		; dr.sts - .byte 0
;	Vdriob : null		;
	Vdrcsr : word		; dr.csr - .word CSR
	Viowct : word		; io.wct - .word 0
	Viobuf : word		; io.buf - .word 0
	Vioblk : word		; io.blk - .word 0
	Vioufd : word		; io.ufd - .word d$pufd
	Aiospc : [12] byte	; io.spc - .blkb 12.
  end

;	Configuration flags (Vsycfg)

	xxLTC_ := 1		; line clock present
	xxKWP_ := 2		; programmable clock present
	xxLPT_ := 4		; line printer present
	xxNUB_ := 10		; NoUniBus
	xx50H_ := 20		; 50 Hertz clock

;	System information table

  type	xxTsys
  is	Asyswi : [24] byte	;  batch/CLI switch buffer
	Asygto : [58] word	;  batch GOTO buffer		(hack)
	Vsytra : word		;  -> .5k transient area	(init)
	Vsyper : word		;  -> permanent memory area	(init)
	Vhwltc : word		;  line clock
	Vhwkwp : word		;  KW11P programmable clock
	Vsyrel : word		;  relocation constant		(init)
	Vsyrpt : word		;  diagnostic repeat count
	Vsydev : word		;  -> d$pdev: .ascii "DDu"<lmd>	(init)
	Vsysup : word		;  ACT supervisor load address	(init)
	Vsytps : word		;  TPS/LPT csr pointer		(init)
	Vsytpb : word		;  TPB/LPB buffer pointer	(init)
	Vfibct : word		;  ReaByt file byte count
	Vsytop : word		;  top of memory		(init)
	Vfiptr : word		;  file buffer pointer
	Vfilck : word		;  LDA load file read checksum
	Vcllin : word		;\ resident command pointer	(init)
	Vcllen : word		;/ line length			(init)
	Vclnxt : word		;  points to next command field
	Vfipos : word		;  current file position
	Vfisvp : word		;  saved/restored file position
	Vclfld : word		;  current field pointer
	Vsyf00 : word		;  ???				(note)
	Vsydat : word		;  system DOSbatch date
	Vsyabt : word		;  setabt/jmpabt address
	Asyemt : [2] word	;  saved EMT vector during image load
	Vsysta : word		;  image START command address and type
	Vsyact : word		;  image activate address
	Vfirck : word		;  ReaBlk checksum
	Vfisck : word		;  Batch saved ReaBlk checksum
	Vsy5ck : word		;  .5k area checksum		(init)
	Vsyf01 : byte		;  free
	Vsyf02 : byte		;  free
	Vsyf03 : byte		;  free
	Vsyf04 : byte		;  free
	Vsycol : byte		;  column (for tabbing)
	Vsypnd : byte		;  pending input character
	Vsyf05 : byte		;  PopBat flag (i.e. not PshBat)
	Vsyqui : byte		;  negative => quiet mode
	Vclclb : word		;  command line backstop
	Aclbuf : [42] byte	;  command line buffer
	Vclbfz : word		;
	Abasfn : [5] word	;  fil - saved batch file name
	Abafnm : [5] word	;  fil - batch file name
	Afirec : [512] byte	;
	Vfircz : word		;  buffer parse & print terminator
;				;  GetCom
	Vsycsr : word		;\ CSR address			(init)
	Vsyf06 : word		;| ???				(note)
	Vsyuni : word		;| unit number			(init)
	Vsycfg : word		;| config flags (LPT$ etc)	(init)
	Vsylpt : word		;| LPT CSR if present		(init)
	Vsykwd : word		;| kwords memory size		(init)
	Asyltc : [3] word	;|\ LTC ISR and block
	Vsyltk : word		;|/ LTC clock-ticks    (50hz=50.)(init)
	Asykwp : [3] word	;|\ KWP ISR and block
	Vsyktk : word		;|/ KWP clock-ticks    (50hz=50.)(init)
	Vsyqvs : word		;| /QV quick verify switch
	Vsybat : byte		;| 1+=batch mode and level
	Vsyf07 : byte		;| ???			(added)(note)
	Vsypgs : word		;| MMU 32w-pages-1 (777=16kw-1pg)(init)
	Vsyerr : word		;/ apps report errors to batch here
;
;	XXRT area
;
	Psyiob : * xxTiob	; system IOB
	Vfinxt : word		; RUST/RT next block
	Vfilst : word		; RUST/RT last block
				;
	Vsyhst : byte		; -1=RUST/BOOT, 0=RUST, 1=RT-11
	Vsyemu : byte		; -1=V11, 0=none, 1=SimH
	Vsyscp : byte		; scope VT100 mode flip/flop
	Vsyshe : byte		; XXRT as shell
	Vsycli : byte		; host CLI single-line command flag
	Vsynew : byte		; CLI prompt newline control
	Vsyver : byte		; system version
	Vsyupd : byte		; system update
  end
end header
