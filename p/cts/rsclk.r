file	rsclk - get RSX clock 
include rid:rider
include rid:tidef

  type	rsTtim
  is	Vyea : WORD
	Vmon : WORD
	Vday : WORD
	Vhou : WORD
	Vmin : WORD
	Vsec : WORD
	Vtik : WORD
	Vhtz : WORD
  end

  type	rsTgtm
  is	cod : WORD
	adr : * rsTtim
  end

	rsItim : rsTtim = {0}
	rsIgtm : rsTgtm = {61+(2*256), &rsItim}

  func	rs_clk
	val : * tiTval
  is	plx : tiTplx
	rsx : * rsTtim = &rsItim
	rs_emt (&rsIgtm, <>)
	plx.Vyea = rsx->Vyea 
	plx.Vmon = rsx->Vmon 
	plx.Vday = rsx->Vday 
	plx.Vhou = rsx->Vhou 
	plx.Vmin = rsx->Vmin 
	plx.Vsec = rsx->Vsec 
	plx.Vmil = rsx->Vtik * (1000/rsx->Vhtz)
	ti_val (&plx, val)
  end
