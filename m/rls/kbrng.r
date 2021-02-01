file	kbrng - keyboard ring
include	rid:rider
include	rid:kbdef
include	rid:medef

code	kb_alc - allocate a keyboard

  func	kb_alc
	()  : * kbTkbd
  is	kbd : * kbTkbd = me_acc (#kbTkbd)
	kbd->Lbuf = kbBUF
	reply kbd
  end

code	kb_can - cancel input

  proc	kb_can
	kbd : * kbTkbd
  is	kbd->Vget = kbd->Vput
  end

code	kb_rea - get next character

  func	kb_rea
	kbd : * kbTkbd
	cha : * kbTcha
	flg : int
  is	fail if kbd->Vget eq kbd->Vput
	*cha = kbd->Abuf[kbd->Vget]
	fine if flg & kbPEE_
	++kbd->Vget if kbd->Vget ne kbd->Lbuf
	kbd->Vget = 0 otherwise
	fine
  end

code	kb_wri - put character in ring buffer

  func	kb_wri
	kbd : * kbTkbd
	cha : * kbTcha
  is	nxt : int = kbd->Vput + 1
	nxt = 0 if nxt eq kbd->Lbuf
	fail if nxt eq kbd->Vget
	kbd->Abuf[kbd->Vput] = *cha
	kbd->Vput = nxt
	fine
  end
