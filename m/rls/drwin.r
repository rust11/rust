file	drwin - Win32 directory operations
include	rid:rider
include	rid:medef
include	rid:mxdef
include	rid:fidef
include	rid:stdef
include <stdio.h>
include	rid:drdef
include rid:dbdef
include	<windows.h>

If !Wnt
Error Need Win32
End

data	drText - native extensions to drTdir

  type	drText
  is	Vhan : HANDLE
  end

code	dr_avl - check directory available

;	Expects a filespec, or at least a trailing \

  func	dr_avl
	spc : * char			; file spec
  is	pth : [mxLIN] char		; temporary path
	atr : int			; file attributes
	typ : nat			; drive type
	col : * char			;
	fail if *spc eq			; nothing doing
	fi_loc (spc, pth)		; localize it
	col = st_fnd (":", pth)		;
	fail if eq			;
	col[1] = '\\', col[2] = 0	;
	typ = GetDriveType (pth)	; check device exists
	fail if (!typ) || (typ eq 1)	; no device or no root directory
	fine if dr_roo (spc)		; is root directory
	fail if !fi_gat (spc, &atr, <>)	; get the attributes
	reply (atr & drDIR_) ne		; check directory attributes
  end

code	dr_sho - current drive/directory

  func	dr_sho
	pth : * char			; the directory path
	cas : int			;
  is	spc : [mxLIN] char		; drive
	dir : * char			;
	GetCurrentDirectory (mxLIN-1, spc)
	fail db_lst ("") if fail	;
	if cas ne drPTH			;
	   dir = st_fnd ("\\", spc)	;
	   fail if null			; crazy
	   *dir = 0 if cas eq drDRV	;
	.. st_mov (dir, spc) otherwise	;
	fine st_cop (spc, pth)		; return the lot
  end

code	dr_set

;	See drset.r for code

code	dr_fre - get free space

;	(¹) indicates invalid drive

  func	dr_fre
	dir : * char			; path
	res : * drTsiz			; could go 64bit
  is	pth : [mxSPC+1] char		;
	spc : LONG			; sectors per cluster
	bpc : LONG			; bytes per cluster
	fre : LONG			; free sectors
	tot : LONG			; total clusters
	sep : * char			;
	fi_loc (dir, pth)		; translate it first
	if (sep = st_fnd ("\\", pth)) ne; got \ 
	   sep[1] = 0			; terminate it there
	else				; no slash found
	.. *st_lst (pth) = '\\'		; add one
	GetDiskFreeSpace (pth, &spc, &bpc, &fre, &tot)
	fail *res = 0 if fail		;
	fine *res = spc * bpc * fre	; calculate freebies
  end

code	dr_mak - make a directory

  func	dr_mak
	spc : * char
  is	reply CreateDirectory (spc, <>)	; make a directory
  end

code	dr_rem - remove directory

  func	dr_rem
	spc : * char
  is	reply RemoveDirectory (spc)	; remove it
  end
code	dr_enu - enumerate
;???	compare use of atr with drdos.r

	NMF := ERROR_NO_MORE_FILES
	IHV := INVALID_HANDLE_VALUE
	wiThan := HANDLE
	wiTfnd := WIN32_FIND_DATA
	wiTboo := BOOL
	First := FindFirstFile
	Next := FindNextFile
	Error := GetLastError

  func	dr_enu
	dir : * drTdir
	ent : * drTent
	atr : int
	nth : int
	()  : * drTent
  is	nxt : wiTfnd
	fnd : wiTboo
	ext : * drText
	fail if !dir
	if dir->Pext eq				;
	.. dir->Pext = me_acc (#drText)		; allocate the native area
	ext = dir->Pext				; get the native area

 	repeat
	   if nth eq
	      ext->Vhan = First (dir->Ppth, &nxt)
	      fail if ext->Vhan eq IHV
	   else
	      fnd = Next (ext->Vhan, &nxt)	;
	      if !fnd && (Error() ne NMF)	;
	      .. fail ++dir->Verr		; some error
	   .. fail if !fnd			;
	   nth = 1				; once-only
  	   quit if nxt.dwFileAttributes & drDIR_;
	until dr_mat (dir, nxt.cFileName)	; match the name

	if !ent					;
	   ent = me_alc (#drTent)		;
	.. fail ++dir->Vovr if <>		; outa space
	me_clr (ent, #drTent)			;
	ent->Vatr = nxt.dwFileAttributes	;
	ent->Vsiz = nxt.nFileSizeLow		;
If 0
	ent->Palt = st_dup (nxt.cFileName)
	if nxt.cAlternateFileName[0]
	   ent->Pnam = st_dup (nxt.cAlternateFileName)
	else
	.. ent->Pnam = st_dup (ent->Palt)	;
Else
	ent->Pnam = st_dup (nxt.cFileName)
	if nxt.cAlternateFileName[0]
	   ent->Palt = st_dup (nxt.cAlternateFileName)
	else
	.. ent->Palt = st_dup (ent->Pnam)	;

End
;	if !(dir->Vatr & drCAS_)		; case not significant
	   st_low (ent->Pnam)			; get lower case
	 st_low (ent->Palt)			; get lower case
	ti_imp (<*tiTwin>&nxt.ftCreationTime, &ent->Icre)
	ti_imp (<*tiTwin>&nxt.ftLastAccessTime, &ent->Iacc)
	ti_imp (<*tiTwin>&nxt.ftLastWriteTime, &ent->Itim)
	reply ent
  end

code	dr_don - end enumeration

  proc	dr_don
	dir : * drTdir
  is	nothing
  end
