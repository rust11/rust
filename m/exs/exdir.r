file	exdir - expat directory command
include rid:rider	; rider
include rid:fidef	; files
include rid:imdef	; images
include	rid:mxdef	; maxima
include rid:stdef	; strings
include	rid:vfdef	; virtual files
include	exb:exmod	; expat

code	directory

;	DIR/BRIEF/DATE/FULL/LIST/OCTAL/PAUSE/BEFORE/DATE/SINCE src
;	DIR/EXECUTE Windows only
;	/DELETED/FREE/TENTATIVE/SUMMARY
;
;	Display macros

	DIS(fmt,str) := fprintf (opt,fmt,str) ; display value
	TYP(fmt)     := fprintf (opt,fmt)     ; type string
	LIN	     := TYP("\n") 	      ; newline	

  func	cm_dir
	src : * vfTobj~			; source VF object
	ent : * vfTent~			; VF directory entry
  is	opt : * FILE = ctl.Hopt		; output file
	fmt : [mxSPC+3] char		; formatted file spec
	tim : [32] char			; date/time strings
	col : * int = &ctl.Vcol		; count columns
	len : LONG			; file length in blocks
					;
	++ctl.Vcnt			; count files
					;
      begin
;	quit if cu_sub (ent->Anam)	; sub-directories
	len = cu_len (ent->Vlen)	; count blocks
	ctl.Vtot += that		; accumulate total blocks
					;
	quit if !cu_cdt (ent)		; /BEFORE/DATE/NEWFILES/SINCE
					;
	st_low (ent->Anam)		; lower case name
If Win
	cu_fmt (ent->Anam, fmt)		; format file spec
Else
	cu_f63 (ent->Anam, fmt)		;
End
					;
If Win
	if ctl.Aexe[0]			; /EXECUTE
	   if ctl.Qlst			; /LIST
	      DIS("%s", fmt)		; display file name
	   .. LIN			; one per line
	   DIS("%s", fmt)		; display file name
	   cu_exe (src, ent)		;
	.. quit
End

	if ctl.Qlst			; /LIST?
	   DIS("%s", fmt)		; display file name
	   LIN				; one per line
	.. quit				; and that's it

If Win
	DIS("%13s ", fmt)		; display file name
	if st_len (fmt) ge 13		; for long names
	   LIN				; newline and indent
	.. TYP("              ") if !ctl.Qbrf
Else
	DIS("%s ", fmt)
End

	if ctl.Qbrf			; /BRIEF
	   quit if ++*col lt 7		; not seven columns yet
	   LIN				; newline
	   quit if !cu_pag ()		; ask for more, perhaps
	.. quit *col = 0		; start next line
					;
	if len gt 65535L		; over 16 bit limit?
	   DIS(" %6luk", len/1024L)	;
	else				;
	.. DIS(" %6lu ", len)	;

;	DIS(" %6lu",cu_len(ent->Vlen))	; file length in blocks
	DIS("C ", <>) if ent->Vflg & vfCTG_
	DIS("  ", <>) otherwise
					;
	ti_dat (&ent->Itim, tim)	; get date
	DIS("%s  ", tim)		; display date
	ti_hmt (&ent->Itim, tim)	; get time
	DIS("%s", tim)			; display time
					;
	if ctl.Qful			; /FULL?
	   DIS(" %6ld ", ent->Vsta/512L) if !ctl.Qoct ; start block
	   DIS(" %6lo ", ent->Vsta/512L) otherwise
	   if src->Vsys eq vfXDP	; and is XXDP
	      DIS("  %6ld ", ent->Vlst/512L) if !ctl.Qoct ; last block
	      DIS("  %6lo ", ent->Vlst/512L) otherwise
	.. .. ;DIS("%o", ent->Vffb )    ; first free byte if DOS11/RSX
	LIN				; newline
	quit if !cu_pag ()		; ask for more, perhaps
      end block
	fine
  end

code	cx_dir - directory exit code
If 0
  cx_dir
	LIN if col ne			; newline if required
					;
	if ctl.Qful			; /FULL
	   DIS(" %ld files,", cnt)	; file count
	   DIS(" %ld blocks\n", tot)	; block count
	   DIS(" %ld free blocks", scn->Vemp/512L) if scn->Vemp ne
	.. LIN				; new line
End

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
