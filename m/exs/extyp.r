file	extyp - expat type command
include rid:rider	; Rider/C header
include	rid:dcdef	; dcl
include rid:fidef	; files
include rid:stdef	; strings
include	rid:vfdef	; virtual file system
include	exb:exmod	; expat

code	type command

;	TYPE/DATE/LOG/PAUSE/QUERY/BEFORE/DATE/SINCE src
;
;	Type always uses /ASCII (which might be a problem)

  func	cm_typ
	dcl : * dcTdcl
  is	src : * vfTobj~ = &Isrc		; source object
	ent : * vfTent~			; destination object
	cha : int~			; some character
	err : int = 0			; error flag
	cnt : LONG = 1			; files found count

	ctl.Vpag = ctl.Qpag ? 0 ?? -1	; count page lines
					;
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
	      if (cha&255) eq '\n'	;
	   .. .. quit ++err if !cu_pag(); /page
	.. quit if err
    end block
	cu_prg ()			; purge open channels
	cu_fnf (cnt)			; check file not found
	fine
  end
