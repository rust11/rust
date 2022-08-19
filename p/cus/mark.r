;???;	WUS:MARK and CUS:MARK are quite different beasts
hun$c := 1
file	mark - marktime utility
include rid:rider
include	rid:imdef
include	rid:stdef
include	rid:chdef
include	rid:tidef
include	rid:timat
include	rid:fidef
include	rid:cldef
include	rid:mxdef
include	rid:qddef

If Win
	ti_sub (x, y, z) := (z = y - x)
Else
;	include	rid:qddef
;	ti_sub (x, y, z) := qd_sub (<*WORD>(x),<*WORD>(y),<*WORD>(z)) 
End

;	%build
;	rider cus:mark/object:cub:
;	link cub:mark/exe:cub:mark/map:cub:,lib:crt/bot=2000/cross
;	%end
;
;	Mark time utility
;
;	Wall: 12:25:30  Mark: 1.2   Cpu: 0.12
;
;	Wall time is current wall clock time
;	Mark time is elapsed wall clock time
;	Cpu time is elapsed compute time
;
;	Negative times are reported

	mkIsta	: tiTval = {0} 		; start time
	mkIold	: tiTval = {0} 		; old time
	mkInew	: tiTval = {0} 		; new time
	mkIelp	: tiTval = {0} 		; cpu adjustment
	mkItot  : tiTval = {0} 		;
	mkIadj	: tiTval = {0} 		; cpu adjustment
					;
If Win
	mkPspc	: * "c:\\mark.tmp"	; temp file
Else
	mkPspc	: * "sy:mark.tmp"	; temp file
End
	mkPfil	: * FILE = <>		; file handle

	mk_hlp	: () void
	mk_sho	: () void
	mk_rep	: () void
	mk_dis  : (*tiTval, int) void
	mk_get	: () int
	mk_put	: () int

data	mkAcmd - command array

	mkDEF := 0
	mkADJ := 1
	mkHLP := 2
	mkRST := 3
	mkSHO := 4
	mkSTA := 5
	mkINV := 6

  init	mkAcmd : [] * char
  is	""		; default - no command
	"a*djust"
	"h*elp"
	"r*eset"
	"sh*ow"
	"st*art"
	<>
  end
code	main 

  func	start
  is	cnt : int			; argument count
	arg : [mxLIN] char		; command

	im_ini ("MARK")			; setup for errors

	ti_clk (&mkInew)		; get clock time first
	mk_get ()			; old times
					;
	if ti_cmp (&mkIold, &mkInew) gt       ; don't go negative
	   PUT("?MARK-W-Time has gone backwards, resetting\n")
	   ti_mov (&mkInew, &mkIold)
	.. ti_mov (&mkInew, &mkIsta)	

	ti_sub (&mkIold, &mkInew, &mkIelp)    ; get difference (elapsed time)

	if ti_cmp (&mkIelp, &mkIadj) ge       ; don't go negative
	.. ti_sub (&mkIadj, &mkIelp, &mkIelp) ; remove adjustment

	ti_sub (&mkIsta, &mkInew, &mkItot)    ; total elapsed time
	if ti_cmp (&mkItot, &mkIadj) gt	      ; don't go negative
	.. ti_sub (&mkIadj, &mkItot, &mkItot) ; remove adjustment
					
	cl_cmd (<>, arg)		; pickup the command
					
	case cl_loo (arg, mkAcmd, <>)	; lookup command (none negated)
	of mkDEF  mk_rep ()		; default: tell and start
		  mk_put ()		;
	of mkADJ  mk_rep ()		; adjust time
		  me_cop (&mkIelp, &mkIadj, #tiTval)
		  mk_put ()		;
	of mkHLP  mk_hlp ()		; help
	of mkRST  me_clr (&mkIadj, #tiTval)
		  mk_put ()		;
	of mkSHO  mk_sho ()		; show
	of mkSTA  ti_mov (&mkInew, &mkIsta)
		  me_clr (&mkIelp, #tiTval)
		  me_clr (&mkItot, #tiTval)
		  mk_put ()		; start
		  mk_rep ()		;
	of other			;
	   im_rep ("E-Invalid command [%s]", arg)
	   im_exi ()			;
	end case			;
	im_exi ()			; exit with status
  end
code	mk_hlp - show help

  proc	mk_hlp
  is	PUT ("\n")
	PUT("MARK - RUST Mark Time utility MARK.SAV V3.2\n")
	PUT ("\n")
	PUT("MARK          Displays wall, full and elapsed mark times\n")
	PUT("MARK ADJUST   Subtracts mark time from later mark times\n")
	PUT("MARK HELP     Displays this information\n")
	PUT("MARK RESET    Resets adjustment to zero\n")
	PUT("MARK SHOW     Displays internal variables\n")
	PUT("MARK START    Restarts mark timers\n")
	PUT ("\n")
	PUT("Where:\n")
	PUT ("\n")
	PUT("  Wall time   is the wall clock time\n")  
	PUT("  Full time   is the time since the last MARK START\n")
	PUT("  Mark time   is the time since the previous MARK command\n")
	PUT("\n")
	PUT("MARK stores time information in the file HOM:MARK.TMP\n")
  end

code	mk_sho - show internal variables

;	Ticks
;	Adjustment

  proc	mk_sho
  is	PUT("?MARK-I-Start time: ")
	mk_dis (&mkIsta, 2)
	PUT("\n")

	PUT("?MARK-I-Adjustment: ")
	mk_dis (&mkIadj, 1)
	PUT("\n")

	PUT("?MARK-I-Tick rate:  %d\n", rt_htz ())
  end
code	mk_rep - report times

  proc	mk_rep
  is	plx : tiTplx

	PUT("Wall: ")
	mk_dis (&mkInew, 0)

	PUT("  Full: ")
	mk_dis (&mkItot, 1)

	PUT("  Mark: ")
	mk_dis (&mkIelp, 1)

	PUT("\n")
  end

code	mk_dis - display time

  proc	mk_dis
	tim : * tiTval				; ticks
	dif : int		; 1=> show days, 2=>show year
  is	buf : [mxLIN] char
	plx : tiTplx
	day : long

	ti_plx (tim, &plx)

	case dif
	of 0  nothing
	of 1  ti_dys (tim, &day)
	      PUT("%ld ", day) if day ne
	of 2  ti_dat (&plx, buf)
	      PUT("%s ", buf)
	end case

	PUT("%02d:%02d:%02d", 
	plx.Vhou, plx.Vmin, plx.Vsec)

If hun$c
	PUT(".%02d", plx.Vmil/10)
End
  end
code	mk_get - get previous times

  func	mk_get
	()  : int
  is	fil : * FILE
	tot : int				; total read
	me_clr (&mkIsta, #tiTval)
	me_clr (&mkIold, #tiTval)
	me_clr (&mkIadj, #tiTval)

	if !(fil = fi_opn (mkPspc, "rb+", <>))	; open file
	   ti_mov (&mkInew, &mkIsta)		; is none, setup new file
	   ti_mov (&mkInew, &mkIold)		; fudge that
	.. fail mk_put ()			; and store it

	if !fi_rea (fil, &mkIsta, #tiTval)	; start time
	|| !fi_rea (fil, &mkIold, #tiTval)	; old time
	|| !fi_rea (fil, &mkIadj, #tiTval)	; adjustment time
	.. im_rep ("W-Error reading [%s]", mkPspc);
	fi_clo (fil)
	fine					; ignore read error
  end

code	mk_put - put current times

  func	mk_put
	()  : int
  is	fil : * FILE = mkPfil

	mkPfil = fil = fi_opn (mkPspc, "rb+", <>); open file
	if !fil				; fails
	   if !(mkPfil = fil = fi_opn (mkPspc, "wb"))
	.. .. fail im_rep ("E-Error creating [%s]", mkPspc)
	if !fi_wri (fil, &mkIsta, #tiTval)	; start time
	|| !fi_wri (fil, &mkInew, #tiTval)	; (new) old time
	|| !fi_wri (fil, &mkIadj, #tiTval)	; adjustment time
	.. im_rep ("W-Error writing [%s]", mkPspc);
	fi_clo (fil)
  end
