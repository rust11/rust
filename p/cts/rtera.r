file	rtera - RT-11 bulk block erase file
include	rid:rider
include rid:medef
include rid:fidef
include	rid:imdef
include rid:rtdir

code	rt_era - bulk block erase file

  func	rt_era
	fil : * FILE
	blk : WORD		; start block
	cnt : WORD		; block count
	flg : int		; later
  is	reply rt_trn (<>, fil, 0, blk, cnt, 0)
  end
