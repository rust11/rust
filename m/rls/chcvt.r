file	chcvt - eight-bit character conversion
include rid:rider
include rid:chdef
include rid:ctdef

	chLOW := -1
	chSWI := 0
	chUPR := 1

  func	ch_cvt
	cha : int~
	cvt : int~
  is	cha &= 255
	if cha lt 128
	   if ct_upr (cha)
	      cha = ch_low (cha) if cvt ne chUPR
	   elif ct_low (cha)
	   .. cha = ch_upr (cha) if cvt ne chLOW
	else
	   if (cha ge 192) && (cha le 222) && (cha ne 215)
	      cha |= 32 if cvt ne chUPR
	   elif (cha ge 224) && (cha le 254) && (cha ne 247)
	   .. cha &= ~(32) if cvt ne chLOW
	end
	reply cha
  end
