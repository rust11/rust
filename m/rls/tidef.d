header	tidef - time definitions

;	See next page for useful time data.
;	All variables are passed as pointers.
;	Vdoy and Vdst are obselete.
;	Use ti_doy (plx) to obtain day of year.

If Win
	tiTyea := long
Else
	tiTyea := long
End

  type	tiTplx		;			Plx  Unx  Dos  Wnt RTx
  is 	Vmil : WORD	; millisecond	0:999	0
	Vsec : WORD	; second	0:59	0
	Vmin : WORD	; minute	0:59	0
	Vhou : WORD	; hour		0:23	0
	Vday : WORD	; day of month	1:31	1    1    1    1   
	Vmon : WORD	; month		0:11	0    0    1    1
	Vyea : tiTyea	; year		0:...	
			; minimum year		     1900 1980 1601 1974
			; maximum year		     2099 2099 2107?2099
If Win
	Vdow : WORD	; day of week	0:6	Sun            Sun
	Vdoy : WORD	; day of year	0:365?	Jan-1
;sic]	Vwoy : WORD	; week of year  0:51
	Vdst : WORD	; daylight saving time
End
  end

If Win
  type	tiTval 
  is	Vlot : LONG			; time as value
 	Vhot : long			; 
  end	
Else
  type	tiTval 
  is	Atim : [4] WORD
  end	
End

  type	tiTcpu : long			; CPU time since booted
	ti_cpu : (*tiTcpu) int		; returns elapsed cpu ticks
					;
	ti_clk : (*tiTval) int		; get wall clock time
	ti_set : (*tiTval) int		; set wall clock time
	ti_cmp : (*tiTval, *tiTval) int	; compare two time values
					;
	ti_val : (*tiTplx, *tiTval) int	; plex to value
	ti_plx : (*tiTval, *tiTplx) int	; value to plex (local time)
	ti_rng : (*tiTplx, *tiTplx) int	; range check and edit
					;
	ti_sdt : (*tiTplx, *char) int 	; scan date string
	ti_stm : (*tiTplx, *char) int	; scan time string
					;
	ti_str : (*tiTplx, *char) *char	; plex to dd-MON-yyyy hh:mm:ss
	ti_dat : (*tiTplx, *char) *char	; plex to dd-MON-yyyy
	ti_dmy : (*tiTplx, *char) *char	; plex to dd-MON-yy
	ti_hms : (*tiTplx, *char) *char	; plex to hh:mm:ss
	ti_hmt : (*tiTplx, *char) *char	; plex to hh:mm
	ti_day : (*tiTplx, *char) *char	; get day of week
					;
	ti_msk : (*tiTval, *tiTval, int); mask to selected time fields
	tiMIL_ := BIT(0)		; retain milliseconds
	tiSEC_ := BIT(1)		; retain seconds
	tiMIN_ := BIT(2)		; etc
	tiHOU_ := BIT(3)		;
	tiDAY_ := BIT(4)		;
	tiMON_ := BIT(5)		;
	tiYEA_ := BIT(6)		;
	tiDST_ := BIT(7)		;
	tiTIM_ := (tiMIL_|tiSEC_|tiMIN_|tiHOU_|tiDST_) ; retain time
	tiDAT_ := (tiDAY_|tiMON_|tiYEA_); retain date

data	system specific routines

If Win
  type	tiTwin
  is	Vlot : LONG			; low order time
	Vhot : LONG			; high order time
  end
	tiTnat  := tiTwin
	ti_imp	:= ti_fnt
	ti_exp	:= ti_tnt
	ti_fnt	: (*tiTwin, *tiTval) int; from wnt filetime to value
	ti_tnt	: (*tiTval, *tiTwin) int; from value to wnt filetime
	ti_sys	: (*tiTval) int		; Win32 System time

  type	tiTast	: (void) void
	ti_sig	: (int, *tiTast) int
	ti_wai	: (LONG) int

End

end header
end file
;	ti_sub : (*tiTval, *tiTval, *tiTval) int; subtracts t1 from t2 into t3
;	ti_utc : (*tiTval, *tiTplx) int	; value to plex (universal/gmt)
					; tifmt (avoid linking this)
;	ti_fmt : (*char, size, *char, *tiTplx) int
					; plex to formatted string
If Dos
  type	tiTdos
  is	Vtim : int			; time
	Vdat : int			;
  end					;
	tiTnat  := tiTdos		; native time
	ti_imp	:= ti_fds		; from o/s filetime to value
	ti_exp	:= ti_tds		; from value to o/s filetime
	ti_fds	: (*tiTdos, *tiTval) int; from dos filetime to value
	ti_tds	: (*tiTval, *tiTdos) int; from value to dos filetime
End
Timekeeping	

;	CC/Unix/Posix timekeeping is used as the model.
;	Mainly because we can always use the platform runtime as a last resort.
;	Where possible we bypass the CRT.
;
;	The names of C time types and functions are awful.
;	The choice of parameter modes is awful.
;	The assignment of functionality is awful.
;	Thus we clean up a little bit.

CC/Unix/Posix system time

 type	tiTunx
 is	tm_sec   	: int	; seconds		0:61
	tm_min   	: int	; minutes		0:59
	tm_hour  	: int	; hour			0:23
	tm_mday  	: int	; day of month		1:31
	tm_mon   	: int	; month			0:11
	tm_year  	: int	; year since 1900	0:2099
	tm_wday  	: int	; day since sunday	0:6
	tm_yday  	: int	; day of year		0:365
	tm_isdst 	: int	; lt=>unknown, eq=>no, gt=>yes
 end

Rider time structures

  type	tiTtim
  is 	Vmil 		: WORD	; millisecond		0:999
	Vsec 		: WORD	; second		0:61
	Vmin 		: WORD	; minute		0:59
	Vhou 		: WORD	; hour			0:23
	Vday 		: WORD	; day of month		1:31
	Vmon 		: WORD	; month			0:11
	Vyea 		: WORD	; year since 0		0:2099
				;
	Vdow 		: WORD	; day of week	Sun=0	0..6
	Vdoy 		: WORD	; day of year	Jan-1=0	0..365?
				;
	Vdst 		: WORD	; daylight saving time
 end

WNT time structures

  type	FILETIME
  is	dwLowDateTime 	: DWORD
	dwHighDateTime 	: DWORD
  end

  type	SYSTEMTIME
  is	wYear		: WORD	; 0:..
	wMonth		: WORD	; 1:12  Jan..Dec
	wDayOfWeek	: WORD	; 0:6	Sun..Sat
	wDay		: WORD	; 1:31  1st..31st
	wHour		: WORD	; 0:23
	wMinute		: WORD	; 0:59
	wSecond		: WORD	; 0:59(61)
	wMilliseconds	: WORD	; 0:999
  end
;  type	tiTenv
;  is	Vmin : WORD			; first recognised year
;	Vmax : WORD			; last recognised year
;	Vcps : LONG			; clock ticks per second
;	Vzon : WORD			; time zone * 2
;	Azon : [1] char			; time zone
;  end
