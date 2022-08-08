file	copy - EXPAT copy command
include rid:rider	; Rider/C header
include	rid:dcdef
include	rid:fidef
include	rid:imdef
include	rid:vfdef	; VF virtual file system
include rid:fidef	; files
If Win			; Windows
include rid:stdef	; strings (stdef exhausts DECUS-C memory)
End
include	exb:exmod

;	COPY/ASCII/DATE/LOG/QUERY/BEFORE/DATE/SINCE src dst
;
;	/NOREPLACE
;	/DELETE/PREDELETE/[NO]PROTECTION
;	/SYSTEM
;	/UNPROTECT
;	/WAIT
;
;	/BINARY/CONCATENATE

;
;	Single wildcard filespec for input and output

  func	cm_cop
	dcl : * dcTdcl
  is	src : * vfTobj~ = &Isrc		; source object
	dst : * vfTobj  = &Idst		; destination object
	ent : * vfTent~			; directory entry
	opt : * FILE~			; output file
	rgt : [mxSPC] char		; right spec (output)
	err : int = 0			; error flag
	cha : int			; some character/byte
	sta : int			; status
	cnt : LONG = 1			; # files found

	vf_alc (src)			; set it up
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
	   ++cnt			; found another file
					;
	   quit ++err if !vf_acc (src)	; access input file
					;	
	   cu_res (dst->Aspc,ent->Anam,rgt) ; get resultant output spec
					;
	   next if !cu_que (ent->Anam)	; check /query
	   cu_log (ent->Anam)		; check /log

	   opt = fi_opn (rgt, "wb", "")	; open the output file
	   quit ++err if fail		; system error
					;
	   while (cha = vf_get (src)) ne EOF
	      next if !cu_asc (cha)	; check /ascii
	      fi_ptb (opt, cha)		; a thousand cuts
	      next if ne EOF		; we're good
	      im_rep ("E-Error writing %s", rgt)
	      fi_prg (opt, "")		; RUST/RT purge; Windows close
	      quit ++err		;
   	   end				;
	   quit if err			;
	   fi_clo (opt, "")		; close output
	   ctl.Qdat ? &ctl.Inew  ?? &ent->Itim ; /SETDATE or source date
	   fi_stp (rgt, that, "") 	; set file time - plex
	end
    end block
	cu_prg ()			; purge open channels
	cu_fnf (cnt)			; check file not found
	fine
  end
