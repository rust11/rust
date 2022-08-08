file	exdir - expat directory command
include rid:rider	; Rider/C header
include	rid:dcdef
include rid:fidef	; files
include	rid:mxdef
include	rid:vfdef	; VF virtual file system
If Win			; Windows
include rid:stdef	; strings (stdef exhausts DECUS-C memory)
End
include	exb:exmod

;	/DELETED/FREE/TENTATIVE/SUMMARY

code	directory

;	DIR/BRIEF/DATE/FULL/LIST/OCTAL/PAUSE/BEFORE/DATE/SINCE src
;	DIR/EXECUTE Windows only
;
;	Display macros

	DIS(fmt,str) := fprintf (opt,fmt,str) ; display value
	TYP(fmt)     := fprintf (opt,fmt)     ; type string
	LIN	     := TYP("\n") 	      ; newline	

  func	cm_dir
	dcl : * dcTdcl
  is	src : * vfTobj~ = &Isrc		; source VF object
	scn : * vfTscn			; VF scan
	ent : * vfTent~			; VF directory entry
	opt : * FILE = <>		; output file
	fmt : [mxSPC+3] char		; formatted file spec
	tim : [32] char			; date/time strings
	lin : int			; count lines
	col : int = 0			; count columns
	len : LONG			; file length in blocks
	tot : LONG = 0			; count total blocks
	cnt : LONG = 1			; count files

	vf_alc (src)			; set it up
	cu_gdt ()			; setup /before/date/newfile/since
	lin = ctl.Qpau ? 0 ?? -1	; /PAUSE? (-1 => no to cl_mor)

    begin
	quit if !vf_att (src)		; attach directory
	quit if !vf_scn (src)		; scan the directory
	cnt = 0				; count files now
					;
	opt = cu_opt (".LST")		; map output file spec
	quit if fail			;
					;
	scn = src->Pscn			; scan
	ent = &scn->Ient		; entry

	while vf_nxt (src) ne		; get next entry
	   next if cu_sub (ent->Anam)	; sub-directories
	   ++cnt			; count files
	   len = cu_len (ent->Vlen)	; count blocks
	   tot += that			; accumulate total blocks
					;
	   next if !cu_cdt (ent)	; /BEFORE/DATE/NEWFILES/SINCE
					;
	   st_low (ent->Anam)		; lower case name
	   cu_fmt (ent->Anam, fmt)	; format file spec
					;
If Win
	   if ctl.Aexe[0]		; /EXECUTE
	      if ctl.Qlst		; /LIST
	         DIS("%s", fmt)		; display file name
	      .. LIN			; one per line
	      DIS("%s", fmt)		; display file name
	      cu_exe (src, ent)		;
	   .. next
End

	   if ctl.Qlst			; /LIST?
	      DIS("%s", fmt)		; display file name
	      LIN			; one per line
	   .. next			; and that's it

	   DIS("%13s ", fmt)		; display file name
	   if st_len (fmt) ge 13	; for long names
	      LIN			; newline and indent
	   .. TYP("              ") if !ctl.Qbrf

	   if ctl.Qbrf			; /BRIEF
	      next if ++col lt 7	; not seven columns yet
	      LIN			; newline
	      quit if !cu_pau (opt,&lin); ask for more, perhaps
	   .. next col = 0		; start next line
					;
	   if len gt 65535L		; over 16 bit limit?
	      DIS(" %6luk", len/1024L)	;
	   else				;
	   .. DIS(" %6lu ", len)	;

;	   DIS(" %6lu",cu_len(ent->Vlen)) ; file length in blocks
	   DIS("C ", <>) if ent->Vflg & vfCTG_
	   DIS("  ", <>) otherwise
					;
	   ti_dat (&ent->Itim, tim)	; get date
	   DIS("%s  ", tim)		; display date
	   ti_hmt (&ent->Itim, tim)	; get time
	   DIS("%s", tim)		; display time
					;
	   if ctl.Qful			; /FULL?
	      DIS(" %6ld ", ent->Vsta/512L) if !ctl.Qoct ; start block
	      DIS(" %6lo ", ent->Vsta/512L) otherwise
	      if src->Vsys eq vfXDP	; and is XXDP
	         DIS("  %6ld ", ent->Vlst/512L) if !ctl.Qoct ; last block
	         DIS("  %6lo ", ent->Vlst/512L) otherwise
	   .. .. ;DIS("%o", ent->Vffb )   ; first free byte if DOS11/RSX
	   LIN				; newline
	   quit if !cu_pau (opt, &lin)	; ask for more, perhaps
	end				;
					;
	LIN if col ne			; newline if required
					;
	if ctl.Qful			; /FULL
	   DIS(" %ld files,", cnt)	; file count
	   DIS(" %ld blocks\n", tot)	; block count
	   DIS(" %ld free blocks", scn->Vemp/512L) if scn->Vemp ne
	.. LIN				; new line
    end block

	fi_clo (opt, "")		; close/flush output
	cu_prg ()			; purge open channels
	cu_fnf (cnt)			; check file not found
	fine
  end
