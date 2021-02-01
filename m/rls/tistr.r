file	tistr - time to string operations
include	rid:rider
include	rid:tidef
include	rid:stdef
include	rid:mxdef

code	ti_str - full date and time

  func	ti_str
	plx : * tiTplx
	str : * char
	()  : * char
  is	ptr : * char
	ti_dat (plx, str)
	ptr = st_end (str)
	*ptr++ = ' '
	ti_hms (plx, ptr)
	reply str
  end

code	ti_day - make date string

  init	tiAday : [] * char own
  is	"Sunday", "Monday", "Tuesday"
	"Wednesday", "Thursday"
	"Friday", "Saturday"
  end

  init	tiAmon : [] * char own
  is	"Jan", "Feb", "Mar", "Apr"
	"May", "Jun", "Jul", "Aug"
	"Sep", "Oct", "Nov", "Dec"
	"Bad"
  end

If Win
code	ti_day - the day of the week

  func	ti_day
	plx : * tiTplx
  	str : * char
	()  : * char
  is	st_cop (tiAday[plx->Vdow], str)	; day of week
	reply str
  end
End

code	ti_dat - the date

  func	ti_dat
	plx : * tiTplx
	str : * char
	()  : * char
  is	mon : int = plx->Vmon
	mon = 12 if mon gt 12		; catch invalid months
	 (plx->Vyea le 9999)		; local
	 (that ? "%02d-%s-%04lu" ?? "%02d-%s-%lu")
	FMT(str, that, plx->Vday, tiAmon[mon], plx->Vyea);
	reply str
  end

  func	ti_dmy				; day-month-year 
	plx : * tiTplx
	str : * char
	()  : * char
  is	mon : int = plx->Vmon
	yea : int = plx->Vyea
	mon = 12 if mon gt 12		; catch invalid months
	FMT(str, "%02d-%s-%02u",	; date
	   plx->Vday, tiAmon[mon], yea)
	st_upr (str)			; upper case
	reply str
  end

code	ti_hms - hours:minutes:seconds

  func	ti_hms
	plx : * tiTplx
	str : * char
	()  : * char
  is	FMT(str, "%02d:%02d:%02d",	; time
	   plx->Vhou, plx->Vmin, plx->Vsec);
	reply str
  end

  func	ti_hmt				; hour-minute
	plx : * tiTplx
	str : * char
	()  : * char
  is	FMT(str, "%02d:%02d",		; time
	   plx->Vhou, plx->Vmin)	;
	reply str
  end
If Win
code	ti_mil - display milliseconds

  func	ti_mil
	cpu : * tiTcpu				; milliseconds
	res : * char				; output buffer
  is	tim : tiTcpu = *cpu			;
	frq : LONG = 1000			; divisor
	day : int				;
	hou : int				;
	min : int				;
	sec : int				;
	mil : int				;
;	if tim lt 0				; negative time
;	   tim = -tim				; make it absolute
;	.. res = st_cop ("-", res)		; indicate past time
	day = <int>(tim/(frq*60*60*24)),	; days
	hou = <int>((tim/(frq*60*60))%24),	; hours
	min = <int>((tim/(frq*60))%60),		; minutes
	sec = <int>((tim/frq)%60)		; seconds
	mil = <int>(((tim%frq)*1000)/frq)	; milliseconds
	res+= FMT(res, "%d ", day) if day	; got days
	res+= FMT(res, "%d:", hou) if (day |= hou)
	res+= FMT(res, "%d:", min) if (day |= min)
	res+= FMT(res, "%d",  sec)		; always want seconds
	st_app (".0", res) 	    if mil eq	; x.0
	FMT (res, ".%03d", mil)     otherwise	; x.001 or x.100
	fine
  end
End
end file
If Dos
code	ti_dtv - date value

  func	ti_dtv
	str : * char
	val : * tiTval			;
	()  : int			; fail => invalid format
  is;	val : tiTval
	plx : tiTplx
	ti_clk (&val)			; get the current time
	ti_plx (val, &plx)		; convert it
	SCN(str,"%2d-%2d-%4d",		;
	    &plx.Vday, &plx.Vmon, &plx.Vyea)
	plx.Vyea -= 1900		; offset it
	plx.Vyea = 0 if lt		; oops
	reply ti_val (plx, &val)	; convert to a value
  end

code	ti_tmv - time scan

  func	ti_tmv
	str : * char
	val : * tiTval			;
	()  : int			; fail => invalid format
  is;	val : tiTval
	plx : tiTplx
	ti_clk (&val)			; get the current time
	ti_plx (val, &plx)		; convert it
	SCN(str,"%2d-%2d-%4d",		;
	    &plx.Vday, &plx.Vmon, &plx.Vyea)
	plx.Vyea -= 1900		; offset it
	plx.Vyea = 0 if lt		; oops
	reply ti_val (plx, &val)	; convert to a value
  end

End
;	%yD
;
;	%D	date field
;	%T	time field
;
;	Y	year
;	M	month
;	D	day
;
;	h	hour
;	m	minute
;	s	second	
;
;	h u	hundreth
;	m i	millisecond
;
;	dow	day of week
;	doy	day of year
	
;	days	
;	

  func	ti_fmt
	fmt : * char
	val : tiTval
	str : * char

  is	while *fmt
	   if (*fmt ne '%') || !fmt[1]
	   .. next *str++ = *fmt++
	   case *fmt++
	   of 'n'  *fmt++ = '\n'
	   of '
