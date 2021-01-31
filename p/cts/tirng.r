file	tirng - range check plex
include rid:rider
include rid:medef
include rid:tidef

code	ti_rng - range check plex

;	DecusC does not implement unsigned longs.

	YEA := 2097151L

  func	ti_rng
	src : * tiTplx~		; source plex to check/edit
	plx : * tiTplx~		; result plex, may be same as src
  is	res : int~ = 1
	me_cop (src, plx, #tiTplx)
	res = 0, plx->Vyea = YEA if ((plx->Vyea lt) || (plx->Vyea gt YEA))
	res = 0, plx->Vmon = 13 if <unsigned>plx->Vmon gt 12
	res = 0, plx->Vday = 0 if <unsigned>plx->Vmon gt 31
	res = 0, plx->Vhou = 0 if <unsigned>plx->Vhou gt 24
	res = 0, plx->Vmin = 0 if <unsigned>plx->Vmin gt 60
	res = 0, plx->Vsec = 0 if <unsigned>plx->Vsec gt 60
If Win
	res = 0, plx->Vmin = 0 if <unsigned>plx->Vmil ge 1000
End
	reply res
  end
