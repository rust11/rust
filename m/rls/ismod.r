;	%unused%
file	ismod - I/O stream management
include	rid:rider
include	rid:medef
include	rid:isdef

code	is_alc -- allocate stream

  func	is_alc 
	add : int
	inc : int
	()  : * isTstm
  is	stm : * isTstm
	stm = me_acc (#isTstm)
	stm->Vadd + stm->Vinc
	stm->Pobj = me_acc (that * 4) ;
	stm->Vinc = inc
	stm->Vadd = add
	is_ini (stm)
	reply stm
  end

  func	is_ini
	stm : * isTstm
  is	stm->Vbot = stm->Vinc
	stm->Vcur = that
	stm->Vtop = that + stm->Vadd
  end

  func	is_dlc
	stm : * isTstm
  is	me_dlc (stm->Pobj)
	me_dlc (stm)
  end

  func	is_add
	stm : * isTstm
	obj : * void
  is	fail if stm->Vadd eq stm->Vtop
	fine stm->Pobj[stm->Vadd++] = obj
  end

  func	is_inc
	stm : * isTstm
	obj : * void
  is	fail if stm->Vcur eq
	fine stm->Pobj[--stm->Vcur] = obj
  end

  func	is_cur
	stm : * isTstm
	()  : * void
  is	fail if stm->Vcur eq stm->Vadd
	reply stm->Pobj[stm->Vcur]
  end

  func	is_stp
	stm : * isTstm
  is	fail if (stm->Vcur+1) eq stm->Vadd
	fine ++stm->Vcur
  end
  