;???;	create front-end thunks for compilers etc
file	build - build applications etc
include	rid:rider
include	rid:stdef
include	rid:mxdef
include	rid:medef
include	rid:fidef
include	rid:imdef
include	rid:fsdef
include	rid:ctdef
include	rid:cldef
include	rid:lndef
include	rid:prdef
include <stdlib.h>
include	rid:dbdef

;	A better way to do this:
;
;	Write portable PLATFORM, RIDER, CC, LINK and LIBRARY front-end apps.
;	Rewrite BUILD to execute those apps.
;	Method would also work on smaller architectures.
;
;	Optimise disk access time during make operations:
;	Do directory scan of SRC: and fill in as many times as possible.
;	Then fill in BIN: times.
;
;	Don't ignore image name in MAKE commands
;	Supress automake in rls: etc
;	Cusps: store setup.bld in source file -- look there first.
;
;	Delete result file of operation that failed
;
;	Remove dependency on binary directory
;	setup.bld describes src/bin etc
;	CUSP.bld is searched for first in source directory
;	...
;
;	man:locate.bld	finds all projects known by build
;	build/create dir [src bin]
;	Distribution names
;
;  Non-goals
;	xxx:....	Should keep it all in this form
;	fsPTH/fsLOG	should be able to stick to logical name form
;	Need to normalize names. (log:name.t)
;
;	list only
;	list libraries
;	store error history
;	save build history

code	macros

	APP(p)	:= cu_put (env, (p))
	SPC	:= cu_put (env, " ")
	NEW	:= cu_put (env, "\r\n")
	TMPSRC(t,b) := cu_spc (env, env->Asrc, env->Afil, (t), (b))
	TMPBIN(t,b) := cu_spc (env, env->Abin, env->Afil, (t), (b))
	TMPHDR(t,b) := cu_spc (env, env->Ahdr, env->Afil, (t), (b))
	SRC(t)  := cu_spc (env, env->Asrc, env->Afil, (t), <>)
	BIN(t)  := cu_spc (env, env->Abin, env->Afil, (t), <>)
	HDR(t)  := cu_spc (env, env->Ahdr, env->Afil, (t), <>)

	LFT(t)	:= TMPBIN((t), env->Alft)
	RGT(t)	:= TMPBIN((t), env->Argt)
	TGT(t)	:= TMPBIN((t), env->Atgt)
	RGTHDR(t) := TMPHDR((t), env->Argt)
	TGTHDR(t) := TMPHDR((t), env->Atgt)
	SRCLFT(t) := (SRC(t), TMPSRC((t), env->Alft))
	BINLFT(t) := (BIN(t), LFT(t))
	BINRGT(t) := (BIN(t), RGT(t))
	BINTGT(t) := (BIN(t), TGT(t))
	BINRGTTGT(t) := (BIN(t), RGT(t), TGT(t))
	HDRRGTTGT(t) := (HDR(t), RGTHDR(t), TGTHDR(t))
	OPR(t)	:= cu_rew (env), (st_cop (t, env->Aopr))

	COPLFT(t) := st_cop ((t), env->Alft)
	COPRGT(t) := st_cop ((t), env->Argt)
	COPTGT(t) := st_cop ((t), env->Atgt)
	COPRGTTGT(t) := (COPRGT(t), COPTGT(t))
data	command qualifiers

;	Some routines assume that quDOS/quWIN are not zero.

  init	cuAqua : [] *char
  is	quALL:	"al*l"		; runs cu_all
	quCEE:	"ce*e"		; C to .OBJ
	quCON:  "co*nsole"	; console platform
	quCRF:  "cr*ossreference" ; crossref map
	quCUS:	"cu*sp"		; %module% to executable
	quDBG:  "deb*ug"	; compile debug mode
	quDET:  "det*ailed"	; detailed logging
	quDIS:  "di*stribute"	; copy image to distribution directory
	quDOS:  "do*s"		; dos platform
	quECH:  "ec*ho"		; echo input
	quERR:	"er*ror"	; don't abort on warnings
	quEXE:	"ex*ecutable"	; link
	quFUL:  "fu*ll"		; full map
	quGRA:  "gr*aphic"	; graphic platform
	quLEA:  "le*ave"	; leave intermediate files
	quHEA:	"he*ader"	; .d to .h	redundant
	quIMG:	"im*age"	; forces link or librarian action
	quIGN:  "ig*nore"	; ignore errors
	quIGW:  "nowa*rnings"	; ignore errors
	quLIB:	"lib*rary"	; *.obj to .lib
;	quLNK:	"lin*k"		; forces link
	quMAC:	"mac*ho"	; .m to .mx
	quMAK:  "mak*e"		; make
	quMSM:	"mas*m"		; .asm to .obj
	quPAS:  "pa*ssive"	; no actions
	quSYM:  "sym*antec"	; symantec compiler
	quRID:	"ri*der"	; .r to .rx
	quVCC:  "vc*c"		; visual C++
	quVER:  "ve*rify"	; verify goings on
	quWIN:	"wi*ndows"	; windows platform
	quINV:	<>
  end

data	build control files

  type	cuTlin
  is	Psuc : * cuTlin
	Pstr : * char
	Vaut : int		; automatic (internally generated)
  end

  type	cuTcol
  is	Vini : int		; is initialized
	Pmod : * cuTlin		; modules
	Phea : * cuTlin		; headers
	Psrc : * cuTlin		; sources
	Pobj : * cuTlin		; objects
	Pimg : * cuTlin		; image
	Plst : * cuTlin		; listing
	Pmap : * cuTlin		; map
	Plib : * cuTlin		; libraries
	Pres : * cuTlin		; resource 
	Ppth : * cuTlin		; include path
	Ppla : * cuTlin		; platform
	Pdst : * cuTlin		; distribution
	Poth : * cuTlin		; other files
  end

data	cuTenv - environment

  type	cuTdis	: forward

  type	cuTenv
  is	Aspc : [mxSPC] char		; input spec
	Aprj : [mxSPC] char		; project directory
	Asrc : [mxSPC] char		; source directory
	Abin : [mxSPC] char		; binary directory
	Ahdr : [mxSPC] char		; header output directory
					;
	Adev : [mxSPC] char		; translated parts of file
	Adir : [mxSPC] char		; translated parts of file
	Afil : [mxSPC] char		;
	Atyp : [mxSPC] char		;
	Vtyp : int			;
	Pdis : * cuTdis			;
					;
	Arid : [mxSPC] char		; rider executable
	Amac : [mxSPC] char		; macho executable
	Acpr : [mxSPC] char		; compiler prelude
	Acee : [mxSPC] char		; C executable
	Acsw : [mxSPC] char		; C switchs
	Acsf : [mxSPC] char		; C source switch
	Acof : [mxSPC] char		; C object switch
	Amsm : [mxSPC] char		; masm executable
	Amsw : [mxSPC] char		; masm switchs
					;
	Alnk : [mxSPC] char		; linker executable
	Alks : [mxSPC] char		; linker switchs
	Ares : [mxSPC] char		; project resource file
					;
	Alib : [mxSPC] char		; librarian executable
	Albs : [mxSPC] char		; librarian switchs
	Albp : [mxSPC] char		; librarian project data
					;
	Acfl : [mxSPC] char		; C filter
	Amfl : [mxSPC] char		; masm filter
	Alkf : [mxSPC] char		; linker filter
	Albf : [mxSPC] char		; librarian filter
					;
	Aset : [mxSPC] char		; "setup.bld" filespec
	Acus : [mxSPC] char		; src:<spec>.bld if exists
	Pcol : * cuTcol			; sections/modules collections
					;
	Aopr : [mxSPC] char		; the operation
	Alft : [mxSPC] char		; left hand file (source)
	Argt : [mxSPC] char		; right hand file (output)
	Atgt : [mxSPC] char		; target file
					;
	Acmd : [mxSPC] char		; command shell executable
	Alog : [mxSPC] char		; build log file
	Plog : * FILE			; log input
	Pflt : * FILE			; filter output
	Abuf : [64*1024] char		; output buffer
	Pbuf : * char			; buffer pointer
	Abld : [mxSPC] char		; build batch file
	Aopt : [mxSPC] char		; linker/librarian options file 
	Anul : [mxSPC] char		; the null device
	Asec : [mxSPC] char		; section holding buffer

	Asup : [mxSPC] char		; supress terminal output of this string
					;
	Vdos : int			; dos things
	Vwin : int			; windows things
	Vcon : int			; console things
	Vgra : int			; graphic things
					;
	Qall : int			; /all
	Qans : int	; on	C	; ansii
	Qaut : int	; off	C	; autoprotoype
	Qcrf : int			; crossreference
	Qbld : int			; required build
	Qcmp : int			; compiler
	Qdbg : int	; off	all	; debug
;	Qcee : int			; .c files only
	Qdet : int			; detailed verify
	Qech : int			; echo input
;	Qexe : int			;
	Qful : int			; full map
	Qdst : int			; distribute result file
	Qfil : int			; file specified (internal)
;	Qhea : int			; headers only
	Qimg : int			; forces image 
	Qign : int			; ignore errors
	Qigw : int			; ignore warnings
	Qlea : int			; leave intermediate files 
;	Qlib : int			;
	Qmak : int			; make -- update stale modules
;	Qmac : int			; macho files only
;	Qmsm : int			; masm only
	Qmod : int			; required model
	Qpas : int			; passive -- no actions
	Qpla : int			; required platform
	Qrid : int			; rider library 
	Qver : int			; verify
					;
  end

code	translation routines

  type	cuTfun	: (*cuTenv) int

	cx_r	: cuTfun
	cx_rx	: cuTfun
	cx_d	: cuTfun
	cx_c	: cuTfun
	cx_cpp	: cuTfun
	cx_m	: cuTfun
	cx_mx	: cuTfun
	cx_asm	: cuTfun
	cx_all	: cuTfun
	cx_lnk	: cuTfun
	cx_lib	: cuTfun

	cf_gen	: cuTfun
	cf_cee	: cuTfun
	cf_msm	: cuTfun
	cf_lib	: cuTfun
	cf_lnk	: cuTfun

	cuVER := 1
	cuINT := 0
	cu_mak	: (*cuTenv, int) int
	cu_ver  : (*cuTenv, *char)
	cu_exe	: (*cuTenv, *char, *cuTfun) int
	cu_cmd	: (*cuTenv, *char, *char) int

	cu_rid (e) := (cu_exe (env, env->Arid, &cf_gen))
	cu_mac (e) := (cu_exe (env, env->Amac, &cf_gen))
	cu_cee (e) := (cu_exe (env, env->Acee, &cf_gen))
	cu_msm (e) := (cu_exe (env, env->Amsm, &cf_msm))
	cu_lnk (e) := (cu_exe (env, env->Alnk, &cf_lnk))
	cu_lib (e) := (cu_exe (env, env->Alib, &cf_lib))

  type	cuTdis
  is	Ptyp : * char
	Pfun : * cuTfun
  end

  init	cuAtyp : [] cuTdis
  is	cuRID:: "r",	cx_r
	cuR2C:: "rx",	cx_rx
	cuHDR:: "d",	cx_d
	cuCEE:: "c",	cx_c
	cuCPP:: "cpp",	cx_cpp
	cuMAC:: "m",	cx_m
	cuM2M:: "mx",	cx_mx
	cuMSM:: "asm",	cx_asm
	cuEXE:: "exe",	cx_lnk
	cuLIB:: "lib",	cx_lib
	cuMAX:: <>
  end

	cu_arg	: (*cuTenv, int, **char, *char) int
	cu_put	: (*cuTenv, *char)
	cu_hlp	: (void) int
	cu_env	: cuTfun
	cu_bld	: (*cuTenv, *char)
	cu_typ	: (*cuTenv, *char) int
	cu_prj	: cuTfun
	cu_pla	: cuTfun
	cu_exi	: cuTfun

	cu_spc	: (*cuTenv, *char, *char, *char, *char)
	cu_sec	: (*cuTenv, *char) int

	cu_lst	: (**cuTlin) **cuTlin
	cuLOC_	:= BIT(0)		; localize
	cuMOD_	:= BIT(1)		; module distribution
	cuBIN_	:= BIT(2)		; bin default
	cuSRC_	:= BIT(3)		; src default
	cuPLA_	:= BIT(4)		; platform section
	cuEQU_	:= BIT(5)		; equate section
	cu_add	: (*cuTenv, *char, **cuTlin, int)
	cu_mod	: (*cuTenv, *char, **cuTlin, int)
	cu_lst	: (**cuTlin) **cuTlin
	cu_sea	: (*cuTenv, *char) int
	cu_del	: (*cuTenv, *char)
	cu_dst	: (*cuTenv, *char)

	cu_int	: cuTfun
	cu_dos	: cuTfun
	cu_con	: cuTfun
	cu_gra	: cuTfun
	cu_win	: (*cuTenv, *char) int
	cu_res	: (*cuTenv, *char) int
	cu_rew	: cuTfun
	cu_sto	: (*cuTenv, *char) int
	cu_rep	: (*cuTenv, *char, *char) int
code	main

;	1.  cu_env  Setup the fixed assignments
;	2.  cu_arg  Get command and qualifiers
;	3.  cu_prj  Setup src:/prj:
;?	4.  cu_cus  Read src:<module.bld> if one exists
;	5.  cu_sec  Read src:setup.bld, applying defaults
;	6.  cu_pla  Setup platform (switch, setup.bld or default)

  func	main
	cnt : int
	vec : **char
  is	env : * cuTenv = me_acc (#cuTenv)	; make environment
	im_ini ("BUILD")			; hello little world
	if cnt ge 2 && st_sam (vec[1], "/?")	;
	.. fail cu_hlp ()			;
	cu_env (env)				; fill in environment
	cu_arg (env, cnt, vec, env->Aspc)	; get the switchs etc
	cu_prj (env)				; get the project
	cu_sec (env, env->Acus) if env->Acus[0]	; custom build file
	cu_sec (env, env->Aset)			; get project setup data
	cu_pla (env)				; setup platform
	cx_all (env) if env->Qall || env->Qmak	; wants the lot
	cu_bld (env, env->Aspc) otherwise	; build one thing
	im_exi ()
 end

  func	cu_hlp
  is	PUT("BUILD - Compiler Front-End - (c) HAMMONDsoftware 1996\n")
	PUT("\n")
	PUT("build/qualifiers dir:file.typ\n")
	PUT("\n")
	PUT("where:\n")
	PUT("\n")
	PUT("file.c\n")
	PUT("   Is the name of a C source file.\n")
	PUT("src:\n")
	PUT("   Is the name of the source directory\n")
	PUT("   Default is current directory\n")
	PUT("bin:\n")
	PUT("   Is the name of the binary directory\n")
	PUT("   The default is really wierd\n")
	PUT("\n")
  end

code	cu_put - put some text

  func	cu_put
	env : * cuTenv
	str : * char
  is	st_cop (str, env->Pbuf)
	env->Pbuf = that
  end

code	cu_rew - rewind the buffer

  func	cu_rew
	env : * cuTenv
  is	env->Pbuf = env->Abuf
	*env->Pbuf = 0
  end

code	cu_spc - write spec to command 

  func	cu_spc
	env : * cuTenv
	dir : * char
	fil : * char
	typ : * char
	buf : * char
  is	spc : [mxSPC] char
	st_cop (dir, spc)
	st_app (fil, spc)
	st_app (typ, spc)
	fi_loc (spc, spc)
	st_cop (spc, buf) if buf
	APP (spc) otherwise
	fine
  end

code	cu_sto - store file from buffer

  func	cu_sto
	env : * cuTenv
	spc : * char
  is	fi_sto (spc, env->Abuf, ~(1), 0, "") 
	im_exi () if fail
	cu_rew (env)
  end

code	cu_rep - report error

  func	cu_rep
	env : * cuTenv
	msg : * char
	obj : * char
  is	im_rep (msg, obj)
	cu_exi (env) if *msg eq 'E'
  end

code	cu_exi - exit 

  func	cu_exi
	env : * cuTenv
  is	im_exi ()
  end
code	cu_env - setup environment

  func	cu_env
	env : * cuTenv
  is	env->Pcol = me_acc (#cuTcol)		; get a collection
	env->Qrid = 1				; default is "rider=on"
	env->Qcmp = quSYM			; assume symantec compiler
	cu_rew (env)				; rewind buffer
						;
	fi_loc ("bin:rider.exe", env->Arid)	; Rider translator
	fi_loc ("bin:macho.exe", env->Amac)	; Macho translator

;	fi_loc ("bin:masm.exe", env->Amsm)	; MASM assembler
;	fi_loc ("sc:\\bin\\sc.exe", env->Acee)	; C compiler
;	fi_loc ("sc:\\bin\\link.exe", env->Alnk);
;	fi_loc ("bin:lib.exe", env->Alib)	;
						;
	fi_loc ("skr:build.bat", env->Abld)	;
	fi_loc ("skr:build.opt", env->Aopt)	;
	fi_loc ("skr:build.log", env->Alog)	;
	fi_loc ("skr:build.res", env->Ares)	;
;	st_cop ("c:\\windows\\command.com/e:32768", env->Acmd) ; the command shell
	st_cop ("c:\\windows\\system32\\cmd.exe", env->Acmd) ; the command shell
	st_cop ("\\nul", env->Anul)		;
	++env->Qlea
  end
code	cu_prj - get the project directory

  func	cu_prj
	env : * cuTenv
  is	pth : [mxSPC] char
	prj : [mxSPC] char
	bin : [mxSPC] char
	cus : [mxSPC] char
	cnt : int = 1

	fs_def (env->Aspc, "", env->Aspc)	; fill it out 
	fs_dev (env->Aspc, env->Adev)		; the directory
	fs_dir (env->Aspc, env->Adir)		; the directory
	fs_nam (env->Aspc, env->Afil)		; the module
	fs_typ (env->Aspc, env->Atyp)		; the controlling type

;	if !env->Adev[0]			; default device
;	.. dr_sho (env->Adev, drDRV)		;
;	if !env->Adir[0]			; default directory
;	.. dr_sho (env->Adir, drDIR)		;
						;
	fs_ass (fsDEV_|fsDIR_, env->Aspc, pth)

;	st_cop (env->Adev, pth)			; initial path
;	st_app (env->Adir, pth)			;
						;
	st_cop (pth, env->Asrc)			;
	st_cop (pth, env->Aprj)			;
	if env->Afil[0]				; got a file
	   ++env->Qfil				; remember that
	   st_cop (pth, cus)			;
	   st_app (env->Afil, cus)		;
	   st_app (".bld", cus)			;
	   if fi_exs (cus, <>)			;
	.. .. st_cop (cus, env->Acus)		; has custom

	st_cop (env->Asrc, env->Aset)		; setup spec
	st_app ("setup.bld", env->Aset)		; 
	fine
  end

  func	cu_bin
	env : * cuTenv
  is	pth : [mxSPC] char
	prj : [mxSPC] char
	bin : [mxSPC] char
	eqv : [mxSPC] char
	cnt : int = 1

;	If we can deduce a binary directory, then use that

     repeat
	ln_rev (pth, prj, cnt)			; try again
	cu_rep (env, "E-Undefined project [%s]", pth) if fail
	if st_len (prj) eq 3			; length good
	&& prj[2] eq 's'			; end's well
	   st_cop (prj, bin)			; get a binary file
	   bin[2] = 'b'				; change from xxS to xxB
	   ln_trn (bin, eqv, 0)			; translate it
	   quit if fine				; got it
	.. cu_rep (env, "W-Undefined project binary [%s:]", bin)
	++cnt					; look for another
     forever
	st_app (":", prj)			; add colon
	st_app (":", bin)			; add colon
	st_cop (prj, env->Aprj)			; the project directory
	st_cop (prj, env->Asrc)			; the source directory
	st_cop (bin, env->Abin)			; binary directory
						; cu_sec() might change bin:
  end
code	cu_pla - setup the platform

;	Called after all input, but before builds
;	Handles debug switchs etc
;
;	sc.exe crashs if options are not space-separated
;
; win	"-A -c -r -a1 -mn -p -o+all -3 ",env->Acsw); C
; dos	"-A -c -r -a1 -ml -p -o+all -3 -R", env->Acsw)  ; C 

  func	cu_pla
	env : * cuTenv
  is	csw : * char = env->Acsw
	st_cop (env->Abin, env->Ahdr) if !env->Ahdr[0]
						;
	env->Vdos = 1 if env->Qpla eq quDOS	;
	env->Vwin = 1 otherwise			; default
						;
	if !env->Qmod				;
	   env->Qmod = quCON if env->Vdos	; dos => console
	.. env->Qmod = quGRA otherwise		; win => graphic
						;
	if env->Qmod eq quGRA			;
	   env->Vgra = 1 if !env->Vdos		;
	elif env->Qmod eq quCON			;
	.. env->Vcon = 1			;
						;
	fi_loc ("bin:masm.exe", env->Amsm)	; MASM assembler
	st_cop ("/Ml /n /t", env->Amsw)		; masm switchs
						;
	if env->Qcmp eq quSYM			; symantec compiler
	   fi_loc ("scb:sc.exe", env->Acee)	; C compiler
	   fi_loc ("scb:link.exe", env->Alnk)	;
	   fi_loc ("scb:lib.exe", env->Alib)	;
	   st_cop ("", env->Acsf)
	   st_cop ("-o", env->Acof)
	   st_cop ("", env->Acpr)		; compiler prelude
	   st_cop ("-c -a1 -o+all -3", csw)	; C
	   st_app (" -mn", csw) if env->Vwin	; native
	   st_app (" -ml -R", csw) otherwise 	; large
	   st_app (" -g", csw) if env->Qdbg	; debug
	   st_app (" -I f:\\m\\sc\\include", csw)
	   st_app (" -w", csw) if env->Qigw	; ignore warnings
	   if !env->Vdos			;
	   .. st_app (" -A", csw) if env->Qans	; ansii
	   st_app (" -p -r", csw) if !env->Qaut	; autoprototype off
	   					; implies strict prototyping
	   st_cop ("/noi/nowarnd/line",env->Alks)	; link
	   st_app ("/debug/co", env->Alks) if env->Qdbg
	   st_app ("/x", env->Alks) if env->Qcrf
	   st_app ("/det", env->Alks) if env->Qful
	else
	   st_cop ("/c /nologo", csw)		; suppress linking
	   st_cop ("/Tc", env->Acsf)		;
	   st_cop ("/Fo", env->Acof)		;
	   fi_loc ("vcb:vcvars32.bat",env->Acpr); compiler prelude
	   fi_loc ("vcb:cl.exe", env->Acee)	; C compiler
	   fi_loc ("vcb:link.exe", env->Alnk)	;
	   fi_loc ("vcb:lib.exe", env->Alib)	;
	end
;	fine if env->Vdos			; dos application
  end

code	cu_int - build link interface

  func	cu_int
	env : * cuTenv
  is	reply cu_dos (env) if env->Vdos
	reply cu_con (env) if env->Vcon
	reply cu_gra (env)
  end

  func	cu_dos
	env : * cuTenv
  is	col : * cuTcol = env->Pcol
	cu_add (env, "lib:riddos.lib", &col->Plib, cuLOC_)
	cu_add (env, "lib:dslib.lib", &col->Plib, cuLOC_)
	cu_add (env, "lib:culib.lib", &col->Plib, cuLOC_)
	fine
  end

  func	cu_con
	env : * cuTenv
  is 	cu_win (env, "CONSOLE")
  end

  func	cu_gra
	env : * cuTenv
  is 	cu_win (env, "WINDOWS")
  end

	APF(p,q) := FMT(buf,p,q), APP(buf)

  func	cu_win
	env : * cuTenv
	mod : * char
  is	col : * cuTcol = env->Pcol
     if env->Qcmp eq quSYM			; symantec compiler
	cu_add (env, "scl:ridwin.lib", &col->Plib, cuLOC_) if env->Qrid
	cu_add (env, "scl:gdi32.lib", &col->Plib, cuLOC_)
	cu_add (env, "scl:kernel32.lib", &col->Plib, cuLOC_)
	cu_add (env, "scl:user32.lib", &col->Plib, cuLOC_)
	cu_add (env, "scl:comdlg32.lib", &col->Plib, cuLOC_)
	cu_add (env, "scl:winmm.lib", &col->Plib, cuLOC_)
	cu_add (env, "scl:shell32.lib", &col->Plib, cuLOC_)
	cu_add (env, "scl:advapi32.lib", &col->Plib, cuLOC_)
	cu_add (env, "scl:win32spl.lib", &col->Plib, cuLOC_)
	cu_add (env, "scl:version.lib", &col->Plib, cuLOC_)
	cu_add (env, "scl:wsock32.lib", &col->Plib, cuLOC_)

	cu_add (env, "lib:k32lib.lib", &col->Plib, cuLOC_)
	cu_add (env, "scl:snn.lib", &col->Plib, cuLOC_)
     else
	cu_add (env, "vcl:ridwin.lib", &col->Plib, cuLOC_) if env->Qrid
	cu_add (env, "vcl:gdi32.lib", &col->Plib, cuLOC_)
	cu_add (env, "vcl:kernel32.lib", &col->Plib, cuLOC_)
	cu_add (env, "vcl:user32.lib", &col->Plib, cuLOC_)
	cu_add (env, "vcl:comdlg32.lib", &col->Plib, cuLOC_)
	cu_add (env, "vcl:winmm.lib", &col->Plib, cuLOC_)
	cu_add (env, "vcl:shell32.lib", &col->Plib, cuLOC_)
	cu_add (env, "vcl:advapi32.lib", &col->Plib, cuLOC_)
	cu_add (env, "vcl:win32spl.lib", &col->Plib, cuLOC_)
	cu_add (env, "vcl:version.lib", &col->Plib, cuLOC_)
	cu_add (env, "vcl:wsock32.lib", &col->Plib, cuLOC_)
     end
	cu_res (env, mod)
	fine
  end

  func	cu_res
	env : * cuTenv
	mod : * char
  is	buf : [mxSPC] char
	nam : [mxSPC] char
	col : * cuTcol = env->Pcol
	fs_nam (env->Argt, nam)
	st_upr (nam)
	cu_rew (env)
	fine if col->Pres		; has own
	   APF("NAME		%s\n", nam)
	   APF("DESCRIPTION	\"%s\"\n", nam)
	if env->Qcmp eq quSYM
	   APP("EXETYPE		NT\n")
	.. APF("SUBSYSTEM	%s\n", mod)
	   APP("CODE		EXECUTE\n")
	   APP("DATA		WRITE\n")
	cu_sto (env, env->Ares)		; store resource file
	cu_add (env, env->Ares, &col->Pres, cuLOC_)
	fine
  end
code	cx_all - do all modules

;	Also runs for MAKE operations

	cu_seq	: (*cuTenv, *cuTlin) int
  func	cx_all
	env : * cuTenv
  is	sec : ** cuTlin
	nod : ** cuTlin
	lin : * cuTlin
	col : * cuTcol = env->Pcol
	idx : int
	if !col->Psrc 			; no objects
	..  cu_rep (env, "W-No sources to build", <>)
	cu_seq (env, col->Phea)
	cu_seq (env, col->Psrc)
	if !col->Pobj
	.. cu_rep (env, "E-No objects to build", <>)
	fine if env->Qbld eq quCUS 	; cusp will be built anyway
	if col->Pimg
	&& col->Pimg->Pstr
	&& st_fnd (".lib", col->Pimg->Pstr)
	   cu_bld (env, ".lib")		; do library
	else				;
	.. cu_bld (env, ".exe")		; do executable
  end

  func	cu_seq
	env : * cuTenv
	lin : * cuTlin
  is	while lin			;
	   cu_bld (env, lin->Pstr)	; go build it
	   lin = lin->Psuc		;
	end				;
  end
code	cu_bld - build something

;	Name and type only may be refined 

  func	cu_bld
	env : * cuTenv
	spc : * char
  is
	fs_nam (spc, env->Afil)			; the module
	fs_typ (spc, env->Atyp)			; the controlling type
	env->Vtyp = cu_typ (env, env->Aspc)	; get the type
	(*(env->Pdis->Pfun))(env)		; dispatch by type
	if env->Qbld eq quCUS			; wants cusp
	&& !st_sam ("exe", env->Atyp)		;
	.. cx_lnk (env)				;
  end

code	cu_typ - translate file type

  func	cu_typ
	env : * cuTenv
	spc : * char
  is	idx : int = 0
	if !env->Atyp[0]		; no type yet
	&& !cu_sea (env, spc)		; and search found none
	   if env->Qbld eq quEXE	; wants an executable
	      st_cop ("exe", env->Atyp)	;
	   elif env->Qbld eq quLIB	; wants a library
	.. .. st_cop ("lib", env->Atyp)	;
	if !env->Atyp[0]		; still got nothing?
	.. cu_rep (env, "E-Source type not located [%s]", spc)
     repeat				;
	if idx ge cuMAX			; not found
	.. cu_rep (env, "E-Invalid file type [%s]", env->Atyp)
	quit if st_sam (cuAtyp[idx].Ptyp, env->Atyp)
	++idx				;
     end				;
	env->Pdis = cuAtyp + idx	;
	reply idx			;
  end

code	cu_sea - search for a source file

  init	cuAsea : [] * char
  is	"r", "m", "c", "asm"
	<>
  end

  func	cu_sea
	env : * cuTenv
	spc : * char
  is	tmp : [mxSPC] char
	typ : ** char = cuAsea
	while *typ
	   st_cop (spc, tmp)
	   st_app (".", tmp)
	   st_app (*typ, tmp)
	   if fi_exs (tmp, <>)
	      st_cop (*typ, env->Atyp)
	   .. fine
	   ++typ
	end
	fail
  end

code	cu_del - delete a temporary file

  func	cu_del
	env : * cuTenv
	spc : * char
  is	fine if env->Qlea		; leave temp files
	PUT("Delete [%s]\n", spc) if env->Qdet
	fine if env->Qpas		; be paranoid about passive
	if fi_exs (spc, <>)		; have the file
	.. fi_del (spc, "")		; try to delete it
	fine
  end

code	cu_dst - distribute file

;	Multiple targets can be set
;
;	.h=rid:
;	.exe=bin:
;	.lib=lib:
;	.dll=...

  func	cu_dst
	env : * cuTenv
	spc : * char			; file to distribute
  is	lft : [mxLIN] char
	rgt : [mxLIN] char
	typ : [mxSPC] char
	nxt : * cuTlin = env->Pcol->Pdst; distribution list
	ptr : * char
	fine if !env->Qdst		; not asked to distribute
	st_cop (".", typ)		; want ".typ"
	fs_typ (spc, typ+1)		; get the file type
     while nxt				; got more
	if st_fnd (typ, nxt->Pstr) eq nxt->Pstr
	   ptr = st_fnd ("=", nxt->Pstr) + 1
	   st_cop (ptr, rgt)		; target
	   fs_nam (spc, that)		; add the name
	   st_cop (typ, that)		;
	   if env->Qver			; say what we are doing
	   .. cu_rep (env, "I-Distribute [%s]", rgt)
	   if !env->Qpas		; not passive
	      fi_cop (spc, rgt, "", 0)	; copy it
	.. .. im_rep ("E-Can't distribute to [%s]", rgt) if fail
	nxt = nxt->Psuc
     forever
  end
code	cx_d - produce rider header

  func	cx_d
	env : * cuTenv
  is	OPR("Header")
	SRCLFT(".d")
	SPC
	HDRRGTTGT(".h")
	fine if !cu_mak (env, cuVER)		; all done
	cu_rid (env)
	cu_dst (env, env->Argt)
  end

code	cx_r - produce rider command

  func	cx_r
	env : * cuTenv
  is	tmp : [mxSPC] char
	OPR("Rider")
	SRCLFT(".r")
	SPC
	BINRGT(".rx")
	TGT(".obj")
	fine if !cu_mak (env, cuVER)	; all done
	st_cop (env->Argt, tmp)
	cu_rid (env)
	if env->Qbld ne quRID
	   cx_rx (env)
	.. cu_del (env, tmp)
  end

code	cx_rx - run rider output through C

  func	cx_rx
	env : * cuTenv
  is	OPR("Rider")

	st_cop (env->Afil, env->Asup)	; hack for VCC
	st_app (".rx", env->Asup)	; which echoes files processed

	APP(env->Acsw)
	SPC
	APP(env->Acof)
	BIN(".obj")	; (".obj")
	RGT(".obj")
	TGT(".obj")
	SPC
	APP(env->Acsf)
	BINLFT (".rx")
	cu_cee (env)
  end

code	cx_c - compile an actual factual C file

  func	cx_c
	env : * cuTenv
  is	OPR("C")

	st_cop (env->Afil, env->Asup)	; hack for VCC
	st_app (".c", env->Asup)	; which echoes files processed

	APP(env->Acsw)
	SPC
	APP(env->Acof)
;	APP("-o")
	BINRGTTGT (".obj")
	SPC
	APP(env->Acsf)
	SRCLFT(".c")
	fine if !cu_mak (env, cuVER)
	cu_cee (env)
  end

code	cx_cpp - compile an actual factual C file

  func	cx_cpp
	env : * cuTenv
  is	OPR("C")
	APP(env->Acsw)
	SPC
	APP(env->Acof)
;	APP("-o")
	BINRGTTGT (".obj")
	SPC
	SRCLFT(".cpp")
	fine if !cu_mak (env, cuVER)
	cu_cee (env)
  end

code	cx_m - compile macho file

  func	cx_m
	env : * cuTenv
  is	tmp : [mxSPC] char
	OPR("Macho")
	SRCLFT(".m")
	SPC
	BINRGT(".mx")
	st_cop (env->Argt, tmp)
	TGT(".obj")
	fine if !cu_mak (env, cuVER)
	cu_mac (env)
	if env->Qbld ne quMAC
	   cx_mx (env)
	.. cu_del (env, tmp)
  end

;	And run it through masm

  func	cx_mx
	env : * cuTenv
  is	OPR("Masm")
	BINLFT(".mm")
	SPC
	BINRGTTGT(".obj")
	SPC
	APP(env->Amsw)
	APP(";")
	cu_msm (env)
  end

code	cx_asm - compile a real masm file

  func	cx_asm
	env : * cuTenv
  is	OPR("Masm")
	SRCLFT(".asm")
	SPC
	BINRGTTGT(".obj")
	SPC
	APP(env->Amsw)
	APP(";")
	fine if !cu_mak (env, cuVER)
	cu_msm (env)
  end
code	cx_lnk - build executable

;	skr:build.bat	the batch file
;	skr:link.opt	the options file

  func	cx_lnk
	env : * cuTenv
  is	sec : ** cuTlin
	nod : ** cuTlin
	lin : * cuTlin
	col : * cuTcol = env->Pcol
	idx : int
	mak : int = 0
	ren : [mxSPC] char
	tmp : [mxSPC] char
	OPR("Link")

	if !col->Pobj			; no objects
	   cu_rep (env, "E-No objects to link", <>)
	elif !col->Pimg->Pstr		;
	.. cu_rep (env, "E-No image for link", <>)
	COPRGTTGT(col->Pimg->Pstr)	; right hand/target
	cu_int (env)			; setup console/graphic things

	lin = col->Pobj			; object files
	while lin
	   COPLFT(lin->Pstr)		; get left hand
	   mak |= cu_mak (env, cuINT)	; check for make
	   fi_loc (lin->Pstr, tmp)
	   APP(tmp)
	   if env->Qcmp eq quSYM	; symantec
	   .. APP ("+") if lin->Psuc
	   NEW
	   lin = lin->Psuc
	end

	if !env->Qpas			; not passive
	&& fi_exs (env->Argt, <>)	; and file exists
	&& !fi_ren (env->Argt, env->Argt, <>) ; and can't rename it
	   st_cop ("_", ren)		; rename CUSP to _CUSP
	   fs_nam (env->Argt, ren+1)	; get name
	   fs_set (fsNAM, env->Argt, ren, env->Argt)
	.. cu_rep (env, "W-Locked target renamed to [%s]", env->Argt)

	fi_loc (env->Argt, tmp) if col->Pimg ; localize
	if env->Qcmp eq quSYM
	   if col->Pimg			; got image
	      APP(tmp)			; image
	   else
	   .. APP(env->Anul)
	   NEW
	else
	   if col->Pimg
	      APP("/out:")
	      APP(tmp)
	.. .. NEW

	fi_loc (col->Pmap->Pstr, tmp) if col->Pmap
	if env->Qcmp eq quSYM
	   APP(tmp) if col->Pmap	
	   APP(env->Anul) otherwise	;
	   NEW
	else
	   if col->Pmap
	      APP("/map:")
	      APP(tmp)
	.. .. NEW

	lin = col->Plib			; libraries
	while lin
	   COPLFT(lin->Pstr)		; source
	   mak |= cu_mak (env, cuINT)	; check make
	   APP(lin->Pstr)
	   if env->Qcmp eq quSYM	; symantec
	   .. APP ("+") if lin->Psuc
	   NEW
	   lin = lin->Psuc
	end

	if !env->Vdos			; not dos
	   if env->Qcmp eq quSYM	; symantec compiler
	   && col->Pres			; got resource file
	      COPLFT(col->Pres->Pstr)	; check make
	      mak |= cu_mak (env, cuINT);
	      APP("/def:") if env->Qcmp eq quVCC
	   .. APP(col->Pres->Pstr)	; resource
	   if env->Qcmp eq quVCC	;
	      NEW
	      APP("/subsystem:console") if env->Qmod eq quCON
	      APP("/subsystem:windows") otherwise
	      NEW
	      APP("/incremental:no")
	      NEW
	   .. APP("/nologo")
	.. NEW

	if !env->Qimg			; not forcing image
	&& env->Qmak && !mak		; and make failed
	.. fine				; nothing to build

	cu_sto (env, env->Aopt)		; store options file

;	Construct the command line

	APP(env->Alks)			; link switchs
	SPC				;
	APP("@")			;
	APP(env->Aopt)			; options file
	cu_ver (env, env->Argt)		; report it
	cu_lnk (env)			; link and filter
	cu_dst (env, col->Pimg->Pstr)	; distribute it
  end
code	cx_lib - build library

;	skr:build.bat	the batch file
;	skr:link.opt	the options file

  func	cu_loc
	ptr : * void
	spc : * char
  is	exit if !ptr
	fi_loc (spc, spc)
  end

  func	cx_lib
	env : * cuTenv
  is	sec : ** cuTlin
	nod : ** cuTlin
	lin : * cuTlin
	col : * cuTcol = env->Pcol
	img : * cuTlin = col->Pimg
	idx : int
	mak : int = 0
	sym : int = env->Qcmp eq quSYM	; symantec environment
	OPR("Library")
	if !col->Pobj			; no objects
	   cu_rep (env, "E-No objects for library", <>)
	elif !img->Pstr
	.. cu_rep (env, "E-No image for library", <>)

	cu_loc (col->Pimg, col->Pimg->Pstr)
	cu_loc (col->Plst, col->Pimg->Pstr)

	COPRGTTGT(col->Pimg->Pstr)	; for make
	if sym
	   APP(img->Pstr) if col->Pimg 	; image
	   APP(env->Anul) otherwise	;
	   NEW
	   APP("Y")			; "YES"
	   NEW
	else
	   if col->Pimg
	      APP("/out:")
	      APP(img->Pstr)
	.. .. NEW

	lin = col->Pobj			; object files
	while lin
	   COPLFT(lin->Pstr)		;
	   mak |= cu_mak (env, cuINT) ;if !mak	;
	   if sym
	      APP("+")
	      cu_loc (lin->Pstr, lin->Pstr)

	      APP(lin->Pstr)
	      APP("&") if lin->Psuc
	      APP(";") if !lin->Psuc && !col->Plst
	   else
	   .. APP(lin->Pstr)
	   NEW
	   lin = lin->Psuc
	end
	if col->Plst			; wants a listing
	   if sym
	      APP(col->Plst->Pstr)	; listing
	      APP (";")			;
	      NEW
	   else				; VCC
;	      APP("/list:")		; can't be combined!!!
;	      APP(col->Plst->Pstr)
;	   .. NEW
	   end
	end

	if !env->Qimg			; not forcing image
	&& env->Qmak && !mak		; and make failed
	.. fine				; nothing to build
	cu_sto (env, env->Aopt)		; store options file

;	First, delete any existing library

	if !env->Qpas 			; not passive
	&& fi_exs (img->Pstr, <>)	; got a file
	   if !fi_del (img->Pstr, "")	;
	.. .. im_rep ("Failed to delete existing library [%s]", img->Pstr)

;	Construct the command line

	APP(env->Albs)			; librarian switchs
	SPC				;
	APP("@")			;
	APP(env->Aopt)			; options file
	cu_ver (env, env->Argt)		; report it
	cu_lib (env)			; library and filter
	cu_dst (env, col->Pimg->Pstr)	; distribute it
  end
code	cu_mak - check make

;	Make also does some sanity checks
;	If the left hand file does not exist...
;	Handles verify

  func	cu_mak
	env : * cuTenv
	ver : int
  is	lft : tiTval = {0}
	rgt : tiTval = {0}
	tgt : tiTval = {0}
	typ : [mxSPC] char
	mat : * char = <>
	fs_typ (env->Alft, typ)
	case env->Qbld
	of quHEA mat = "d"
	of quCEE mat = "c"
	of quRID mat = "r"
	of quMAC mat = "m"
	of quMSM mat = "msm"
	end case
	fail if mat && !st_sam (mat, typ)

	if !fi_exs (env->Alft, <>)
	   cu_rep (env, "E-Source missing [%s]", env->Alft) if !env->Qpas
	   cu_rep (env, "W-Source missing [%s]", env->Alft) otherwise
	.. fail
	fail if st_fnd ("build.res", env->Alft) ; ignore automatic files

	if !env->Qmak			; not doing make
	   cu_ver (env, env->Alft) if ver ; check verify
	.. fine

	if !fi_gtm (env->Alft, &lft, <>); left file is missing
	   PUT("Missing left [%s]\n", env->Alft) if env->Qdet
	.. fail				; can't build that anyway
	if !fi_gtm (env->Atgt, &tgt, <>); target file is missing
	   PUT("Make new [%s] to [%s]\n", env->Alft, env->Atgt) if env->Qver
	.. fine				; build it
	if ti_cmp (&lft, &tgt) gt	; left is greater than right
	   if env->Qver			; want detailed info
	   .. PUT("Make [%s] to [%s]\n", env->Alft, env->Atgt)
	   fine				; build
	else				;
	   if env->Qdet			; want detailed info
	   .. PUT("Same [%s] as [%s]\n", env->Alft, env->Atgt)
	.. fail				; don't build it
  end

code	cu_ver - verify operation

  func	cu_ver
	env : * cuTenv
	spc : * char
  is	fine if !env->Qver
	fine cu_rep (env, "I-Build [%s]", spc)
  end
code	cu_exe - execute command

  func	cu_exe
	env : * cuTenv
	img : * char
	flt : * (*cuTenv) int
  is	sts : int 

	cu_cmd (env, img, env->Abuf)
	cu_rew (env)

	fine if env->Qpas		; passive
	env->Plog = fi_opn (env->Alog, "r", "")
	cu_exi (env) if fail

	env->Pflt = stdout
	sts = (*flt)(env)
	fi_clo (env->Plog, <>)

	cu_exi (env) if !sts
;	cu_exi (env) if sts
	reply sts
  end
code	cu_cmd - issue command

  func	cu_cmd
	env : * cuTenv
	img : * char
	par : * char
  is	cmd : [mxLIN*3] char
	sts : int = 1
	st_cop ("", cmd)
	st_app ("echo on\r\n", cmd) if env->Qdet
	st_app ("echo off\r\n", cmd) otherwise
	if env->Acpr[0]
	   st_app ("call ", cmd)
	   st_app (env->Acpr, cmd)
	   st_app ("\r\n", cmd)
	   if env->Qcmp eq quVCC
	   && env->Pcol->Ppth
	      st_app ("SET INCLUDE=", cmd)
	      st_app (env->Pcol->Ppth->Pstr, cmd)
	.. .. st_app (";%INCLUDE%\r\n", cmd)

	st_app (img, cmd)
	st_app (" ", cmd)
	st_app (par, cmd)
	st_app ("\r\n", cmd)
	fi_sto (env->Abld, cmd, (~0), 0, "")	; info only
	st_cop (env->Acmd, cmd)
	st_app (" /c ", cmd)
	st_app (env->Abld, cmd)
	st_app (" > ", cmd)
	st_app (env->Alog, cmd)
	st_app ("\n", cmd)
	PUT("[%s %s]\n", img, par) if env->Qdet
	PUT("cmd=[%s]\n",cmd) if env->Qdet
	fine if env->Qpas

	sts = pr_cmd (cmd)
	PUT("sts=%d\n",cmd) if env->Qdet

	reply sts
  end
code	cf_lnk - filter linker output

	lkMAX	:= (mxLIN * 4)

  init	cfAlnk	: [] * char
  is	"Setting environment"
	"Microsoft (R)"
	"OPTLINK (R)"
	"Copyright (C)"
	"Object Modules ["
	"Run File ["
	"List File ["
	"Libraries ["
	"LINK : warning L4021:"
	"Temporary file"
	" pos: "
	<>
  end
	cfAter	: "terminated by user"
	cfAerr	: " : error "

  func	cf_lnk
	env : * cuTenv
  is	ipt : * FILE = env->Plog	; the input line
	opt : * FILE = env->Pflt	; filtered output
	lin : [lkMAX] char		;
	jnk : ** char			;
	ptr : * char			;
	res : int = 1			; assume ok
     repeat				;
	fi_get (ipt, lin, lkMAX)	; get another
	quit if eof			;
	next PUT("LINK: %s\n", lin) if env->Qdet
	next if *lin eq			; null lines go
	next if st_sam (lin, env->Alft)	; hack for MS Link
	next if st_fnd ("echo off", lin)
	next if st_fnd ("echo on", lin)
	next if st_fnd ("OMF to COFF", lin)
	jnk = cfAlnk			; junk food
	while *jnk ne			; more guk
	   quit if st_scn (*jnk, lin)	; same food
	   ++jnk			; you are 
	end				; what you eat
	next if *jnk ne			; matched something
	quit if st_fnd (cfAter, lin)	; terminated by user
If 0
;	Microsoft linker only
	if (ptr = st_fnd (cfAerr, lin)) ne ; got [ : error A1234 : ]
	&& ct_upr (ptr[9])		; check error number
	&& ct_dig (ptr[10])		;
	&& ct_dig (ptr[13])		;
	&& st_scn (": ", ptr+14)	;
	.. st_cop (ptr+15, ptr)		;
End					;
	fi_put (opt, lin)		; write it
	res = 0				; remember fail
     end				;
	fine if res || env->Qign	; ignore errors
	im_err ()			; it was an error
	reply res			;
  end
code	cf_lib - library filter

  init	cfAlib	: [] * char
  is	"Digital Mars Librarian Version"
	"Digital Mars Librarian complete."
	"action-object"
	"library file"
	"create new library"
	"Setting environment"
	"Microsoft (R)"
	"Copyright (C)"
	"Library does not exist"
	"Library name:"
	"List file:"
	"Operations:"
;;;	" redefinition ignored"
	<>
  end

  func	cf_lib
	env : * cuTenv
  is	ipt : * FILE = env->Plog	; the input line
	opt : * FILE = env->Pflt	; filtered output
	lin : [lkMAX] char		;
	jnk : ** char			;
	ptr : * char			;
	res : int = 1			; assume ok
     repeat				;
	fi_get (ipt, lin, lkMAX)	; get another
	quit if eof			;
	PUT("LIBR: %s\n", lin) if env->Qdet
	next if *lin eq			; null lines go
	next if st_fnd ("echo off", lin)
	next if st_fnd ("echo on", lin)
	next if st_fnd ("OMF to COFF", lin)
	jnk = cfAlib			;
	while *jnk ne			; more guk
	  if **jnk eq ' '		;
	     quit if st_fnd (*jnk, lin)	; same food
	  else				;
	  .. quit if st_scn (*jnk, lin)	; same food
	   ++jnk			; you are 
	end				; what you eat
	next if *jnk ne			; matched something
	fi_put (opt, lin)		; write it
	res = 0				; remember fail
     end				;
	fine if res || env->Qign	; ignore errors
	im_err ()			; it was an error
	reply res			;
  end
code	cf_msm - masm filter

  func	cf_msm
	env : * cuTenv
  is	ipt : * FILE = env->Plog	; the input line
	opt : * FILE = env->Pflt	; filtered output
	fst : [lkMAX] char		; previous line
	snd : [lkMAX] char		;
	lin : * char = fst
	prv : * char = snd
	tmp : * char
	res : int = 1			; assume ok
	*lin = *prv = 0			; starts clean
     repeat				;
	tmp=prv, prv=lin, lin=tmp	; switch lines
	fi_get (ipt, lin, cuMAX)	; get another
	quit if eof			;
	if st_fnd ("): error",lin)	; error
	|| st_fnd ("): warni",lin)	; warning
	   if *prv ne			; got previous line
	      fi_put (opt, prv)		; write it
	   .. *prv = 0			; once only
	   fi_put (opt, lin)		; write it
	   *lin = 0			; once only
	.. res = 0			; it was an error
     end				;
	fine if res || env->Qign	; ignore errors
	im_err ()			; it was an error
	reply res			;
  end
code	cf_gen - generic filter

  func	cf_gen
	env : * cuTenv
  is	ipt : * FILE = env->Plog	; the input line
	opt : * FILE = env->Pflt	; filtered output
	lin : [lkMAX] char		;
	res : int = 1			; assume ok
     repeat				;
	fi_get (ipt, lin, lkMAX)	; get another
	quit if eof			;
	next if *lin eq			; null lines go
	PUT("MORE: %s\n", lin) if env->Qdet
	next if st_sam (lin, env->Asup)	; hack for VCC
	if st_fnd (" : warning", lin)	;
	|| st_fnd (" : Warning", lin)	;
	   next if env->Qigw		; ignore warnings
	.. next fi_put (opt, lin)	; write it
	next if st_fnd ("echo on", lin)
	next if st_fnd ("echo off", lin)
	next if st_fnd ("Microsoft (R)", lin)
	next if st_fnd ("Copyright (C)", lin)
	next if st_scn ("Setting environment", lin)
	next if st_scn ("%RIDER-I-",lin); info message
	next if st_scn ("%RIDER-W-",lin);
	next if st_scn ("%MACHO-I-",lin);
	next if st_scn ("%MACHO-W-",lin);
	fi_put (opt, lin)		; write it
	res = 0				; remember fail
     end				;
	env->Asup[0] = 0		; a bit iffy
	fine if res || env->Qign	; ignore errors
	im_err ()			; it was an error
	reply res			;
  end

  func	cf_cee
	env : * cuTenv
  is	ipt : * FILE = env->Plog	; the input line
	cf_gen (env)			; generic
	fine
  end
code	cu_sec - read a section file

	cu_lst	: (**cuTlin) **cuTlin
;	cuLOC_	:= BIT(0)		; localize
;	cuMOD_	:= BIT(1)		; module distribution
;	cuBIN_	:= BIT(2)		; bin default
;	cuSRC_	:= BIT(3)		; src default
;	cuPLA_	:= BIT(4)		; platform section
;	cuEQU_	:= BIT(5)		; equate section

	cu_get : (*cuTenv, *FILE, *char) int
  func	cu_sec
	env : * cuTenv
	spc : * char
  is	col : * cuTcol = env->Pcol
	sec : **cuTlin = <>
	buf : [512] char
	def : [mxSPC] char
	ipt : * FILE = fi_opn (spc, "r","")
	idx : int
	flg : int = 0

	req : int = env->Qpla		; required platform
	cur : int = 0			; current platform
	def[0] = 0			; no default
	env->Asec[0] = 0		; no hanging sections
					;
	cu_exi (env) if !ipt		; no input file
	fine if col->Vini		; already initialized

     while cu_get (env, ipt, buf)	;

	if st_sam (buf, "[modules]")
	   sec = &col->Pmod, flg = cuMOD_
	   st_cop (".r", def)
	elif st_sam (buf, "[headers]")
	   sec = &col->Phea, flg=cuSRC_
	   st_cop (".d", def)
	elif st_sam (buf, "[sources]")
	   sec = &col->Psrc, flg=cuSRC_
	   st_cop (".r", def)
	elif st_sam (buf, "[objects]")
	   sec = &col->Pobj, flg=cuBIN_
	   st_cop (".obj", def)
	elif st_sam (buf, "[libraries]")
	   sec = &col->Plib, flg=cuLOC_
	   st_cop (".lib", def)
	elif st_sam (buf, "[image]")
	   sec = &col->Pimg, flg=cuBIN_
	   st_cop (".exe", def)
	elif st_sam (buf, "[listing]")
	   sec = &col->Plst, flg=cuBIN_
	   st_cop ("", def)
	elif st_sam (buf, "[map]")
	   sec = &col->Pmap, flg=cuBIN_
	   st_cop ("", def)
	elif st_sam (buf, "[resources]")
	   sec = &col->Pres, flg=cuSRC_
	   st_cop ("", def)
	elif st_sam (buf, "[include_path]")
	   sec = &col->Ppth, flg=cuLOC_
	   st_cop ("", def)
	elif st_sam (buf, "[distribution]")
	   sec = &col->Pdst, flg=cuEQU_	
	elif st_sam (buf, "[other]")		; other files
	   sec = &col->Poth, flg=cuSRC_
	   st_cop ("", def)

	elif st_sam (buf, "[platform]")		; platform
	   sec = &col->Ppla, flg=0		;
	elif st_sam (buf, "[dos]")		; dos
	   cur = quDOS				;
	elif st_sam (buf, "[windows]")		; windows
	   cur = quWIN				;
	elif st_sam (buf, "[common]")		; common
	   cur = 0
	elif *buf eq '['
	   cu_rep (env, "E-Invalid section name [%s]", buf)
	else
	   next if req && cur && req ne cur	; filter remainder
	   if st_sam (buf, "interface=console")
	      env->Qpla = req = quWIN if !req
	      env->Qmod = quCON if !env->Qmod
	   .. next
	   if st_sam (buf, "interface=graphic")
	      next if env->Qpla eq quDOS
	      env->Qpla = req = quWIN if !req
	      env->Qmod = quGRA if !env->Qmod
	   .. next
	   if st_sam (buf, "platform=windows")
	      env->Qpla = req = quWIN if !req
	   .. next
	   if st_sam (buf, "platform=dos")
	      env->Qpla = req = quDOS if !req
	   .. next

	   if st_sam (buf, "debug=on")
	   .. next env->Qdbg = 1
	   if st_sam (buf, "debug=off")
	   .. next env->Qdbg = 0

	   if st_sam (buf, "rider=on")
	   .. next env->Qrid = 1
	   if st_sam (buf, "rider=off")
	   .. next env->Qrid = 0

	   if st_sam (buf, "compiler=symantec")
	   .. next env->Qcmp = quSYM
	   if st_sam (buf, "compiler=vcc")
	   .. next env->Qcmp = quVCC

	   if st_scn (buf, "options=")
	      next env->Qdbg = 1 if st_fnd ("/debug", buf)
	      next env->Qcrf = 1 if st_fnd ("/cross", buf)
	   .. next env->Qful = 1 if st_fnd ("/full", buf)

	   if st_sam (buf, "cusp=default")
	      env->Qbld = quCUS if !env->Qbld
	   .. next 
	   if st_sam (buf, "library=default")
	      env->Qbld = quLIB if !env->Qbld
	   .. next 

	   if st_scn ("image=", buf)
	   .. next cu_add (env, buf+6, &col->Pimg, cuBIN_)
	   if st_scn ("map=", buf)
	   .. next cu_add (env, buf+4, &col->Pmap, cuBIN_)
	   if st_scn ("binary=", buf)
	   .. next st_cop (buf+7, env->Abin)
	   if st_scn ("headers=", buf)
	   .. next st_cop (buf+8, env->Ahdr)

;	Already retiring

	   if st_sam (buf, "autoprototype=on")
	   .. next env->Qaut = 1
	   if st_sam (buf, "autoprototype=off")
	   .. next env->Qaut = 0
	   if st_sam (buf, "distribution=on")
	   .. next env->Qdst = 1
	   if st_sam (buf, "distribution=off")
	   .. next env->Qdst = 0
	   if st_sam (buf, "ansii=off")
	   .. next env->Qans = 0
	   if st_sam (buf, "ansii=on")		; takes hours to compile
	   .. next env->Qans = 1

	   if flg & cuEQU_			; in equate section
	      if !st_fnd ("=", buf)
	      .. cu_rep (env, "E-Invalid equate line [%s]", buf)
	   else
	      if st_fnd ("=", buf)
	   .. .. cu_rep (env, "E-Invalid control line [%s]", buf)

	   st_rep ("%module%", env->Afil, buf)
	   fi_def (buf, def, buf)
	   cu_mod (env, buf, sec, flg) if flg & cuMOD_
	.. cu_add (env, buf, sec, flg) otherwise
     end

	if env->Qdet
	   PUT("Platform=[%s] ", (env->Qpla eq quWIN) ? "Windows" ?? "Dos")
	   PUT("Source=[%s] ", env->Asrc)
	   PUT("Binary=[%s] ", env->Abin)
	   PUT("Image=[%s] ", (col->Pimg) ? col->Pimg->Pstr ?? "(none)")
	.. PUT("\n")
  end

code	cu_mod - add module

  func	cu_mod
	env : * cuTenv
	spc : * char
	sec : ** cuTlin
	flg : int
  is	col : * cuTcol = env->Pcol
	buf : [mxSPC] char
	lin : * cuTlin
	nod : ** cuTlin
	cu_add (env, spc, &col->Pmod, 0)
	cu_add (env, spc, &col->Psrc, cuSRC_)
	fs_set (fsTYP, spc, ".obj", buf)
	fs_clr (fsDIR, buf, buf)
	fs_clr (fsDEV, buf, buf)
	fi_loc (buf, buf)
	cu_add (env, buf, &col->Pobj, cuBIN_)
  end

code	cu_add - add node

  func	cu_add
	env : * cuTenv
	spc : * char
	sec : ** cuTlin
	flg : int
  is	buf : [mxSPC] char
	lin : * cuTlin
	nod : ** cuTlin
	st_cop (spc, buf)
	if flg & cuSRC_
	   fi_def (buf, env->Asrc, buf)
	elif flg & cuBIN_
	   if !env->Abin[0]
	   .. cu_rep (env, "E-Binary directory not located", <>)
	   fi_def (buf, env->Abin, buf)
	elif flg & cuLOC_
	.. fi_loc (buf, buf)
	lin = me_acc (#cuTlin)
	lin->Pstr = st_dup (buf)
	nod = cu_lst (sec)
	*nod = lin
  end

code	cu_lst - point at last entry

  func	cu_lst
	nod : ** cuTlin
	()  : ** cuTlin
  is	nod = &((*nod)->Psuc) while *nod
	reply nod
  end

code	cu_get - get next line from section file

;	Strip comments (;)
;	Separate sections (,)

  func	cu_get
	env : * cuTenv
	fil : * FILE
	buf : * char
  is	fnd : * char
      repeat
	if env->Asec[0]
	   st_cop (env->Asec, buf)
	   env->Asec[0] = 0
	else
	   fi_get (fil, buf, mxLIN)
	   fail if lt
	   PUT("%s\n", buf) if env->Qech
	   *fnd = 0 if (fnd = st_fnd (";", buf)) ne
	.. st_trm (buf)
	if (fnd = st_fnd (",", buf)) ne
	   *fnd++ = 0
	   st_cop (fnd, env->Asec)
	.. st_trm (buf)
	next if !buf[0]
      never
	fine
  end
;???;	WUS:BUILD - Most command qualifiers are not implementd
code	cu_arg - command argument

;	Only one parameter is expected

	cu_qua	: (*cuTenv, *char) void own

  func	cu_arg
	env : * cuTenv
	cnt : int
	vec : ** char
	arg : * char
  is	*arg = 0			; assume none
	--cnt, ++vec			; skip the first
      while cnt--
	quit if *vec eq <> 		; done
	cu_qua (env, *vec)		; strip qualifiers
	if *vec && *arg			; more than one?
	.. cu_rep (env, "E-Too many parameters [%s]", *vec)
	st_cop (*vec++, arg)		; copy the parameter
	st_trm (arg)			; remove spaces
      end				; loop for argument
  end

code 	cu_qua - get qualifiers

  proc	cu_qua
	env : * cuTenv			;
 	fld : * char			; command field
  is	buf : [mxLIN] char		;
	dst : * char			; 
	idx : int = 0			;
	atr : int = 0			;
     while fld ne <> && *fld ne 	; got more
	next fld++ if *fld ne '/'	; no slash
	*fld++ = 0			; dump it
	dst = buf			;
	while ct_aln (*fld)		;
	.. *dst++ = *fld++		; copy it
	*dst = 0			;
	st_low (buf)			; get our kind of name
	idx = cl_loo (buf, cuAqua,<>);
	case idx
	of quINV  cu_rep (env, "E-Invalid qualifier [%s]", buf)
	of quALL  ++env->Qall		; do them all
	of quMAK  ++env->Qmak		; make
	of quDBG  ++env->Qdbg		; debug
	of quCRF  ++env->Qcrf		; crossref
	of quFUL  ++env->Qful		; full map
	of quDET  ++env->Qdet		; detailed verify
	or quVER  ++env->Qver		; verify it
	of quIMG  ++env->Qimg		; force image
					;
	of quPAS  ++env->Qpas		; passive
	of quECH  ++env->Qech		; echo input
	of quLEA  ++env->Qlea		; leave intermediate files
	of quIGN  ++env->Qign		; ignore errors
	of quIGW  ++env->Qigw		; ignore warnings
	of quDOS  env->Qpla = quDOS	; dos platform
	of quWIN  env->Qpla = quWIN	; windows platform
	of quCON  env->Qpla = quWIN	; console
		  env->Qmod = quCON
	of quGRA  env->Qpla = quWIN	; graphic
		  env->Qmod = quGRA	
	of quCUS			; %module% to executable
	or quEXE			; link
	or quLIB			; *.obj to .lib
	or quMAC			; .m to .mx
	or quRID			; .r to .rx
	or quCEE			; C to .OBJ
	or quHEA  			; .d to .h	redundant
;	or quLNK  			; *.obj to .exe
	or quMSM  			; .asm to .obj
		  env->Qbld = idx	; remainder qualify translation
	of quSYM  env->Qcmp = quSYM	; symantec compiler
	of quVCC  env->Qcmp = quVCC	; visual C++ compilers
	of other  cu_rep (env, "E-Switch not handled [%s]", buf)
	end case
     end
  end
end file
Resources	
	Rename our .RES file to .DEF (definition)
	BUILD [resource] section
		literal lines
	Creates a SKR:BUILD.RC
	Compiled with RC to create SKR:BUILD.RES
	BUILD.RES added to BUILD.DEF

begin help
title	BUILD
intro	BUILD is used to construct programs and libraries.
syntax	BUILD [Spec][/Qualifiers]
notes	

entry	Spec
	Specifies any of the directory, filespec or filetype
	involved in the operation.
entry	Selection

entry	/ALL
	Instructs BUILD to process all selected files.
entry	/RIDER
	Selects 
	Only RIDER .R files will be built.

entry	



end help
code	cu_val - extract value
;	cu_val	: (*cuTqua, **char) void

  proc	cu_val
	qua : * cuTqua
	fld : ** char
  is	str : * char = *fld
	val : * int = qua->Pflg		; the value
	*val = 0			;
	if *str++ ne '='		; missing =
	   exit if qua->Vopt & quOPT	; its optional
	.. cu_err (E_MisVal, qua->Pnam)	;
	if !ct_dig (*str)		; no digit
	.. cu_err (E_InvVal, qua->Pnam)	; no value
	while ct_dig (*str)		;
	   *val = (*val * 10) + *str++ - '0'
	end				;
	*fld = str			;
  end
BUILD: Compile/Link/Librarian Front-End -- (c) HAMMONDsoftware 1996

build /qualifiers dir:file.typ

dir     names the project directory
file    names the target module
typ     specifies the translation
/ansii  Ansii C translation

;
;	build dir:file.typ
;
;	dir:	is the project directory; might not be source directory
;		.c files usually live in related directories
;		the default is the current project directory
;
;	file	is the controlling module name
;		there is currently no default
;
;	typ	is build file type
;		the default is ".r"
;
;		from	to	to
;		----	--	--
;		.r	.rx	.obj		rider
;		.c		.obj		C
;		.m	.mx	.obj		macho
;		.asm		.obj		masm
;		.d		.h		rider header
;
;	No other file types are accepted.
;	Directory names must match HAMMONDsoftware standard.

	BUILD		Build one or more components
	MAKE		Make the target image or library
			Uses timestamps

Concepts

	The BUILD facility uses the following fundamental components
	to organise projects, builds etc.

	Facility	2 character prefix of all module names.
			Facilities are translated to project ids.
	Project Id	2 character prefix of project directories.
		
	Directory	Facility + 1 character directory type
			s=source, b=binary, ...
	Logical		Logical name defining a directory

	For example:

	"usroo.r"	Facility is "us", source directory would be "uss"
			and the logical would be "uss:".

	stmod.r		Facility is "st", but project id is "rl", and
			source is "rls".
Command	
	build			without parameters, builds the current
				project.
Switchs	
	/rider			riders
	/header			headers only
	/compile		C or masm only
	/link			link only
	/library		lib only

	/project		shows current project
	/project   dir:		selects project

	/platform		shows current platform
	/platform   dir:	sets current platform

	/show			shows lots of things

Build Database	

	[platform]		project platform (Dos, Windows)
	[sources]		list of source files
	[objects]		list of object files
	[libraries]		list of input libraries
	[image]			target .exe, .dll, .lib etc
	[resources]		Windows .RC file
	[timestamps]		Timestamps of all files
				This section is maintained by build
	if  buf[0] eq '%'		; want some replacement?
	   idx = -1			;
	   SCN(buf+1, "%d", &idx)	; get one
	   fail cu_rep ("Invalid macro [%s]", buf) if idx lt
	   idx += 1			; skip first two parameters
	   next if idx gt cnt		; no such argument
	.. st_cop (vec[idx], buf)

system.bld
common.bld

[header]
  title=....
  authors=...
  purpose=
[modules]		can be used for rebuild/etc
[sources]		additional to modules
[objects]		additional to modules
[libraries]
[resources]
[rider]
  headers=
[linker]
  switchs=....
  listing-
  image=
listing=
[librarian]
  switchs=
  listing=
  library=
stamps.bld
[links]
  