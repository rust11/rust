file	mark - marktime utility
include rid:rider
include	rid:imdef
include	rid:stdef
include	rid:chdef
include	rid:tidef
include	rid:cldef
include	<stdio.h>
include	<time.h>

;	Mark time utility
;
;	Wall: 12:25:30  Mark: 1.2   Cpu: 0.12
;
;	Wall time is current wall clock time
;	Mark time is elapsed wall clock time
;	Cpu time is elapsed compute time
;
;	Negative times are reported

	CLK	:= CLK_TCK		; clock ticks
	mkTcpu	:= clock_t		; compute time
	mkTelp	:= time_t		; elapsed time
	mkTplx	:= struct tm		; time plex
					;
	oldVcpu	: mkTcpu = 0		; old time
	newVcpu	: mkTcpu = 0		; new time
	adjVcpu	: mkTcpu = 0		; cpu adjustment
	difVcpu	: mkTcpu = 0		; cpu difference
	oldVelp	: mkTelp = 0		; old time
	newVelp	: mkTelp = 0		; new time
	difVelp : mkTcpu = 0		; elapsed difference (cpu time)
					;
If Vms
	mkPspc	: * "sys$login:mark.tmp"; temp file
Else
	mkPspc	: * "c:\\mark.tmp"	; temp file
End
	mkPfil	: * FILE = <>		; file handle

	mk_hlp	: () void
	mk_sho	: () void
	mk_rep	: () void
	mk_dis  : (long, *char) void
	mk_get	: () int
	mk_put	: () int

data	mkAcmd - command array

  init	mkAcmd : [] * char
  is	mkDEF: ""		; default - no command
	mkADJ: "a*djust"
	mkHLP: "h*elp"
	mkRST: "r*eset"
	mkSHO: "sh*ow"
	mkSTA: "st*art"
	mkTEL: "t*ell"
	mkINV: 	<>
  end
code	main 

  func	main
	cnt : int			; argument count
	vec : ** char			; argument vector
  is	arg : * char			; command argument
	im_ini ("MARK")			; setup for errors
					;
	newVcpu = ti_cpu (<>)		; new times
	newVelp = time (<>)		;
	mk_get ()			; old times
	difVcpu = newVcpu-oldVcpu	; cpu difference
	difftime (newVelp, oldVelp)	; elapsed difference in seconds
	<mkTcpu>(that * <double>CLK)	; into CLK_TCK units
	difVelp = that			;
					;
	arg = ""     if *++vec eq	; use default if no command
	arg = *vec++ otherwise		; get first command
    repeat				;
	case cl_loo (arg, mkAcmd, <>)	; lookup command (none negated)
	of mkDEF  mk_rep ()		; default: tell and start
		  mk_put ()		;
	of mkADJ  mk_rep ()		; adjust time
		  adjVcpu = difVcpu	;
		  mk_put ()		;
	of mkHLP  mk_hlp ()		; help
	of mkRST  adjVcpu = 0		; reset
		  mk_put ()		;
	of mkSHO  mk_sho ()		; show
	of mkSTA  mk_put ()		; start
	of mkTEL  mk_rep ()		; tell
	of other			;
	   im_rep ("E-Invalid command [%s]", arg)
	   im_exi ()			;
	end case			;
     until (arg = *vec++) eq <>		; get another command
	im_exi ()			; exit with status
  end
code	mk_hlp - show help

  proc	mk_hlp
  is	printf ("\n")
	printf(" MARK V3.0 - Mark time utility - (c) HAMMONDsoftware 1992\n")
	printf ("\n")
	printf("  mark          tell & start (see below)\n")
	printf("  mark adjust   subtracts this cpu time from subsequent\n")
	printf("  mark help     displays this information\n")
	printf("  mark reset    resets adjustment to zero\n")
	printf("  mark show     displays internal variables\n")
	printf("  mark start    starts mark & cpu timers\n")
	printf("  mark tell     displays wall, mark & cpu time\n")
	printf ("\n")
	printf("  where:\n")
	printf ("\n")
	printf("  wall time     is the wall clock time\n")  
	printf("  mark time     is the elapsed wall clock time\n")  
	printf("  cpu  time     is the elapsed compute time\n")  
printf("  1 12:13:4.05	1 day 12 hours 13 minutes 4 seconds 5 hundreths\n")
	printf ("\n")
  end

code	mk_sho - show internal variables

;	Some implementations do not support (mktime) - thus use
;	a fairly round-about way of determining ticks per second elapsed

  proc	mk_sho
  is	res : [64] char
	plx : * mkTplx			; plex time
	sec : int			; seconds
	loc : time_t = <time_t>8000	; a local time
	plx = localtime (&loc)		; convert to plex time
	sec = plx->tm_hour * 60 * 60	;
	sec+= plx->tm_min * 60		;
	sec+= plx->tm_sec		;
	printf ("Mark ticks per second: %d\n", 8000/sec)
					;
	res[0] = 0			; terminate buffer
	mk_dis (adjVcpu, res)		; get adjustment time
					;
	printf ("Cpu ticks per second: %d\n", CLK_TCK)
	printf ("Cpu adjustment (%d ticks):%s\n",
		<int>adjVcpu, res)
	printf ("Mark data file: \"%s\"\n", mkPspc)
  end
code	mk_rep - report times

  proc	mk_rep
  is	tim : time_t
	plx : * mkTplx			; plex time
	cpu : mkTcpu			;
	adj : mkTcpu			;
	res : [128] char		; result string
	res[0] = 0			;
					;
	tim = time (<>)			; get current time
	plx = localtime (&tim)		; make it local
	st_cop ("Wall: ", res)		; Wall: 
	sprintf (st_end (res),		;
		 "%02d:%02d:%02d",	; current time
		 plx->tm_hour,		;
		 plx->tm_min,		;
		 plx->tm_sec)		;
					;
	st_app ("  Mark:", res)		; mark time
	mk_dis (difVelp, st_end (res))	;
					;
	st_app ("  Cpu:", res)		; cpu time
	cpu = difVcpu, adj = adjVcpu	; get cpu difference
	if adj gt			; got adjustment
	   cpu -= adj   if cpu gt adj	; adjustment is in range
	.. cpu = 0	otherwise	; otherwise 
	mk_dis (cpu, st_end (res))	;
					;
	printf ("%s\n", res)		; display it all
  end

code	mk_dis - display time

  proc	mk_dis
	tim : mkTcpu				; ticks
	res : * char				; output buffer
  is	day : int				;
	hou : int				;
	min : int				;
	sec : int				;
	hun : int				;
	if tim lt 0				; negative time
	   tim = -tim				; make it absolute
	   res = st_app ("-", res)		; indicate past time
	else					;
	.. res = st_app (" ", res)		; space for positive time
	day = <int>(tim/(CLK*60*60*24)),	; days
	hou = <int>((tim/(CLK*60*60))%24),	; hours
	min = <int>((tim/(CLK*60))%60),		; minutes
	sec = <int>((tim/CLK)%60)		; seconds
	hun = <int>(((tim%CLK)*100)/CLK)	; hundreths
	res+= sprintf (res, "%d ", day) if day	; got days
	res+= sprintf (res, "%d:", hou) if (day |= hou)
	res+= sprintf (res, "%d:", min) if (day |= min)
	res+= sprintf (res, "%d",  sec)		; always want seconds
	st_app (".0", res) 	    if hun eq	; x.0
	sprintf (res, ".%02d", hun) otherwise	; x.01 or x.10
  end
code	mk_get - get last time

  func	mk_get
	()  : int
  is	fil : * FILE
	tot : int				; total read
	oldVcpu = 0				; assume first time
	oldVelp = 0				;
	adjVcpu = 0				;
	mkPfil = fil = fopen (mkPspc, "rb+")	; open the file
	if fil eq <>				; fails
	   mkPfil = fil = fopen (mkPspc, "wb")	;
	   fine if that ne <>			; great
	   im_rep ("E-Error creating [%s]", mkPspc)
	.. fail					;
	tot = fread (&oldVelp, 1, #mkTelp, fil)	; elapsed time
	tot+= fread (&oldVcpu, 1, #mkTcpu, fil)	; old cpu time
	tot+= fread (&adjVcpu, 1, #mkTcpu, fil)	; cpu adjustment
	if tot ne (#mkTelp+#mkTcpu+#mkTcpu)	; some error
	.. im_rep ("W-Error reading [%s]", mkPspc);
	fine					; ignore read error
  end

code	mk_put - put current times

  func	mk_put
	()  : int
  is	fil : * FILE = mkPfil
	tot : int				; total written
	exit if fil eq <>			; create failed
	rewind (fil)				; rewind it
	tot = fwrite (&newVelp, 1, #mkTelp, fil); elapsed time
	tot+= fwrite (&newVcpu, 1, #mkTcpu, fil); cpu time
	tot+= fwrite (&adjVcpu, 1, #mkTcpu, fil); cpu adjust time
	fclose (fil)				; close it
	if tot ne (#mkTelp+#mkTcpu+#mkTcpu)	; some error
	.. im_rep ("W-Error writing [%s]", mkPspc);
	fine					; ignore error
  end
