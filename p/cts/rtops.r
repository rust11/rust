file	rtops - get operating system code
include	rid:crt
include	rid:osdef

  func	rt_ops
	ops : * rtTops~
  is	cod : int~ = 0
	xmm : int = rt_xmm ()		; XM system
	ops->Vfam = 0

	case rt_gvl (0)			; RMON signature
;	of 0000	 code = RSTS		;
	of 0167  cod = osRTJ		; RT-11/SJ
		 cod = osRTB if rt_fbm(); RT-11/FB
		 cod = osRTM if xmm	; RT-11/XM
		 ops->Vfam = osRTJ	; RT-11 family

	of 0137  cod = osRSJ		; RUST/SJ
		 cod = osRXM if xmm	; RUST/XM
		 ops->Vfam = osRSJ	; RUST family
	of 0240  cod = osRBT		; RUST/BT
		 ops->Vfam = cod	; RUSTboot family
	end case
	ops->Vcod = cod			;
	reply cod			; fail => unknown
  end

end file
