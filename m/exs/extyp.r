file	extyp - expat type command
include rid:rider	; Rider/C header
include	rid:dcdef
include	rid:fidef
include	rid:vfdef	; VF virtual file system
include rid:fidef	; files
If Win			; Windows
include rid:stdef	; strings (stdef exhausts DECUS-C memory)
End
include	exb:exmod

code	type

;	TYPE/DATE/LOG/PAUSE/QUERY/BEFORE/DATE/SINCE src
;
;	Type always uses /ASCII (which might be a problem)

  func	cm_typ
	dcl : * dcTdcl
  is	src : * vfTobj~ = &Isrc		; source object
	ent : * vfTent~			; destination object
	lin : int = ctl.Qpau ? 0 ?? -1	; pause - for cl_mor
	cha : int~			; some character
	err : int = 0			; error flag
	cnt : LONG = 1			; files found count

	vf_alc (src)			; setup source object
	cu_gdt ()			; setup /before/date/newfile/since
    begin
	quit if !vf_att (src)		; attach directory
	quit if !vf_scn (src)		; scan the directory
	cnt = 0				; count files now
	ent = &src->Pscn->Ient		; entry
					;
	while vf_nxt (src) ne		; get next entry
	   next if cu_sub (ent->Anam)	; ignore subdirectories
	   next if !cu_cdt (ent)	; /BEFORE/DATE/NEWFILES/SINCE
	   ++cnt			; another file found
	   next if !cu_que (ent->Anam)	; /query
	   cu_log (ent->Anam)		; /log
	   quit ++err if !vf_acc (src)	; access
	   while (cha = vf_get (src)) ne EOF
	      next if !cu_asc (cha)	; not an ascii character
 	      PUT("%c", cha) if cha ne	; get a byte/put a byte
	      if (cha&255) eq '\n'		;
	   .. .. quit if !cu_pau(<>,&lin); /pause
	.. quit if err
    end block
	cu_prg ()			; purge open channels
	cu_fnf (cnt)			; check file not found
	fine
  end
