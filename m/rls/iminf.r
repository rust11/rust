file	iminf
include	rid:wimod
include	rid:iminf
include	rid:mxdef
include	rid:medef
include	rid:fidef
include	rid:stdef
include	rid:dbdef

code	im_opn - open image

  func	im_opn
	img : * imTinf
	spc : * char
	rea : * int
  is	loc : [mxSPC] char
	siz : DWORD
	han : DWORD
	fi_loc (spc, loc)
	siz = GetFileVersionInfoSize (loc, &han)
	if fail
	   *rea = imFNF if GetLastError() eq ERROR_FILE_NOT_FOUND
	   *rea = imFMT otherwise
	   fail
	end
	if !img->Linf
	   siz += 1024	; leave space for bigger ones
	   img->Pinf = me_alc (siz)
	   img->Linf = siz
	   siz -= 1024
	elif img->Linf lt siz
	   img->Pinf = me_ral (img->Pinf, siz)
	.. img->Linf = siz
	GetFileVersionInfo (loc, han, siz, img->Pinf)
	fail *rea = imFMT if fail
;	fail db_lst ("GetFileVersionInfo") if fail
	fine
  end

code	im_clo - close image

  func	im_clo
	img : * imTinf
  is	fine if !img || !img->Linf
	me_dlc (img->Pinf)
	img->Linf = 0
	fine
  end

code	im_que - query image

	_imPRE := TEXT("\\StringFileInfo\\040904e4\\")
  func	im_que
	img : * imTinf
	hdr : * char
	buf : * char
  is	tit : [mxLIN] char
	res : * char = img->Ares
	ptr : * char
	siz : UINT
	st_cop (_imPRE, tit)
	st_app (hdr, tit)
	VerQueryValue (img->Pinf, tit, &<*void>ptr, &siz)
	pass fail
;	fail db_lst ("VerQueryValue") if fail
	(siz lt mxLIN) ? siz ?? mxLIN
	st_fit (ptr, res, that)
	st_col (res, res)	
	st_cop (res, buf) if buf
	fine
  end
code	im_dsc - get description

	_imCMP := "CompanyName"		; Cmp
	_imDSC := "FileDescription"	; Dsc
	_imVER := "FileVersion"		; Ver
	_imIDT := "InternalName"	; Idt Use
	_imCPY := "LegalCopyright"	;
	_imSPC := "OriginalFilename"	; Spc Ver
	_imPRD := "ProductName"		; Prd Prv
	_imPRV := "ProductVersion"	;

;	Idt -- Dsc
;	Spc Ver (Prd Prv)
;	Cmp
;
;	VDT -- VDT Virtual device (version 4.00)
;	VDT.VDX Version 4.0 (Windows V4.0.567) (MS)
;	Microsoft Corporation

	INF(s,i) := FMT(st_end (res), s, im_que (img, (i), <>))
  func	im_dsc
	img : * imTinf
	spc : * char
	rea : * int
  is	res : int
	fail if !im_opn (img, spc, rea)
	im_que (img, _imIDT, img->Aidt)
	im_que (img, _imDSC, img->Adsc)
	im_que (img, _imSPC, img->Aspc)
	im_que (img, _imVER, img->Aver)
	im_que (img, _imPRD, img->Aprd)
	im_que (img, _imPRV, img->Aprv)
	im_que (img, _imCMP, img->Acmp)
	fine
  end
end file
	_imPRE := TEXT("\\StringFileInfo\\040904e4\\")
  func	im_que
	img : * imTinf
	hdr : * char
	res : * char
  is	tit : [mxLIN] char
	ptr : * char
	siz : UINT
	st_cop (_imPRE, tit)
	st_app (hdr, tit)
	VerQueryValue (img->Pinf, tit, &<*void>ptr, &siz)
;	fail db_lst ("VerQueryValue") if fail
	pass fail
	(siz lt mxLIN) ? siz ?? mxLIN
	st_fit (ptr, res, that)
	fine
  end
