file	tisig - timer signals
include	rid:rider
include	rid:tidef
include	<windows.h>

;	Windows callback

	tiPast : * tiTast = <>

  func	ti_ast
	evt : UINT
	rsv : UINT
	usr : DWORD
	f01 : DWORD
	f02 : DWORD
	()  : CALLBACK void
  is	tiPast () if tiPast
  end

  func	ti_sig
	res : int
	ast : * tiTast
  is	tiPast = ast
	timeSetEvent (res, res, ti_ast, 0, TIME_PERIODIC)
  end

	tiHwai : HANDLE

  func	ti_wai
	mil : LONG
  is	tiHwai = CreateEvent (<>, 1, 0, <>) if !tiHwai
	WaitForSingleObject (tiHwai, mil)
  end
