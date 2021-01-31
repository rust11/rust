header	rttim - RUST time format
include	rid:tidef

data	rtTtim - RT-11 clock time

  type	rtTtim
  is	Vdat : WORD		; RT-11 date
	Vhot : WORD		; hi-order time (ticks-since-midnight)
	Vlot : WORD		; lo-order time
	Vera : WORD		; extended date (high-order years)
  end

data	rtTftm - RT-11 file time

  type	rtTftm
  is	Vdat : WORD		; RT-11 date
	Vsec : WORD		; seconds_since_midnight/3
	Vext : WORD		; extended time/date
  end
	rtXTM_ := 03		; extended time (seconds remainder)
	rtXDT_ := 0177774	; extended date (high-order years)

	rt_tcp : (*rtTtim, *tiTplx, int) void
	rt_tpc : (*tiTplx, *rtTtim, int) void
				; RT-11 clock time to plex
				; plex to RT-11 clock time
	rt_tfp : (*rtTftm, *tiTplx) void
	rt_tpf : (*tiTplx, *rtTftm) void
				; RT-11 file time to plex
				; plex to RT-11 file time
	rt_htz : () int		; RT-11 clock rate (50 or 60)


data	RT-11 native time

  type	ntTval
  is	Aval : [3] WORD
  end
	nt_val : (*tiTplx, *tnTval)
	nt_plx : (*tnTval, *tiTplx)
	nt_cmp : (*tnTval, *tnTval) int

end header
