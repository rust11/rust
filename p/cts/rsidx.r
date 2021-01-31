file	rsidx - process RSX index file
include	rid:rider
include	rid:fidef
include	rid:fsdef
include	rid:mxdef
include	rid:stdef

;	returns total and free header count
;	for directory listings

code	rs_idx - process RSX index file

 type	rsThdr
 is	Vsiz : WORD		; bitmap size
	Vblk : long		; bitmap disk LBN
	Vmax : WORD		; maximum files
 end
	
  func	rs_idx
	vol : * char
	tot : * long		; total headers
	fre : * long		; free headers
  is	spc : [mxSPC] char
	fil : * FILE~
	hdr : rsThdr
	cnt : WORD~
	res : int = 0
	msk : WORD~
	wrd : WORD

	fs_ext (vol, spc, fsDEV_)	; extract device name
	st_app ("\\000000\\INDEXF.SYS", spc) ; append path
	fil = fi_opn (spc, "rb", <>)	; open index file
	pass fail			; nope
      repeat
	quit if !fi_see (fil, 512L)	; home block
	quit if !fi_rea (fil, &hdr, #rsThdr) ; read header
	*tot = cnt = hdr.Vmax		; maximum files
	*fre = 0			;
	quit if !fi_see (fil, 1024L)	; header bitmap
	res = 1				; assume fine
	while cnt-- ne			; more
	   if !msk			; mask expired
	      fi_rea(fil, &wrd, 2)	; get another word
	      quit res = 0 if fail	; oops
	      if cnt ge 16		;
		 next cnt -= 15 if wrd eq 0xffff
	      .. next cnt -= 15, *fre += 16L if !wrd
	   .. msk = 1			; reset mask
	   ++*fre if !(wrd & msk)	; this one is free
	   msk <<= 1			; next bit in mask
	end				;
      never				;
	fail if !fi_clo (fil, <>)	; close bitmap
	reply res
  end

