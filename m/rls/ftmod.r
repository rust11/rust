code	ft_mod - font and glyph operations
include	rid:wimod
include	rid:stdef
include	rid:medef
include	rid:bmdef
include	rid:ftdef
include	rid:dbdef
include	rid:imdef

;	These routine only function if a window has been mapped.

	p := ftPAP		; paper
	i := ftINK		; ink

  init	ftAmap : [] char
  is	p,p,p,p
	p,p,p,i
	p,p,i,p
	p,p,i,i
	p,i,p,p
	p,i,p,i
	p,i,i,p
	p,i,i,i
	i,p,p,p
	i,p,p,i
	i,p,i,p
	i,p,i,i
	i,i,p,p
	i,i,p,i
	i,i,i,p
	i,i,i,i
  end

  func	ft_alc
	()  : * ftTfnt
  is	fnt : * ftTfnt = me_acc (#ftTfnt)
	rec : RECT = {0}
	wnd : HWND
	dev : HDC
	fnt->Ldat = ftMAX/8
	fnt->Pdat = fnt->Agly
	fnt->Ibmp.Vtot = ftMAX
	fnt->Ibmp.Pdat = fnt->Abmp
	fnt->Hdev = CreateEnhMetaFile (<>,<>,&rec,<>)
	reply fnt if fnt->Hdev
	fail me_dlc (fnt)
  end

  func	ft_dlc
	fnt : * ftTfnt
  is	ft_rel (fnt)
	DeleteEnhMetaFile (fnt->Hdev)
	me_dlc (fnt)
  end
code	ft_map - map a font

  func	ft_map
	fnt : * ftTfnt
  is	log : LOGFONT = {0}
	cha : int = fnt->Vcha
	ft_rel (fnt)
	log.lfHeight = fnt->Vhgt
	log.lfWidth = fnt->Vwid
	log.lfCharSet = OEM_CHARSET if cha & ftDOS_
	log.lfCharSet = SYMBOL_CHARSET if cha & ftSYM_
	log.lfPitchAndFamily = FIXED_PITCH if cha & ftFIX_
	log.lfWeight = 700 if cha & ftBOL_
	log.lfUnderline = 1 if cha & ftUND_
	log.lfItalic = 1 if cha & ftITA_
	st_fit (fnt->Anam, log.lfFaceName, #log.lfFaceName)
	fnt->Hfnt = CreateFontIndirect (&log)
	pass fail
	ft_sel (fnt, fnt->Hdev)
	pass fine
	fail ft_rel (fnt)
	fine
  end

  func	ft_sel
	fnt : * ftTfnt
	dev : wsTdev
  is	met : TEXTMETRIC
	fnt->Hold = SelectObject (dev, fnt->Hfnt)
	pass fail
	GetTextMetrics (dev, &met)
	fnt->Vhgt = met.tmHeight
	fnt->Vasc = met.tmAscent
	fnt->Vdes = met.tmDescent
	fnt->Vwid = met.tmMaxCharWidth
;	fnt->Vhgt, fnt->Vasc, fnt->Vdes, fnt->Vwid)
	fine
  end

  func	ft_uns
	fnt : * ftTfnt
	dev : wsTdev
  is	fine if !fnt->Hold
	SelectObject (fnt->Hdev, fnt->Hold)
	fnt->Hold = 0
	fine
  end

code	ft_rel - unmap prevailing font

  func	ft_rel
	fnt : * ftTfnt
  is	ft_uns (fnt, fnt->Hdev)
	if fnt->Hfnt
	   DeleteObject (fnt->Hfnt)
	.. fnt->Hfnt = 0
	fine
  end
code	ft_gly - get glyph representation of character

  func	ft_gly
	fnt : * ftTfnt
	cha : int
  is	bmp : * bmTbmp = &fnt->Ibmp
	met : GLYPHMETRICS = {10,20,0,0,10,20}
	mat : MAT2 = {0,1, 0,0, 0,0, 0,1}
	res : int
	wid : int
	hgt : int
	brd : int
	len : int
	maj : int
	sp  : * long
	tp  : * long
	src : * long
	dst : * long
	tgt : * long
	lng : long
	rem : int
	min : int
	top : int
	; note:	fnt->Ldat guards overrun in Agly AND Abmp
	res = GetGlyphOutline (fnt->Hdev, cha, GGO_BITMAP, &met,
			 fnt->Ldat, fnt->Pdat, &mat)
	fail if res le
;	fail db_lst ("ft_gly") if res le
	bmp->Vwid = wid = met.gmBlackBoxX
	bmp->Vhgt = hgt = met.gmBlackBoxY
	brd = ((wid+3)/4)*4
bmp->Vwid = brd
	len = ((wid+31)/32)*32
	fail if (brd * hgt) gt bmp->Vtot
	sp = <*long>fnt->Pdat
	tp = <*long>bmp->Pdat

	top = met.gmptGlyphOrigin.y
	if top ne fnt->Vasc
	   bmp->Vhgt += fnt->Vasc-top
	.. tp = me_set (tp, (fnt->Vasc-top)*brd, ftPAP)

	while hgt--
	   maj = len/32
	   rem = brd/4
	   src = sp, sp = sp + maj
	   tgt = tp, tp = tp + rem
	   while maj--
	      lng = *src++		; walk through source
;	      dst = tgt++
	      min = 4 
	      min = rem if min gt rem
	      rem -= min
	      while min-- 
		 *tgt++ = (<*long>ftAmap)[(lng>>4)&0xF]
		 *tgt++ = (<*long>ftAmap)[lng&0xF]
	         lng = (lng >> 8) & 0x00ffffff
	      end
	   end
	end
	fine
  end 
end file
;PUT("wid=%d hgt=%d x=%d top=%d hor=%d ver=%d\n", 
;	met.gmBlackBoxX,
;	met.gmBlackBoxY,
;	met.gmptGlyphOrigin.x,
;	met.gmptGlyphOrigin.y,
;	met.gmCellIncX,
;	met.gmCellIncY)

