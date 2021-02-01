file	db_rev - reverse exception out
include	rid:rider
include	rid:dbdef
include	rid:dadef
include	rid:imdef
include	rid:fidef
;nclude	rid:fsdef
include	rid:stdef
include	rid:medef
include	rid:ctdef
include	<stdio.h>
include	rid:wimod
include rid:chdef

	handle := HANDLE
	db_get : (handle, *char, size) int

;	This routine may have to exist in a very sick environment.
;	Thus, do not call extensive library facilities.

  func	db_rev
	exc : * dbTexc
  is	spc : [mxSPC] char
	lin : [mxLIN] char
	mod : [mxSPC] char
	num : [mxLIN] char
	typ : * char
	ptr : * char
	dig : * char
	fil : handle
	lft : * char
	rgt : * char
	pln : int
	pad : LONG
	csn : int
	cln : int
	cad : LONG
	fnd : int = 0
	fln : int = 0
	fst : int = 1
	byt : * BYTE
	cnt : int

	PUT("%%%s-I-", imPfac)
	PUT("Image=[%s] IP=%X SP=%X\n", exc->Aspc, exc->Pip, exc->Psp)
	st_cop (exc->Aspc, spc)		; get a copy
	typ = st_fnd (".", spc)		;
	typ = st_end (spc) if !typ	; was none
	st_cop (".map", typ)		;
	st_low (spc)			;

	fil = CreateFile (spc, GENERIC_READ,
		FILE_SHARE_READ|FILE_SHARE_WRITE,
		<>, OPEN_EXISTING, 0, <>)
	if fil eq INVALID_HANDLE_VALUE	; no such file
	.. fail PUT("%%%s-W-File not found [%s]\n", imPfac, spc)

	while db_get (fil, lin, mxLIN)
	   next if !st_fnd ("Line numbers", lin)
	   next if (lft = st_fnd ("(", lin)) eq
	   next if (rgt = st_fnd (")", lin)) eq
	   *<*char>(me_cop (lft+1, mod, rgt-(lft+1)))= 0
	   db_get (fil, lin, mxLIN)
	   while db_get (fil, lin, mxLIN)
;	      quit if !*lin
	      ptr = lin
	      while *ptr
	         next ++ptr if *ptr le 32
		 dig = num
		 *dig++ = *ptr++ while ct_dig (*ptr)
		 *dig = 0
		 SCN(num, "%d", &cln)
	         ++ptr while *ptr le 32

		 dig = num
		 *dig++ = *ptr++ while ct_hex (*ptr)
		 *dig = 0
		 SCN(num, "%X", &csn)
		 ++ptr if *ptr eq ':'
		 dig = num
		 *dig++ = *ptr++ while *ptr gt 32
		 *dig = 0
		 SCN(num, "%X", &cad)
		 cad += csn * 0x1000
;PUT("csn=%d, cln=%d cad=%X\n", csn, cln, cad)
		 quit ++fnd if cad ge <LONG>exc->Pip
		 fst = 0				; not first anymore
		 pln = cln, pad = cad
	      end
	      quit if fnd
	   end
	   quit if fnd
	end
	if !fnd || fst
	   PUT("%%%s-W-Source line not located\n",imPfac)
	   byt = exc->Pip
	   cnt = 5
	   while cnt--
	      byt = db_dis (0, lin, byt)
	      PUT("%s\n", lin)
	   end
	.. fail
	   
	PUT("%%%s-I-Module=[%s] Line=%d\n", imPfac, mod, pln)

	fil = CreateFile (mod, GENERIC_READ,
		FILE_SHARE_READ|FILE_SHARE_WRITE,
		<>, OPEN_EXISTING, 0, <>)
	if fil eq INVALID_HANDLE_VALUE	; no such file
	.. fail PUT("%%%s-W-File not found [%s]\n", imPfac, mod)
	cln = pln		; actually want previous
	pln = cln - 3
	pln = 0 if pln lt
	fln = 0
	db_get (fil, lin, mxLIN)
	while db_get (fil, lin, mxLIN)
	   next if st_scn ("#line", lin)
	   ++fln
	   next if fln lt pln
	   PUT("%d ", fln)
	   PUT("*") if fln eq cln
	   PUT("\t%s\n", lin)
	   quit if fln gt cln+3
	end
  end

code	db_get - Returns next line from a file

;	Uses standard descriptors and GETC
;
;	Drops null, return and linefeed
;	Returns on end of line or end of file

  func	db_get
	han : handle
	buf : * char			; the buffer
	cnt : size			; maximum buffer size
	()  : int			; result count or EOF
  is	dot : * char = buf		; output
	cha : int			; next character
	rea : LONG
	repeat				;
	   *dot = 0			; terminate it
	   quit if cnt eq		; done all
	   ReadFile (han, &cha, 1, &rea, <>)
	   fail if !rea		        ; unterminated line
	   cha &= 0xff
	   next if cha eq		; ignore nulls
		|| cha eq _cr		; and returns
	   quit if cha eq _nl		; done on newline
	   *dot++ = cha			; store it
	   --cnt			; count it
	forever				;
	fine
  end
end file

;	db_fil : (*char, *char, *char) handle
	db_fil : (*char) handle
;, *char, *char) handle
code	db_fil - Open file

  func	db_fil
	spc : * char
;	mod : * char
;	msg : * char
	()  : handle
  is	han : handle
	han = CreateFile (spc, GENERIC_READ,
		FILE_SHARE_READ|FILE_SHARE_WRITE,
		<>, OPEN_EXISTING, 0, <>)
	reply han if han ne INVALID_HANDLE_VALUE
	PUT("%%%s-W-File not found [%s]\n", imPfac, spc)
	fail				;
  end

