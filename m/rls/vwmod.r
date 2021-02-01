file	vwmod - windows/dos device I/O
include	rid:wimod
include	rid:vwdef
include	rid:medef

;	Handle to VWIN32 is opened once, process wide.

	vwHhan : HANDLE = <>	

	VWIN32_DIOC_DOS_IOCTL := 1

  func	vw_dio
	ret : * vwTreg		; optional
	eax : LONG
	ebx : LONG
	ecx : LONG
	edx : LONG
	esi : LONG
	edi : LONG
  is	reg : vwTreg
	han : HANDLE = vwHhan
	res : LONG
	car : LONG
	if !han
	   han = CreateFile ("\\\\.\\vwin32", 0, 0,
		<>, 0, FILE_FLAG_DELETE_ON_CLOSE, <>)
	   fail if han eq INVALID_HANDLE_VALUE
	.. vwHhan = han

	reg.Veax = eax
	reg.Vebx = ebx
	reg.Vecx = ecx
	reg.Vedx = edx
	reg.Vesi = esi
	reg.Vedi = edi
	reg.Vflg = 1
	res = DeviceIoControl (han, VWIN32_DIOC_DOS_IOCTL,
		&reg, #reg, &reg, #reg, &car, 0)
	fail if !res || (reg.Vflg & 1)
	me_cop (&reg, ret, #reg) if ret
	fine
  end
