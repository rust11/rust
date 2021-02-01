;+++;	V11 needs its own RT-11 trace (like DOS/RSX/XXDP)
;???;	v11 - "v11 rust command" =>  "oot v2.4"
;	Remove 30kw mapping, LSI etc
;	Keep UNIBUS for DOS
;
;	RUN V11.TSK creates V11.CMD|@V11
;
;	/TWENTY		remove
;	/EIS		broken
;	/NOQUIET	add
;	/RSX etc	automatic trace
;	/TRACE
;	/NOTRAPS
;
;	inhibit clock for 100->102=0
;	force upper case terminal 
;	smart upper case for DOS
file	elroo - PDP-11 root
include	elb:elmod
include	rid:medef
include	rid:fidef
include	rid:cldef
include	rid:imdef
include	rid:dbdef
include	rid:stdef
include	rid:mxdef
include	rid:ctdef
include rid:codef
include rid:tidef
include rid:wcdef
include rid:shdef
include rid:rtutl
include	rid:vtdef
include	rid:lndef
include	rid:drdef

;	DOS needs manual interrupts (bis #100,csr where csr=200)
;
;	RSTS V? requires FPU 
;
;	Unix V7 requires I/D space
;	Unix V5 loads root directory instead of secondary boot code
;	(Might be an unnormalized disk)
;
;	debug mode
;	multiple debug commands
;	count cycles
;	reverse compile

	el_cmd : (*char) int	; parse command
	el_inf : ()
code	main

  func	main
	cnt : int
	vec : ** char
  is	cmd : [mxLIN] char
	par : int = 0
	ptr : * char = cmd
	im_ini ("V11")
	cl_lin (cmd)
	el_cmd (cmd)			; parse command line
	if vec[1]
	   st_low (cmd)
	   st_trm (cmd)
	   if st_fnd ("/?", cmd)
	   || st_fnd ("/he", cmd)
	   .. exit el_hlp ()
	   if st_fnd ("/in", cmd)
	   .. exit el_inf ()
;	   bgVbpt=0, ++par if st_fnd  ("/nobp", cmd)	; nobpt
;	   elVctc=1, ++par if st_fnd  ("/ct", cmd)	; ctrlc
	   elVclk=0, ++par if st_fnd("/nocl", cmd)	; noclock
	   elVdbg=1, ++par if st_fnd  ("/de", cmd)	; debug
	   bgVdsk=1, ++par if st_fnd  ("/di", cmd)	; disk
	   elFdlx=0, ++par if st_fnd("/nodl", cmd)	; DL: extended
	   elVdos=1, ++par if st_fnd  ("/do", cmd)	; dos
	   elFeis=2, ++par if st_fnd  ("/ei", cmd)	; lsi with eis
	   elVemt=1, ++par if st_fnd  ("/em", cmd)	; emt log
	   elFhog=1, ++par if st_fnd  ("/ho", cmd)	; hog cpu
	   elFiot=1, ++par if st_fnd("/noio", cmd)	; noiot
	   elVlog=1, ++par if st_fnd  ("/lo", cmd)	; log
	   elFlsi=1, ++par if st_fnd  ("/ls", cmd)	; lsi
	   elFltc=0, ++par if st_fnd  ("/nolt", cmd)	; noltc
	   elVmai=1, ++par if st_fnd  ("/ma", cmd)	; maintenance debug
	   elFmap=0, ++par if st_fnd("/nomm", cmd)	; nommu
	   elVpau=1, ++par if st_fnd  ("/pa", cmd)	; pause
	   elVrsx=1, ++par if st_fnd  ("/rs", cmd)	; rsx
	   elFsma=0, ++par if st_fnd("/nosm", cmd)	; nosmarts
	   elFstp=1, ++par if st_fnd  ("/st", cmd)	; stop before start
	   elVtrp=1, ++par if st_fnd  ("/tr", cmd)	; trace TRAPs
	   elFold=1, ++par if st_fnd  ("/tw", cmd)	; twenty (11/20 etc)
	   elFwri=1, ++par if st_fnd  ("/wr", cmd)	; write
	   elFwri=0, ++par if st_fnd("/nowr", cmd)	; nowrite
	   elFuni=1, ++par if st_fnd  ("/un", cmd)	; unibus model
	   elFupr=1, ++par if st_fnd  ("/up", cmd)	; uppercase terminal
	   elFvrb=1, ++par if st_fnd  ("/ve", cmd)	; verbose
	   elFvtx=0, ++par if st_fnd  ("/novt", cmd)	; novt100
	   elVxdp=1, ++par if st_fnd  ("/xx", cmd)	; xxdp
	   elVhtz=50,++par if st_fnd  ("/50", cmd)	; 50 hertz
	   elVhtz=60,++par if st_fnd  ("/60", cmd)	; 60 hertz
	   elF7bt=1, ++par if st_fnd  ("/7",  cmd)	; 7bit
	   vt_mod (52) if st_fnd ("/vt52", cmd)		; vt52
	   if elFuni					; unibus
	      elVhwm = elUAS				; 18-bit space
	   .. elVnmx = _256k
;	   if elFrsx
;	   .. elFdlx = 1				; rsx
	   if elFlsi
	      elVvio = 0170000 				; 30kw
	   .. elFmap = 0				; not a mapped system
	   if elFlsi && (elFeis eq 1)			; lsi without eis
	  .. elFeis = 0

	   elVdbg = 3 if elVmai				; maintenance debug
	   bgVfst = 0 if elVdbg
	   elPlog = fi_opn ("v11.txt", "wb", <>) if elVlog ; open a log
	end
	db_ini ()
;	co_att (<>)
;	ek_ctc (coDSB) if elVctc
DMP("6")
	el_ini ()
DMP("7")
	el_dis ()
DMP("8")
  end

code	exit

  proc	el_exi
  is	im_exi ()
;PUT("exit\n")
  end

code	verbose output

  func	el_vrb
	str : * char
  is	PUT(str) if elFvrb
  end
code	el_cmd - edit command

;	v11 /switchs disk command...
;
;	elAsys -> system disk name

  func	el_cmd
	cmd : * char
  is	ptr : * char
	dst : * char

	ptr = cmd			
	++ptr while *ptr eq ' '		; skip leading spaces
	if *ptr eq '/'			; have options
	   while *ptr			; 
	      next if *ptr++ ne ' '	; not a space
	      next if *ptr eq ' '	; and another
	      next if *ptr++ eq '/'	; got an option
	      --ptr 			; backup
	      ptr[-1] = 0		; terminate qualifiers
	      quit			;
	.. end				;

;	ptr now points past any qualifiers
;	the next field is the image name

	dst = elAsys			;
	while *ptr && (*ptr ne ' ')	;
	   *dst++ = *ptr++		;
	end				;
	*dst = 0			; terminate image name

;	the next field is an optional command

	exit if !*ptr			; no command coming
					;	
	++ptr while *ptr eq ' '		;
	exit if !*ptr			; no command

	st_cop (ptr, elAcmd)		; remember it
	elPcmd = elAcmd			;
	elVcmd = elENB_			; command enabled
  end

code	el_ddt - insert DOSBATCH command

  func	el_ddt
  is	cmd : [64] char
	val : tiTval
	plx : tiTplx
	ptr : *char = cmd
	ti_clk (&val)
	ti_plx (&val, &plx)
	plx.Vyea = 98
	*ptr++ = ' '
	ti_dmy (&plx, ptr)
	ptr = st_end (ptr)
	*ptr++ = '\r'
	*ptr++ = ' '
	ti_hmt (&plx, ptr)
	ptr = st_end (ptr)
;	*ptr++ = '\r'
;	*ptr++ = 'N'
	if elPcmd
	   *ptr++ = '\r'
	else
	.. elPcmd = elAcmd
	*ptr++ = 0
	st_ins (cmd, elPcmd)
  end
code	el_hlp - help

	elAhlp : [] * char

  func	el_hlp
  is	hlp : ** char = elAhlp		; help lines
	lft : ** char			; 
	rgt : ** char			;
	len : int = 0			;

	lft = hlp			; two column help
	++len while *hlp++ 		; count them
	rgt = lft + (len /= 2)		; right
	PUT("\n")
	PUT("V11.EXE - RUST PDP-11 emulator.  ")
;	PUT("See RUST.WIKISPACES.COM for documentation.")
	PUT("\n\n")
	while len--			; got more
	   PUT("%-40s", *lft++)		; the left part
	   PUT("%s\n", *rgt++)		;
	end
	PUT("\n")
	PUT("Disk defaults: PDP:.DSK.  ")
	PUT("Use ALT-H for runtime help.  ")
	PUT("Use ALT-C to abort V11.")
	PUT("\n")
  end

  init	elAhlp : [] * char
  is  	"V11 [/options] disk [command]"
	""
;	"/nobpt    Disable BPT traps"
	"/noclock  Disable clock"
	"/debug    Debug mode"
	"/dos      System is DOS/Batch (for /emt)"
	"/disk     Trace disk I/O operations"
	"/nodlx    Disable DL: extended address"
	"/eis      LSI emulation with EIS"
	"/emt      Trace EMT instructions"
	"/help /?  Display help"
	"/info     Displays boot information"
	"/noiot    Disable special V11 IOTs"
	"/log      Log output to v11.txt"
	"/lsi      LSI-11 emulation"
	"/noltc    Remove line time clock"
	"/maint    Maintenance debug mode"
	"/nommu    Disable Memory Management"
	"/pause    Pause screen output"
;	/"noquiet  Display passed command"
	"/report   Display startup debug info"
	"/rsx      System is RSX (for /emt)"
	"/nosmarts Disable O/S date setup etc"
	"/stop     Stop before execution"
	"/traps    Trace TRAPs (with /XXDP)"
	"/twenty   PDP-11/20 emulation"
	"/unibus   Unibus model"
	"/upper    Upper-case terminal"
;	"/verbose  Report startup operations"
	"/xxdp     System is XXDP (for /emt)"
;	"/windows  Display Windows dependenies"
	"/nowrite  Disable disk writes"
	"/60       60 hertz clock"
	"/7bit     Force 7 bit terminal output"
	<>
  end

code	el_inf - boot info

  func	el_inf
  is	PUT("DOS      LOGIN 1,1 |RUN PIP |^C |KILL(then hangs)\n")
	PUT("RT-11    No login required\n")
	PUT("RSX-11   No login required\n")
	PUT("RSTS     Not supported (needs FPU)\n")
	PUT("RUST/SJ  No login required\n")
	PUT("UNIX-5   @unix |login: root |#ls -l\n")
	PUT("UNIX-6   @unix |login: root |#ls -l\n")
	PUT("UNIX-7   @unix |rl(0,0)rl2unix\n")
	PUT("UNIX-7   @unix |rk(0,0)rkunix |STTY -LCASE\n")
  end
code	el_win - show windows dependencies

	el_lnp : (*char)

  func	el_win
  is	PUT("\n")
	el_lnp ("NF7")
	el_lnp ("PDP")
	el_lnp ("RUST")
 end

code	el_lnp - logical name path

  func	el_lnp
	pth : * char
  is	eqv : [mxSPC] char

	if !ln_trn (pth, eqv, 0)
	   exit PUT("%s not defined\n", pth)
	else
	.. PUT("%s:=[%s] (", pth, eqv)

	PUT("not ") if !dr_avl (pth)
	PUT("available)\n")
  end
