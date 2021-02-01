file	thmod - thread operations
include	rid:rider
include	rid:medef
include	rid:wsdef
include	rid:thdef

;	Threads are created with an event for synchronisation.
;	The Windows/98 version of SuspendThread and ResumeThread
;	was sufficiently flawed to be useless.

code	th_thk - thread process thunk

  func	th_thk
	par : * void
	()  : WINAPI DWORD
  is	thr : * thTthr = par
	fun : * thTfun = thr->Pfun
	reply (*fun)(thr) if fun
	repeat
	  th_wai (thr)		; just wait forever
	forever
  end

code	th_cre - create thread

  func	th_cre
	fun : * thTfun
	par : * void
  	()  : * thTthr
  is	thr : * thTthr = me_alc (#thTthr)
	hnd : LONG
	idt : LONG
	thr->Pfun = fun
	thr->Vevt = <LONG>CreateEvent (0, 0, 0, <>)
	thr->Vhnd = <LONG>CreateThread (0, 1024*1024, th_thk, thr, 0, &idt)
	SetThreadPriority (<*void>thr->Vhnd, THREAD_PRIORITY_HIGHEST)
;	SetThreadPriorityBoost (<*void>thr->Vhnd, 0)
PUT("yuk\n") if fail
	thr->Ppar = par
	thr->Vidt = idt
	reply thr
  end

code	th_wai - wait for thread

  func	th_wai
	thr : * thTthr
  is	hnd : HANDLE = <HANDLE>thr->Vevt
	WaitForSingleObject (hnd, INFINITE)
	fine
  end

code	th_sig - set/clear thread event

  func	th_sig
	thr : * thTthr
 	sig : int
  is	hnd : HANDLE = <HANDLE>thr->Vevt
	SetEvent (hnd) if sig
	ResetEvent (hnd) otherwise
	fine
  end
end file

code	th_roo - create root process thread

  func	th_roo
	()  : * thTthr
  is	thr : * thTthr
	prc : HANDLE = GetCurrentProcess ()
	vir : HANDLE = GetCurrentThread ()
	phy : HANDLE
	thr = me_alc (#thTthr)
	thr->Vidt = <LONG>GetCurrentThreadId ()
	DuplicateHandle (prc, vir, prc, &phy, 0, 0, 0)
	thr->Vhnd = <LONG>phy
PUT("prc=%d, vir=%d, phy=%d\n", prc, vir, phy)
	reply thr
  end


code	th_exi - exit/terminate thread

  func	th_exi
	thr : * thTthr
	res : LONG
  is	if !thr
	   ExitThread (<DWORD>res)
	else
	   TerminateThread (<HANDLE>thr->Vhnd, <DWORD>res)
	end
	fine
  end

  func	th_sus
	thr : * thTthr
  is	SuspendThread (<HANDLE>thr->Vhnd)
	fine
  end

  func	th_res
	thr : * thTthr
  is	ResumeThread (<HANDLE>thr->Vhnd)
	fine
  end

  type	evTevt
  is	Psuc : * evTevt
	Pnam : * char
	Vhnd : LONG
  end

  func	ev_cre
	nam : * char
	man : int
	sta : int
  	()  : * evTevt
  is	evt : * evTevt = me_alc (#evTevt)
	evt->Vhnd = <LONG>CreateEvent (0, man, sta, nam)
	reply evt
  end

  func	ev_wai
	evt : * evTevt
  is	WaitForSingleObject (<HANDLE>evt->Vhnd, INFINITE)
	fine
  end

  func	ev_sig
	evt : * evTevt
 	sig : int
  is	hnd : HANDLE = <HANDLE>evt->Vhnd
	SetEvent (hnd) if sig
	ResetEvent (hnd) otherwise
	fine
  end

