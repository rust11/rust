file	rienu - orders
include rid:rider
include rib:eddef
include rib:ridef
include	rid:imdef
include rid:stdef

; type	day : { sun, mon, tue, wed }
;
; enum	day
; is	sun, mon
;	tue
;	...
; end

	ri_enm	: (void) void

code	kw_enu - enum specification

  proc	kw_enu
  is	nam : [64] char			; type name
	pnd : int = 0			; pending comma

	if ed_fnd (" : {")		; got enumeration
	.. exit ri_enm ()		; inline enumeration

;	enum name \ is

	if not riVis			; must have (is) on next line
	   im_rep ("W-Enum missing (is) [%s]", edPdot) ; say so
	.. exit				;
					;
	ed_rst (nam)			; the rest to nam
	ri_fmt ("#define %s enum %s_t", nam, nam)
	++riVsup			; already written
					;
	ri_fmt ("enum %s_t ", nam)	; enum nam_t
					; (is) inserts ({)
	repeat				;
	   ri_get ()			; get the next
	   if riPcur->Veof		; got end of file
	      im_rep ("EOF in enum [%s]", nam)
	   .. exit			; forget it
					;
	   if riVend			; all over
	   .. quit --riPcur->Vend	; we reduce nesting level
					;
	   if ed_mor ()			; got items on line
	      quit if ed_del (" end")	; this ends it - put it out
	      ed_pre (",") if pnd ne	; got pending comma
	   .. pnd = (*ed_lst () ne ',')	; needs comma before next one
	   ri_put ()			; write it
	forever				;
					;
	ed_app (" };")			; end it
	riPcur->Vend = 0		; remove end count
	ri_put ()			; write it
	--riVnst			; nest down
	++riVsup			; already written
  end
code	ri_enm - inline enum type

; type	day : { sun, mon, tue, wed }
;
;	#define day enum day_t
;	enum day_t { sun, mon, tue, wed };

  proc	ri_enm
  is	nam : [64] char
	ed_sub (" : ", "", nam)		; get the name
	ri_fmt ("#define %s enum %s_t", nam, nam) ; define it
	st_app ("_t", nam)		; insert the name
	ed_pre (" ")			;
	ed_pre (nam)			; shove that in
	ed_pre ("enum ")		; enum nam_t
	ed_app (";")			;
  end
