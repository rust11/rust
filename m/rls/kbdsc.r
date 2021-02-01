file	kbdsc - describe key
include	rid:rider
include	rid:kbdef
include	rid:stdef

	FLG(s)   := FMT(st_end (buf), (s))
	NUM(s,n) := FMT(st_end (buf), (s), (n))

  func	kb_dsc
	cha : * kbTcha
	buf : * char
  is	ord : int
	flg : int
	buf[0] = 0
	ord = cha->Vord
	flg = cha->Vflg
	FLG("Enh ") if flg & kbENH_
	FLG("Ctl ") if flg & kbCTL_
	FLG("Shf ") if flg & kbSHF_
	FLG("Alt ") if flg & kbALT_
	FLG("Sys ") if flg & kbSYS_
	FLG("Vir ") if flg & kbVIR_
	FLG("Asc ") if flg & kbASC_
	flg &= ~(kbENH_|kbCTL_|kbSHF_|kbALT_|kbSYS_|kbVIR_|kbASC_)
	NUM("rem=%x ", flg) if flg
	NUM("0x%X ", ord)
	NUM("%d ", ord)
	NUM("\"%c\" ", ord) if (ord gt 0) && (ord lt 256)
	fine
  end
