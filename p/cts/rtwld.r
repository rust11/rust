file	rtwld - scan wildcard entries
include rid:rider
include rid:fidef
include rid:stdef
include rid:rtdir

  func	rt_wld
	scn : * rtTscn~
	wld : * char
	spc : * char
	msg : * char
  is	while rt_nxt (scn, spc, msg)
	   fine if st_wld (wld, spc)		; got a match
	end
	fail
  end
