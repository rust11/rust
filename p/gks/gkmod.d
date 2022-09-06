header	gkmod - diag module definitions
include	rid:dcdef
include	rid:mxdef

  type	cuTctl
  is	Pdcl : * dcTdcl
	V1   : int
	Qcmt : int		; gkkbd - keyboard/comment
	Vcsr : WORD		; gkdlv - dlv/csr=%o
	Astr : [mxLIN] char	; display
  end

	ctl : cuTctl+

	gk_asc : dcTfun
	gk_kbd : dcTfun
	gk_pqt : dcTfun
	gk_bau : (int)
	gk_sna : dcTfun
	gk_bpt : dcTfun
	gk_bus : dcTfun
	gk_cpu : dcTfun
	gk_dis : dcTfun
	gk_res : dcTfun
	gk_hlt : dcTfun
	gk_hrs : dcTfun
	gk_flk : dcTfun
	gk_rmn : dcTfun
	gk_pdp : dcTfun
	gk_mch : dcTfun
	gk_mem : dcTfun
	gk_mmu : dcTfun
	gk_mrs : dcTfun
	gk_cfg : dcTfun
	gk_dev : dcTfun
	gk_rtx : dcTfun
	gk_low : dcTfun
	gk_slo : dcTfun
	gk_rad : dcTfun

;	gk_clk : dcTfun
	gk_rat : dcTfun
	gk_sno : dcTfun
	gk_vec : dcTfun
	gk_snf : dcTfun
	gk_trp : dcTfun
	gk_dlv : dcTfun

end header


