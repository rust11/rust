;	Add DATE to set the date
;	Add VERIFY to display chain files regardless of QUIET
;	Add TRAPS to set trap catchers.
;
;	Add XXIOB offsets
file	EXERT - Exercise XXRT system calls and structures
include	rid:rider
include	rid:dcdef
;nclude	gkb:gkmod
include rid:imdef
include rid:xxsys

;	Dependencies
;
;	@@xrs:xrt rebuilds all the following:
;
;	cts:xrt.mac
;	cts:xrtmac.mac
;	cts:xrtlib.mac
;	cts:xxsys.d
;	cus:exert.r
;
;	%build
;	rider cus:exert/object:cub:
;	link cub:exert,lib:xrt,lib:crt/exe:cub:exert.bin/lda/map:cub:exert
;	!link cub:exert,lib:crt/exe:tmp:xxdig.sav/map:tmp:exert
;	copy cub:exert.bin sy:/nolog
;	%end

	cu_dmp : (*word, int)

	_cuABO := "XXRT Exerciser EXERT.BIN V1.0\n"	; ABOUT string

  type	cuTctl
  is	Pdcl : * dcTdcl
	V1   : int
  end
	ctl : cuTctl = {0}

code	cuAdcl - DCL processing

  init	cuAhlp : [] * char
  is   "XXRT exerciser EXERT.BIN V1.0"
	""
       "ALL        Display everything"
       "EXIT       Return to system"
       "HELP       Display help"
       "LOW        Display low memory"
       "SHOW       Display configuration"
       "TRAPS      Rebuild vector traps"
	<>
	<>
  end

	cu_bau : dcTfun
	cu_hlp : dcTfun
	cu_mem : dcTfun
	cu_mon : dcTfun
	cu_all : dcTfun
	cu_low : dcTfun
	cu_sho : dcTfun
	cu_trp : dcTfun

  init	cuAdcl : [] dcTitm
; level symbol		task	P1	V1 type|flags
  is 1,	"HE*LP",	dc_hlp,	cuAhlp,	0, dcEOL_
     1,	"EX*IT",	dc_exi,	<>,	0, dcEOL_
     1,	"AL*L",		cu_all,	<>,	0, dcEOL_
     1,	"LO*W",		cu_low,	<>,	0, dcEOL_
     1,	"SH*OW",	cu_sho,	<>,	0, dcEOL_
     1,	"TR*APS",	cu_trp,	<>,	0, dcEOL_
     1,	<>,		<>, 	<>,	0, dcEOL_
     0,	 <>,		<>,	<>,	0, dcEOL_
  end
code	start 

  func	start
  is	dcl : * dcTdcl
	im_ini ("EXERT")
	dcl = ctl.Pdcl = dc_alc ()
	dcl->Venv = dcCLI_|dcCLS_
	dc_eng (dcl, cuAdcl, "EXERT> ")
  end

code	cu_hlp - display help

  func	cu_hlp
	dcl : * dcTdcl
  is	PUT("%s\n", _cuABO)
	im_hlp (cuAhlp, 2)

	PUT("\nSome tests require [ctrl/c] to terminate\n\n")
	fine
  end

code	cu_all - show all

  func	cu_all
  is	cu_mon ()
	cu_cfg ()
	cu_flg ()
;	cu_low ()
	cu_mem ()
	cu_stk ()
;	cu_gtl ()
	fine
  end

code	cu_sho - show configuration

;	Host device
;	Hardware

  func	cu_sho
  is	sys : *xxTsys = GetSys ()
	dev : *xxTdev = GetDev ()
	cfg : int = sys->Vsycfg

	NewLin ()
	PUT("XXRT V%d.%d\n", sys->Vsyver, sys->Vsyupd)
	NewLin ()

	PUT("System Device:   %c%c%c: ",dev->Anam[0],\
				dev->Anam[1],dev->Vuni)
	NewLin ()

	PUT("Restart Address: %o", sys->Vsytop-2) 
	NewLin ()

	PUT("Memory Size:     %dkw", sys->Vsykwd)
	NewLin ()

	if cfg & (xxLTC_)
	   PUT("Line Clock:      ")
	   PUT("50hz ") if cfg & xx50H_
	   PUT("60hz ") otherwise
	   NewLin ()
	end
	if cfg & (xxKWP_)
	   PUT("Program. Clock:  ")
	   PUT("50hz ") if cfg & xx50H_
	   PUT("60hz ") otherwise
	   NewLin ()
	end
	PUT("No Clock\n") if !(cfg & (xxLTC_|xxKWP_))
	
	PUT("Lineprinter\n") if cfg & xxLPT_
	
	PUT("System Bus:      ")
	PUT("Qbus ") if cfg & xxNUB_
	PUT("Unibus" ) otherwise
	NewLin ()

	PUT("Host System:     ")
	case sys->Vsyhst
	of 0 PUT("RUST/SJ")
	of 1 PUT("RT-11")
	end case
	NewLin ()

	if sys->Vsyemu
	   PUT("PDP-11 Emulator: ")
	   case sys->Vsyemu
	   of 1 PUT("V11")
	   of 2 PUT("SimH")
	   end case
	   NewLin ()
	end

	PUT("Terminal is set: ")
	PUT("NO") if !sys->Vsyscp
	PUT("SCOPE")
	NewLin ()
	NewLin ()

	fine
  end
code	cu_mon - display monitor variables

	xxVemt : WORD+

code	cu_mon - show monitor variables

  func	cu_mon
  is	sys : *xxTsys = GetSys ()
	dev : *xxTdev = GetDev ()
	iob : *xxTiob = xx_iob (sys->Psyiob)
	psw : * word = 0177776

	PUT("\nDevice=[%c%c%c:] ", dev->Anam[0], dev->Anam[1], dev->Vuni)
	PUT("Media code=0%o\n", dev->Vmed)

	PUT("System CSR=%o  ", sys->Vsycsr)
	PUT("Driver CSR=%o  ", iob->Vdrcsr)
	NewLin ()

	PUT("GetSys: %o\n", GetSys ())
	PUT("GetCom: %o\n", GetCom ())
	PUT("GetDev: %o\n", GetDev ())

	PUT("IOB: %o\n", sys->Psyiob)
	PUT("EMT: %o\n", xxVemt)
	PUT("PSW: %o\n", *psw)
	Newlin ()
  end

code	cu_cfg - show configuration

  func	cu_cfg
  is	sys : * xxTsys = GetSys ()
	cfg : int = sys->Vsycfg

	PUT("Config: (%o)\n", cfg)
	PUT("50hz ") if cfg & xx50H_
	PUT("60hz ") otherwise
	PUT("Line clock ") if cfg & xxLTC_
	PUT("Programmable clock ") if cfg & xxKWP_
	PUT("No clock") if !(cfg & (xxLTC_|xxKWP_))
	Newline ()
	PUT("Lineprinter\n") if cfg & xxLPT_
	PUT("Not Unibus\n") if cfg & xxNUB_
	NewLin ()
  end

code	cu_flg - show system flags

  func	cu_flg
  is	sys : * xxTsys = GetSys ()

	PUT("Flags:\n")
	PUT("sy.sta=%o ", sys->Vsysta)
	PUT("sy.act=%o ", sys->Vsyact)
	PUT("sy.rpt=%d ", sys->Vsyrpt)
	NewLin ()

	PUT("sy.bat=%o ", sys->Vsybat)
	PUT("sy.qvs=%o ", sys->Vsyqvs)
	PUT("sy.qui=%o ", sys->Vsyqui)
	PUT("sy.col=%o ", sys->Vsycol)
	PUT("sy.pnd=%o ", sys->Vsypnd)
	NewLin()
	PUT("sy.hst=%o ", sys->Vsyhst)
	PUT("sy.emu=%o ", sys->Vsyemu)
	PUT("sy.scp=%o ", sys->Vsyscp)
	PUT("sy.she=%o ", sys->Vsyshe)
	PUT("sy.cli=%o ", sys->Vsycli)
	PUT("sy.new=%o ", sys->Vsynew)
	NewLin()
	NewLin()
  end

code	cu_low - show low memory

  func	cu_low
  is	mem : * word = 0
	PUT("\nLow Memory:\n")

	while mem lt 01000
	   if *mem ne mem + 1 || mem[1] ne 0
	   .. PUT("%o:\t%o\t%o\n", mem, *mem, mem[1])
	   mem += 2
	end
	NewLin ()
	fine
  end

code	cu_mem - show memory structure

  func	cu_mem
  is	sys : * xxTsys = GetSys ()
	PUT("Monitor Memory:\n")
	PUT("Memory Size: %o ", sys->Vsytop)
	   PUT("(Kwords: %d., ", sys->Vsykwd)
	   PUT("Pages: %d.)\n", sys->Vsypgs)
	PUT("Permanent:   %o\n", sys->Vsyper)
	PUT("Transient:   %o\n", sys->Vsytra)
	PUT("Relocation:  %o\n", sys->Vsyrel)
	PUT("Supervisor:  %o\n", sys->Vsysup)
	NewLin ()
  end

code	cu_stk - check stack area

	cuSWI := 24	; 24-byte switch area
	cuSTK := 58	; 58-word stack area

  func	cu_stk
  is	sys : * xxTsys = GetSys ()
	swi : * word = sys->Asyswi
	gto : * word = sys->Asygto

	PUT("Switches:\n")
	cu_dmp (swi, cuSWI/2)
	NewLin ()

	PUT("Goto/Stack:\n")
	cu_dmp (gto, cuSTK)
	NewLin ()
  end
code	cu_trp - reset trap catchers

  func	cu_trp
  is	emt : WORD
	vec : WORD
	ptr : * WORD = 0
	cnt : int = 128

	emt = ptr[030/2]
	vec = ptr[032/2]

	while cnt--
	  *ptr = ptr + 1
	   ptr++
	  *ptr++ = 0
	end

	ptr = 0
	ptr[030/2] = emt
	ptr[032/2] = vec

	fine
  end
code	utilities

;	Dump a memory segment

  func	cu_dmp
  	mem : * word
	cnt : int
  is	min : int
	don : int = 0
	while don lt cnt
	   min = 8
	   PUT("%o:\t", mem)
	   while min--
	       quit if don++ eq cnt
	   ..  PUT("%o\t", *mem++)
	.. PUT("\n")
  end
end file

code	system calls

  func	cu_gtl
  is	lin : * char
	fld : * char
	ter : int
	NewLin ()
      repeat
	PUT("GetLin>")
	quit if !GetLin (&lin, &ter)
	cu_lin ("line: ", lin, ter)
	repeat
	   quit if !ParFld (&fld, &ter)
	   cu_lin ("field: ", fld, ter)
	end
      end
  end

code	cu_lin - display line, fields

  func	cu_lin
	hdr : * char
	lin : * char
	ter : int
  is	PUT("%s [%s] ", hdr, lin)
	PUT("<%o> \n", ter) if ter le ' '
	PUT("[%c] \n", ter) otherwise
  end


