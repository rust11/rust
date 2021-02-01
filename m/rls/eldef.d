header	eldef - pdp-11 basics

  type	elTwrd	: WORD
  type	elTbyt	: BYTE
  type	elTlng	: LONG
  type	elTadr	: LONG

	elADR_ := 0x1ffff	; masks
	elADE_ := 0x1fffe	; even address
	elWRD_ := 0xffff	;
	elBYT_ := 0xff		;
;?	elINS_ := 0x8000	; I-space flag

	elT_	:= BIT(4)
	elN_	:= BIT(3)
	elZ_	:= BIT(2)
	elV_	:= BIT(1)
	elC_	:= BIT(0)
	elPRI_	:= 0340
	elPRV_	:= 0030000
	elCUR_	:= 0140000

	veBUS	:= 04
	veCPU	:= 010
	veBPT	:= 014
	veIOT	:= 020
	vePWF	:= 024
	veEMT	:= 030
	veTRP	:= 034
	veKBD	:= 060
	veTER	:= 064
	veCLK	:= 0100
	vePAR	:= 0114
	vePRQ	:= 0240
	veFPU	:= 0244
	veMMU	:= 0250

end header
