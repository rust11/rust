ast$c := 0
file	kbwin - windows keyboard
include	rid:rider
include	rid:wsdef
include	rid:kbdef
include	rid:medef
include	rid:vkdef

	kb_evt : wsTast own
	kb_put : (*wsTevt, *kbTcha) int	own	; put in ring

code	kb_att - attach keyboard

  func	kb_att
	()  : * kbTkbd
  is	ctx : * wsTctx = ws_ctx ()
	kbd : * kbTkbd = ctx->Pkbd
	fac : * wsTfac
	if !kbd
	   ctx->Pkbd = kbd = kb_alc ()
	   fac = ws_fac (<>, "kb")
	   fac->Pusr = kbd
	.. fac->Past = kb_evt		; bingo
	GetKeyboardState (kbd->Asta)
	reply kbd
  end

code	kb_det - detach keyboard

  func	kb_det
  is	kbd : * kbTkbd = kb_att ()
	fac : * wsTfac = ws_fac (<>, "kb")
	fac->Past = <>
	fine
  end

code	kb_get - get next character

  func	kb_get
	cha : * kbTcha
	flg : int
  is	ctx : * wsTctx = ws_ctx ()
	kbd : * kbTkbd = ctx->Pkbd
     repeat
	fine if kb_rea (kbd, cha, flg)
	; Have to let some events through even if non-wait
	fail if !ws_pee (<>, (flg & kbWAI_) ne)
     forever
  end
code	kb_evt - handle keyboard event

;	replying "fine" means we handled the character

  func	kb_evt
	evt : * wsTevt
	fac : * wsTfac
  is	msg : int = evt->Vmsg
	sta : [256] char
	buf : [4] WORD
	ptr : * WORD = buf
	kbd : * kbTkbd = fac->Pusr
	cha : kbTcha
	vir : kbTord
	lng : int
	scn : int
	alt : int
	flg : int
	res : int = 0
	fine if msg eq WM_SYSCHAR
	if (msg ne WM_KEYUP) && (msg ne WM_SYSKEYUP)
	&& (msg ne WM_KEYDOWN) && (msg ne WM_SYSKEYDOWN)
	.. fail
	lng = evt->Vlng
	vir = evt->Vwrd
	scn = (lng >> 16) & 0xffff
	alt = (lng & BIT(29)) ne
	flg = kbd->Vflg

	case evt->Vmsg
	of WM_KEYUP
	or WM_SYSKEYUP
	   case vir
	   of VK_SHIFT	 flg &= (~kbSHF_)
	   of VK_CONTROL flg &= (~kbCTL_)
	   of VK_MENU	 flg &= (~kbALT_)
	   end case
	   kbd->Vflg = flg
	   fail
	of WM_SYSKEYDOWN
	or WM_KEYDOWN
	   GetKeyboardState (kbd->Asta)
	   res = ToAscii (vir, scn, kbd->Asta, buf, alt)
	   case vir
	   of VK_SHIFT	 flg |= kbSHF_
	   of VK_CONTROL flg |= kbCTL_
	   of VK_MENU	 flg |= kbALT_
	   end case
	of other
	   fail
	end case
	kbd->Vflg = flg
	flg |= kbENH_ if lng & BIT(24)
	flg |= kbSYS_ if evt->Vmsg eq WM_SYSKEYDOWN

	if res eq
	   cha.Vflg = flg|kbVIR_
	   cha.Vord = vir
	   kb_wri (kbd, &cha)
	elif res gt
	   cha.Vflg = flg|kbASC_
	   while res--
	      cha.Vord = *ptr++
	      kb_wri (kbd, &cha)
	   end
	else
	.. nothing

	if flg eq (kbSYS_|kbALT_|kbVIR_)
	&& cha.Vord eq 18			; just alt is ours
	.. fine

	fail if evt->Vmsg eq WM_SYSKEYDOWN
If ast$c
	fine if !kbd->Past			; no ast
	reply (*kbd->Past)(kbd, &cha, 0)	; they decide
End
	fail evt->Vmsg = WM_COMMAND		; force command
	fine
  end
end file
code	kb_put - put character in ring buffer

  func	kb_put
	evt : * wsTevt
	cha : * kbTcha
  is	ctx : * wsTctx = evt->Pctx
	kbd : * kbTkbd = ctx->Pkbd
	nxt : int = kbd->Vput + 1
	nxt = 0 if nxt eq kbd->Lbuf
	fail if nxt eq kbd->Vget
	kbd->Abuf[kbd->Vput] = *cha
	kbd->Vput = nxt
	fine
  end
