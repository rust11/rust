file	bmloa - load bitmap
include	rid:rider
include	rid:fidef
include	rid:medef
include	rid:wimod
include	rid:bmdef

	bm_inv	: (*char, *char, size, size)
code	bm_loa - load bitmap file

  func	bm_loa
	spc : * char				;
	msg : * char				;
	()  : *bmTbmp
  is	buf : * char = <>			;
	bmp : * bmTbmp = <>			; result bmp
	fhd : * BITMAPFILEHEADER
	inf : * BITMAPINFOHEADER
	dat : * void
      repeat					; fail block
	quit if !fi_loa (spc, &(<*void>buf), <>, <>, "")
	fhd = <*BITMAPFILEHEADER>buf		; get the fileheader
	inf = <*BITMAPINFOHEADER>(buf + #BITMAPFILEHEADER)
	dat = buf + fhd->bfOffBits		;
	bmp = bm_alc (<>, bmPAL, inf->biWidth, inf->biHeight)
	bm_inv (dat, bmp->Pdat, bmp->Vwid, bmp->Vhgt)
	fi_dlc (buf)				; forget that
	reply bmp				;
      never					;
	fi_dlc (buf) if buf			;
	me_dlc (bmp) if bmp			; deallocate buffer
	reply <>
  end

code	bm_inv - invert bitmap

  func	bm_inv
	src : * char
	dst : * char
	wid : size
	hgt : size
  is
exit
	wid = ((wid + 3) * 4) / 4
	dst += hgt * wid
	while hgt--
	   dst -= wid
	   me_cop (src, dst, wid)
	   src += wid
	end	
	fine
  end
end file
file	bmloa - bitmap load and store
include	rid:rider
include	rid:fidef
include	rid:medef
include	rid:wimod
include	rid:bmdef

	bm_inv	: (*char, *char, size, size)
  func	main
	cnt : int
	vec : ** char
  is	bmp : * bmTbmp = bm_loa ("wus:exit.bmp", "")
	pix : * char
	yc  : int
	xc  : int
	PUT("Load=%d\n", bmp)
	exit if !bmp
	PUT("wid=%d hgt=%d\n", bmp->Vhgt, bmp->Vwid)
	pix = bmp->Pdat
	yc = 20
	while yc--
	   xc = 40
	   while xc--
	      PUT(".") if !*pix
	      PUT("X") otherwise
	      ++pix
	   end
	   PUT("\n")
	end
  end


end file
code	bm_sto -- store file

  func	bm_sto 
	bmp : * bmTbmp
	spc : * char				;
	msg : * char				; error message
  is	fil : * FILE				;
	buf : * char = <*char>bmp->Phdr		; start of data
	siz : size = bmp->Vtot + #wvThdr	; total size
	fail if !bmp				; no bitmap
	buf = <*char>bmp->Phdr			; start of data
	siz = bmp->Vtot + #wvThdr		; total size

;	if !(flg & wvALL_) && bmp->Vsiz		;
;	    buf += bmp->Vbeg			;
;	..  siz = bmp->Vsize

	if (fil = fi_opn (spc, "wb", "")) eq	; write a file
	|| fi_wri (fil, buf, siz) eq		;
	   fi_rep (spc, msg, "")		; say what happened
	   fi_clo (fil, "")			;
	.. fail					;
	fi_clo (fil, "")			; close it
	fine
  end

code	bm_clo - close and deallocate buffer

  func	bm_clo
	bmp : * bmTbmp
  is	fine bm_dlc (bmp)
  end
