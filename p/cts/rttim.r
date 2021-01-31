file	rttim - rust time routines
include rid:rider
include rid:medef
include rid:rttim
include rid:tidef
include rid:rttim

	rt_tdp : (int, int, *tiTplx) void-
	rt_tpd : (*tiTplx, *int, *int) void-

	rt_tsp : (long, int, *tiTplx) void-
	rt_tps : (*tiTplx, long, int) void-

code	rt_tcp - clock time to plex

  proc	rt_tcp
	clk : * rtTtim
	plx : * tiTplx
	htz : int		; clock rate
  is	val : * long = &(<*long>clk->Vhot)
	sec : long
	tim : rtTtim
	mil : int

	rt_tdp (clk->Vdat, clk->Vera, plx)
	htz = rt_htz () if !htz	;
	sec = *val/htz		; get seconds
	mil = (*val%htz) * (1000/htz)
	rt_tsp (sec, mil, plx)
  end

code	rt_tpc - plex to clock time

  proc	rt_tpc
	plx : * tiTplx
	clk : * rtTtim
	htz : int		; clock rate
  is	hot : * long = &(<*long>clk->Vhot)
	sec : long
	mil : int
	htz = rt_htz () if !htz
	rt_tpd (plx, &clk->Vdat, &clk->Vera)
	rt_tps (plx, &sec, &mil)
	*hot = sec * htz
	*hot += plx->Vmil / (1000L/htz)
  end
code	rt_tdp - time: date to plex

;	Time structures
;
;	EraMonthDay     Year
;	e emm mmd ddd dyy yyy
;
;         m m   m   d   d d   y      	
;	5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0  M = Month     1:15
;	E E M M M M D D D D D Y Y Y Y Y	 D = Day       1:31
;	Era Month   Day       Year	 Y = Year-1972 0:31  1972-2003
;	2   4       5         5		 E:Y eYear     0:127 1972-2099

  proc	rt_tdp
	dat : int~
	ext : int~
	plx : * tiTplx~
  is	me_clr (plx, #tiTplx)
	plx->Vyea = dat & 037		; year
	plx->Vyea |= ((dat>>9) & 0140L)	; y2k
	plx->Vyea += (ext<<7L)		; extra
	plx->Vyea += 1972L		;
	plx->Vmon = ((dat>>10) & 017)
	--plx->Vmon if plx->Vmon
	plx->Vday = ((dat>>5) & 037) 
  end

code	rt_tpd - time: plex to date

; ???	Only handles 16-bit year

  proc	rt_tpd
	plx : * tiTplx~
	dat : * int~
	ext : * int
  is	yea : int~ = plx->Vyea - 1972	; truncated value
	*dat = (yea & 037)		;
	*dat |= (yea & 0140) << 9	;
	*ext = yea/128L		;
	*dat |= ((plx->Vmon+1) << 10)	;
	*dat |= (plx->Vday) << 5	;
  end
code	rt_tfp - file time to plex

  proc	rt_tfp
	ftm : * rtTftm~
	plx : * tiTplx~
  is	sec : long
 	rt_tdp (ftm->Vdat, ftm->Vext>>2, plx)  ; convert date
	sec = (<long>(ftm->Vsec & 0x7FFF)*3) + (ftm->Vext&3)
	rt_tsp (sec, 0, plx)
  end

code	rt_tpf - plex to file time

  proc	rt_tpf
	plx : * tiTplx~
	ftm : * rtTftm~
  is	sec : long
	mil : int
	rt_tpd (plx, &ftm->Vdat, &ftm->Vext)
	ftm->Vext <<= 2
	rt_tps (plx, &sec, &mil)
	ftm->Vsec = (sec/3) | 0100000
	ftm->Vext |= sec % 3
  end
code	rt_tsp - time: seconds to plex

  proc	rt_tsp
	sec : long
	mil : int
	plx : * tiTplx~
  is	tim : long~ = sec		; destructive
	plx->Vhou = (tim/3600)
	tim = tim % 3600
	plx->Vmin = (tim/60)
	tim = tim % 60
	plx->Vsec = tim
	plx->Vmil = mil
;PUT("%d:%d:%d ", plx->Vhou, plx->Vmin, plx->Vsec)
;PUT("secs:%ld ", sec)
;PUT("\n")
  end

code	rt_tps - time: plex to seconds

  proc	rt_tps
	plx : * tiTplx~
	sec : * long
	mil : * int
  is	(plx->Vhou*3600L) + (plx->Vmin*60L) + plx->Vsec
	*sec = that
	*mil = plx->Vmil
  end
end file

	50hz : n * 20
	60hz : n * 16
