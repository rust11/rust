header	dcdef - DCL engine

  type	dcTitm : forward

  type	dcTdcl
  is	Venv : int		; command environment (see below)
	Vsta : int		; status of last operation
	Vflg : int		; command result flags (15)
	Verr : int 		; error count (internal)
	Pitm : * dcTitm		; item (from parse)
	Vqua : int		; qualifier flags (from parse)
	Pqua : * dcTitm		; qualifier list
				;
	Plin : * char		; command line
	Prem : * char		; remainder of command
	Pobj : * char		; current object
	Aobj : [32] char	; object buffer
	Alin : [82] char	; command/remainder line buffer
  end
				; environment
	dcCLI_ := BIT(1)	; get CLI command
	dcCLS_ := BIT(2)	; CLI command is single-line mode
	dcSIN_ := BIT(3)	; single-line command
	dcNKW_ := BIT(4)	; no keyword
	dcDBG_ := BIT(5)	; debug displays
	dcNUL_ := BIT(6)	; null commands accepted
;sic]	dcFIN_ := BIT(11)	; command done (see dcTitm Vctl dcFIN_)

  type	dcTfun : (*dcTdcl) int	; DCL function

; Level Idt=(Vrb|Kwd|Qua)	Fun	P1  V1	   Flg

  type	dcTitm			; keyword dispatch block
  is	Vlev : int		; nesting level
	Pkwd : * char		;\keyword
	Pfun : * (*dcTdcl) int	;|function
 	P1   : * void		;|pointer
	V1   : int		;|value
	Vctl : int		;/control: type|flags
  end
				; flags
;	|ctl|...|typ|flg

;		  0:15		; set one of 15 "marks" in dcl->Vmrk

	dcFLG_ := 0x0f		; 15 flags (0 is unused)

	dcTYP_ := 0x70		; type (1 of 16)
	dcTRS  := 4		; type right shift
				; dc_atr/dc_val codes
	dcNOP  := 0x00		; nop
	dcOCT  := 0x10		; octal
	dcDEC  := 0x20		; decimal
	dcHEX  := 0x30		; hex
	dcR50  := 0x40		; rad50
	dcSTR  := 0x50		; string
	dcSPC  := 0x60		; file spec
;	dcXXX  := 0x70		; 
				; dc_set codes
	dcSET  := 0x10		; set - val  = V1  (default)
	dcBIS  := 0x20		; bis - val |= V1
	dcBIC  := 0x30		; bic - val &= ~V1
	dcAND  := 0x40		; and - val &= V1
	dcNEG  := 0x50		; neg - val = -val
;	dcXXX  := 0x60		;
				;
;	dcCTL_ := 0xff80	;
; ?	dcXXX_ := BIT(8)	;
; ?	dcXXX_ := BIT(9)	;
; ?	dcPUR_ := BIT(10)	; pure - don't clear *P1 during init
	dcFIN_ := BIT(11)	; command is finished (error free)
	dcDFT_ := BIT(12)	; V1 is default value for dc_set
	dcOPT_ := BIT(13)	; optional field or optional attribute/value
	dcNST_ := BIT(14)	; time to nest
	dcEOL_ := BIT(15)	; must be end of line
				;
				; syntax	
	dcAidt : [] char+	; identifier keyword
	dcAspc : [] char+	; file spec filter

	dc_eng : (*dcTdcl, *dcTitm, *char)+
	dc_alc : (void) *dcTdcl+; allocate
	dc_dlc : dcTfun+	; deallocate
	dc_ini : dcTfun+	; init for next command
				; DCL engine
	dc_act : dcTfun+	; interpret action list
	dc_kwd : dcTfun+	; process keywords
	dc_qua : dcTfun+	; process qualifiers
	dc_fld : dcTfun+	; parse field
	dc_atr : dcTfun+	; attribute (=value)
	dc_val : dcTfun+	; process value
	dc_set : dcTfun+	; set value

;	callback routines

	dc_inv : dcTfun+	; invalid command
	dc_rep : dcTfun+	; image report 
	dc_exi : dcTfun+	; EXIT command
	dc_hlp : dcTfun+	; HELP command
	dc_fin : dcTfun+	; NOP function, returning FINE

end header
end file
