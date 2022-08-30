;	COPY/DETAB
;	show protected status
;	total files
;	Cancel FNF for aborts
;	UIC/protection/columns
;	dir file/block counts
;	still not listing sub-directories
;	ctl.Vcnt
;	dr_scn retuns maximum filename size
;
;	Windows LPT
;	readme.txt
;	/OWNER
;???	/PASSALL
;???	/page
;???	/OUTPUT TT: LP:
;???	TOUCH/DATE/[UN]PROTECT
;???	Redo listing formats
;???	Native file check
;???	PRINT command
;???	CX_DIS has cu_opt()--not generic
;???	Pause after "error accessing"
;???	Need free blocks
;???	DIR/WINDOWS format
;???	/DRS, file count
;???	Add descriptions for monitors and drivers
;???	DIR/XXDP="string"
;???	DIR/VOLUME shows BOOT.VOL, HOME, BOOT2, DIR
;???	DIR/VOLUME shows BOOT.SYS, MFD1, MFD2, DIR, BOOT2
;???	dcSTR should have option to include "/" and strip quotes
;???	COPY must check input errors
;???	Windows vs RT block size
;???	obj->Pbuf
;???	missing files
;???	HELP
;???	Header/time for /FULL
;???	/OCTAL default for blocks
;???	dir pdp:\xxdp23\:mmdp freezes for a second
;???	Windows files can't be copied to self
;???	Support SimH .TAP
;???	Add /HEADER to display paths, detected environment
;???	Set copy date and /SETDATE:date
;???	Should omit filetimes for XXDP at least
;???	Test under RT-11
;???	RT-11 dir \x\y\ lists sy:
;???	
;	V2
;???	DIR/STRUCTURE shows boot/home/etc
;???	BUG: doesn't list Windows sub-directories
;???	Add EXECUTE to copy and execute a command
;???	DIR doesn't list sub-directories
;???	V11 doesn't write zero block files to Windows
;???	vf_nxt should not do the file name compare
;
;???	/IGNORE
;???	/BEFORE/DATE/NEWFILES/SINCE
;???	DIR/USAGE free blocks etc only
;???	Finish /OCTAL
;???	error messages
;???	dir/brief tmp: formatting for long filenames
;???	Error messages
;???	DIR/TAG=1140.LSI.DL11
;???	DIR/DRS
;???	COPY/LDA
;???	COPY X.X X.X needs tentative file and then rename
;???	use root dispatcher for dcl functions
;???	monitor EXPAT stack size
;???	ctrl-c should only abort app at command prompt
;???	2-column directory default
;???	dc_ini, dc_exi, dcIGN_ 
;???	DOS and .DTA
;???	dc_lnk - link to sub-table
;???	cts:rtdyn - translate dynamic names
;???	Skip non-6.3 files when appropriate
;???	dir should show sub-directories
;???	touch, validate
;???	cl_mor must set jsw gtlin$ flag
;???	"..", *.dir, etc
;???	rt rts:\xxx\ fails
;???	fs_res - truncates file names to six characters?
;???	Stop after first file if no wildcards
;???	Transfer size must be size_t not long
;???	Add an RTX function to access the last file's entry
;???	Add home block to NF directory crack
;	definition file for long file names and headers
;	xxx_1 := name="", etc
file	EXPAT - expatriate file exchange program

;	---------------------------
;	EXPAT file exchange utility
;	---------------------------
;
;	EXPAT (from "expatriate") is a file housekeeping utility for PDP-11
;	file systems that runs under RT-11 compatible systems and Windows.
;	The current release is a preliminary minimal version designed to
;	import files from RT-11 and XXDP disk media.
;
;	Host	Input File Systems	Output
;	----	------------------	------
;	RT-11	RT-11 XXDP  		RT-11
;	RUST11	RT-11 XXDP  		RT-11
;	Windows RT-11 XXDP Windows 	Windows
;
;	Unlike most file exchange apps, EXPAT requires no special commands
;	to access non-native file structures. Instead, EXPAT detects file
;	system structures automatically. Assuming an XXDP volume is mounted
;	on DL1:, the command below will automatically detect the XXDP file
;	structure.
;
;	EXPAT> COPY DL1:HSAAGB.SYS SY:
;
;	Sub-directory notation is used to access RT-11 .DSK container files.
;	For example, the command below accesses the logical disk "XXDP23.DSK"
;	on the system disk and detects its XXDP volume structure.
;
;	EXPAT> DIR SY:\XXDP23\*.CCC	
;
;	Windows and RUST/SJ can combine their sub-directory notation with
;	EXPAT specifications. 
;
;	Features:
;	--------
;
;	o Runs under RT-11, RUST and Windows
;	o Runs under RSX using RUST/RTX
;	o Supports DOS11, XXDP, RT-11, RUST, RSX and VMS volumes
;	o Supports Windows directories when running under Windows
;	  or when using V11 to run RUST under Windows.
;
;	o Supports disk-like and container file volumes
;	o Automatically recognizes volume file structures
;	  File structures may also be specified explictily, e.g. "/RSX"
;	o Uses subdirectory notation to specify .DSK container files
;	o Supports 32-bit I/O and RT-11 disk partitions
;	  DECUS-C effectively limits block sizes to 2^21 blocks (2,097,152)
;	  RT-11 32-bit I/O is used where available (MSCP etc)
;	o Wildcard files, but not wildcard sub-directories
;	o Single input and output file specifications
;	o EXPAT on Windows has a line recall facility
;
;	Restrictions
;
;	o Doesn't list sub-directories
;	o RT-11 EXPAT doesn't sort directories; Windows does 
;
;	General usage
;	-------------
;	EXPAT does away the MOUNT command that file exchange utilities
;	usually require to access a disk volume, with two features:
;	auto-detection and the use of sub-directory notation to access
;	container files.
;
;	EXPAT> dir rl1:*.*		! accesses the device "DL1:"
;	EXPAT> dir dl1:\mydisk\*.*	! accesses "DL1:MYDISK.DSK"
;
;	Under RUST, RUST-on-RSX and Windows, container files are 
;	specified as the last sub-directory:
;
;	EXPAT> dir \disks\xxdp\xxdl82\	! => "DK:\DISKS\XXDP\XXDL82.DSK"
;	EXPAT> dir [1,54]\xxdl82\	! => "[1,54]XXDL82.DSK"
data	local definitions
include rid:rider	; rider
include	rid:codef	; command line
include	rid:dcdef	; DCL
include rid:fidef	; files
include rid:fsdef	; file specs
include rid:imdef	; image
include rid:medef	; memory
include rid:mxdef	; maxima
include rid:tidef	; time
include	rid:vfdef	; virtual files
include	exb:exmod	; expat
If Win			; DECUS-C runs out of memory
include	rid:cldef	; command line
include rid:stdef	; strings
End

data	local structures

	Isrc  : vfTobj = {0}	; source object instance
	Idst  : vfTobj = {0}	; destination object instance

	ctl   : cuTctl = {<>, &Isrc, &Idst}

code	start - expat mainline

  func	start
  is	im_ini ("EXPAT")	; image name for messages
	co_ctc (coENB)		; enable ctrl/c abort
	cu_dcl ()		; process DCL command
  end
code	overlay thunks

;	For RUST/SJ the DCL engine and VF driver are located in the
;	same overlay region. To return to DCL we must first reload
;	the DCL overlay, which we do with CU_OVL() (see EXDCL.R).

  func	cv_cop
	dcl : * dcTdcl
  is	ctl.Vflg = cuACC_|cuFNF_
	fine cu_dis (dcl, &cm_cop)
  end

  func	cv_del
	dcl : * dcTdcl
  is	ctl.Vflg = cuFNF_|cuNAT_|cuRTV_|cuQUW_
	fine cu_dis (dcl, &cm_del)
  end

  func	cu_dir
	dcl : * dcTdcl
  is	cv_xdp (dcl) if ctl.Qxdp	; dir/xxdp
	cv_dir (dcl) otherwise		; dir
	fine
  end

  func	cv_dir
	dcl : * dcTdcl
  is	ctl.Vflg = cuFNF_|cuOPT_|cuSUB_
	fine cu_dis (dcl, &cm_dir)
  end

;  func	cv_pro
;	dcl : * dcTdcl
;  is	ctl.Vflg = cuFNF_|cuNAT_
;	fine cu_dis (dcl, &cm_pro)
;  end

  func	cv_xdp
	dcl : * dcTdcl
  is	ctl.Vflg = cuFNF_|cuOPT_
	fine cu_dis (dcl, &cm_xdp)
  end

  func	cv_prt
	dcl : * dcTdcl
  is	ctl.Vflg = cuFNF_|cuLPT_|cuOPT_
	fine cu_dis (dcl, &cm_prt)
  end

  func	cv_tou
	dcl : * dcTdcl
  is	++ctl.Qdat
	ctl.Vflg = cuFNF_|cuNAT_|cuRTV_
	fine cu_dis (dcl, &cm_tou)
  end

  func	cv_typ
	dcl : * dcTdcl
  is	ctl.Vflg = cuFNF_|cuOPT_|cuPAG_
	fine cu_dis (dcl, &cm_typ)
  end
code	cu_dis - generic dispatcher

; type	cmTfun : (*vfTobj, *vfTent) int	; file processor function

	FLG(x) := (ctl.Vflg & (x))

  func	cu_dis
	dcl : * dcTdcl
	fun : * (*vfTobj, *vfTent) int	; literal cmTfun for DECUSC
  is	src : * vfTobj~ = &Isrc		; source object
	spc : * char = src->Aspc	; source file spec
	ent : * vfTent~			; destination object
	flg : int~ = ctl.Vflg		; context flags
	err : int = 0			; error flag
	que : int			; query status
					;
	ctl.Vflg |= cuINI_		; flag init to command routine
	ctl.Vcnt = -1			; init file count
	ctl.Vtot = 0			; total blocks
	ctl.Vcol = 0			; directory column zero
					;
	vf_alc (src)			; setup source object
	cu_gdt ()			; setup /before/date/newfile/since
					;
      begin				; completion block
	quit if !vf_att (src)		; attach directory
					;
	if FLG(cuNAT_)			; must be native directory
	.. quit if !cu_nat (src)	;
					;
	quit if !vf_scn (src)		; scan the directory
	ent = &src->Pscn->Ient		; entry
					;
	if FLG(cuQUW_)			; /QUERY if wildcards
	&& st_int ("?%*", spc, <>)	; spec has wildcards (intersection)
	.. ctl.Vflg |= cuQUE_		; flag wildcards present
	ctl.Qque = 1 if FLG(cuQUE_)	;
					;
	cu_opn ()			; open listing file
	ctl.Vcnt = 0			; counting files now
					;
	while vf_nxt (src) ne		; get next entry
	   st_low (ent->Anam)		; lower case name
					;
	   if !FLG(cuSUB_)		; exclude sub-directories?
	   .. next if cu_sub (ent->Anam); ignore subdirectories
	   next if !cu_cdt (ent)	; /BEFORE/DATE/NEWFILES/SINCE
					;
	   que =  cu_que (ent->Anam)	; /query
	   next if que eq		; ignore this file
	   quit if que lt		; terminate operation
					;
	   ++ctl.Vcnt			; another file found
	   cu_log (ent->Anam)		; /log
					;
	   if FLG(cuACC_)		; access file
	   .. quit ++err if !vf_acc(src);
					;
	   (*fun)(src, ent)		; call the file processor
	   quit ++err if !that		; failed
					;
	   vf_dac (src) if FLG(cuACC_)	; deaccess file
	end
      end block
	cu_clo ()			; close any listing file
	cu_prg ()			; purge open channels
	cu_fnf () if FLG(cuFNF_)	; check file not found
	cu_ovl ()			; reread DCL overlay
	fine
  end
code	qualifiers

code	cu_asc - /ascii elide non-ascii codes

;	/ascii - elide non-ascii codes from DOS11/XXDP text files
;	/sevenbit - exclude eight-bit codes

  func	cu_asc
	cha : char~
  is	fail if ctl.Q7bt && cha & 0200		; exclude eight-bit codes
	fine if !ctl.Qasc
	fine if (cha ge 040) && (cha lt 0177)	; printing
	fine if (cha ge 011) && (cha le 015)	; ht/lf/vt/ff/cr
	fine if (cha eq 032)			; ^z
	fail
  end


code	cu_exc - /exclude=string

  func	cu_exc
	ent : * vfTent
  is	exc : * char~ = ctl.Aexc
	fail if !*exc			; not specified
	reply st_wld (exc, ent->Anam)	; report match
  end


code	cu_log - /log log filename

  func	cu_log
	nam : * char
  is	exit if ctl.Qque		; /QUERY doesn't need /LOG
	PUT("%s\n", nam) if ctl.Qlog	; display the filename
  end


code	cu_pag - /page output every 24 lines

;	flush directory/type output before prompt

  func	cu_pag
	()  : int
  is	lin : * int~ = &ctl.Vlin	;
	fine if *lin lt			; counting disabled
	if ctl.Vopt && *lin+1 ge 24	; need to flush output?
	.. fi_flu (ctl.Hopt)		; flush output 
	reply cl_mor (lin)		; count and prompt
  end


code	cu_que - /query operation

;	FILNAM.SPC ?
;
;	out	 1  => fine
;		 0  => no
;		-1  => quit operation

  func	cu_que
	nam : * char
  is	prm : [mxNAM] char~		; command prompt
	cmd : [mxLIN] char~		; command input
					;
	fine if !ctl.Qque || ctl.Qnqu	; not /QUERY
					;
	st_cop (nam, prm)		;
	st_upr (prm)			; upper case it
	st_app ("? ", prm)		;
	cl_cmd (prm, cmd)		; get response
					;
	st_low (cmd)			; lower case
	case cmd[0]			; Y/A/L/Q
	of 'y' fine			; Yes 
	of 'a' fine ctl.Qque = 0	; All
	of 'l' fine ctl.Qque=0,ctl.Qlog=1; all and Log
	of 'q' reply -1			; Quit
	of other fail			; No
	end case
  end
code	utilities

code	cu_f63 - format 6.3 file name

  func	cu_f63
	nam : * char~
	fmt : * char
  is 	ptr : * char~ = fmt
	col : int~ = 0

	while col lt 10
	   if ((*nam eq '.') && (col lt 6))
	   || !*nam
	      *ptr++ = ' '
	   else
	   .. *ptr++ = *nam++
	   ++col
	end
	*ptr = 0
	st_upr (fmt)
  end


code	cu_fmt - format long file name

  func	cu_fmt
	spc : * char~
	fmt : * char~
  is	len : int = st_len (spc)
	dot : int = st_fnd (".", spc) - spc
	dif : int = 3 - (len-dot)
	st_cop (spc, fmt)
	exit if dot le
	st_app (" ", fmt) while dif-- ge
  end


code	cu_fnf - check file not found

  func	cu_fnf
  is	fine if ctl.Vcnt ne
 	im_rep ("E-No files found: %s", Isrc.Aspc)
 end


code	cu_len - normalize block length

  func	cu_len
	len : LONG
	()  : LONG
  is	reply (len+511L)/512L
  end


code	cu_nat - check native file

  func	cu_nat
	obj : * vfTobj~
  is	sys : int~ = obj->Vsys
	fine if sys eq vfNAT	; is native path
	fine if cuSYS eq vfRTA && FLG(cuRTV_)
	im_rep ("E-Incompatible path for operation [%s]", obj->Apth)
	fail
  end


code	cu_opn - open listing file

  func	cu_opn
  is	opt : * char~ = ctl.Aopt	; output spec
					;
	fine if !FLG(cuOPT_)		; no listing required
	ctl.Vlin = -1			; assume not paging
	if ctl.Qpag || FLG(cuPAG_)	;
	&& !ctl.Qnpg			;
	.. ctl.Vlin = 0			; wants paging
					;
	st_cop ("LP:", opt) if FLG(cuLPT_) ; select device
	st_cop ("TT:", opt) otherwise	;
					;
	if Idst.Aspc[0]			; if we have /output file
	.. fi_def (Idst.Aspc,"DK:.LST",opt); default it
					;
	ctl.Hopt = fi_opn (opt, "w","")	; open (non-binary) output
	reply that ne
  end

  func	cu_clo
  is	fi_clo (ctl.Hopt,"") if ctl.Hopt;
	ctl.Hopt = <>		;
  end


code	cu_prg - purge object files

  func	cu_prg
  is	vf_prg (&Isrc)
	vf_prg (&Idst)
  end


code	cu_res - form resultant file spec

  func	cu_res
	spc : * char
	nam : * char
	res : * char~
  is	fs_res (spc, nam, res)		; get resultant
	fi_loc (res, res)		; localize it
	st_low (res)			; lower case it
  end


code	cu_sub - check for subdirectory

  func	cu_sub
	sub : * char
  is	reply st_fnd (".dir", sub) ne	; subdirectory?
  end
code	filter /dates and /exclude

;	/BEFORE/DATE/NEWFILES/SINCE 

	cu_gdi : (*tiTplx, *char)-
	cu_cdi : (*vfTent, *tiTplx, *char, int)-

code	cu_gdt - get date qualifier information

  func	cu_gdt
  is	fail if !cu_gdi (&ctl.Ibef, ctl.Abef)	; /before:
	fail if !cu_gdi (&ctl.Idat, ctl.Adat)	; /date:...
	fail if !cu_gdi (&ctl.Isin, ctl.Asin)	; /since:...
	tm_clk (&ctl.Inew) if ctl.Qnew|ctl.Qdat	; /newfiles or /setdate
	fine
  end


code	cu_gdi - get date item

  func	cu_gdi
	plx : * tiTplx
	str : * char~
  is	fine if !str[0]			; not specified
	fine if ti_sdt (plx, str)	; scan it
	fail im_rep ("E-Invalid date [%s]", str)
  end


code	cu_cdt - check dates

  func	cu_cdt
	ent : * vfTent~
  is	fail if !cu_cdi (ent, &ctl.Ibef, ctl.Abef, -1)
	fail if !cu_cdi (ent, &ctl.Idat, ctl.Adat, 0)
	fail if !cu_cdi (ent, &ctl.Isin, ctl.Asin, 1)
	fail if ctl.Qnew && !cu_cdi (ent, &ctl.Inew, "1", 0)
	fail if cu_exc (ent)
	fine
  end


code	cu_cdi - check date item

  func	cu_cdi
	ent : * vfTent~		; directory entry
	dat : * tiTplx~		; date plex
	str : * char		; command string
 	cas : int		; -1,0,+1 => before/same/since
  is	dif : int~
	fine if !str[0]		; ignore if not specified

	dif = ent->Itim.Vyea - dat->Vyea 
	dif = ent->Itim.Vmon - dat->Vmon if !dif
	dif = ent->Itim.Vday - dat->Vday if !dif

	fine if !dif && !cas	; /date
	fine if dif gt && cas gt; /before
	fine if dif lt && cas lt; /since
	fail
  end
                                                                                                                                                                                                                                                                   