header	wsdef - server module definitions
include rid:wimod

;	Redefine as two records
;	One holds all the window's specific stuff
;
;	User program must reference at least ws_lnk ()
;	to invoke this library.

	wsSVR := 1		; set server. Also inhibits wcdef

  type	wsTctx : forward	;

  type	wsTevt 			; Windows event
  is	Hwnd : HWND		; window handle
	Vmsg : UINT		; message
	Vwrd : UINT		; word parameter
	Vlng : LONG		; long parameter
				; paint
	Hdev : HDC		; device context
	Ipnt : PAINTSTRUCT ;???	; paint structure
	Pctx : * wsTctx	   ;^^^	; our context
	Hchd : HWND	   ;---	; event child window
  end

  type	wsTcar
  is	Vfoc : int 		; window has focus
	Vcre : int 		; caret is created
	Vvis : int		; caret is visible counter
	Vsho : int		; app want's it shown
	Vren : int		; caret rendition
	Vcol : int		; position
	Vrow : int		;
  end

  type	wsTfac : forward	;
  type	wsTcal : (*wsTevt) int	; standard call
  type	wsThan : * void		;
  type	wsTdev : wsThan		;

  type	wsTctx
  is	Hins : HANDLE		; window instance
	Hprv : HANDLE		; previous instance, if any
	Pcmd : LPSTR	;--	; the command string
	Vsho : int	;--	; show flag for initial update

;	setup by standard routines

	Hwnd : HWND		; window handle
	Vhgt : int		; height
	Vwid : int		; width
	Pmen : * void	;--	; menu context -- set mnmod

;	client setup

	Xcla : LPSTR	;???	; class name
	Xwnd : LPSTR	;???	; window name
	Xmen : LPSTR	;???	; menu name
	Xico : LPSTR	;???	; icon name
				;
	Vpnt : int		; set to force repaint
	Harr : HCURSOR	;--	; arrow 
	Hhou : HCURSOR	;--	; hourglass

	Vlft : size		; display window left
	Vtop : size		; display window top
				;
	Ptim : * wsTcal	;--	; timer ast pointer
	Hchd : HWND	;--	; current child window
	Vclr : int	;??	; clear screen before paint
	Pfac : * wsTfac		; facility list
	Vmin : int 		; minimized state
	Vsty : int		; style
	Vcla : int		; class
	Vchh : int		; char height
	Vchw : int		; char width
	Pkbd : * void		; keyboard buffer (kbdef.d)
	Ievt : wsTevt		; dummy event
	Vbow : int		; black on white
	Hbru : HBRUSH		;
	Hpen : HPEN		;
	Icar : wsTcar		; caret
;	Pdrp : * wsTcal		; drag/drop events
;	Ploo : * wsTcal		; default loop
 end

  type	wsTfnt	: LOGFONT		; font
	ws_chd	: (*wsTevt, HWND) HWND	; get/set child window handle

include	rid:wgdef			; this must be last
end header
