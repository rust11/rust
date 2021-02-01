file	dbprc - get procedure address
include	rid:wimod
include	rid:mxdef
include	rid:stdef

code	db_prc - get procedure address

  func	db_prc
	dll : * char
	fun : * char
	()  : LONG
  is	spc : [mxSPC] char
	mod : HANDLE
	st_cop (dll, spc)
	st_app (".DLL", spc) if !st_fnd (".", spc)
	mod = GetModuleHandle ("KERNEL32.DLL")
	pass fail			; not W95
	reply <LONG>GetProcAddress (mod, fun)
  end

