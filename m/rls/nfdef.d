header	nfdef - vamp network definitions
include	rid:eldef

;	   SAM	SHARE	Win32	prep	xvx
; prc	28 jid	va.prn	Vjid	qjnum	--	local process number
; chn	29 jcn	va.pch	Vjcn	0	chan	local process channel
;
;				cab
;	20 sid	va.nod	Vsid	nod	{node}	originator node
;	21 sjn	va.npn	Vsjn	0	{pid}	originator node process id
;
;	{node} & {pid} only from STAR satellites
;
;	Process EXPERT extension area
;
;	STAR, SHARE and SHAREplus append some additional information.
;	/pen/ precedes the guard word for compatibility with satellites.
;
;	.rad50	/filnamtyp/		;filename
;	.rad50	/pen/			;penultimate logical name
;	.rad50	/xvx/			;guard
;	.byte	0			;va.prn - local process number
;	.byte	0			;va.pch - local process channel
;	.byte	0			;va.nod - originator node
;	.byte	0			;va.npn - originator node process number

  type	nfTvab
  is	Vfun : elTbyt 	  ; 0 	; function
	Vflg : elTbyt	  ; 1	; flags
	Vcid : elTwrd ;CAB; 2	; channel handle
	Vsta : elTwrd	  ; 4 	; status
	Vlen : elTwrd	  ; 6 	; length or block
	Vdbc : elTwrd	  ; 8 	; data byte count (max = 512)
	Afna : [4] elTwrd ; 10 	; first filename
				; Overlay area	
	Vblk : elTwrd	  ; 18 	; block number or seqnum
	Vrwc : elTwrd	  ; 20 	; request word count (for caching)
	Vtwc : elTwrd	  ; 22 	; transfer word count
	Vfmt : elTwrd	  ; 24 	; format return from lookup
	Vvid : elTwrd ;PKT; 26 	; packet sequence id
	Vjid : elTbyt ;PRC; 28 	; client job number (zero for VRT)
	Vjcn : elTbyt ;CHN; 29	; client job channel number
			  ;     ; Checksums (unused by ethernet and VRT)
	Vhck : elTwrd	  ; 30 	; header checksum
	Vdck : elTwrd	  ; 32 	; data checksum
			  ; 34	; end of transmitted VAB info
			  ;	; Internal (fills out minimum ethernet size)
	Asrc : [6] BYTE	  ; 34	; source station address (win32)
	Pcab : * void	  ; 40	; name cab
	Vnod : elTbyt	  ; 44	; node number (zero for VRT)
	Vf00 : elTbyt	  ; 45	;
  end			  ; 46 	;

  type	nfTnam			; ACP name overlay
  is	Apad : [18] BYTE  ;	;
	Afnb : [1] elTwrd ; 18 	; actually [4]	rename
	Vsid : BYTE	  ; 20	; satellite id 	look/enter/delete
	Vsjn : BYTE   ;PRC; 21	; sat. job num.	look/enter/delete
	Af00 : [2] WORD	  ; 22	; remainder of Afnb
	Vpad : WORD	  ; 26	;
	Vsts : BYTE	  ; 28	; server status
	Vsys : BYTE	  ; 29	; server system type
	Anam : [2] WORD	  ; 30	; server rad50 node name
  end				

	nfETH := 14		; Ethernet header size
	nfVAB := 46		; VAB size

	nfSVR := 0303		; server status

	osDOS := 0130
	osW32 := 0140
	osSHP := 0324
	osVMS := 0171

	nfINF_ := BIT(2)	; has information (reply)
	nfSUB_ := BIT(3)	; sub-directory
	nfWLK_ := BIT(4)	; directory walk
	nfDSK_ := BIT(5)	; disk I/O
	nfINP_ := BIT(6)	; init process flag
	nfINI_ := BIT(7)	; init all flag

data	functions

	nfABO	:=  0		; error
	nfREA	:=  1		; read
	nfWRI	:=  2		; write
	nfLOO	:=  3		; lookup
	nfENT	:=  4		; enter
	nfCLO	:=  5		; close
	nfDEL	:=  6		; delete
	nfREN	:=  7		; rename
	nfSIZ	:=  8		; device size
	nfPUR	:=  9		; purge
	nfINF	:=  10		; file info
	nfCLZ	:=  11		; close with size
	nfINV   :=  12		; invalid packet
	nfMAX	:=  12		; max code

				; lookup format argument
	nfMNT	:= 040001	; mount file (permanent cab)
	nfDSM	:= 040002	; dismount file

data	status

	nfEOF   := 1		; end of file
	nfFNF   := 1		; file not found
	nfIOX   := 2		; i/o error
;	nfNSD   := 3		; no such device

	nfCSW_	:= (1 << 8)	; has CSW
	nfFNA_	:= (2 << 8)	; has filename
	nfDAT_	:= (4 << 8)	; has data (reply)
	nfSDA_	:= (8 << 8)	; sends data
	nfDIR_	:= (16 << 8)	; directory
	nfSPU_	:= (32 << 8)	; special user

	nf_ser : (*nfTvab) 	; service vab
	nf_tra : (int) void	; trace on/off
	nf_rep : (*nfTvab,*BYTE, int) void ; report vab

	nfPbuf : * char extern	; fudged buffer

end header
