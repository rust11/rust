file	rnmod - random numbers
include rid:rider
If Win
include rid:tidef
Else
include rid:rttim
End

;	Seed created from current time and date.
;	Date and time may be static in some environments.
;	An alternative would be to store a seed in a file and
;	update the seed using a different random algorithm.
;
;	rt_gtm used in RUST environment so that we don't 
;	pull in the rather large time library routines.

	rnVfst : int = 1
	rnVnum : int = 0

  func	rn_see
	see : int~
  is
If Win
	plx : tiTplx
	val : tiTval
	fine if !see && !rnVfst
	rnVfst = 0
	if eq see
	   ti_clk (&val)
	   ti_plx (&val, &plx)
	.. see = ((plx.Vsec<<8)|plx.Vmil)^(plx.Vmin<<12)
Else
	tim : rtTtim
	fine if !see && !rnVfst
	rnVfst = 0
	if eq see
	   rt_gtm (&tim)
	.. see = (tim.Vdat^tim.Vlot)^(tim.Vhot<<7)
End
	rnVnum = see
  end

  func	rn_rnd
	()  : int
  is	rn_see (0) if rnVfst
	rnVnum = ((rnVnum * 7621) + 1) % 0x8000
	reply rnVnum
  end

end file

	rnVz : int = 0
	rnVw : int = 12345

  func	cu_ran
  is	rnVz = 36969 * (rnVz & 65535) + (rnVz >> 16)
	rnVw = 18000 * (rnVw & 65535) + (rnVw >> 16)
	reply (rnVz<<16) + rnVw
  end

  func	cu_see
	see : int
  is	rnVz = ti_cpu (<>)
	rnVw = cu_ran ()
  end
