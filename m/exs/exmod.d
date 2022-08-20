header	exmod - EXPAT module definitions
include rid:rider	; rider
include	rid:dcdef	; dcl
include rid:fidef	; files
include rid:mxdef	; maxima
include rid:tidef	; time
include	rid:vfdef	; virtual files

If Win
	cuSYS := vfWIN
Else
	cuSYS := vfRTA
End

data	cuTctl - EXPAT cusp control block

  type	cuTctl
  is	Pdcl : *dcTdcl		; DCL control
	Psrc : *vfTobj		; VF source object
	Pdst : *vfTobj		; VF destination object
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
	Qpag : int 		; /PAGE
	Qnpg : int		; /NOPAGE
	Qrep : int		; /REPLACE
	Qnrp : int		; /NOREPLACE
	Qque : int 		; /QUERY
	Qnqu : int		; /NOQUERY
	Q7bt : int		; /SEVENBIT
	Qxdp : int 		; /XXDP
				;
	Aexc : [mxLIN] char	; /EXCLUDE=string
	Asch : [mxLIN] char	; /SEARCH="..."
				;
	Abef : [mxSPC] char	; /BEFORE:date
	Adat : [mxSPC] char	; /DATE:date
	Asin : [mxSPC] char	; /SINCE:date
				;
	Ibef : tiTplx		; /before time data
	Idat : tiTplx		; /date
	Inew : tiTplx		; /newfiles
	Isin : tiTplx		; /since

;	Context dispatcher (cx_dis)

	Vflg : int		; context flags
				;
	Vopt : int		; want output
	Aopt : [mxSPC] char	; /output=spc
	Hopt : *FILE		;
				;
	Vcol : int		; output column
	Vlin : int		; output line number
	Vcnt : int		; file count
	Vtot : LONG		; total blocks

;	xindex.txt (exxdp.r)

;???
	Adir : [mxSPC] char	; EXPAT image directory
	Hidx : * FILE		; XINDEX.TXT handle
	Pidx : * void		; XINDEX.TXT index
	Vidx : int		; index file status
If Win
	Aexe : [mxLIN] char	; /EXECUTE="she command"
End
  end

;	ctl.Vctx - context flags

	cuACC_	:= BIT(0)	; access file
	cuFNF_	:= BIT(1)	; report files not found
	cuINI_	:= BIT(2)	; flags init to command routines
	cuNAT_	:= BIT(3)	; native files only
	cuOPT_	:= BIT(4)	; open default output file
	cuLPT_	:= BIT(5)	; default output to LP:
	cuPAG_	:= BIT(6)	; default to /PAGE
	cuQUE_	:= BIT(7)	; default to /QUERY
	cuSUB_	:= BIT(8)	; include sub-directories

;	Externals

	ctl    : cuTctl+	; EXPAT control plex
				;
	Isrc   : vfTobj+	; source object instance
	Idst   : vfTobj+	; destination object instance
				;
	cuAdcl : [] dcTitm+	; DCL table (exdcl.r)
	cuAhlp : [] *char+	; ditto

;	Commands

	cv_cop : dcTfun		; thunks
	cv_del : dcTfun		;
	cu_dir : dcTfun		;
	cv_dir : dcTfun		;
	cv_ren : dcTfun		;
	cv_prt : dcTfun		;
	cv_tou : dcTfun		;
	cv_typ : dcTfun		;
	cv_xdp : dcTfun		;

  type	cmTfun : (*vfTobj, *vfTent) int	; command functions
 	cu_dis : (*dcTdcl, *cmTfun) int	; command dispatcher

	cm_cop : cmTfun		; copy
	cm_del : cmTfun		; delete
	cu_exe : cmTfun		; /execute:"SHE command" (windows)
	cm_dir : cmTfun		; directory
	cm_ren : cmTfun		; rename
	cm_prt : cmTfun		; print
	cm_tou : cmTfun		; touch
	cm_typ : cmTfun		; type
	cm_xdp : cmTfun		; dir/xxdp

;	Qualifiers

	cu_asc : (char) int		; /ascii
	cu_gdt : ()			; get dates /before/date/since 
	cu_cdt : (*vfTent)		; check dates
	cu_exc : (*vfTent)		; /exclude=string
	cu_log : (*char) int		; /log
	cu_opn : ()			; /output open
	cu_clo : ()			; /output close
	cu_pag : ()			; /page
	cu_que : (*char) int		; /query

;	Utilities

	cu_dcl : ()			; process DCL command
	cu_ovl : ()			; force DCL overlay into memory
	cu_f63 : (*char, *char)		; format 6.3 directory file name
	cu_fmt : (*char, *char)		; format directory file name
	cu_fnf : ()			; no files found test/message
	cu_len : (LONG) LONG		; normalize file block length
	cu_nat : (*vfTobj)		; check native path
	cu_prg : ()			; purge open files
	cu_res : (*char, *char, *char)	; resultant output spec
	cu_sub : (*char) int		; subdirectory check

end header
