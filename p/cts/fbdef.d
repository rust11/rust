header	fbdef - CRT fileblock

	FILE := fbTfil		; replace default <*void> definition

  type	fbTfil
  is	Vflg : WORD		; flags 		
	Vchn : BYTE		; channel 		
	Verr : BYTE		; error code, if any
	Pman : * void		; manual driver
	Pptr : * char		; manual pointer
	Vcnt : WORD		; also rt_rea/rt_wri result r0
				; file:
	Pspc : * char		; file spec pointer
	Vdsw : WORD		; device status word
	Vdrv : WORD		; driver address (for release)
	Vlen : WORD		; file block length (or device length)
				; end-of-file:
	Vebl : WORD		; end-of-file block
	Vebt : WORD		; end-of-file byte
				; position:
	Vblk : WORD		; current block
	Vbyt : WORD		; current byte 
				; buffer:
	Pbuf : * char		; buffer pointer
	Vbsz : WORD		; buffer size
  end
				; open mode:
	fbNEW_ := BIT(0)	; w new file (close, not purge)
	fbBIN_ := BIT(1)	; b binary i/o, otherwise text i/o
	fbPHY_ := BIT(2)	; p physical (write file-structured device)
				; 3 4 5	
	fbRON_ := BIT(6)	; no-write
	fbOPN_ := BIT(7)	; file open for business
				; device:
	fbSEQ_ := BIT(8)	; sequential, else block-oriented
	fbTER_ := BIT(9)	; terminal - stdin or stdout
	fbMAN_ := BIT(10)	; manual control
				; stream engine:
	fbWRI_ := BIT(11)	; file written, requires close
	fbFLU_ := BIT(12)	; buffer written, requires flush
	fbBUF_ := BIT(13)	; buffer valid
	fbERR_ := BIT(14)	; some error
	fbEOF_ := BIT(15)	; EOF
	EOF := (-1)		; EOF constant

;	manual control
;
;  func	mn_xxx		0(sp)  return
;	fil : * FILE	2(sp) r4 -> file
;	opr : int	4(sp)	
;	P1  : word	6(sp) r0 = p1
;	P2  : word	8(sp) r1 = p2
;		...

	fbGET := 1	;out r0=byte	; get 
	fbPUT := 2	;in  p1=byte	; put 
	fbOPN := 3	;    p1=*ext	; open (not called yet)
	fbCLO := 4	;in  p1=*ext	; close
	fbSEE := 5	;in  p1/p2=pos	; seek
	fbPOS := 6	;out r0/r1=pos	; position
	fbFLU := 7	;		; flush

end header
