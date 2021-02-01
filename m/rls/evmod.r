file	evmod - environment operations
include	rid:rider
include	rid:evdef
include	rid:fidef
include	rid:imdef
include	rid:mxdef
include	rid:stdef
include	<windows.h>
include rid:dbdef

  type	evTkey
  is	Ppar : * evTkey		; parent key 
	Vcod : int		; key code
	Pnam : * char		; key name
	Hkey : HKEY		; registry key
	Hevt : HANDLE		; change event
	Vdis : LONG		; disposition
  end

  type	evTval
  is	Pkey : * evTkey		; windows object
	Pnam : * char		; value name
	Pdef : * char		; default value
	Vlen : int		; buffer length
	Pbuf : * char		; result buffer
  end

	evKloc : evTkey = {0, evUNK, 0, HKEY_LOCAL_MACHINE}
	evKrst : evTkey = {&evKloc, evRST, "SOFTWARE\\Rust", }
	evKlog : evTkey = {&evKrst, evLOG, "Logicals"}
	evKcmd : evTkey = {&evKrst, evCMD, "Commands"}
	evKdev : evTkey = {&evKrst, evDEV, "Devices"}

	evIroo : evTval = {&evKrst, "Root", "C:\\Rust", 64}
	evIdef : evTval = {&evKrst, "Default", "C:\\Rust", 64}
	evIlog : evTval = {&evKlog, "Update", "1", 8}
	evIcmd : evTval = {&evKcmd, "Update", "1", 8}
	evIdev : evTval = {&evKdev, "Update", "1", 8}
  
  init	evAval : [] * evTval
  is	<>
	&evIroo
	&evIdev
	&evIlog
	&evIcmd
	&evIdef
  end

	evVsta : int = -1

	ev_cre	: (*evTkey, *evTval) int
	ev_rea	: (*evTval) int
	ev_wri	: (*evTval, *char) int
	ev_wat	: (*evTkey) int
	ev_trg	: (int) int
code	ev_get - get environment variable

;	Get a \Rust\ value

  func	ev_get
	nam : * char
	buf : * char
	len : int
	()  : int
  is	val : evTval = {0}
	val.Pkey = &evKrst
	val.Pnam = nam
	val.Pbuf = buf
	val.Vlen = len
	reply ev_rea (&val)
  end

code	ev_set - set environment variable

  func	ev_set
	nam : * char
	str : * char
  is	loc : [mxLIN] char
	val : evTval = {0}

	st_cop (nam, loc), st_low (loc)
	if st_sam (loc, "root")
	   st_cop (str, loc)
	   st_app ("\\", loc) if *st_lst (loc) ne '\\'
	   st_app ("roll.def", loc)
	   fi_loc (loc, loc)
	   if !fi_exs (loc, <>)
	   .. fail im_rep ("E-Invalid root [%s]", str)
	   fi_def (str, "c:", loc)
	.. str = loc

	val.Pkey = &evKrst
	val.Pnam = nam
	reply ev_wri (&val, str)
  end
code	ev_ins - instantiate registry

  func	ev_ins
  is	reply evVsta if evVsta ne -1	; once-only
	evVsta = 1			; stops recursion	
	if ev_cre (&evKrst, &evIroo)
	&& ev_cre (&evKrst, &evIdef)
	&& ev_cre (&evKlog, &evIlog)
	&& ev_cre (&evKcmd, &evIcmd)
	&& ev_cre (&evKdev, &evIdev)
	.. fine
	fail evVsta = 0
  end

  func	ev_cre
	key : * evTkey
	val : * evTval
  is	par : * evTkey = key->Ppar
	res : int
	if RegOpenKeyEx (par->Hkey, key->Pnam,
	   0, 0, &key->Hkey) ne ERROR_SUCCESS
	&& RegCreateKeyEx (par->Hkey, key->Pnam,
	   0, <>, REG_OPTION_NON_VOLATILE,
	   KEY_QUERY_VALUE|KEY_WRITE|KEY_NOTIFY, <>,
	   &key->Hkey, &key->Vdis) ne ERROR_SUCCESS
;db_lst ("cre")
	.. fail
	ev_wri (val, val->Pdef) if !ev_rea (val)
	ev_wat (key)
	fine
  end

  func	ev_rea
	val : * evTval
  is	key : * evTkey = val->Pkey
	len : LONG = val->Vlen
	err : int 
	fail if !ev_ins ()
;PUT("nam=[%s]\n", val->Pnam)
	err = RegQueryValueEx (key->Hkey, 
	   val->Pnam, <>, <>, 
	   <LPBYTE>val->Pbuf, &len)
	if err ne ERROR_SUCCESS
	.. fail db_rep ("rea", err)
	fine if !val->Pbuf		; just checking it's there
	fail if len ge val->Vlen
	val->Pbuf[len] = 0
;PUT("nam=[%s] rea=[%s]\n", val->Pnam, val->Pbuf)
	fine
  end

  func	ev_wri
	val : * evTval
	str : * char
  is	key : * evTkey = val->Pkey
	sig : int = evFST
	fail if !ev_ins ()
	fail if RegSetValueEx (key->Hkey,
	    val->Pnam, 0, REG_SZ,
	    <LPBYTE>str, st_len (str) +1)
;PUT("ev_wri(%s)", key->Pnam)
	fine if !st_sam (val->Pnam, "Root")
;PUT(" TRG ")
	ev_trg (sig++) while sig le evLST
	fine
  end

code	watch and check entity changed

;	Used by logical names and command definitions to see
;	if another process has altered the data.

  func	ev_wat
	key : * evTkey
  is	fine if key->Vcod eq evUNK
	if !key->Hevt
	.. key->Hevt = CreateEvent (<>, 0, 0, <>)
	fail if !key->Hevt
	RegNotifyChangeKeyValue (key->Hkey, 0,
   	  REG_NOTIFY_CHANGE_LAST_SET, key->Hevt, 1)
  end

  func	ev_chk
	cod : int 
  is	val : * evTval = evAval[cod]
	key : * evTkey = val->Pkey
	res : int
	fail if !ev_ins ()
;PUT("ev_chk(%s)=", key->Pnam)
	fail if !key->Hevt
	res = WaitForSingleObjectEx (key->Hevt, 0,0)
	if res eq WAIT_OBJECT_0
;	   ResetEvent (key->Hevt)
	   ev_wat (key)
;PUT("Changed %s\n", key->Pnam)
	   fine
	elif res eq WAIT_TIMEOUT
;PUT("Same\n")
	   fail
	else
;PUT("WRONG=%d ", res)
	   fail
	end
  end

  func	ev_sig
	cod : int
  is	ev_trg (cod)
	ev_chk (cod)
  end

  func	ev_trg
	cod : int
  is	val : * evTval = evAval[cod]
	key : * evTkey = val->Pkey
	fail if !key->Hevt
;PUT("ev_trg(%s) ", key->Pnam)
	ev_wri (val, "0")
	ev_wri (val, "1")
  end
