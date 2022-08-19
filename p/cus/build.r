.if ne 0
file	build - extract command files 
include	rid:rider
include	rid:fidef
include	rid:fsdef
include	rid:imdef
include rid:mxdef
include	rid:rtcsi
include	rid:stdef
include	rid:tidef

;???	BUILD/STAMP image copies info to image
;	;	% ident	<?PATCH-I-...>
;	;	% type	<SAV>
;	;	% system	<RUST> <RUST/SJ> <RUST/XM>
;	;	% date	<....>
;	;	% edit	<....>
;	;	RUST binary image patch utility PATCH.SAV V2.0"
;	;	RUST executable, built
;
;???	Use BUILD.INI to load filetypes dynamically
;
;	Based on Ewald's earlier version in Maree
;	Dropped database and backup functions
;	Dropped build from command line input (use DISPLAY/OUT...)
;
;	%build
;	macro cus:build.r/object:cub:build.inf
;	rider cus:build/object:cub:build
;	link cub:build(.inf,.obj)/exe:cub:/map:cub:,lib:crt/cross
;	%end

If 0
  init	imAidt : [] char
  is	"%image%"
	"%name:BUILD - RUST program build utility BUILD.SAV V2.0%  "
;	"%time:12-Dec-2012 10:25:12%   "
	"%end%"
  end
End

  type	cuTctl
  is	Pfil : * FILE
	Popt : * FILE
	Aspc : [mxSPC] char
	Alin : [mxLIN] char
	Acmd : [mxLIN] char

	Vbui : int
	Vedi : int
	Vdat : int
	Vext : int
	Vexe : int
	Vlog : int
	Vpar : int
	Apar : [mxLIN] char
  end
	ctl : cuTctl = {0}
	csi : csTcsi = {0}

  init	cuAtyp : [] * char
  is	"MAC", "R", "D", "C", "MAS", "HLP", "BUI",
	"PAS", "FOR", "FTN", "MAR", <>
  end

  func	cu_rep
	msg : * char
  is	im_rep (msg, ctl.Aspc)
  	fail
  end

  func	cu_gln
  is	reply fi_get (ctl.Pfil, ctl.Alin, 80) ne EOF
  end
code	start

  func	start
  is 	swi : * csTswi
	im_ini ("BUILD")		; who we are
      repeat
	csi.Pidt = "?BUILD-I-RUST image build utility BUILD.SAV V3.0"
	csi.Pnon = "LP"			; no value
	csi.Popt = <>			; optional value
	csi.Preq = ""			; required value
	csi.Pexc = <>			; mutually exclusive
	csi.Ptyp = "            "	; default filetypes

	next if !cs_par (&csi, <>)	; parse the command
	swi = csi.Aswi
	while swi->Vcha
	   case swi->Vcha
	   of 'L'  ++ctl.Vlog		; /Log
	   of 'P'  ++ctl.Vpar		; /Parameters
	   end case
	   ++swi
	end
	next if !cs_val (&csi, 010, 010); required, permitted files

	if ctl.Vpar			; has parameters
	.. cl_cmd ("Parameters? ", ctl.Apar)

	fi_def (csi.Aipt[0].Pspc, "dk:", ctl.Aspc)
	next if !cu_opn ()		; open the file
	next if !cu_par ()		; parse file
	fi_clo (ctl.Pfil)		; flush stuff
	cu_exe () if ctl.Vexe		; execute commands
	im_exi () otherwise		;
      forever				; 
  end
code	cu_opn - open file

  func	cu_opn
  is	typ : **char = cuAtyp
	tem : * char = ctl.Aspc
	spc : [16] char
	if fs_ext (tem, spc, fsTYP_)
	   st_cop (tem, spc)
	   ctl.Pfil = fi_opn (spc, "rb", "")
	   reply ctl.Pfil ne
	end
	while *typ
	   st_cop (tem, spc)
	   st_app (".", spc)
	   st_app (*typ++, spc)
	   if (ctl.Pfil = fi_opn (spc, "rb+", <>)) ne
	      cu_rep ("I-%s", spc) if ctl.Vlog
	   .. fine
	end
	cu_rep ("E-Build file not located %s", spc)
	fail
  end
code	cu_par - parse file

;	% build		contains build commands
;	% edit		update edit number
;	% date		update time value
;
;	search for "%" and keyword separately to avoid matches here 

  func	cu_par
  is	lin : * char~ = ctl.Alin
	ptr : * char~
	while cu_gln ()
	   next if *lin eq '\t'
	   next if *lin eq ' '
	   next if (ptr = st_fnd ("%", lin)) eq
	   ++ptr
	   ++ctl.Vbui, cu_bui () if !ctl.Vbui && st_scn ("build", ptr)
	   ++ctl.Vedi, cu_edi () if !ctl.Vedi && st_scn ("edit", ptr)
	   ++ctl.Vdat, cu_dat () if !ctl.Vdat && st_scn ("date", ptr)
	   ++ctl.Vext if !ctl.Vext && st_scn ("extend", ptr)
	end
	fine if ctl.Vbui|ctl.Vedi|ctl.Vdat
	fail cu_rep ("E-No build commands in file %s")
  end
code	cu_bui - process build commands

;	Create hom:build.000.com
;	Copy commands from input file to command file
;
; ??	Get process number for RUST/XM
; ??	don't process zero length command file
; ??	stop at form feed (sanity)

  func	cu_bui
  is	lin : * char~ = ctl.Alin
	ptr : * char~
	ctl.Popt = fi_opn ("HOM:BUI000.COM", "w",<>)
	if that
	   st_cop ("@HOM:BUI000.COM", ctl.Acmd)	
	else
	   ctl.Popt = fi_opn ("DK:BUI000.COM", "w", "")
	   pass fail
	   st_cop ("@DK:BUI000.COM", ctl.Acmd)	
	end

	while cu_gln ()
	   quit if st_fnd ("%end", lin)
	   ptr = lin
	   ++ptr while *ptr && (*ptr ne '\t')
	   next if *ptr++ ne '\t'
	   fi_put (ctl.Popt, ptr, "")
	end

	fi_clo (ctl.Popt)
	ctl.Vexe = 1
  end

code	cu_exe - execute commands

;	exit to command file
;
;	RT_XTC sends the DCL command to RUST/RT 

  func	cu_exe
  is	cmd : * char = ctl.Acmd
	if ctl.Vpar
	   st_app (" ", cmd)
	.. st_app (ctl.Apar, cmd)
	rt_xtc (cmd)
  end
code	cu_edi - process edit string

;	;	% edit
;	...	<12345>
;
;	Sanity check output format
;	Swap from read stream to write stream

  func	cu_edi
  is	fil : * FILE = ctl.Pfil
	lin : * char~ = ctl.Alin
	ptr : * char~ = lin
	pst : * char			; past <...>
	pos : long			; file position
	edt : int			;
	pos = fi_pos (fil)		;

      repeat
	quit if !cu_gln ()		; must have a line
	quit if !(ptr = st_fnd("<",lin)); find <
	ptr++				; skip it
	quit if !(pst = st_fnd(">",lin)); find >
	quit if (pst-ptr) ne 5		; must be exactly 5 columns
	SCN(ptr, "%d", &edt)
	FMT(ptr, "%d", ++edt)		; increment edit number
	quit if !fi_see (fil, pos)	; reposition file	
	fi_wri (fil, lin, st_len (lin))	;
	fi_flu (fil)			;
	fi_see (fil, fi_pos (fil))	; 
	fine
      never
	fail cu_rep ("W-Invalid edit information %s") 
  end
code	cu_dat - process date string

;	Old format:
;	;	% date
;	;	<22-Dec-2008 02:11:42.22>
;
;	New format:
;	;	% date
;	;	<22-Dec-2008 02:11:42>
;
;	To convert old to new replace ".22>" with ">   "
;
;	Sanity check output format
;	Swap from read stream to write stream

  func	cu_dat
  is	fil : * FILE = ctl.Pfil
	lin : * char~ = ctl.Alin
	ptr : * char~ = lin
	str : [mxLIN] char
	pst : * char			; past <...>
	pos : long			; file position
	edt : int			;
	len : int
	pos = fi_pos (fil)		;

      repeat
	quit if !cu_gln ()		; must have a line
	quit if !(ptr = st_fnd("<",lin)); find <
	ptr++				; skip it
	quit if !(pst = st_fnd(">",lin)); find >
	len = pst-ptr			; must be 23 or 20

	case len
	of 20 ti_str (<>,ptr)		; new
	of 23 ti_str (<>,str)
	      st_app (">   ", str)	; old  
	      me_cop (str, ptr, 24)	;
	of other			;
	      quit			; just wrong
	end case

	quit if !fi_see (fil, pos)	; reposition file	
	fi_wri (fil, lin, st_len (lin))	;
	fi_flu (fil)			;
	fi_see (fil, fi_pos (fil))	; 
	fine
      never
	fail cu_rep ("W-Invalid date information %s") 
  end
code	generate command file name

  func	cu_nam
  is
	nothing
  end
end file
.endc
.title	build
.include "lib:rust.mac"
.list me,meb

	.word	0
	$imgdef	BUILD 3 0
	$imginf	fun=sav cre=hammo aut=ijh use=<RUST compile utility BUILD.SAV>
	$imgham	yrs=<2008> oth=<>
;	%date
	$imgdat	<29-Jun-2022 22:25:29>
;	%edit
	$imgedt	<65   >

.end
[build] 

[windows]
[rust]
...

platform=rust
source=pth:
binary=pth
image=dir:filnam.typ		; .exe .sav .lib
map=dir:filnam.typ
library=lib:
debug=on|off
[source]
[headers]
elmod.d
[modules]
elroo.r

	if st_cmp (lin, "[build]")
	...
	else

build=cusp|library
interface=console|graphic

image=%image%.sav
map=%moduke%.map
[modules]
%module%.r
[common]
[link]

[libraries]
".r"=

