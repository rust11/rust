file	fimod - file operations
include	rid:rider
  If Vms
include	<unixio>			; has fileno()
  Elif Dos				;
#undef __STDC__				;
include	<stdio.h>			; has fileno()
  End					;
include	rid:fidef			; also includes <stdio.h>
include	rid:imdef			;
include	rid:stdef			;
include	rid:medef			;
include	rid:osdef			;

;	o  Filename defaults
;	o  Fully qualified filespecs
;	o  Truenames
;	o  Local translation of filenames
;	o  Messages (and default messages) with local filenames
;	o  Improve on standard C's lack of concern for read/write errors

	E_OpnFil := "E-Error opening file [%s]"
	E_CreFil := "E-Error creating file [%s]"
	E_PrcFil := "E-Error processing file [%s]"
	E_CloFil := "E-Error closing file [%s]"
	E_DelFil := "E-Error deleting file [%s]"
	E_RenFil := "E-Error renaming file [%s]"
	E_ExsFil := "E-Missing file [%s]"
	E_MisFil := "E-File already exists [%s]"

  type	fiTinf
  is	Vlen : short			; filespec slot size
	Pspc : * char			; file spec
	Pfil : * FILE			; some implementations only
;	Verr : int			; errno
;	Vcod : int			; local error
  end

	fiPrep	: * imTrep = &im_rep	; report function
	fiAinf	: [fiCmax] fiTinf own = {0} ; info array

	fi_reg	: (*FILE, *char) int own; register file
	fi_drg	: (*FILE) void own	; deregister file
	fi_inf	: (*FILE) * fiTinf own	; get file info slot
code	fi_opn - open file

;	Add logic to handle sys$input/stdin etc
;	if *mod eq 'w'			; a new file
;	   fil->Pfil = fopen (spc, mod, "RFM=STM") ; create stream file
;
;	"r"	read, input
;	"w"	write, create
;	"rw"	input and output
;	"b"	binary

  func	fi_opn
	spc : * char			; filespec
	mod : * char			; fopen mode
	msg : * char			; the message
	()  : * FILE			; file or null
  is	fil : * FILE			;
	loc : [fiLspc] char		; local copy
	if !st_sam (spc, "con")
	   fi_loc (spc, loc)		; localize the filespec
	else
If Wnt
	   st_cop ("conin$", loc) if st_fnd ("r", mod)
	   st_cop ("conout$", loc) otherwise
End
	end
;PUT("opn=[%s] ", loc)
	if (fil = fopen (loc, mod)) ne	; open it
	   fi_reg (fil, loc)		; register it
	.. reply fil			; opened it
	reply null if msg eq 		; they do it
	if *msg eq			; default message
	   if st_mem ('r', mod) eq	; not read
	   && st_mem ('w', mod) ne	; and explicit write
	      msg = E_CreFil		; is a create error
	   else				; anything else, including
	.. .. msg = E_OpnFil		; errors is an open
	fi_rep (msg, loc, msg)		; tell them
	reply null			;
  end

code	fi_clo - close file

;	o  Ignores NULL files
;	o  Reports either processing or close error 

  func	fi_clo
	fil : * FILE
	msg : * char			; the message
	()  : int			; fail => errors detected
  is	sta : int			;
	fine if fil eq <>		; null files have no errors
	sta = fi_chk (fil, msg)		; check it
	fi_drg (fil)			; deregister it first
	reply sta if fclose (fil) ne EOF; closed without error
	fail if sta eq			; already failed
	fail fi_rep (msg, fi_spc (fil), E_CloFil); report it
  end
code	fi_del - delete file

  func	fi_del
	spc : * char
	msg : * char			; the message
	()  : int			; fine/fail
  is	loc : [fiLspc] char		;
	fi_loc (spc, loc)		; make a copy
	fine if remove (loc) eq		; dump it
	fine if os_del (loc, <>)	; delete it
	fail fi_rep (msg, spc, E_DelFil);
  end

code	fi_ren - rename file

  func	fi_ren
	old : * char
	new : * char
	msg : * char
  is	src : [(fiLspc*2)+2] char	; space for both names in a message
	dst : [fiLspc] char		;
	fi_loc (old, src)		; localize them
	fi_loc (new, dst)		;
	fine if rename (src, dst) eq	;
	st_app ("] [", src)		; join the names
	st_app (dst, src)		; Error renaming [src] [dst]
	fail fi_rep (msg, src, E_RenFil); report it
  end
code	fi_exs - check file exists

  func	fi_exs
	spc : * char
	msg : * char			; exists message
  is	fil : * FILE
	fil = fi_opn (spc, "rb", <>) 	; no such file
	fine fi_clo (fil, <>) if fil	; no problems
	fail fi_rep (msg, spc, E_ExsFil); handle messages
  end

code	fi_mis - check file missing

  func	fi_mis
	spc : * char
	msg : * char			; exists message
  is	fil : * FILE
	fil = fi_opn (spc, "rb", <>) 	; test file
	fine if !fil			; no such - great
	fi_clo (fil, <>)		; close it first
	fail fi_rep (msg, spc, E_MisFil); handle messages
  end

code	fi_chk - check file for errors

  func	fi_chk
	fil : * FILE
	msg : * char
	()  : int
  is	spc : * char			; the filespec
	fine if ferror (fil) eq		; no errors
	spc = fi_spc (fil)		; get the filespec
	fail fi_rep (msg, spc, E_PrcFil); handle messages
  end

code	fi_rep - report file error

  func	fi_rep
	msg : * char
	spc : * char
	def : * char			; default message
  	()  : int			; always fine
  is	fine if msg eq <>		; no message required
	msg = def if *msg eq		; want default message
	(*fiPrep)(msg, spc)		; report it
	fine
  end
code	fi_spc - workout filespec

  func	fi_spc
	fil : * FILE			;
	()  : * char			; filespec or null
  is	inf : * fiTinf			;
	reply "(null)" if fil eq <>	; common error
	inf = fi_inf (fil)		; get the information slot 
	reply "(invalid)" if null	; invalid file number
	reply inf->Pspc if inf->Pspc ne	; known filespec
	reply "(stdin)" if fil eq stdin	;
	reply "(stdout)" if fil eq stdout ;
	reply "(stderr)" if fil eq stderr ;
	reply "(unknown)"		;
  end

code	fi_reg - register spec

  func	fi_reg
	fil : * FILE
	spc : * char
	()  : int			; fine/fail
  is	inf : * fiTinf			;
	len : int = st_len (spc) + 1	;
	inf = fi_inf (fil)		; get the slot
	fail if null			; out of touch
	inf->Pfil = fil			; registered
	if inf->Vlen lt len		;
	   inf->Vlen = (len + 31) & ~(31) ; avoid fragmentation
	.. me_alp (<**void>&inf->Pspc, that) ; ZTC fails
	st_cop (spc, inf->Pspc)		; save it
	fine				;
  end

code	fi_drg - deregister file

;	File is deregisted by clearing inf->Pfil
;	This variable will be used on systems lacking fileno()

  proc	fi_drg
	fil : * FILE
  is	inf : * fiTinf
	inf = fi_inf (fil)		; get the slot
	exit if null			; is none
	inf->Pfil = <>			; deregister
  end

code	fi_inf - get info entry address

  func	fi_inf
	fil : * FILE			;
	()  : * fiTinf			; spec or null
  is	idx : unsigned			;
	idx = fileno (fil)		; get the filenumber
	reply <> if idx ge fiCmax	; too high
	reply &fiAinf[idx]		; the entry
  end
end file
code	fi_sav - setup file context

;	fiPspc		most recent filename from open, delete, rename
;			fully qualified and localized
;
;	fiPmsg		default message for most recent error
;			null if most recent operation succeeded
;
;	fiPctx		pointer to user defined context 
;
;	fiPrep		pointer to default report routine
;			null for muted messages
;			defaults to im_rep

  proc	fi_sav
	sav : * fiTsav			; the save area
	rep : * () int			; user report function
	ctx : * void			; user report context (if any)
	()  : * fiTsav			;
  is	if sav eq <>			; dynamic
	   sav = me_acc (#fiTsav)	; allocate & clear it
	.. ++sav->Vdyn			; remember its dynamic
	sav->Pmsg = fiPmsg		; save it
	sav->Pspc = fiPspc		;
	sav->Prep = fiPrep		;
	sav->Pctx = riPctx		;
	fiPmsg = <>			; no message
	fiPspc = <>			; or spec
	fiPrep = rep			;
	fiPrep = &im_rep if null	; default to im_rep
	fiPctx = ctx			; user context
	reply sav			;
  end

code	fi_res - restore context

  proc	fi_res
	sav : * fiTsav
  is	fiPmsg = sav->Pmsg
	fiPspc = sav->Pspc
	fiPrep = sav->Prep
	fiPctx = sav->Pctx
	me_dlc (sav) if sav->Vdyn	; deallocate dynamic block
  end
