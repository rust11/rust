file	lnmod - logical names
include	rid:rider
include rid:lndef

;	define RT-11 logical names
;
;	see rtlog.mac

  func	ln_def
	log : * char
	equ : * char
	mod : int
  is	lnm : WORD
	enm : WORD
	rx_pck (log, &lnm, 1)
	rx_pck (equ, &enm, 1)
	lt_def (lnm, enm)
  end

  func	ln_und
	log : * char
	mod : int
  is	lnm : WORD
	rx_pck (log, &lnm, 1)
	lt_und (lnm)
  end

  func	ln_rem
	equ : * char
	mod : int
  is	enm : WORD
	rx_pck (equ, &enm, 1)
	lt_und (enm)
  end
