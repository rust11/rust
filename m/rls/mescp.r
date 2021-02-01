file	mescp - scope a buffer
include	rid:rider
include	rid:medef

  func	me_scp
	min : size~			; minimum usuable
	max : size~			; max required (optional)
	res : size			; reserve this much
	()  : size			; result size
  is	avl : size~
If Win
	reply max			; never a problem
Else
	avl = me_max ()			; get max available
	fail if avl lt (min+res)	; not enough space
	avl -= res			; reserve the space
	avl = max if max && (avl gt max); limit it	
	reply avl
End
  end
