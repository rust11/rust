header	rtutl - rt-11 utilities
include rid:eldef
include	rid:tidef
include	rid:fidef

	rt_rea : (*FILE, elTwrd, *char, elTwrd, int)
	rt_wri : (*FILE, elTwrd, *char, elTwrd, int)
	rtWAI := 0

	rt_clk : (*tiTval, *int, int) void
	rt_tim : (*tiTval, *int, *int) void
	rt_dat : (*tiTval, *int, int) void
	rt_era : (*tiTval, *int) void
	rt_utm : (int, int, *tiTplx) void
	rt_udt : (int, int, *tiTplx) void

	rt_unp : (*elTwrd, *char, int) void
	rt_pck : (*char, *elTwrd, int) *char
	rt_spc : (*char, *elTwrd, int, int) *char
	rt_xxx : ()

;	vrSPC := 64		; spec size

end header
