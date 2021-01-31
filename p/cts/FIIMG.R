file	fiimg - open image channel
include	rid:rider
include rid:fbdef

;	For use with rt_rea() and rt_wri()
;	(all they need is the channel #)
;	BOOT.R uses this 

  func	fi_img
	()  : * FILE
  is	fil : * fbTfil = me_acc (#fbTfil)
	fil->Vchn = 15			; the image channel
	reply fil
  end

