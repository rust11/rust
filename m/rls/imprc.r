file	imprc - get image process address
include	rid:wimod

  func	im_prc
	img : * char
	prc : * char
	()  : * void
  is	ker : HANDLE = <>
	ker = GetModuleHandle (img)
	pass fail
	reply GetProcAddress(ker, prc)
  end
