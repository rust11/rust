file	mnmod - windows menu support
include	rid:wsdef
include	rid:mndef
include	rid:medef
include	rid:mxdef
include rid:imdef
include rid:stdef

	mnMAX  := 64			; menu maximum
	mnOPN_ := BIT(0)		; menu is open

  type	mnTmen				; a menu
  is	Vflg : int			;
	Vcnt : int			;
	Hpop : HMENU			;
	Anam : [mxIDT] char		;
  end

  type	mnTctx	
  is	Hmen : HMENU			; main menu
	Vcnt : int			; menu count
	Pmen : * mnTmen			; current menu
	Atab : [mnMAX] mnTmen		; menu array
  end
	mn_ini : (void) * mnTctx own
	mn_loo : (*mnTctx, *char) *mnTmen

data	menu objects

  type	mnTobj
  is	Vidt : int
	Hhan : HANDLE
  end

  init	mnAobj : [] mnTobj
  is	bmUP0: OBM_UPARROW, <>
	bmUP1: OBM_UPARROWD, <>
	bmDN0: OBM_DNARROW, <>
	bmDN1: OBM_DNARROWD, <>
	bmLF0: OBM_LFARROW, <>
	bmLF1: OBM_LFARROWD, <>
	bmRG0: OBM_RGARROW, <>
	bmRG1: OBM_RGARROWD, <>
	bmRD0: OBM_REDUCE, <>
	bmRD1: OBM_REDUCED, <>
	bmZO0: OBM_ZOOM, <>
	bmZO1: OBM_ZOOMD, <>
	bmRS0: OBM_RESTORE, <>
	bmRS1: OBM_RESTORED, <>
  end
code	mn_ini - setup menu context

  func	mn_ini
	()  : * mnTctx
  is	srv : * wsTctx = ws_ctx ()	; get our context
	ctx : * mnTctx			;
	if srv->Pmen eq			; first time
	   srv->Pmen = me_acc (#mnTctx)	; setup menu context
	   ctx = that			;
	.. ctx->Hmen = CreateMenu ()	; get a handle
	reply srv->Pmen
  end

code	mn_win - get menu handle

  func	mn_win
	()  : * void
  is	ctx : * mnTctx = mn_ini ()
	reply ctx->Hmen
  end

code	mn_loo - lookup menu

  func	mn_loo
	ctx : * mnTctx
	nam : * char
	()  : * mnTmen
  is	idx : int
	cnt : int = ctx->Vcnt
	men : * mnTmen = &ctx->Atab[0]	; first one
	while cnt--			; do existing
	   if st_sam (nam, men->Anam)	; same menu?
;	   .. reply ctx->Pmen = men	; got it
	   .. reply men			;
	   ++men			; next menu
	end				;
	reply <> if ctx->Vcnt ge mnMAX	;
	++ctx->Vcnt			;
	st_cop (nam, men->Anam)		; save the name
	if st_sam (nam, "@SYSTEM")	;
	   men->Hpop = GetSystemMenu ((ws_ctx ())->Hwnd, 0)
	   men->Vflg |= mnOPN_		; it's already open
	.. men->Vcnt = 9		; open items
	reply men			; send it back
  end
code	mn_beg - begin new menu

  func	mn_beg
	nam : * char			; menu name
  is	ctx : * mnTctx = mn_ini ()	; setup
	men : * mnTmen = mn_loo(ctx,nam); find the menu
	cnt : int			;
	fail if !men			; too many menus
	ctx->Pmen = men			; got a new one
					;
	if (men->Vflg & mnOPN_) eq	; not open
	   men->Vflg |= mnOPN_		; mark it open
	   men->Hpop = CreatePopupMenu(); create the menu
	   if *nam && *nam ne '@'	;
	      AppendMenu (ctx->Hmen,	; add to menu bar
		MF_ENABLED|MF_POPUP,	; always on
		<UINT>men->Hpop, 	;
	   ..	nam)			;
	.. fine				;
	cnt = men->Vcnt			;
	while cnt--			;
	   DeleteMenu (men->Hpop, 0,	; delete current items
		       MF_BYPOSITION)	;
	end				;
	men->Vcnt = 0			; reset the counter
	fine				;
  end					;
	
code	mn_but - menu button

  func	mn_but
	cod : int
	nam : * void			; menu name
	msk : int			; later
  is	reply mn_trg (cod, nam, nam, msk)
  end

  func	mn_trg
	cod : int
	nam : * void			; menu name
	txt : * void			;
	msk : int			; later
  is	srv : * wsTctx = ws_ctx ()
	ctx : * mnTctx = mn_ini ()	; setup
	men : * mnTmen = mn_loo(ctx,nam); find the menu
	cnt : int			;
	flg : int
	hlt : int = msk & mnHLT_	; hihight
	if (msk & mnBMP_) && !nam	;
	   msk = 0			;
	.. nam = "???"			;
					;
	flg = MF_BITMAP	 if msk & mnBMP_;
	flg = MF_STRING	 otherwise	;
	flg |= MF_ENABLED		;
	if msk & mnBMP_
	.. nam = mn_han (msk >> 16)	;
				
	fail if !men			; too many menus
	if (men->Vflg & mnOPN_) eq	; not open
	   men->Vflg |= mnOPN_		; mark it open
	   AppendMenu (ctx->Hmen,	; add to menu bar
	  	flg, cod, txt)		;
	end
	hlt = MF_BYCOMMAND
	hlt |= MF_HILITE if msk & mnHLT_
	HiliteMenuItem (srv->Hwnd, ctx->Hmen, cod, hlt)
	fine
  end
	
code	mn_han - get bitmap handle

  func	mn_han
	idt : int
	()  : * void
  is	obj : * mnTobj = mnAobj + idt
	if obj->Hhan eq
	.. obj->Hhan = LoadBitmap (<>, MAKEINTRESOURCE(obj->Vidt))
	reply <*void>obj->Hhan
  end

code	mn_sim - add simple menu item

  func	mn_sim
	cod : int
	nam : * char
  is	mn_com (cod, nam, mnENB_)
  end

code	mn_com - add complex menu item

  func	mn_com
	cod : int
	nam : * char
	msk : int 
  is	ctx : * mnTctx = mn_ini ()
	men : * mnTmen = ctx->Pmen
	sub : * mnTmen

	flg : int = MF_STRING
	if msk & mnENB_
	   flg |= MF_ENABLED
	else
	   flg |= MF_GRAYED    if msk & mnGRY_
	.. flg |= MF_DISABLED  otherwise
	flg |= MF_CHECKED      if msk & mnCHK_
	flg |= MF_UNCHECKED    if msk & mnUNC_

	if *nam eq '@'			; submenu
	   sub = mn_loo (ctx, nam)	; find the menu
	   fail if !sub			; no such beast
	   cod = <UINT>sub->Hpop	; make a popup
	   flg |= MF_POPUP		; brand it
	.. ++nam			; skip that
	AppendMenu (men->Hpop, flg, cod, nam)
	++men->Vcnt			; count the item
	fine
  end

code	mn_skp - skip menu slot

  func	mn_skp
  is	ctx : * mnTctx = mn_ini ()	;
	men : * mnTmen = ctx->Pmen	;
	AppendMenu (men->Hpop,		; is this an item???
		MF_SEPARATOR, 0, "")	;
	++men->Vcnt			; count the item
	fine
  end

code	mn_sho - display menu

  func	mn_sho
  is	srv : * wsTctx = ws_ctx ()
	ctx : * mnTctx = mn_ini ()
	men : * mnTmen = ctx->Pmen
	SetMenu (srv->Hwnd, ctx->Hmen)
	DrawMenuBar (srv->Hwnd)
	fine
  end

code	mn_trk - track menu

  func	mn_trk
	evt : * wsTevt
  is	srv : * wsTctx = ws_ctx ()
	ctx : * mnTctx = mn_ini ()
	men : * mnTmen = ctx->Pmen
;	SetMenu (srv->Hwnd, ctx->Hmen)
;	DrawMenuBar (srv->Hwnd)
	fine
 	TrackPopupMenu (men->Hpop, TPM_LEFTALIGN, 0,0,0,evt->Hwnd, NULL)
 end
code	mn_alc - allocate a history

  func	mn_alc
	bas : int
	cnt : int
	()  : * mnThis
  is	his : * mnThis
	idx : int = 0
	fail if cnt le 0
	cnt = 20 if cnt gt 20
	his = me_acc (#mnThis + (#<*char> * cnt))
	his->Vbas = bas
	his->Vcnt = cnt
	while cnt--
	.. his->Atab[idx++] = me_acc (mxSPC)
	reply his
  end

code	mn_dlc - deallocate a history

  proc	mn_dlc
	his : * mnThis
  is	idx : int = 0
	exit if !his
	while idx in 0..his->Vcnt-1
	.. me_dlc (his->Atab[idx])
	me_dlc (his)
  end

code	mn_new - enter new file

  proc	mn_new
	his : * mnThis
	new : * char			; insert that
  is	cnt : int = his->Vcnt		;
	tab : ** char = his->Atab	;
	lft : * char			;
	rgt : * char			;

;	Move down until we find an empty

	tab = his->Atab			;
	lft = tab[0]			; get the first one
	while --cnt gt 			; till an empty, the same or the last
	   quit if !*lft		; got an empty entry
	   quit if st_sam (new, lft)	; same entry
	   rgt = tab[1]			;
	   tab[1] = lft			;
	   lft = rgt			;
	   ++tab			;
	end				;
	his->Atab[0] = lft		; move it in
	st_cop (new, lft)		; copy in the spec
  end

code	mn_dis - display entries

  proc	mn_dis
	his : * mnThis
  is	tab : ** char = his->Atab
	ent : * char
	cnt : int = his->Vcnt
	cod : int = his->Vbas
	fst : int = 0
	while cnt--
	   ent = *tab++
	   quit if !*ent
	   mn_skp () if !fst++
	   mn_sim (cod++, ent)
	end
  end

code	mn_fil - filter base code

  func	mn_fil
	his : * mnThis
	cod : int
  is	idx : int
	reply cod if !his		; no history allocated
	idx = cod - his->Vbas		;
	reply cod if idx lt		; not ours
	reply cod if idx ge his->Vcnt	;
	reply his->Vbas			; this is us
  end

code	mn_sel - return selected entry

  func	mn_sel
	his : * mnThis
	cod : int
	()  : * char
  is	reply mn_enu (his, cod - his->Vbas)
  end

code	mn_enu - enumerate entries

  func	mn_enu
	his : * mnThis
	cod : int
	()  : * char
  is	reply <> if cod lt || !his	; not ours or no history
	reply <> if cod ge his->Vcnt	;
	reply his->Atab[cod]		; the string
  end
code	mn_loa - input menu history

  func	mn_loa
	his : * mnThis
	def : * dfTctx
	stb : * char			; stub name
  is	nam : [mxSPC] char		;
	ent : * dfTdef			;
	cnt : int = his->Vcnt		; insert in reverse order
	while cnt ge 			;
	   st_cop (stb, nam)		;
	   FMT(that, "%d", cnt--)	;
	   ent = df_loo (def, nam)	;
	   next if eq			;
	   mn_new (his, ent->Pbod)	; insert the name
	end				;
	fine				;
  end

code	mn_sto - store menu history

  func	mn_sto
	his : * mnThis
	def : * dfTctx
	stb : * char			; stub name
  is	idx : int = 0			;
	nam : [mxSPC] char		;
	str : * char
	repeat
	   str = mn_enu (his, idx)	; get the entry
	   quit if null || !*str	; all over
	   st_cop (stb, nam)		;
	   FMT(that, "%d", idx++)	;
	   df_ins (def, nam, str)	;
	forever				;
	fine				;
  end
end file	

file	mnkbd - menu keyboard commands
header	kbacc - define keyboard accelerators

  type	mnTacc
  is	Vflg : BYTE
	Vkey : WORD
	Vcmd : WORD
  end

	kbALT := 0x10
	kbCTL := 0x08
	kbNIV := 0x02
	kbSHF := 0x04
	kbVIR := 0x01

	kb_acc ("CA", 'A', evCUT)
  func	kb_acc
	mod : * char
	key : int
	cmd : int
  is	flg : int = 0
	while *mod
	   case *mod++
	   of 'C'  flg |= mnCTL
	   of '|' key = *mod++
	   end case
	end
	flg |= kbCTL if st_fnd ("c", mod)
	flg |= kbCTL if st_fnd ("c", mod)
	flg |= kbCTL if st_fnd ("c", mod)
	flg |= kbCTL if st_fnd ("c", mod)

  type	kbTkey
  is	Psuc : * kbTkey
	Vflg : int
	Astr : [8] char
	Vevt : int
  end

	kbPkey : * kbTkey = <>

	kb_reg ("^A", evXXX)

  func	kb_reg
	str : * char
	evt : int
  is	pre : ** kbTkey = &kbPkey
	fine if !evt			; no such event
	while *pre
	   key = *pre			; get the next
	   pre = &key->Psuc		;
	   if st_sam (str, key->Astr)	; same string
	   .. fine key->Vevt = evt	;
	end				;
	key = me_acc (#kbTkey)		; get another
	st_cop (str, key->Astr)
	key->Vevt = evt
	fine
  end

  func	kb_trn
	evt : * wsTevt
  is	key : * kbTkey = kbPkey
	str : [8] char
	*str++ = "^" if xxx & ....
	*str++ = "^" if xxx & ....
	*str++ = "^" if xxx & ....
	*str++ = "^" if xxx & ....
	while key
	   if st_sam (key->Astr, str)
	   .. reply key->Vevt
	   key = key->Psuc
	end	
	fail
  end

	kbALT_	:= BIT(0)		; alt key down
	kbSHF_	:= BIT(1)		; shift key down
	kbCTL_	:= BIT(3)		; control key down
	kbCAP_	:= BIT(2)		; capsLock on
	kbNUM_	:= BIT(4)		; numLock on
	kbSCR_	:= BIT(5)		; scroll lock on
	kbUPR_	:= BIT(6)		; up

	kbMOD_	:= (kbALT_|kbSHF_|kbCTL_)
	kb_mod (e) := (kb_flg(e) & kbMOD_)
	kbMmod (f) := ((f) & kbMOD_)
	kb_flg	: (*wsTevt) int

 	xxALT := 0x20000000
 func	kb_flg
	evt : * wsTevt
	()  : int			; key flags
  is	flg : int = 0
	flg |= kbSHF_ if GetKeyState (VK_SHIFT)
	flg |= kbCAP_ if GetKeyState (VK_CAPITAL)
	if (flg eq kbSHF_) or (flg eq kbCAP_)
	.. flg |= kbUPR_
	flg |= kbALT_ if evt->Vlng & xxALT_
	flg |= kbCTL_ if GetKeyState (VK_CONTROL)
	flg |= kbNUM_ if GetKeyState (VK_NUMLOCK)
	flg |= kbSCR_ if GetKeyState (VK_SCROLL)
	reply flg
  end
;	kb_ass ()
;	Keyboard associations
;
;	$	escape
;	^	Control
;	&	Alt
;	#	Shift
;
;	Insert
;	Delete
;	Home
;	End
;	PageUp	
;	PageDown
;
;	"\tTab"
