header	usmod
include <stdio.h>
If Win
include <stdlib.h>
End
include rid:rider
include rid:chdef
include rid:ctdef
include rid:stdef
include rid:medef
include rid:imdef
include rid:mxdef
;nclude	rid:dfdef
include	rid:drdef
include	rid:fidef
include rid:mxdef
include	rid:cldef
include	rid:tidef
include	rid:iminf
If Dos
include	rid:dslib
Else
	ki_ini () :=
	ki_exi () :=
	ki_ctc () := (0)
End

	NL	:= cu_new ()

data	qualifiers

	quFall	: int extern	; /all			all
	quFany	: int extern	; /any			all
	quFbig	: int extern	; /big			all
	quFbin	: int extern	; /binary		   lst		cmp
	quFbyt	: int extern	; /byte			       dmp
	quFbar	: int extern	; /bare			   lst cmp sea
	quFdat	: int extern	; /date			   lst
	quFdbg	: int extern	; /debug
	quFdec	: int extern	; /decimal		?	
	quFdir	: int extern	; /directories		atr
	quFdou	: int extern	; /double		    prn
	quFdtb	: int extern	; /detab
	quFdwn	: int extern	; /down					srt
	quFeps	: int extern	; /epson		    prn
	quFfor	: int extern	; /force
	quFfre	: int extern	; /free
	quFfst	: int extern	; /first		        dmp
	quFful	: int extern	; /full			    lst cmp sea
	quFhex	: int extern	; /hex			    lst
	quFimg	: int extern	; /image		    lst
	quFlng	: int extern	; /long			       dmp
	quFlog	: int extern	; /log			all
	quFnew	: int extern	; /new
	quFold	: int extern	; /old			all
	quFpau	: int extern	; /pause		all
	quFpee	: int extern	; /peek			    lst
	quFque  : int extern	; /query		all except dir/list
	quFnqr  : int extern	; /noquery		all
	quFqui	: int extern	; /quiet		all
	quFrep	: int extern	; /replace		    cop ren
	quFnrp	: int extern	; /noreplace		    cop ren
	quFoct	: int extern	; /octal			dmp
	quFrev	: int extern	; /reverse		srt
	quFsma	: int extern	; /small		all
	quFtim	: int extern	; /time			    lst
	quFtit	: int extern	; /title		    lst	
	quFtrm	: int extern	; /trim					srt
	quFtot	: int extern	; /totals			cmp sea
	quFuse  : int extern	; /use			    lst
	quFvrb	: int extern	; /verbose
	quFwid	: int extern	; /wide (dos)		    lst
	quFwrd	: int extern	; /word				dmp
				;
	quVfro	: int extern	; /from=column				srt
	quVlft	: int extern	; left indent			prn
	quVtop	: int extern	; top indent			prn
	quVlin : int extern	; line in page
				;
	quFlst	: int extern	; listing
	quFvie	: int extern	; review
	quFsiz	: int extern	; sizes in listing
	quFacc	: int extern	; accumulators
				;
	quFcop	: int extern	; transfer=copy
	quFmov	: int extern	; transfer=move
	quFren	: int extern	; transfer=rename
				;
	quVatr	: int extern	; attributes
	quVcat	: int extern	; attrs to clear
	quVsat	: int extern	; attrs to clear
	quVcol	: int extern	; columns
	quVsrt	: int extern	; sort criteria
	
	E_MisCmd := "E-Command missing"
	E_InvCmd := "E-Invalid command [%s]"
	E_InvQua := "E-Invalid qualifier [%s]"
	E_MisVal := "E-Missing qualifier value [%s]"
	E_InvVal := "E-Invalid qualifier value [%s]"
	E_RngVal := "E-Value out of range [%s]"
	E_InvCnt := "E-Wrong number of parameters [%s]"
	E_InvWld := "E-Invalid wildcards [%s]"
	_cuQUE	 := ": Yes, No, All, Quit? "

  type	cuTctx	: forward
  type	cuTrou	: (*cuTctx) int

  type	cuTctx
  is	Pcmd : * char		; command name
	P1   : * char		; p1 - source filespec
	P2   : * char		; p2 - dest. or search string
	P3   : * char		; p3 - output
	Varg : int		; argument count
	Pdir : * drTdir		; directory
	Pent : * drTent		; entry
	Ppth : * char		; dir->Apth - source directory path
	Pnam : * char		; ent->Anam - actual current file name
	Pspc : * char		; source filespec (pth+nam)
				;
	Ptar : * char		; target filespec - (p2*nam)
	Psrc : * FILE		; source file
	Pdst : * FILE		; destination file
				;
	Pfun : * cuTrou		; command function routine
	Vsrt : int		; directory sort
	Vatr : int		; operation attributes
	Vsiz : long		; normalized filesize
	Vtot : long		; total size of all files
	Vcnt : int		; number of files
	Vmat : int		; number of matchs
 	Vmis : int		; missing count
	Vsam : int		; same count
	Vdif : int		; different count
	Vcha : long		; counts
	Vwrd : long		;
	Vlin : long		;
	Vpag : long		;
				;
	Itim : tiTval		; current time (and date)
	Idat : tiTval		; current date (only)
	Pobf : * char		; output buffer
	Popt : * char		; output line buffer
	Vqui : int		; quit time
	Vtar : int		; has target spec
 	Phdr : * char		; Compare x.x with yyy
	Pobj : * char		; x.x with yyy
	Pjoi : * char		; "to", "with", "for"
	Iimg : imTinf		; image info
				;
;	Pdef : * dfTctx		; definitions
;	Pnxt : * dfTdef		; next definition
  end

	cuPsrc	: * cuTctx extern; source context
	cuPdst	: * cuTctx extern; destination context

	cu_ctx	: (void) * cuTctx

	cu_cmd	: (*cuTctx, int, **char) int
	cu_arg	: (*cuTctx, **char, *char) **char own

	cu_tit	: (*cuTctx) void
	cu_opr	: (*cuTctx) int
	cu_que	: (*cuTctx, *char) int
	cu_ask	: (*cuTctx, *char, *char) int
	cu_siz	: (long, *char) void
	cu_dts	: (*tiTval, *char) *char
	cu_tms	: (*tiTval, *char) *char
	cu_new	: (void) void

	cu_rew	: (*cuTctx) void
	cu_flu	: (*cuTctx) void
	cu_typ	: (*char) void
	cu_opt	: (*char, *char) void
	OPT(c,o) := cu_opt (c, o)
	APP(c) 	:= cu_opt (c, <>)

	cu_abt	: (void) void
	cu_err	: (*char, *char) void
	cu_src	: (*cuTctx) *FILE
	cu_dst	: (*cuTctx) *FILE
	cu_clo	: (*cuTctx, **FILE, *char) int
	cu_tar	: (*cuTctx) *FILE
	cu_opn	: (*char, *char, *char, *char) *FILE
	cu_cln	: (*cuTctx) int
	cu_rpl	: (*cuTctx) int
	cu_wld	: (*cuTctx, int) void

	cu_tot	: (*cuTctx) void
	cu_scn	: (*cuTctx) void
	cu_don	: (*drTdir) void
	cu_avl	: (*char) int
	cu_spc	: (*char, *char, *char) *char
	cu_kop	: (*FILE, *FILE, long) int
	us_scn	: (*cuTctx) int
	us_nxt	: (*cuTctx) *drTent

	su_cmp	: cuTrou
	su_edt	: cuTrou
	su_cre	: cuTrou
	su_tra	: cuTrou
	su_sea	: cuTrou
	su_zap	: cuTrou
	pu_zap	: cuTrou
	
	kw_atr	: cuTrou
	kw_cmp	: cuTrou
	kw_var	: cuTrou
	kw_edt	: cuTrou
	kw_dif	: cuTrou
	kw_chg	: cuTrou
	kw_cnt	: cuTrou
	kw_cre	: cuTrou
	kw_del	: cuTrou
	kw_dmp	: cuTrou
	kw_hlp	: cuTrou
	kw_lst	: cuTrou
	kw_mak	: cuTrou
	kw_prn	: cuTrou
	kw_rem	: cuTrou
	kw_sho	: cuTrou
	kw_tou	: cuTrou
	kw_tra	: cuTrou
	kw_typ	: cuTrou
	kw_see	: cuTrou
	kw_sea	: cuTrou
	kw_srt	: cuTrou
	kw_tru	: cuTrou
	kw_zap	: cuTrou

end header
