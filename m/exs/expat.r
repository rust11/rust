;???	Pause after "error accessing"
;???	Need free blocks
;???	DIR/WINDOWS format
;???	/DRS, file count
;???	/EXCLUDE=...
;???	Add descriptions for monitors and drivers
;???	DIR/XXDP="string"
;???	DIR/VOLUME shows BOOT.VOL, HOME, BOOT2, DIR
;???	DIR/VOLUME shows BOOT.SYS, MFD1, MFD2, DIR, BOOT2
;???	dcSTR should have option to include "/" and strip quotes
;???	COPY must check input errors
;???	COPY must copy date and support /SETDATE
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
;	o Supports XXDP, RT-11, RUST volumes
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
data	EXPAT implementation

;	--------------------
;	EXPAT implementation
;	--------------------
;
;	EXPAT is developed simultaneously for the PDP-11 and Windows using
;	the C front-end language Rider/C and an extensive shared library.
;	The C compiler I use for the PDP-11 is DECUS-C, which lacks full
;	function prototypes and other features. Rider/C irons out these
;	differences.
;
;	EXPAT runs under any RT-11 or Windows system. It can also run under
;	RSX using RUST/RTX (an RT-11 environment that runs on RSX).
;
;	The sources for EXPAT itself are fairly short because most of the
;	functionality resides in libraries.
;
;	--------------
;	User Interface
;	--------------
;	The EXPAT user interface is driven by a DEC-style DCL interpreter.
;	The function below is all that is required to initiate the DCL 
;	interpreter.
;
;	  func	start
;	  is	dcl : * dcTdcl			; DCL control object
;		im_ini ("EXPAT")		; image init for messages
;		dcl = ctl.Pdcl = dc_alc ()	; allocate DCL object
;		dc_eng (dcl, cuAdcl, "EXPAT> ")	; pass control to DCL
;	  end
;
;	The equivalent C-code output by Rider/C follows. Note that <start()>
;	is called by a library <main ()> routine.
;
;	start()
;	{ dcTdcl *dcl;
;	  im_ini ("EXPAT");
;	  co_ctc (coENB);
;	  cu_ini ();
;	  dcl = ctl.Pdcl = dc_alc ();
;	  dcl->Venv |= dcCLI_|dcCLS_;
;	  dc_eng (dcl, cuAdcl, "EXPAT> ");
;	} 
;
;	The DCL interpreter is table-driven, as shown in this excerpt:
;
;	  init	cuAdcl : [] dcTitm
;	; level symbol		task	P1	  V1  	type|flags
;	  is
;	     1,	"EX*IT",	dc_exi, <>,	   0, 	dcEOL_
;	     1,	"HE*LP",	dc_hlp, cuAhlp,	   0, 	dcEOL_
;	  
;	     1,	"CO*PY",	dc_act, <>,	   0,	dcNST_
;	      2,  <>,		dc_fld, Isrc.Aspc, 32,	dcSPC
;	      2,  <>,		dc_fld, Idst.Aspc, 32,	dcSPC
;	      2,  <>,		cu_cop, <>, 	   0, 	dcEOL_
;
;	     1,	"DI*RECTORY",	dc_act, <>,	   0, 	dcNST_
;	      2,  <>,		dc_fld, Isrc.Aspc, 32,	dcSPC|dcOPT_
;	      2,  <>,		cu_dir, <>, 	   0, 	dcEOL_
;	      2,  "BR*IEF",	dc_set, &ctl.Qbrf, 1,	dcOPT_
;	     0,	 <>,		<>,	<>,	   0, 	0
;	  end
;
;	Container file notation
;	-----------------------
;	
;
;	Directory and file operations
;	-----------------------------
;	All directory and file operations are implemented by "VF", a 
;	long-planned Virtual File system that was finally implemented in
;	parallel with EXPAT.
;
;	VF handles the following tasks:
;
;	o Automated file system detection
;	o Scanning directories
;	o File open, close, read, write, rename, delete, etc.
;
;	VF currently handles XXDP, RT-11 and Windows file systems. DOS11,
;	RSX and (early) VMS are in preparation.
;
;	VF hides the specific details of each of the file systems.
;
;	o File specifications are ascii strings.
;	  (PDP-11 6.3 Rad50 specs are hidden)
;	o Device and file locations are long 32-bit byte values.
;	o Device and file lengths are long 32-bit byte values.
;	 (PDP-11 block numbers and 16-bit block number limits are hidden)
;	 (DECUS-C does not support unsigned longs, effectively limiting
;	  longs to a 31-bit range arithmetically. However, that still
;	  handles the largest disks available to PDP-11s).
;
;	Essentially, VF conforms to standard 32-bit C I/O practice.
;
;	------------
;	VF interface
;	------------
;	Using VF is also relatively simple. The Rider/C excerpt below 
;	implements a bare-bones directory function.
;
;	  func	cu_dir
;		dcl : * dcTdcl
;	  is	obj : * vfTobj = &Isrc		; VF object
;		ent : * vfTent			; VF directory entry
;		fine if !vf_acc (obj)		; access directory
;		fine if !vf_scn (obj)		; scan the directory
;		ent = &obj->Pscn->Ient		; entry
;	        while vf_nxt (obj) ne		; get next entry
;		   PUT("%s\n", ent->Anam)	; output file name
;	        end
;		fine
;	  end
;
;	The equivalent C code reads as:
;
;	cu_dir(dcl)
;	  dcTdcl *dcl;
;	{ vfTobj *obj;
;	  vfTent *ent;
;	  obj = &Isrc;
;	  vf_alc (obj);
;	  if (!vf_acc (obj)) return 1;
;	  if (!vf_scn (obj)) return 1;
;	  ent = &obj->Pscn->Ient;
;	  while (vf_nxt (obj) != 0) {
;	    printf("%s\n", ent->Anam);
;	  } 
;	  return 1;
;	} 
;
;	File export
;	-----------
;	File import is relatively easy. I have written file import software
;	for DOS11, XXDP, RT-11, RSX and VMS in the past.
;
;	File export can be more complex. 
;
;	RT-11:
;	I already have a Rider/C library that fully manages RT-11 disk
;	volumes.
;
;	DOS11/XXDP:
;	The XXDP file system is largely derived from the DOS11 file
;	system. The export functionality is relatively simple.
;
;	RSX/VMS:
;	VMS is largely an extension of the RSX file system. I've already
;	have a file import utility for RSX/VMS which will act as a 
;	template for VF import. Export will be more complex, particularly
;	since RSX/VMS use an ornate system of file record types.
;
;	Windows:
;	Windows support for EXPAT exists only when EXPORT runs under
;	Windows, where I can use native Windows system calls for all
;	functionality.
data	local definitions
include rid:rider	; Rider/C header
include rid:codef	; console
include	rid:dcdef	; DCL interface
include rid:fidef	; files
include rid:fsdef	; file specs
include rid:imdef	; image
include rid:medef	; memory
include rid:mxdef	; maximums
include rid:tidef	; time
include	rid:vfdef	; VF virtual file system
include	exb:exmod
If Win			; Windows
include	rid:cldef	; command line
include rid:rxdef	; rad50
include rid:stdef	; strings (stdef exhausts DECUS-C memory)
End

data	Local structures

;	See EXMOD.D for EXPAT definitions

	Isrc  : vfTobj = {0}	; source object instance
	Idst  : vfTobj = {0}	; destination object instance

	ctl   : cuTctl = {<>, &Isrc, &Idst}

;	EXPAT help frame

  init	cuAhlp : [] * char
  is   "PDP-11 file exchange program EXPAT.SAV V1.0"
       " "
       "COPY path path	 Copy files    /ASCII/LOG/QUERY"
       "DIRECTORY path	 List files    /BRIEF/FULL/LIST/OUTPUT=path/PAUSE"
       "TYPE path	 Display files /LOG/PAUSE/QUERY"
       "Date options:   /BEFORE:date/DATE:d"

       "EXIT		 Exit EXPAT"
       "HELP		 Display this help"
	<>
  end
code	start

;	EXPAT mainline

	ex_dcl : ()
	ex_dco : ()

  func	start
  is	;dcl : * dcTdcl~			; DCL context
					;
	im_ini ("EXPAT")		; image name for messages
	co_ctc (coENB)			; enable ctrl/c abort
					;				;
	ex_dcl ()

;	dcl = ctl.Pdcl = dc_alc ()	; allocate DCL control block
;	dcl->Venv = dcCLI_|dcCLS_	; DCL as CLI and single line command 
;					;
;	dc_eng (dcl, cuAdcl, "EXPAT> ")	; DCL does all command processing
  end

code	overlay thunks

;	For RUST/SJ the DCL engine and command modules are located
;	same overlay region. Thus to return to DCL we must first reload
;	the DCL overlay, which we do with EX_DCO() (see RLS:DCMOD.R).

  func	cv_cop
	dcl : * dcTdcl
  is	cm_cop (dcl)
	ex_dco ()
	fine
  end

  func	cv_dir
	dcl : * dcTdcl
  is	cm_xdp (dcl) if ctl.Qxdp|ctl.Qdrs|ctl.Qpas
	cm_dir (dcl) otherwise
	ex_dco ()
	fine
  end

  func	cv_typ
	dcl : * dcTdcl
  is	cm_typ (dcl)
	ex_dco ()
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


code	cu_pau - /pause output every 24 lines

;	flush directory/type output before prompt

  func	cu_pau
	opt : * FILE~
	cnt : * int~
  is	fine if *cnt lt			; counting disabled
	if *cnt+1 ge 24			; about to prompt "More? "
	.. fi_flu (opt) if opt ne	; flush output 
	reply cl_mor (cnt)		; count and prompt
  end


code	cu_que - /query operation

;	FILNAM.SPC ?

  func	cu_que
	nam : * char
  is	str : [mxNAM] char~
	fine if !ctl.Qque		; not /QUERY
	st_cop (nam, str)		;
	st_upr (str)			; upper case it
	PUT("%13s", str)		; "  FILNAM.TYP"
	reply cl_que (" ? ")		; "  FILNAM.TYP ? "
  end
code	utilities

code	cu_fmt - format file spec for directory display

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
	cnt : LONG
  is	fine if cnt ne
 	im_rep ("E-No files found: %s", Isrc.Aspc)
 end


code	cu_len - normalize block length

  func	cu_len
	len : LONG
	()  : LONG
  is	reply (len+511L)/512L
  end


code	cu_opt - default /ouput file

  func	cu_opt
	typ : * char			; default type
	()  : * FILE
  is	opt : * char = ctl.Aopt		; output spec
	if Idst.Aspc[0]			; if we have /output file
	   fi_def (Idst.Aspc, typ, opt)	; default file type
	else				;
	.. st_cop ("TT:", opt)		; default output to terminal
	ctl.Hopt = fi_opn (opt, "w","")	; open (non-binary) output
	reply that			;
  end

code	cu_prg - purge files

;	Purge files at command completion

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

;	COPY and TYPE ignore RUST/Windows etc sub-directories

  func	cu_sub
	sub : * char
  is	reply st_fnd (".DIR", sub) ne	; subdirectory?
  end
code	dates

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
If Win
code	cu_exe - /execute=command SHE command

;	directory/execute:"... %p %s ..."
;
;	%p	replaced by path
;	%s	replaced by filespec
;
;	she command path-spec entry-filespec

  func	cu_exe
	obj : * vfTobj
	ent : * vfTent
  is	cmd : [mxLIN] char
	fine if !ctl.Aexe[0]		; no command string
					;
	st_unq (ctl.Aexe, cmd)		; unquote the string
	st_rep ("%p", obj->Apth, cmd)	; replace "%p" with path
	st_rep ("%s", ent->Anam, cmd)	; replace "%s" with file spec
	st_quo (cmd, cmd)		; add quotes to the "command"
					;
	im_exe ("root:she.exe", cmd, 0)	; execute command
	reply that ge			; negative is an error
  end
End
code	cx_dis - generic dispatcher

; type	cxTfun : (*vfTobj, *vfTent) int	; file processor function

  func	cx_dis
	dcl : * dcTdcl
	fun : * (*vfTobj, *vfTent) int	; literal cxTfun for DECUSC
  is	src : * vfTobj~ = &Isrc		; source object
	ent : * vfTent~			; destination object
	err : int = 0			; error flag
	cnt : LONG = 1			; files found count

	vf_alc (src)			; setup source object
	cu_gdt ()			; setup /before/date/newfile/since
					;
      begin				; completion block
	quit if !vf_att (src)		; attach directory
	quit if !vf_scn (src)		; scan the directory
	cnt = 0				; count files now
	ent = &src->Pscn->Ient		; entry
	cu_opt (".LST")			; open output file
	pass fail			;
					;
	while vf_nxt (src) ne		; get next entry
	   next if cu_sub (ent->Anam)	; ignore subdirectories
	   next if !cu_cdt (ent)	; /BEFORE/DATE/NEWFILES/SINCE
	   st_low (ent->Anam)		; lower case name
;	   cu_fmt (ent->Anam, fmt)	; format file spec

	   ++cnt			; another file found
	   next if !cu_que (ent->Anam)	; /query
	   cu_log (ent->Anam)		; /log
	   quit ++err if !vf_acc (src)	; access file
					;
	   (*fun)(src, ent)		; call the file processor
	   quit ++err if !that		; failed
	end
      end block
	cu_prg ()			; purge open channels
	cu_fnf (cnt)			; check file not found
	fine
  end
end file

ANALYSE
MOVE
SEARCH
TOUCH


CONVERT
/DETAB
/ENTAB
/LOWER
/UPPER
/ASCII	remove padding

/BEFORE
/AFTER
/NEWFILES
/LATER
/EARLIER
/DELETE
/PREDELETE
/EXCLUDE
/IGNORE
/WARNING
/INFORMATION
/PREDELETE
/PROTECT
/REPLACE
/SETDATE
/SINCE
/SYSTEM
/WAIT
/VERIFY

MOVE
/ASCII
/STF	Stream to formatted
/FTS	Formatted to stream
/NEWFILES/BACKUP=path

TOUCH/DATE=
