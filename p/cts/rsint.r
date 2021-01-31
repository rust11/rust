file	rsint - stop/start RTX interrupts
include	rid:rider
include	rid:tidef
include	rid:qddef

;	RTX may run a different time to the host RSX system
;
;	Stop	Delta = RTX time - RSX time
;	Start	RTX time = RSX time + Delta
;
; ???	Need to catch exit to force clock restart

	rsIdif : tiTval- = {0}

  func	rs_int
  	opr : int			; 0 => stop, 1 => start
  is	dif : * tiTval = &rsIdif
	rsx : tiTval
	rtx : tiTval

	if opr eq
	   ti_clk (&rtx)		; rtx = RUST time
	   rs_clk (&rsx)		; rsx = RSX time
	   qd_sub (&rsx, &rtx, dif)	; dif = RTX - RSX
	   rs_stp ()			; stop clock
	else				;
	   rs_clk (&rsx)		; rsx = RSX time
	   qd_add (dif, &rsx, &rtx)	; rtx = RSX + dif
	   ti_set (&rtx)		; set RTX time
	   rs_sta ()			; start clock
	end
  end

