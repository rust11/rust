;	rg_wri -- error message disabled
;	\rust\mode=usermode=on|off
;	\rust\warnings=on|off
file	rgmod - registry operations
include	rid:rider
include	rid:imdef
include	rid:mxdef
include	rid:stdef
include	<windows.h>
include rid:dbdef
include	rid:rgdef
dbg$c=0

;	RUST registry data is stored as logical names
;
;	HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Rust
;
;	May be virtualised as:
;
; HKEY_USERS\...\Software\Classes\VirtualStore\MACHINE\SOFTWARE\Wow6432Node\RUST
;
;	rg_set (reg, key, str)
;	rg_get (reg, key, str)
;	rg_del (reg, key)
;	rg_enu (reg, key, str, nth)

  type	rgTkey
  is	Ppar : * rgTkey		; parent key 
	Pnam : * char		; key name
	Hkey : HKEY		; registry key
  end

  type	rgTval
  is	Pkey : * rgTkey		; windows object
	Pnam : * char		; value name
	Pdef : * char		; default value
	Vlen : int		; buffer length
	Pbuf : * char		; result buffer
  end

	rgUNK := 0
	rgRST := 1
	rgLOG := 2

	rgKloc : rgTkey = {0, 0, HKEY_LOCAL_MACHINE}
	rgKrst : rgTkey = {&rgKloc, "SOFTWARE\\Rust", }
	rgIroo : rgTval = {&rgKrst, "Root", "C:\\Rust", 64}
	rgIdef : rgTval = {&rgKrst, "Default", "C:\\Rust", 64}
	rgVsta : int = -1

	rg_cre	: (*rgTkey, *rgTval) int
	rg_rea	: (*rgTval) int
	rg_wri	: (*rgTval, *char) int
	rg_del	: (*rgTval, *char) int
	rg_enu	: (*rgTval, int, *char, LONG)

;If dbg$c
;func	rg_dbg
;	val : * rgTval
;	str : * char
;  is	if !db_lst (str)
;	.. PUT("Registry [%s]\n", str)
;	exit if !val
;	PUT("Key=[%s] ", val->Pnam)
;	PUT("Value=[%s]\n", val->Pdef)
;  end
;  End
code	rg_get - get environment variable

;	exported routines
;
;	Get a \Rust\ value

  func	rg_get
	nam : * char
	str : * char
	len : int
;	mod : int
	()  : int
  is	log : [mxLIN] char
	val : rgTval = {0}
	st_fit (nam, log, mxLIN)
	st_low (log)

	val.Pkey = &rgKrst
	val.Pnam = log
	val.Pbuf = str
	val.Vlen = len
	reply rg_rea (&val)
  end

code	rg_set - set environment variable

  func	rg_set
	nam : * char
	str : * char
;	mod : int
  is	log : [mxLIN] char
	equ : [mxLIN] char
	val : rgTval = {0}

	st_fit (nam, log, mxLIN), st_low (log)
	st_fit (str, equ, mxLIN), st_low (equ)

	val.Pkey = &rgKrst
	val.Pnam = log
	reply rg_wri (&val, equ)
  end

code	rg_und - undefine environment variable

  func	rg_und
	nam : * char
;	mod : int
  is	loc : [mxLIN] char
	val : rgTval = {0}

	st_fit (nam, loc, mxLIN), st_low (loc)
	val.Pkey = &rgKrst
	val.Pnam = nam
	reply rg_del (&val, nam)
  end

code	rg_nth - get nth entry

  func	rg_nth
	nth : int
	res : * char
	len : int
;	mod : int
  is	val : rgTval = {0}

	val.Pkey = &rgKrst
	val.Pnam = res
	reply rg_enu (&val, nth, res, len)
  end
code	rg_ini - init registry

;	internal routines

  func	rg_ini
;	key : *rgTkey
  is	reply rgVsta if rgVsta ne -1	; once-only
	rgVsta = 1			; stops recursion	
	if rg_cre (&rgKrst, &rgIroo)
	&& rg_cre (&rgKrst, &rgIdef)
	.. fine
	fail rgVsta = 0
  end

  func	rg_cre
	key : * rgTkey
	val : * rgTval
  is	par : * rgTkey = key->Ppar
	res : int
	if RegOpenKeyEx (par->Hkey, key->Pnam,
	   0, 0, &key->Hkey) ne ERROR_SUCCESS
	&& RegCreateKeyEx (par->Hkey, key->Pnam,
	   0, <>, REG_OPTION_NON_VOLATILE,
	   KEY_QUERY_VALUE|KEY_WRITE|KEY_NOTIFY|KEY_ENUMERATE_SUB_KEYS,
	   <>, &key->Hkey, <>) ne ERROR_SUCCESS
	   ;rg_dbg (val, "Registry Create")
	   db_lst ("cre")
	.. fail

	rg_wri (val, val->Pdef) if !rg_rea (val)
	fine
  end

  func	rg_rea
	val : * rgTval
  is	key : * rgTkey = val->Pkey
	len : LONG = val->Vlen
	err : int 

	fail if !rg_ini ()
	err = RegQueryValueEx (key->Hkey, 
	   val->Pnam, <>, <>, 
	   <LPBYTE>val->Pbuf, &len)
	if err ne ERROR_SUCCESS
	.. fail ;db_rep ("rea", err)

	fine if !val->Pbuf		; just checking it's there
	fail if len ge val->Vlen-1
	val->Pbuf[len] = 0
	fine
  end

  func	rg_wri
	val : * rgTval
	str : * char
  is	key : * rgTkey = val->Pkey
	fail if !rg_ini ()
	if !RegSetValueEx (key->Hkey,
	    val->Pnam, 0, REG_SZ,
	    <LPBYTE>str, st_len (str) +1)
	.. fail ;rg_dbg (val, "Registry Write")
	fine
  end

  func	rg_del
	val : * rgTval
	nam : * char
  is	key : * rgTkey = val->Pkey
	fail if !rg_ini ()
	fail if RegDeleteValue (key->Hkey, val->Pnam)
	fine
  end

  func	rg_enu
	val : * rgTval
	idx : int
	nam : * char
	len : LONG
  is	key : * rgTkey = val->Pkey
	err : int
	fail if !rg_ini ()
	err = RegEnumValue (key->Hkey,
	    idx, nam, &len,
	    <>, <>, <>, 0)
	fine if eq
	fail
  end
