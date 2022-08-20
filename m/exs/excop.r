file	copy - expat copy command
include rid:rider	; rider
include	rid:fidef	; files
include	rid:imdef	; image
include	rid:vfdef	; virtual files
include rid:fidef	; files
include rid:stdef	; strings
include	exb:exmod	; expat

code	touch command

;	Touch and copy share the set date library routines

  func	cm_tou
	src : * vfTobj
	ent : * vfTent~
  is	spc : [mxSPC] char
	cu_res (src->Aspc,ent->Anam,spc); get resultant spc
	fi_stp (spc, &ctl.Inew, "") 	; set file time - plex
	fine
  end

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
;
;	Single wildcard filespec for input and output

  func	cm_cop
	src : * vfTobj
	ent : * vfTent~
  is	dst : * vfTobj = &Idst		; destination object
	opt : * FILE~			; output file
	rgt : [mxSPC] char		; right spec (output)
	err : int = 0			; error flag
	cha : int			; some character/byte
	sta : int			; status

	++ctl.Vcnt			; found another file
					;	
	cu_res (dst->Aspc,ent->Anam,rgt) ; get resultant output spec

	opt = fi_opn (rgt, "wb", "")	; open the output file
	fail ++err if fail		; system error
					;
	while (cha = vf_get (src)) ne EOF
	   next if !cu_asc (cha)	; check /ascii
	   fi_ptb (opt, cha)		; a thousand cuts
	   next if ne EOF		; we're good
	   im_rep ("E-Error writing %s", rgt)
	   fi_prg (opt, "")		; RUST/RT purge; Windows close
	   fail ++err		;
   	end				;
	fail if err			;
	fi_clo (opt, "")		; close output
	ctl.Qdat ? &ctl.Inew  ?? &ent->Itim ; /SETDATE or source date
	fi_stp (rgt, that, "") 	; set file time - plex
	fine
  end
