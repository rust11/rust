header	stdef - string definitions

	st_app : (*char, *char)		*char ;	append	*app, *dst
	st_apc : (char, *char, size)	*char ;	appchar	char, *dst, lim
	st_bal : (*char)		*char ; balance	*str
	st_chg : (*char, *char, *char)  *char ; change	*mod, *rep, *dst
	st_cmp : (*char, *char)		int   ; compare	*src, *dst
	st_col : (*char, *char)         int   ; collapse *src, *dst
	st_cop : (*char, *char)		*char ; copy	*src, *dst
        st_cln : (*char, *char, size)	*char ; clonen  *src, *dst, strlim
	st_del : (*char, size)		*char ; delete	*str, cnt
        st_dif : (*char, *char, size)	int   ; differn	*src, *dst, lim
	st_dmp : (*char)		      ; dump    *str
	st_dup : (*char)		*char ; duplicate *str
	st_eli : (*char, *char, *char)	int   ; elide	*mat, *src, *dst
	st_end : (*char)		*char ; end	*str
	st_exc : (*char, *char, int)	*char ; exchange *rep, *dst, cnt
	st_ext : (*char,*char,*char,*char)*char; extract *ctl,*prg,*str,*seg
	st_fit : (*char, *char, size)	*char ; fit	*str, *buf, buflim
	st_flt : (*char,*char,*char,int) int  ; filter  *mod,*src,*dst,flg/lim
	st_flx : (*char,*char,*char,*char,int) int 
			  ; filter with exceptions  *mod,*bra,*src,*dst,flg/lim
	st_fnd : (*char, *char)		*char ; find	*mod, *str
	st_idx : (int, *char)		int   ; index	cha, *str
	st_ins : (*char, *char)		*char ; insert	*ins, *dst
	st_len : (*char)		int   ; length	*str
	st_loo : (*char, **char)	int   ; lookup	*mod, **tab
	st_low : (*char)		*char ; lower	*str
	st_lst : (*char)		*char ; last	*str
	st_mem : (int, *char)		int   ; member	cha, *str
	st_mov : (*char, *char)		*char ; move	*src, *dst
	st_nth : (*char,*char,*char,int)*char ; nth	*mod, *tar, *lim, nth
	st_pad : (*char, int, int)	*char ; pad	*str, cnt,  cha
	st_par : (*char, *char, *char)	*char ; parse	*ctl, *prg, *str
	st_rem : (*char, *char)		*char ; remove	*mod, *dst
	st_rep : (*char, *char, *char)	*char ; replace	*mod, *rep, *dst
	st_rev : (*char)		*char ; reverse	*str
	st_sam : (*char, *char)		int   ; same	*src, *dst
	st_scn : (*char, *char)		*char ; scan	*mod, *dst
	st_seg : (*char,*char,*char,*char)*char; segment *ctl,*prg,*str,*seg
	st_skp : (*char)		*char ; skip	*str
	st_sub : (*char, *char)		int   ; subst	*mod, *str
	st_trm : (*char)		*char ; trim	*dst
	st_int : (*char, *char, *char)  int   ; union   *set, *str, *res
	st_upr : (*char)		*char ; upper	*str
	st_val : (*char,int,*int,*int)  int   ; value   *str, bas, *val, *len
	st_wld : (*char, *char) 	int   ; compare wild *model, *string

end header
