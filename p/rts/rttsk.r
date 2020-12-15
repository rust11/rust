rxm$c := 0
file	rttsk - make RTX.TSK task image
include	rid:rider
include rid:fidef

;	%build
;	rider rts:rttsk/object:rtb:
;	link rtb:rttsk/exe:rtb:/map:rtb:,lib:crt
;	%end

If rxm$c
	rtLEN := 65536L-4096L-(512L*2)
Else
	rtLEN := 65536L-(512L*2)
End

  func	start
  is	sav : * FILE
	stb : * FILE
	tsk : * FILE
	len : long
	cha : int
	im_ini ("RTTSK")

	sav = fi_opn ("rtb:rtx.sav", "rb", "")
	exit if fail
	stb = fi_opn ("rtb:rtstb.tsk", "rb", "")
	exit if fail
	tsk = fi_opn ("rtb:rtx.tsk", "wb", "")
	exit if fail
	len = 512L*4L
	while len-- ne
	   cha = fi_gtb (stb)
	   fi_ptb (tsk, cha)
	end
	len = rtLEN
	fi_see (sav, 512L*2)
	while len-- ne
	   cha = fi_gtb (sav)
	   fi_ptb (tsk, cha)
	end
	fi_clo (tsk, "")
  end
