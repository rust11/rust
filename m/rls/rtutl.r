tst$c=1
;???;	RLS:RTUTL - debug code for RD_ALC present (nopped)
file	rtutl - rt-11 utilities
include rid:rider
include rid:rtutl
include rid:tidef
include	rid:ctdef
include	rid:chdef
include	rid:medef
include rid:rddef
include rid:fidef

	rt_plx : (*tiTval, *tiTplx) void

code	rt_xxx clock/date/time routines

;
;	To handle date rollover it's necessary to drive combined
;	date/clock and date/time routines from the same time value.
;	Here's some example code for these routines.
;
;	  proc	el_tim
;		clk : * int
;		dat : * int
;	  is	val : tiTval
;		ti_clk (&val)			; get current time
;		rt_clk (&val, clk, elVhtz)	; setup the clock
;		rt_dat (&val, dat, elFy2k)	; the date
;	 end

code	rt_clk - convert current time to rt-11 clock form

;	The RT-11 clock counts in ticks since midnight.
;	A 50 hertz system has fifty ticks per second.
;	A 60 hertz system has sixty ticks per second.
;	DEC shipped kits with a 60 hertz default.
;
;	A 50 hertz clock makes more sense for an emulator
;	since the windows clock has millisecond periods.
;	That's exactly 20 milliseconds per tick for 50 hertz.
;	It's 16.66 for a sixty hertz machine.
;
;	The time is not stored in DEC's usual inverted long
;
;	clock:	.word	lot,hot
; ???	This looks wrong...

  proc	rt_clk				; tiVval to RT-11 time value
	val : * tiTval
	clk : * int
	htz : int			; hertz: 50 or 60
  is	plx : tiTplx
	rt_plx (val, &plx)
	*clk = ((plx.Vhou*3600) + (plx.Vmin*60) + plx.Vsec) * htz
  end

code	rt_tim - rt11x file time

;	TSX established a time format for RT11A directories.
;	Bit-15 flags a valid time entry. The 15	remaining bits
;	store the seconds since midnight / 3.
;
;	The SHAREplus RT11X format stores the 3-second remainder
;	in the low-order two bits of the first extra directory
;	entry word.
;
;	tim:	.word	0100000 | (seconds/3)
;	rem:	.word	(seconds%3) 

  proc	rt_tim			; val to rt-11 time/remainder
	val : * tiTval
  	tim : * int
	rem : * int
  is	plx : tiTplx
	sec : int
	tmp : int
	rt_plx (val, &plx)
	sec = ((plx.Vhou*3600) + (plx.Vmin*60) + plx.Vsec)
	*tim = 0x8000 | ((sec/3)&0x7fff) if tim
	*rem |= (sec%3) if rem
  end

code	rt_dat - get rt-11 date

;	date:	.word	date
;
;	15 14 13 12 11 10 9  8  7  6  5  4  3  2  1  0  
;	[era] [month 1..] [ day 1..31 ]  [ year-1972 ]
;
;	[era] is the high-order two bits of year-1972.
;
;	Base:   1972
;		+ 32  2004   non-era expiry
;	3*32    + 96  2100   era expiry

  proc	rt_dat				; val to rt-11 date
	val : * tiTval
	dat : * int
	y2k : int			; want y2k date
  is	plx : tiTplx
	yea : int
	rt_plx (val, &plx)
	yea = plx.Vyea
	yea = 2099 if plx.Vyea gt 2099
	yea -= 1972
	*dat = ((plx.Vmon+1)<<10) | (plx.Vday<<5) | (yea&0x1f)
 	*dat |= (yea&0x60)<<9 if y2k
  end

  proc	rt_era				; val to RUST era
	val : * tiTval
	era : * int
  is	plx : tiTplx
	rt_plx (val, &plx)
	if plx.Vyea gt 2099
	   *era = plx.Vyea-2099
	else
	.. *era = 0
  end

  proc	rt_plx				; val/current to plex
	vap : * tiTval
	plx : * tiTplx
  is	val : tiTval
	ti_clk (&val), vap=&val if !vap	; use current time
	ti_plx (vap, plx)		; get plex form
  end

  proc	rt_udt				; rt-11 date to plex
	dat : int
	y2k : int			; want y2k date
	plx : * tiTplx
  is	plx->Vyea = dat & 0x1f
	plx->Vyea |= ((dat>>9) & 0x60) if y2k
	plx->Vyea += 1972
	plx->Vmon = ((dat>>10) & 0xf) - 1
	plx->Vday = ((dat>>5) & 0x1f) 
  end

  proc	rt_utm			; rt-11 time to plex
  	tim : int
	rem : int
	plx : * tiTplx
  is	sec : int
	tim &= 077777		; only 15 bits
	tim *= 3		; convert to 1-second units
	plx->Vhou = (tim/3600)
	tim -= plx->Vhou * 3600
	plx->Vmin = (tim/60)
	tim -= plx->Vmin * 60
	plx->Vsec |= (rem&3)
  end
code	rt_unp - unpack rad50 filespec

  init	rtAunp : [41] char
  is	" ABCDEFGHIJKLMNOPQRSTUVWXYZ$%*0123456789"
  end

  proc	rt_unp
	rad : * elTwrd		; pointer to rad50 input
	asc : * char		; pointer to ascii output
	maj : int		; number of words to convert
				; -4 => file spec
  is	div : int
	wrd : int
	spc : int = 0
	rem : int
	maj = 4, spc = 1 if maj eq -4
	maj = 3, spc = 1 if maj eq -3
	while maj--
	   wrd = *rad++
	   div = 40 * 40
	   while div && wrd
	      rem = wrd / div
	      wrd -= rem * div
	      *asc++ = rtAunp[rem]
	      div /= 40
	   end
	   next if !spc
	   *asc++ = ':' if maj eq 3
	   quit if !*rad && maj eq 3
	   *asc++ = '.' if maj eq 1
	end
	*asc++ = 0
  end
code	rt_pck - pack rad50 word

  func	rt_pck
	str : * char
	res : * elTwrd
	all : int
	()  : * char
  is	cnt : int = 3
	cha : int
	wrd : elTwrd = 0
	dig : int
     while cnt--
	cha = *str
	dig = 0
	if cha eq '$'
	   dig = 27, ++str if all
	elif cha eq '%'
	   dig = 28, ++str if all
	elif cha eq '*'
	   dig = 29, ++str if all
	elif cha eq '_'
	   dig = 0, ++str if all
	elif ct_dig (cha)
	   dig = cha - 022, ++str
	elif ct_alp (cha)
	.. dig = ch_upr (cha) - 0100, ++str
	wrd = wrd * 40 + dig
     end
	*res = wrd
	reply str
  end

code	rt_spc - pack rad50 filespec

  func	rt_spc
	spc : * char
	nam : * elTwrd
	mod : int
	cnt : int			; words to pack: 3 or 4
	()  : * char
  is	wrd : elTwrd
	nth : int
	me_clr (nam, cnt*2)
					;
	spc = rt_pck (spc, &wrd, mod)	;
	if cnt eq 4			; want full spec
	   if *spc eq ':'		; device
	      *nam++ = wrd, ++spc	;
	      spc = rt_pck (spc, &wrd, mod);
	   else
	.. .. *nam++ = 0		;
	*nam++ = wrd			;
	if ne				; got a filename
	   spc = rt_pck (spc,nam++,mod)	; fill in the filename
	   if *spc eq '.'		; got a filetype
	   && spc[1]			;
	   .. spc = rt_pck (++spc, nam,mod); fill in the filename
	else				;
	.. *nam++ = *nam++ = 0		;

	reply spc
  end
code	rt_rea - RT-11 style read/write

code	rt_rea (fil, blk, buf, wct, don)
code	rt_wri (fil, blk, buf, wct, don)

  func	rt_rea
	fil : * FILE
	blk : WORD
	buf : * char
	wct : WORD
	don : int
  is	fi_see (fil, blk*512)
	fi_rea (fil, buf, wct*2)
	reply that
  end

  func	rt_wri
	fil : * FILE
	blk : WORD
	buf : * char
	wct : WORD
	don : int
  is	fi_see (fil, blk*512)
	fi_wri (fil, buf, wct*2)
	reply that
  end

end file

