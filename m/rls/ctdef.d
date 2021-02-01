header	ctdef - character types
include	rid:rider

; Note:	Rider treats $ and _ as alphabetic and alphanumeric.
;
;	alp	AZ az 
;	dig	         09
;	hex	AF af    09
;	aln	AZ az $_ 09

	ctCTL_ := (0)
	ctUPR_ := (1<<0)		; uppercase letter
	ctLOW_ := (1<<1)		; lowercase letter
	ctDIG_ := (1<<2)		; digit
	ctPUN_ := (1<<3)		; punctuation
	ctIDN_ := (1<<4)		; identifier $ and _
	ctSPC_ := (1<<5)		; space
	ctPRN_ := (1<<6)		; printing
	ctHEX_ := (1<<7)		; hex digit
					;
	ctLET_ := (ctUPR_|ctLOW_)	; letter
	ctALP_ := (ctUPR_|ctLOW_|ctIDN_); alphabetic -- initial identifier
	ctALN_ := (ctALP_|ctDIG_)	; alphanumeric
	ctGRA_ := (ctALN_|ctPUN_)	; graphic
					;
	ctAtab : [128] BYTE+		;

	ctTST(cha,msk) := (ctAtab[(cha)&0177] & (msk))

	ct_aln(cha) := (ctTST(cha, ctALN_))
	ct_alp(cha) := (ctTST(cha, ctALP_))
	ct_ctl(cha) := (ctTST(cha, ctPRN_))
	ct_dig(cha) := (ctTST(cha, ctDIG_))
	ct_idn(cha) := (ctTST(cha, ctIDN_))
	ct_gra(cha) := (ctTST(cha, ctGRA_))
	ct_hex(cha) := (ctTST(cha, ctHEX_))
	ct_let(cha) := (ctTST(cha, ctLET_))
	ct_low(cha) := (ctTST(cha, ctLOW_))
	ct_pun(cha) := (ctTST(cha, ctPUN_))
	ct_spc(cha) := (ctTST(cha, ctSPC_))
	ct_upr(cha) := (ctTST(cha, ctUPR_))
	ct_whi : (int) int

end header
