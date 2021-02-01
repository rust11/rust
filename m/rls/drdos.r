file	drdos - dos directory operations
include	rid:rider
include	rid:medef
include	rid:mxdef
include	rid:stdef
include	rid:drdef
include <stdio.h>
include <stdlib.h>
include <dos.h>
include <direct.h>
include	rid:dsmod

	dr_fun	: (*char, int, *int) int own

code	dr_avl - check directory available

;	Expects a filespec, or at least a trailing \

  func	dr_avl
	spc : * char			; file spec
  is	reg : dsTreg			;
	atr : int = 0			;
	drv : int			;
	fail if *spc eq			; nothing doing
	drv = ds_TrnDrv (spc)		; get the drive
	fail if eq			; invalid drive
	BX = drv, ds_r21 (0x4409)	; check remote device
	fail if CF			; no such device
	fine if dr_roo (spc)		; is root directory
	dr_fun (spc, 0x4300, &atr)	; get the file attributes
	reply (atr & drDIR_) ne		; check directory attributes
  end

code	dr_sho - current drive/directory

  func	dr_sho
	pth : * char			; the directory path
	cas : int			;
  is	drv : [mxLIN] char		; drive
	drv[0] = ds_GtCDrv()+('A'-1)	; get the drive
	drv[1] = ':', drv[2] = 0	;
	if (cas eq drPTH) || (cas eq drDRV)
	.. pth = st_cop (drv, pth)	; copy in the drive
	if (cas eq drPTH) || (cas eq drDIR)
	.. ds_GtCDir (drv, pth)		; get drives current working directory
	fine				;
  end

code	dr_set - change directory

;	see drset.r

code	dr_fre - get free space

;	(~1) indicates invalid drive

  func	dr_fre
	pth : * char			; path
	fre : * drTsiz			; could go 64bit
  is	siz : size = ds_GetFre (pth)	; get the space
	fail if siz eq (~1)		; no such beast
	fine *fre = siz			; just honky dory
  end

code	dr_mak - make a directory

  func	dr_mak
	spc : * char
  is	reply dr_fun (spc, 0x3900, <>)	; make a directory
  end

code	dr_rem - remove directory

  func	dr_rem
	spc : * char
  is	reply dr_fun (spc, 0x3a00,<>)	; remove a directory
  end

code	dr_fun - dos directory function

  func	dr_fun
	spc : * char
	fun : int
	res : * int 
	()  : int own
  is	pth : [mxSPC] char		; directory path
	seg : dsTseg			;
	reg : dsTreg			;
	ds_seg (&seg)			;
	dr_spc (spc, <>, pth)		; get the directory path
	DS = SEG(pth), DX = OFF(pth)	; setup pointers
	fail if ds_s21 (fun), CF	; do it
	*res = CX if res ne <>		; attributes for some
	fine				;
  end
code	dr_enu - enumerate

	drTfnd	:= struct FIND
	First	:= findfirst
	Next	:= findnext
	attr	:= attribute	; shorten that

  func	dr_enu
	dir : * drTdir
	ent : * drTent
	atr : int
	nth : int			; le to start search, gt for subsequent
	()  : * drTent			;
  is	nxt : * drTfnd			;
	tim : tiTdos			; dos time
					;
 	repeat				;
	   nxt = First (dir->Ppth, atr) if nth le
	   nxt = Next () otherwise	;
	   fail if !nxt 		; no entries
	   nth = 1			; once-only
	   quit if nxt->attr & drDIR_	; is a directory
	until dr_mat (dir, nxt->name)	; match the name
					;
	if !ent				;
	   ent = me_alc (#drTent)	;
	.. fail ++dir->Vovr if <>	; outa space
	me_clr (ent, #drTent)		;
	ent->Vatr = nxt->attr		;
	ent->Vsiz = nxt->size		;
	tim.Vdat = nxt->date		;
	tim.Vtim = nxt->time		;
	ti_fds (&tim, &ent->Itim)	; import the time
	ent->Pnam = me_alc (14)		;
	fail ++dir->Vovr if <>		; no room
	me_cop (nxt->name, ent->Pnam,13); get a copy
	ent->Pnam[13] = 0		; paranoia
	st_low (ent->Pnam)		; get lower case
	ent->Palt = 0			; no alternate name
	ent->Icre = 0			; no creation time
	ent->Iacc = 0			; no access time
	reply ent			;
  end

code	dr_don - end enumeration

  proc	dr_don
	dir : * drTdir
  is	nothing
  end
