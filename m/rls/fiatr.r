file	faatr - file attribute operations
include	rid:rider
include	rid:fidef
include	rid:tidef
include	rid:mxdef
include	<windows.h>

	E_AccFil := "E-Error accessing file [%s]"
	E_SetFil := "E-Error setting file [%s]"
	fiAacc	: * char own = E_AccFil
	fiAset	: * char own = E_SetFil

code	fi_gtm - get file date/time

	diTsta := struct stat

  func	fi_gtm
	spc : * char			; file spec
	val : * tiTval			; the time
	msg : * char			; error message
	()  : int			; fine/fail
  is	nam : [mxLIN] char		;
	han : HANDLE			; file handle
	fil : FILETIME			;
	fi_loc (spc, nam)		; translate the name
	han = CreateFile (nam, GENERIC_READ,
	      FILE_SHARE_READ|FILE_SHARE_WRITE,
	      <>, OPEN_EXISTING, 0, 0)
	if that ne <>			; got a handle
	&& GetFileTime (han, <>,<>,&fil); file time
	&& CloseHandle (han)		; close the file
	&& ti_fnt (&<tiTwin>fil, val)	; convert to our format
	.. fine				;
	fail fi_rep (msg, spc, fiAacc)	; error accessing file
  end 

code	fi_stm - set file date/time

  func	fi_stm
	spc : * char			; file spec
	val : * tiTval			; the time
	msg : * char			; error message
	()  : int			; fine/fail
  is	nam : [mxLIN] char		;
	han : HANDLE			; file handle
	fil : FILETIME			; filetime
	fi_loc (spc, nam)		; translate the name
	ti_tnt (val, &<tiTwin>fil)	; convert to WNT format
	pass fail			;
	han = CreateFile (nam, GENERIC_WRITE,
	      FILE_SHARE_READ|FILE_SHARE_WRITE,
	      <>, OPEN_EXISTING, 0, 0)
	if that ne <>			; yuk
	&& SetFileTime (han, &fil,&fil,&fil); file time
	&& CloseHandle (han)		; close the file
	.. fine				;
	fail fi_rep (msg, spc, fiAacc)	; error accessing file
  end 

code	fi_gat - get attributes

  func	fi_gat
	spc : * char
	atr : * int
	msg : * char			;
	()  : int			;
  is	nam : [mxLIN] char		;
	res : LONG
	fi_loc (spc, nam)		; translate the name
	res = GetFileAttributes (nam)
	if res ne 0xFFFFFFFF		; got the attributes
	   *atr = <int>res if atr	; return attributes
	.. fine				;
	fail fi_rep (msg, spc, fiAacc)	; error accessing file
  end

code	fi_sat - set attributes

  func	fi_sat
	spc : * char
	bic : int			; clear
	bis : int			; set
	msg : * char			;
	()  : int			;
  is	nam : [mxLIN] char		;
	atr : int 			;
	fi_loc (spc, nam)		; translate the name
      repeat				;
	quit if !fi_gat (nam, &atr, <>)	;
	atr &= ~(bic)			; clear some
	atr |= bis			; set some
	SetFileAttributes (nam, <WORD>atr) ;
	pass fine			;
      never				;
	fail fi_rep (msg, spc, fiAset)	; error setting file
  end
end file

code	fi_sta - get local file status

  type	fiTsta
  is	Vdev : word	; dev	device		drive#		handle
	Vnod : word	; ino	inode		0		0
	Vmod : word	; mode
	Vlnk : word	; nlink	links		1		1
	Vuid : word	; user id
	Vgid : word	; group id
	Vred : word	; rdev	redirection	drive#		handle
	Vf00 : word	; dummy
	Vlen : long	; size	byte length
	Vacc : long	; atime	access time
	Vmod : long	; mtime	modify time
	Vcre : long	; ctime	creation time
  end

;	mode bits

	fiMOD_	:= 0xf000
	fiREG	:= 0x8000
	fiBLK	:= 0x6000
	fiNAM	:= 0x5000
	fiDIR	:= 0x4000
	fiCHR	:= 0x2000

	fiMreg(m) := (((m)&(fiMOD_))==fiREG)
	fiMblk(m) := (((m)&(fiMOD_))==fiBLK)
	fiMnam(m) := (((m)&(fiMOD_))==fiNAM)
	fiMdir(m) := (((m)&(fiMOD_))==fiDIR)
	fiMchr(m) := (((m)&(fiMOD_))==fiCHR)

; uid/gid flags

	fiREA_	:= 0x0100 
	fiWRI_	:= 0x0080
	fiEXE_	:= 0x0040

  func	fi_sta
	spc : * char
	han : * FILE
	sta : * fiTsta
  is	loc : struct stat
	res = stat (spc, &stat) if spc
	res = fstat (han, &stat) otherwise
	fail if res eq -1
	sta->Vdev = loc.st_dev
	sta->Vnod = loc.st_ino
	sta->Vmod = loc.st_mode
	sta->Vlnk = loc.st_nlink
	sta->Vuid = loc.st_uid
	sta->Vgid = loc.st_gid
	sta->Vred = loc.st_rdev
	sta->Vlen = loc.st_size
	sta->Vcre = loc.st_ctime
	sta->Vacc = loc.st_atime
	sta->Vmod = loc.st_mtime
  end

struct stat
{	short	st_dev;
	unsigned short	st_ino;
	unsigned short st_mode;
	short	st_nlink;
	unsigned short	st_uid;
	unsigned short	st_gid;
	short	st_rdev;
