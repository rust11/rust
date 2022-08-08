header	exmod - EXPAT module definitions
include rid:rider	; Rider/C header
include	rid:dcdef
include rid:fidef	; files
include rid:mxdef	; maximums
include rid:tidef	; time
include	rid:vfdef	; VF virtual file system

  type	cxTfun : (*vfTobj, *vfTent) int	; file processor function

 	cx_dis : (*dcTdcl, *cxTfun) int	; file process dispatcher

data	cuTctl - EXPAT control block

	Isrc  : vfTobj+		; source object instance
	Idst  : vfTobj+		; destination object instance

  type	cuTctl
  is	Pdcl : *dcTdcl		; DCL control
	Psrc : *vfTobj		; VF source object
	Pdst : *vfTobj		; VF destination object
				;
	Abef : [mxSPC] char	; /BEFORE:date
	Adat : [mxSPC] char	; /DATE:date
	Asin : [mxSPC] char	; /SINCE:date
	Ibef : tiTplx		; 
	Idat : tiTplx		; 
	Inew : tiTplx		; 
	Isin : tiTplx		; 
	Aexc : [mxLIN] char	; /EXCLUDE=string
				;
	Aopt : [mxSPC] char	; /output=spc
	Hopt : *FILE		;
				;
	Adir : [mxSPC] char	; EXPAT image logical/device name
	Vfct : int		; file count
				;
	Qasc : int 		; /ASCII
	Qbrf : int 		; /BRIEF
	Qdat : int		; /SETDATE
	Qexe : int		; /EXECUTE
	Qful : int 		; /FULL
	Qlst : int 		; /LIST
	Qlog : int 		; /LOG
	Qnew : int 		; /NEWFILES
	Qoct : int 		; /OCTAL
	Qpau : int 		; /PAUSE
	Qque : int 		; /QUERY
	Q7bt : int		; /SEVENBIT
	Asch : [mxLIN] char	; /SEARCH="..."
				;
	Qxdp : int 		; /XXDP
	Qana : int 		; /ANALYSE
	Qemt : int		; /EMT
	Qdrs : int		; /DRS
	Qpas : int		; /PASS
	Qxmx : int		; /XM
If Win
	Aexe : [mxSPC] char	; /EXECUTE="she command"
End
  end

	ctl    : cuTctl+	; EXPAT data

	cuAdcl : [] dcTitm+	; see EXDCL.R
	cuAhlp : [] *char+	; ditto

;	Command routines

	cv_cop : dcTfun
	cv_dir : dcTfun
	cv_typ : dcTfun
	dc_ovl : ()

	cm_cop : dcTfun			; copy
	cm_del : dcTfun			; delete
	cm_dir : dcTfun			; directory
	cm_ren : dcTfun			; rename
	cm_typ : dcTfun			; type
	cm_xdp : dcTfun			; directory/xxdp

;	Utility routines

	cu_asc : (char) int		; /ascii
	cu_gdt : ()			; /before/date/since 
	cu_cdt : (*vfTent)		; check dates
	cu_exe : (*vfTobj, *vfTent) int	; /execute:"SHE command" (windows)
	cu_exc : (*vfTent)		; /exclude=string
	cu_log : (*char) int		; /log
	cu_opt : (*char) *FILE		; /output
	cu_pau : (*FILE, *int)	int	; /pause
	cu_que : (*char) int		; /query
	cu_res : (*char, *char, *char)	; resultant output spec
	cu_fmt : (*char, *char)		; format directory file spec
	cu_sub : (*char) int		; subdirectory check
	cu_prg : ()			; purge open files
	cu_fnf : (LONG)			; no files found test/message
	cu_len : (LONG) LONG		; normalize file block length

end header
