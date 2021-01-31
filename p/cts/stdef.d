header	stdef.d - string definitions

	st_cop : () * char extern
	st_app : () * char extern
	st_end : () * char extern
	st_len : () int extern
	st_cmp : () int extern
	st_skp : () * char extern

	st_fnd : () * char extern
	st_scn : () * char extern
	st_mov : () * char extern
	st_trm : () * char extern
	st_lst : () * char extern
;	st_seg : () * char extern
	st_par : () * char extern
	st_pad : () * char extern
	st_rep : () * char extern
	st_exc : () * char extern
	st_upr : () * char extern
	st_low : () * char extern
	st_mem : () int extern
	st_val : () * char extern
	st_wld : () int extern

	st_bal : () * char extern		; (stbal.r)
	st_ins : () * char extern		; (stbal.r)

end header
