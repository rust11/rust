file	sbsto - storage buffers
include rid:rider
include rid:medef
include rid:sbdef
include rid:stdef

code	sb_ini - init store

  func	sb_ini
	alc : size
	itm : size			; item size
	cmp : * sbTcmp
	()  : * sbTsto
  is	sto : * sbTsto~
	sto = me_acc (#sbTsto)
	sto->Psto = me_alc (alc)
	sto->Ptmp = me_alc (itm)
	sto->Pcmp = cmp

	sto->Lsto = alc
	sto->Litm = itm
	sb_clr (sto)
	reply sto
  end

code	sb_dlc - deallocate store

  func	sb_dlc
	sto : * sbTsto
  is	me_dlc (sto->Psto)
	me_dlc (sto)
  end

code	sb_clr - clear store

  func	sb_clr
	sto : * sbTsto~
  is	sb_rew (sto)
	sto->Ptop = sto->Psto
	sto->Lrem = sto->Lsto
	sto->Vcnt = 0
  end

code	sb_rew - rewind store

  func	sb_rew
	sto : * sbTsto~
  is	sto->Pcur = sto->Psto
	sto->Vcur = 0
  end

code	sb_sto - append object to store

  func	sb_sto
	sto : * sbTsto~
  	obj : * void
  is
	fail if sto->Lrem lt sto->Litm
	me_cop (obj, sto->Ptop, sto->Litm)
	sto->Ptop = sto->Ptop + sto->Litm
	sto->Lrem -= sto->Litm
	++sto->Vcnt
	fine
  end

code	sb_nxt - get next store object

  func	sb_nxt
	sto : * sbTsto
 	obj : * void
  is	fail if sto->Vcur ge sto->Vcnt
	me_cop (sto->Pcur, obj, sto->Litm)
	sto->Pcur = sto->Pcur + sto->Litm
	++sto->Vcur
	fine
  end

code	sb_srt - sort the store

  func	sb_srt
	sto : * sbTsto
  is
If Pdp
	qsort (sto->Psto, sto->Vcnt, sto->Litm, sto->Pcmp)
End
  end
code	sb_rev - reverse store

  func	sb_rev
	sto : * sbTsto~
  is	tmp : * char = sto->Ptmp
	bot : * char = sto->Psto
	top : * char
	siz : size~ = sto->Litm
	cnt : int = sto->Vcnt
	top = bot + (siz * (cnt - 1))
	while cnt ge 2
	   me_cop (bot, tmp, siz)
	   me_cop (top, bot, siz)
	   me_cop (tmp, top, siz)
	   top -= siz, bot += siz
	   cnt -= 2
	end
  end

