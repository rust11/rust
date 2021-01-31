file	rsmap - process RSX bitmap
include	rid:rider
include	rid:fidef
include	rid:fsdef
include	rid:mxdef
include	rid:stdef

code	rs_map - get RSX free blocks

; type	rsTmap
; is	Afre : [3] char
;	Vcnt : char		; bitmap blocks
;	Ablk : [126] rsTblk	; Vcnt * 4 if Vcnt ge 127
;	Vtot : long		; total logical blocks
; end
	
  func	rs_map
	vol : * char		; volume spec, or file spec
	tot : * long		; total blocks
	fre : * long		; free blocks
	ctg : * long		; largest contiguous space
  is	fil : * FILE~
	spc : [mxSPC] char
	hdr : [4] char
	maj : long~
	msk : WORD~
	wrd : WORD
	cnt : int
	res : int = 0
	gap : long

	fs_ext (vol, spc, fsDEV_)
	st_app ("\\000000\\BITMAP.SYS", spc)
	fil = fi_opn (spc, "rb", <>)
	pass fail
      repeat
	quit if !fi_rea (fil, hdr, 4)	; read 4-byte header
	cnt = hdr[3] & 0xff		; number of bitmap blocks
	cnt = 0 if cnt gt 126		; big disks
	quit if !fi_see (fil, ++cnt*4L)	; seek to position
	quit if !fi_rea (fil, &maj, 4)	; read total blocks
	*tot = maj			; return value
	*fre = 0			; free blocks
	*ctg = 0			; largest contiguous
					;
	quit if !fi_see (fil, 512L)	; position at first map block
	msk = 0, gap = 0, res = 1	;
	while maj-- ne			;
	   if !msk			; mask expired
	      fi_rea(fil, &wrd, 2)	; get another word
	      quit res = 0 if fail	;
	   .. msk = 1			; reset mask
	   if wrd & msk			; this one is free
	      ++gap, ++*fre		; measure gap, count free
	      *ctg = gap if gap gt *ctg	; update largest
	   else				;
	   .. gap = 0			; end of contiguous gap
	   msk <<= 1			; next bit in mask
	end				;
      never
	fail if !fi_clo (fil, <>)	; close bitmap
	reply res
  end
