timC := 0
file	tiwin - Windows time routines
include rid:rider
include rid:medef
include rid:tidef
include	rid:tiwin

code	ti_cpu - get cpu ticks

;	Wnt supplies millisecond resolution

	tiKcps := 1000			; milliseconds
  func	ti_cpu
	cpu : * tiTcpu
  is	val : int = GetTickCount ()	; get ticks since boot
	*<*LONG>cpu = val if cpu	; counter wraps after 49.5 days
	reply <int>val			;
  end
code	ti_clk - get current wall clock time

;	Adjust for local time immediately

  func	ti_clk
	val : * tiTval
	()  : int
  is	sys : SYSTEMTIME
	fil : FILETIME
	GetLocalTime (&sys)
	SystemTimeToFileTime (&sys, &fil)
	val->Vlot = fil.dwLowDateTime
	val->Vhot = fil.dwHighDateTime
	fine
  end

code	ti_sys - get Windows system time

  func	ti_sys
	val : * tiTval
	()  : int
  is	sys : SYSTEMTIME
	fil : FILETIME
	GetSystemTime (&sys)
	SystemTimeToFileTime (&sys, &fil)
	val->Vlot = fil.dwLowDateTime
	val->Vhot = fil.dwHighDateTime
	fine
  end

code	ti_cmp - compare times (lft-rgt)

;	if LFT cnd RGT then

  func	ti_cmp
	lft : * tiTval
	rgt : * tiTval
	()  : int
  is	reply 1 if lft->Vhot gt rgt->Vhot
	reply -1 if lft->Vhot lt rgt->Vhot
	reply 1 if lft->Vlot gt rgt->Vlot
	reply -1 if lft->Vlot lt rgt->Vlot
	reply 0
  end

code	ti_sub - subtract times  (res=lft-rgt)

  func	ti_sub
	lft : * tiTval		
	rgt : * tiTval
	res : * tiTval
  is	res->Vhot = lft->Vhot - rgt->Vhot
	res->Vlot = lft->Vlot - rgt->Vlot
	--res->Vhot if lft->Vlot lt rgt->Vlot
  end
code	ti_val - plex to value

  func	ti_val
	plx : * tiTplx
	val : * tiTval
	()  : int
  is	sys : SYSTEMTIME
	fil : FILETIME
	ti_tnp (plx, &sys)		; convert it
	SystemTimeToFileTime (&sys, &fil)
	val->Vlot = fil.dwLowDateTime
	val->Vhot = fil.dwHighDateTime
	fine
  end

code	ti_plx - value to plex

  func	ti_plx
	val : * tiTval
	plx : * tiTplx
	()  : int
  is	sys : SYSTEMTIME
	fil : FILETIME
	fil.dwLowDateTime = val->Vlot
	fil.dwHighDateTime = val->Vhot
	FileTimeToSystemTime (&fil, &sys)
	ti_fnp (&sys, plx)		; convert it
	fine				;
  end

code	ti_msk - mask time fields

  func	ti_msk
	val : * tiTval
	res : * tiTval
	mod : int
	()  : int
  is	plx : tiTplx
	ti_plx (val, &plx)
	plx.Vmil = 0 if !(mod & tiMIL_)
	plx.Vsec = 0 if !(mod & tiSEC_) 
	plx.Vmin = 0 if !(mod & tiMIN_) 
	plx.Vhou = 0 if !(mod & tiHOU_) 
	plx.Vday = 0 if !(mod & tiDAY_) 
	plx.Vmon = 0 if !(mod & tiMON_) 
	plx.Vyea = 0 if !(mod & tiYEA_) 
	plx.Vdst = 0 if !(mod & tiDST_) 
	ti_val (&plx, res)
	fine	
  end
code	ti_fnt - from Wnt filetime to value

  func	ti_fnt
	fil : * tiTwin				; WNT filetime
	val : * tiTval				; our value type
	()  : int
  is	plx : tiTplx				; our time
	loc : FILETIME				;
	sys : SYSTEMTIME			; NT system time
						;
If timC
	FileTimeToSystemTime (<*FILETIME>fil, &sys)	; convert time
	pass fail				; failed miserably
Else
	FileTimeToLocalFileTime (<*FILETIME>fil, &loc) ; localize it
	FileTimeToSystemTime (&loc, &sys)	; convert time
	pass fail				; failed miserably
End
	ti_fnp (&sys, &plx)			; get plex time
	fine ti_val (&plx, val)			; convert the times
  end

code	ti_tnt - to wnt filetime

  func	ti_tnt					; to WNT filetime
	val : * tiTval				; our value type
	fil : * tiTwin				; WNT filetime
	()  : int
  is	sys : SYSTEMTIME			; NT system time
	loc : FILETIME				;
	plx : tiTplx				; our time
	ti_plx (val, &plx)			; explode it
	pass fail				; failed miserably
	ti_tnp (&plx, &sys)			; to nt plex
	SystemTimeToFileTime (&sys, &loc)
	LocalFileTimeToFileTime (&loc, <*FILETIME>fil)
	fine					;
  end
code	ti_fnp - from nt plex to rider plex

  proc	ti_fnp
	sys : * SYSTEMTIME
	plx : * tiTplx
  is	doy : int				; day of year
	me_clr (plx, #tiTplx)
	plx->Vmil = sys->wMilliseconds		; 0=0
	plx->Vsec = sys->wSecond		; 0=0
	plx->Vmin = sys->wMinute		; 0=0
	plx->Vhou = sys->wHour			; 0=0
	plx->Vday = sys->wDay			; 1=1
	plx->Vmon = sys->wMonth - 1		; Jan=1
	plx->Vyea = sys->wYear			; 1601=1601
	plx->Vdow = sys->wDayOfWeek		; Sun=0
	plx->Vdoy = 0				;
	plx->Vdst = 0				;

	plx->Vsec = 59 if plx->Vsec ge 60	; some bug
  end

code	ti_tnp - to nt plex from rider plex

  proc	ti_tnp
	plx : * tiTplx
	sys : * SYSTEMTIME
  is	me_clr (sys, #SYSTEMTIME)
	sys->wMilliseconds = plx->Vmil		; transfer
	sys->wSecond = plx->Vsec		;
	sys->wMinute = plx->Vmin		;
	sys->wHour = plx->Vhou			;
	sys->wDay = plx->Vday			;
	sys->wMonth = plx->Vmon + 1		;
	sys->wYear = plx->Vyea			;
	sys->wDayOfWeek = plx->Vdow		;sic]
	sys->wSecond = 59 if sys->wSecond ge 60	;
  end
