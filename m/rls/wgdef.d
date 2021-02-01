header	wgdef - windows client/server generic definitions

;	These definitions are common to server and client
;
;	wcdef and wsdef define wsTcal, wsTctx etc differently
;	before including this module.

  type	wsTast	: (*wsTevt, *wsTfac) int
  type	wsTfac			; facility
  is	Psuc : * wsTfac		; next facility
	Anam : [16] char	; facility name
	Vflg : int		; some flags
	Past : * wsTast		; ast
	Pusr : * void		; pointer to user data
	Vusr : int		; user value
  end
	ws_fac : (*wsTevt, *char) *wsTfac; create facility
	ws_dis : (*wsTevt) LONG

	ws_cod : wsTcal			; extracts command code
;	ws_pch : (int) void		; putchar replacement
;	ws_prt : (*char const, ...)	; printf replacement

;	Cusp callback routines

	wc_mai : wsTcal			; preset things
	wc_bld : (*wsTevt, *char) int	; build image
	wc_cre : wsTcal			; create window bypass
	wc_cmd : wsTcal			; dispatch command (defaults)
	wc_mou : wsTcal			; client mouse
	wc_pnt : wsTcal			; paint window bypass
	wc_qui : wsTcal			; quit bypass
	wc_loo : wsTcal			; client loop
	ws_loo : wsTcal			; server-driven loop
	wc_fnd : (*wsTevt,int,int,*char,*char) ; find ast
					;
	ws_ctx : (void) *wsTctx		; get context
	ws_evt : (void) *wsTevt		; get dummy event
	ws_cod : wsTcal			;
	ws_pee : (*wsTevt, int) int	; peek/execute next message
	ws_upd : wsTcal			; initiate screen update
	wc_exi : wsTcal			;
	ws_exi : wsTcal			;
					;
	ws_run : (*char, int) int	; run a program
	ws_msg : (*char, *char) int	; message out
	ws_dec : (*char, int) int	; decimal message
	ws_lnk : (void) int		; link to server
					;
	wsDIH := 1			; display inner height
	wsDIW := 2			; display inner width
	wsDSX := 10			; display screen X origin
	wsDSY := 11			; display screen Y origin
	wsDTH := 12			; desktop height
	wsDTW := 13			; desktop width
	wsCLR := 14			; clear window before paint
	wsMIN := 15			; minimize on/off
	wsBOX := 16			; window box style
	wsSTY := 17			; style
	wsCLA := 18			; class
	wsBUT := 19			; button class
	wsCMD := 20			; command string
	wsCHH := 21			; char height
	wsCHW := 22			; char width
	wsBOW := 23			; black on white
	wsDEV := 24			; event device
					;
	ws_int : (*wsTevt, int) int	; int information services
	ws_str : (*wsTevt, int) *char	; string information services
					;
	wsPNT := 3			; repaint screen later
	ws_set : (*wsTevt, int, int) int ; set flags
	ws_mov : (*wsTevt)		; move to context position
	ws_pnt : wsTcal			; repaint screen now
	ws_tit : (*wsTevt, *char)	; set window title
					;
	gr_beg : wsTcal			; begin
	gr_end : wsTcal			; end
	gr_pol : (*wsTevt,*long,int) int; draw polyline
	gr_txt : (*wsTevt, int, int, *char) int ; draw text
	gr_txw : (*wsTevt, int, int, *WORD, int) int ; draw text
	gr_col : (*wsTevt, int, int) int; set paper/ink palette colours
	gr_fnt : (*wsTevt, int) int	; setup font
	gr_car : (*wsTevt, int, int, int) int
	grHID  := 0			; hide caret
	grSHO  := 1			; show caret
	grBLK  := 2			; create black caret
	grGRY  := 3			; create grey caret
	grPOS  := 4			; position caret
	grFOC  := 5			; SET FOCUS
	grKIL  := 6			; KILL FOCUS
	wsTfnt := void			; yuk
	gr_sel : (*wsTevt, *wsTfnt) int ; select font
	gr_uns : (*wsTevt, *wsTfnt) int ; unselect font
					;
	tm_sta : (*wsTevt, long,*wsTcal); start timer
	tm_stp : (*wsTevt)		; stop timer
end header
