file	txdis - text object dispatcher
include	rid:wsdef
include	rid:txdef
include	rid:medef
include	rid:fidef
Log := 1
include	rid:dbdef

	txPdis : * txTdis = <>

code	tx_cre - create text window

  func	tx_cre
	evt : * wsTevt
	()  : * txTtxt
  is	fail if !txPdis
	reply (*txPdis->Pcre) (evt)
  end

code	tx_des - destroy text window

  func	tx_des
	evt : * wsTevt
	txt : * txTtxt
  is	(*txPdis->Pdes) (evt, txt) if txPdis
	fine
  end

code	tx_loa - load file

  func	tx_loa
	evt : * wsTevt
	txt : * txTtxt
	spc : * char
	mod : int
	()  : int
  is	fail if !txPdis
	reply (*txPdis->Ploa) (evt, txt, spc, mod)
  end

code	tx_clo - close file

  func	tx_clo
	evt : * wsTevt
	txt : * txTtxt
  is	(*txPdis->Pclo) (evt, txt) if txPdis
	fine
  end

code	tx_sto - store file

  func	tx_sto
	evt : * wsTevt
	txt : * txTtxt
	spc : * char
	mod : int
  is	fail if !txPdis
	reply (*txPdis->Psto) (evt, txt, spc, mod)
  end

code	tx_fun - simple functions

  func	tx_fun
	evt : * wsTevt
	txt : * txTtxt
	fun : int
  is	fail if !txPdis
	reply (*txPdis->Pfun) (evt, txt, fun)
  end

code	tx_fnt - get/set font

  func	tx_fnt
	evt : * wsTevt
	txt : * txTtxt
	fnt : * wsTfnt
	()  : * wsTfnt
  is	fail if !txPdis
	reply (*txPdis->Pfnt) (evt, txt, fnt)
  end
code	tx_opt - output string

  func	tx_opt
	evt : * wsTevt
	txt : * txTtxt
	buf : * char
	len : int
  is	fail if !txPdis
	(*txPdis->Popt) (evt, txt, buf, len)
	fine
  end

end file
code	tx_get - get active text

  func	tx_get
	evt : * wsTevt
	buf : * txTbuf
  is	txt : * txTtxt
                         iOffset = HIWORD (
                              SendMessage (hwndEdit, EM_GETSEL, 0, 0L)) ;

  end
