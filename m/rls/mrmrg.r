file	mrmrg - buffer merging
include rid:rider
include rid:fidef
include rid:sbdef

date	mrTstm - object stream

  type	mrTcmp : (*void, *void) int

  type	mrTstm
  is	Vbas : long			; stream start
	Vend : long			; stream end
	Vnxt : long			; next object
  end

	mrSTM := 16

  type	mrTmrg
  is	Hfil : * FILE			; temp file
	Lfil : long			; length thereof
	Vtop : long			; next to write
	Vrem : long			; remaining 
					;
	Astm : [mrSTM] mrTstm		; stream array
	Pcur : * mrTstm			; current stream
	Vcur : int			; current stream
	Vcnt : int			; number of streams
	Vtot : int			; total streams
					;
	Pobj : * byte			; array of stream objects
	Lobj : size			; length of stream object
	Pcmp : * mrTcmp			;
  end

	mr_mrg : (*mrTmrg, size, *mrTcmp); setup to merge
	mr_clr : (*mrTmrg)		; clear streams
	mr_rew : (*mrTmrg)		; rewind streams
	mr_stm : (*mrTmrg)		; create new stream 
	mr_put : (*mrTmrg *void)	; append to stream
	mr_nth : (*mrTmrg,int,*void,size); get nth stream object
	mr_get : (*mrTmrg, *void)	; get next stream object

code	mr_mrg - setup to merge

  func	mr_mrg
	mrg : * mrTmrg
	siz : size
	cmp : * mrTcmp
  is	fil : * FILE
	fil = tm_fil (50*1024)
	pass fail
	mrg->Hfil = fil
	mrg->Lobj = siz
	mrg->Pcmp = cmp
	mrg->Vtot = mrSTM
	mr_clr (mrg)
  end

code	mr_clr - clear streams

  func	mr_clr
	mrg : * mrTmrg
	mrg->Vrem = mrg->Lrem
	mrg->Vtop = 0
	mrg->Vcur = 0
	mrg->Vcnt = 0
	mrg->Pcur = mrg->Astm

	if mrg->Pobj
	   me_dlc (mrg->Pobj)
	.. mrg->Pobj = <>
	mr_rew (mrg)
  end

code	mr_rew - rewind streams

  func	mr_rew
	mrg : * mrTmrg
  is	stm : * mrTstm = mrg->Astm
	cnt : int = mrg->Vtot
	mrg->Vstm = 0
	while cnt--
	   stm->Vnxt = stm->Vbas
	   ++stm
	end
  end

code	mr_stm - next stream

  func	mr_stm
	mrg : mrTmrg
  is	stm : * mrTstm = mrg->Astm + mrg->Vcur
	++mrg->Pcur if mrg->Vcnt
	++mrg->Vcnt
	mrg->Pcur->Vbas = fi_pos (mrg->Hfil)
  end

code	mr_put - write to stream file

  func	mr_put - write to stream
	mrg : * mrTmrg
	obj : * void
	siz : size
  is	fi_wri (mrg->Hfil, obj, siz)
	pass fail
	mrg->Pstm->Vtop = fi_pos (mrg->Hfil)
  end
	
code	mr_get - get one of n stream objects

  func	mr_get
	mrg : * mrTmrg
	obj : * void
  is	idx : int = 
	win : int = 0
	repeat
	   fail if idx ge mrg->Vstm
	   quit if !stm->
	   ++idx, ++stm
	forever	
	me_cop (mrg
	while idx lt mrg->Vstm
	   if (cmp)(obj, stm->Pobj) gt
	      me_cop ()
	   .. win = idx
	   ++idx
	end
  end
