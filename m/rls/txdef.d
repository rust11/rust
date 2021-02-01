header	txdef - text routines

If wsSVR
  type	txTtxt
  is	Hwnd : HGLOBAL
	Hfnt : HFONT
	Sfnt : LOGFONT
  end
Else
  	txTtxt	:= void
End

  type	txTbuf
  is	Ptxt : * txTtxt		; text parent
	Pdat : * char		; start of data
	Vtot : size		; total size
	Vflg : int		; some flags
	Vbot : size		; page bottom
	Vlim : size		; page end
	Vtop : size		; logical top
	Vbeg : size		; section begin
	Vend : size		; section end
	Adat : [1] char		; for local data
  end

	tx_cmp	:= "Use st_dif (...)"
	tx_cop	:= "Use st_cln (...)"

;	Text window object

	tx_cre	: (*wsTevt) *txTtxt			; create
	tx_des	: (*wsTevt, *txTtxt) int		; destroy
	tx_loa	: (*wsTevt, *txTtxt, *char, int) int	; load file
	txINS_	:= BIT(0)				; insert file
	tx_sto	: (*wsTevt, *txTtxt, *char, int) int	; store file
	txSEL_	:= BIT(1)				; write selected area
	tx_clo	: (*wsTevt, *txTtxt)			; close text
	tx_fun	: (*wsTevt, *txTtxt, int)		; function
	txUND	:= 1
	txCUT	:= 2
	txCOP	:= 3
	txPAS	:= 4
	txDEL	:= 5
	txALL	:= 6
	txCLO	:= 7
	tx_fnt	: (*wsTevt, *txTtxt, *wsTfnt) *wsTfnt	; set font

	tx_get	: (*wsTevt, *txTbuf) int		; get text area
	tx_set	: (*wsTevt, *txTbuf) int		; set text area
	tx_fnd	: (*wsTevt, *txTbuf, int, *char)	; find string
	tx_ipt	: (*wsTevt, *txTtxt, *char, int)	; input string
	tx_opt	: (*wsTevt, *txTtxt, *char, int)	; output string
	tx_chk	: (*wsTevt, *txTtxt)			; get modified state

end header
