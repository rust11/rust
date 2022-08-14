file	mouse - mouse maintenance
include	rid:rider
include	rid:imdef
include	rid:fidef
include rid:rtrea

;	%build
;	@@its:mouse.inf
;	!rider its:mouse/obj:itb:/nodel
;	link itb:mouse/exe:itb:/map:itb:,itb:mouinf,lib:(crt,ridlib)/bot:2000
;	copy itb:mouse.sav hd1:*.*
;	%end

  type	moTevt
  is	Vbut : char
	Vx   : char
	Vy   : char
	Vz   : char
  end
	moLFT_ := 1
	moMID_ := 2
	moRGT_ := 4

  type	moTpos
  is	Vbut : WORD
	Vx   : word
	Vy   : word
	Vz   : word
  end

  type	moTbuf
  is	Vcnt : char
	Vtyp : char
	Verr : char
	Vrun : char
	Aevt : [15] moTevt
  end

  func	start
  is	fil : FILE
	buf : moTbuf 
	cnt : int
	evt : * moTevt

	im_ini ("MOUSE")
	fil = fi_opn ("MO:", "rb", "")
	exit if fail
;	mo_drw (fil)
	repeat
	   rt_rea (fil, 0, &buf, 32, rtWAI)
;	   exit if fail
	   PUT("Cnt=%d Typ=%d Err=%d Rnt=%d ", 
	      buf.Vcnt, buf.Vtyp, buf.Verr, buf.Vrun)
	   cnt = buf.Vcnt
	   evt = buf.Aevt
	   while cnt--
	      PUT("L") if evt->Vbut & moLFT_
	      PUT("M") if evt->Vbut & moMID_
	      PUT("R") if evt->Vbut & moRGT_
	      PUT(" X=%d", evt->Vx) if evt->Vx
	      PUT(" Y=%d", evt->Vy) if evt->Vy
	      PUT(" Z=%d", evt->Vz) if evt->Vz
	      PUT("  ")
	      ++evt
	   end
	   PUT("\n")
	end
  end

end file

	if !buf->Vcnt 

      while

	fil : FILE
	buf : moTbuf 
	cnt : int
	evt : * moTevt

code	mo_drw - draw mouse

  func	mo_drw
  is	pos : moTpos
	str : [32] char
    repeat
	mo_pos (&pos)
	ptr = str
	*str++ = 033
	st_cop ("[x
	FMT(str, "[%d;%d;", pos.x, pos.y)
    end
  end
		

code	mo_get - get next event

  func	mo_get
	pos : * moTpos
  is	evt : * moTevt
	pos : * moTpos

	while !buf->Vcnt
	   moVnxt = 0
	.. rt_rea (moPfil, 0, &moIbuf, 32, 0)
	evt = moPevt = moIbuf.Aevt[moVnxt++]
	mo_pos (evt, pos)
  end

  func	mo_pos
	evt : * moTevt
	pos : * moTpos
  is	pos->Vx += evt->Vx
	pos->Vy += evt->Vy
	pos->Vx = 1 if pos->Vx lt
	pos->Vx = 79 if pos->Vx ge 80
	pos->Vy = 1 if pos->Vy lt
	pos->Vx = 1 if pos->Vy ge 24
  end
