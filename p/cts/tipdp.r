;rem$c optimisation needs testing before enabling
file	tipdp - RT-11 time routines
include rid:rider
include rid:mxdef
include rid:rttim
include rid:tidef
rem$c := 0	; use remainder function
chp$c := 0	; chop time (used during initial debug)

;	maximum year is between 4M and 8M
;
; tests:
;
;	ets:ticlk.r	Rider clock time
;	ets:rtgtm.r	RT-11 get/set clock time
;
;	ets:tival.r	plx->val->plx
;	ets:ticmp.r	ti_cmp on files a.a and b.b
;
;	ets:qdmod.r	quad arithmetic
;
; definitions:
;
;	rls:tidef.d
;	cts:rttim.d
;	cts:fidef.d
;
; modules:
;
; tipdp	ti_clk - get clock time
; .r	ti_set - set clock time
;	ti_cmp - compare times
;	ti_plx - value to plex
;	ti_val - plex to value
; tistr	ti_str*- string output
;
; rttim	rt_tfp - file time to plex
; .r	rt_tcp - rt-11 clock time to plex
;	rt_tpt - plex to file time
;	rt_tpc - plex to rt-11 clock time
;	rt_htz - get clock rate
;
; rtgtm	rt_gtm - get clock time
; rtstm	rt_stm - set clock time
; rtftm rt_ftm - get clock time as file time (for rdmod.r only)
; .mac
;
; fitim	fi_gtm - get file time
; .r	fi_stm - set file time
;
; rtinf	rt_gfd (*spc, &val) int		; get file date
; .mac	rt_gft (*spc, &val) int		; get file time
;	rt_sfd (*spc, &val, int) int	; set file date
;	rt_sft (*spc, &val, int) int	; set file time
;
; structures:
;
; type	tiTplx		;			Plx  Unx  Dos  Wnt RTx
; is   	Vmil : WORD	; millisecond	0:9999	?    0	  0    ?   ?
	Vsec : WORD	; second	0:59	0
;	Vmin : WORD	; minute	0:59	0
;	Vhou : tiTyea	; hour		0:23	0
;	Vday : WORD	; day of month	1:31	1    1    1    1   
;	Vmon : WORD	; month		0:11	0    0    1    1
;	Vyea : tiTyea	; year		0:...	
; end
;
; type	tiTyea : long
;
; type	tiTval 
; is	Aval : [4] WORD
; end	
;
;data	rtTtim - RT-11 clock time
;
; type	rtTtim
; is	Vdat : WORD		; RT-11 date
;	Vhot : WORD		; hi-order time (ticks-since-midnight)
;	Vlot : WORD		; lo-order time
;	Vera : WORD		; extended date (high-order years)
; end
;
;data	rtTftm - RT-11 file time
;
; type	rtTftm
; is	Vdat : WORD		; RT-11 date
;	Vsec : WORD		; seconds_since_midnight/3
;	Vext : WORD		; extended time/date
; end
;	rtXTM_ := 03		; extended time (seconds remainder)
;	rtXDT_ := 0177774	; extended date (high-order years)
;
;  struct tm {
;	int tm_sec;
;	int tm_min;
;	int tm_hour;
;	int tm_mday;
;	int tm_mon;
;	int tm_year;
;	int tm_wday;
;	int tm_yday;
;	int tm_isdst;
;	int tm_zon;
;	int tm_ampm;
;	};

  	ti_lea : (int) int-		; is leap year
	ti_ext : (*WORD, int) int-	; extract field
	ti_rem : (*long,*long,long,int)-; calculate remainder
If rem$c
	ti_ins : (*WORD, int, int) int-	; insert field
End
code	ti_clk - get current wall clock time

  func	ti_clk
	val : * tiTval
  is	tim : rtTtim
	plx : tiTplx
	tim.Vdat = -1
	tim.Vhot = -1
	rt_gtm (&tim)
	rt_tcp (&tim, &plx, 0)
	ti_val (&plx, val)
  end

code	ti_set - set current wall clock time

  func	ti_set
	val : * tiTval
  is	tim : rtTtim
	plx : tiTplx
	ti_plx (val, &plx)
	rt_tpc (&plx, &tim, 0)
	rt_stm (&tim)
  end

code	ti_cmp - compare times

  func	ti_cmp
	src : * tiTval
	dst : * tiTval
  is	reply qd_cmp (<*WORD>src, <*WORD>dst)
  end

code	ti_day - return days

  func	ti_day
	tim : * tiTyea
	day : * long
  is	tmp : [4] WORD
	div : [4] WORD
	lng : long
;	XXX : int = 0
;
;PUT("\ntim") if XXX
;qd_dmp ("",<*WORD>tim) if XXX

	qd_mov (tim, &tmp)
;PUT("\ntmp") if XXX
;qd_dmp ("",&tmp) if XXX

	qd_lqu (86400000L, &div)
;PUT("\ndiv") if XXX
;qd_dmp ("",&div) if XXX
	ti_div (&tmp, &div, &tmp, 0)

;PUT("\nquo") if XXX
;qd_dmp ("",&tmp) if XXX

	qd_qtl (&tmp, day)
;PUT("\nptr=%ld", *day) if XXX
	lng = *day
;PUT("\nloc=%ld\n", *day) if XXX

  end

code	ti_msk - mask time fields

  func	ti_msk
	val : * tiTval
	res : * tiTval
	mod : int~
	()  : int
  is	plx : tiTplx~
	ti_plx (val, &plx)
	plx.Vsec = 0 if !(mod & tiSEC_) 
	plx.Vmin = 0 if !(mod & tiMIN_) 
	plx.Vhou = 0 if !(mod & tiHOU_) 
	plx.Vday = 0 if !(mod & tiDAY_) 
	plx.Vmon = 0 if !(mod & tiMON_) 
	plx.Vyea = 0 if !(mod & tiYEA_) 
;	plx.Vdst = 0 if !(mod & tiDST_) 
	ti_val (&plx, res)
	fine	
  end
code	ti_plx - convert time value to time plex

  init	tiAmon : [] int-
  is	31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31	; 365 day year
	31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31	; leap year
  end

  func	ti_ror
	qua : * WORD
  is	res : int
	res = qua[3] & 1
	qd_ror (qua)
	qua[0] &= 077777
  end

  func	ti_plx
	val : * tiTval
	plx : * tiTplx~
  is	qua : [4] WORD
	rem : long
	acc : long = 0
	lea : int = 0

	qd_mov (val, qua)
	plx->Vmil = ti_ext (qua, 1000)
	plx->Vsec = ti_ext (qua, 60)
	plx->Vmin = ti_ext (qua, 60)
	plx->Vhou = ti_ext (qua, 24)

	qd_qtl (qua, &rem)

If chp$c
     if rem ge 10958L
	   plx->Vyea = 2000
	   rem -= 10958L
End
If rem$c
	ri_rem (&rem, &acc, 146097L, 400)
	ri_rem (&rem, &acc, 36524, 100)
Else
	if rem ge 146097L
	.. acc = (rem/146097L)*400, rem = rem%146097L
	if rem ge 36524L
	.. acc += (rem/36524L)*100, rem = rem%36524L
End
If chp$c
     else
	plx->Vyea = 1968
     	rem += 730L
     end
End
If rem$c
	ri_rem (&rem, &acc, 1461L ,4)
	ri_rem (&rem, &acc, 365L, 1)
Else
	if rem ge 1461L
	.. acc += (rem/1461L)*4, rem = rem%1461L

	if rem ge 365L
	.. acc += (rem/365L), rem = rem%365L
End

If chp$c
	plx->Vyea += acc
Else
	plx->Vyea = acc
End

	acc = 0
	lea = 12 if ti_lea (plx->Vyea)
	while acc lt 12				; sanity check
	   quit if tiAmon[lea+acc] gt rem	; no more days left
	   rem -= tiAmon[lea+acc]		; another month
	   ++acc
	end
	plx->Vmon = acc
;PUT("rem=%ld\n", rem)
	plx->Vday = rem + 1
	fine
  end

  func	ti_ext			; extract
	qua : * WORD
	chp : int
	()  : int-		; remainder
  is	rem : [4] WORD
	div : [4] WORD
	qd_clr (div), div[3] = chp
	qd_div (qua, div, qua, rem)
	reply rem[3]
  end

If rem$c
   func	ti_rem
	rem : * long~
	acc : * long~
	lim : long
	mul : int
  is	if *rem ge lim
	.. *acc = (*rem/lim)*mul, *rem = *rem%lim
  end
End
code	ti_val - convert plex to value

  init	tiAmtd : [] int-		;  month to day
  is	0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334
	0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335
  end

  func	ti_val
	plx : * tiTplx
	val : * tiTval
  is	res : long
	mon : int = plx->Vmon 
	qua : * WORD = <*WORD>val
	buf : [mxLIN] char
	yea : long
	lea : int = 0

	yea = plx->Vyea
If chp$c
	res = (yea-1968) / 4
	res -= (yea-1900) / 100
	res += (yea-1600) / 400
	res += (yea-1970) * 365L
Else
	res = (yea) / 4
	res -= (yea) / 100
	res += (yea) / 400
	res += (yea) * 365L
End
	lea = 12 if ti_lea(yea)
	res += tiAmtd[lea+mon]

	res += plx->Vday
	--res if plx->Vday

	qd_lqu (res, qua)
	ti_ins (qua, plx->Vhou, 24)
	ti_ins (qua, plx->Vmin, 60)
	ti_ins (qua, plx->Vsec, 60)
	ti_ins (qua, plx->Vmil, 1000)
  end

  func	ti_ins		; insert field
	qua : * WORD
	val : int
	mul : int
	()  : int-
  is	tmp : [4] WORD
	qd_clr (tmp)
	tmp[3] = mul
	qd_mul (qua, tmp, qua)
	tmp[3] = val
	qd_add (tmp, qua, qua)
  end

  func	ti_lea
	yea : int
	()  : int-
  is	fail if (yea % 4) ne	; definitely not leap
	fine if (yea % 400) eq	;
	reply yea % 100		;
  end

end file
	every 400 years has 100-3 leap years
	thus (400*365)+97 = 400 years (146097 days)

	yea = (days/146097)*400, rem = days%146097

	every remaining 100 years has (100/4)-1 leap years
	thus (100*365)+24 = 100 years (36524 days)

	yea += (rem/36524)*400, rem = rem%146097

	every remaining 4 year period has 1 leap year
	thus (4*365)+1 = 4 year (1461 days)

	yea += (rem/1461)*400, rem = days%1461
	PDP-11s store the time
	in an unsigned long with 1970 subtracted from the year.
	We can't add 1970 back before computing leap years
	because when multiplied by 365 etc it overflows the long.

	The leap year pattern repeats on 400 year boundaries
	if (actual_years-1970) gt 30 
	aka DAYS gt 10957
	   subtract DAYS(1970-2000) from the DAYS
	   (72 76 80 84 88 92 96 100) => (30*365)+7 => 10958
	   and change the EPOCH to 2000
	otherwise
	   add (2*365)=730+1 to DAYS and change the EPOCH to 1968
	   do only the *4 leap year calculation
	end
 
	if rem gt 10958
	   plx->Vyea = 2000
	   rem -= 10958L
	   400s 100s
	else
	   plx->Vyea = 1968
	.. rem += 730
	   4s 1s




end file
