file	prwin - process control
include rid:rider.h
include rid:fidef.h
include rid:lndef.h
include rid:medef.h
include rid:prdef.h
include rid:shdef.h
include rid:dbdef.h
include <windows.h>

	prPacx : * prTacc = <>
	prVhst : int = 0
	prPhst : * char = "c:\\windows\\system32\\cmd.exe"
	prPalt : * char = "c:\\windows\\command.com"
;	prPalt : * char = "c:\\windows\\system32\\command.com"
	pr_hst : () int-

code	pr_acc - create access block

  func	pr_acc
 	()  : * prTacc
  is	prc : * prTacc
	reply me_acc (#prTacc)
  end

code	pr_cmd - execute command

  func	pr_cmd
	cmd : * char
  is	buf : [512] char
	st_cop (cmd, buf)
	st_low (buf)
	if !st_fnd (".exe", buf)
	|| st_fnd (".exe", buf) gt st_fnd (" ", buf)
	|| st_fnd (">", buf)
	   pr_hst ()
;	   ln_trn ("host", buf, 0)
	   st_cop (prPhst, buf)
	   st_app (" /c ", buf)
	else 
	.. buf[0] = 0
	st_app (cmd, buf)
	reply pr_exe (buf)
  end

code	pr_exe - execute executable

  func	pr_exe
	cmd : * char
  is	prc : * prTacc = prPacx
	sts : int
	prc = prPacx = pr_acc () if !prc
	prc->Pcmd = cmd
	pr_cre (prc)
	pass fail
	pr_opr (prc, prWAI)
	sts = pr_opr (prc, prSTS) 
;	reply sts if sts ne prACT
	reply sts
  end

code	pr_cre - create a process

  func	pr_cre
	acc : * prTacc
  is	nam : * char = acc->Pnam	; process image spec
	cmd : * char = acc->Pcmd	; process command
	prc : * void = <>		; process security attributes
	thr : * void = <>		; thread security attributes
	inh : BOOL = FALSE		; inherit handles
	cre : LONG = 0 		 	; creation flags
	env : * void = <>		; environment block
	dir : * void = <>		; current directory
	sin : STARTUPINFO = {0}		;
	pin : PROCESS_INFORMATION = {0}	;
	sin.cb = #STARTUPINFO
	CreateProcess (nam, cmd, prc, thr, inh, cre, env, dir, &sin, &pin)
	pass fail
;	fail db_lst ("CreateProcess") if fail	;
	acc->Hprc = pin.hProcess	; return the handle
	acc->Hthr = pin.hThread		;
	fine
  end

code	pr_opr - process operations

  func	pr_opr
	prc : * prTacc
	opr : int
  is	cnt : int = 0
	case opr
	of prCRE
	   reply pr_cre (prc)
	of prWAI
	   reply WaitForSingleObject (prc->Hprc,INFINITE); wait for completion
	of prSTS
	   while cnt++ lt 5
	      GetExitCodeProcess (prc->Hprc, <*LONG>&prc->Vsts); get exit code
;	fail db_lst ("getexitcode") if fail	;
	      pass fail
;	      fine if prc->Vsts ne STILL_ACTIVE		; process still active
	      pr_slp (1)				; wait 1 millisecond
	   end
	   reply prACT
	of prTER
	   TerminateProcess (prc->Hprc, 0)
	   reply that ne
	end case
	fine
  end

code	pr_hst - locate host command processor

  func	pr_hst
  is	fine if prVhst			; already found
	if !fi_exs (prPhst, <>)		;
;;;	   fail if !fi_exs (prPalt, <>)	; not found
	   if !fi_exs (prPalt, <>)	; not found
	   .. fail db_lst("fi_exs")
	.. prPhst = prPalt		; use alternate
	++prVhst			; have host
	fine
  end

code	pr_slp - sleep

  func	pr_slp
 	tim : int
  is	Sleep (tim)
  end

code	pr_pri - control priority

	If !&PROCESS_MODE_BACKGROUND_BEGIN
	   ABOVE_NORMAL_PRIORITY_CLASS   := 0x4000
	   BELOW_NORMAL_PRIORITY_CLASS   := 0x8000
	   PROCESS_MODE_BACKGROUND_BEGIN := 0x100000
	   PROCESS_MODE_BACKGROUND_END   := 0x200000
	   THREAD_MODE_BACKGROUND_BEGIN  := 0x10000 
	   THREAD_MODE_BACKGROUND_END    := 0x20000
	End

	prVpri : LONG = NORMAL_PRIORITY_CLASS
	prVthr : int = THREAD_PRIORITY_NORMAL

  init	prApri : [] LONG
  is	prIDL: IDLE_PRIORITY_CLASS
	prBLW: BELOW_NORMAL_PRIORITY_CLASS
	prNOR: NORMAL_PRIORITY_CLASS
	prABV: ABOVE_NORMAL_PRIORITY_CLASS
	prHGH: HIGH_PRIORITY_CLASS
	prRTM: REALTIME_PRIORITY_CLASS
	prBGD: PROCESS_MODE_BACKGROUND_BEGIN
	prFGD: PROCESS_MODE_BACKGROUND_END
	thIDL: THREAD_PRIORITY_IDLE
	thLOW: THREAD_PRIORITY_LOWEST 
	thBLW: THREAD_PRIORITY_BELOW_NORMAL
	thNOR: THREAD_PRIORITY_NORMAL
	thABV: THREAD_PRIORITY_ABOVE_NORMAL
	thHGH: THREAD_PRIORITY_HIGHEST
	thRTM: THREAD_PRIORITY_TIME_CRITICAL
	thBGD: THREAD_MODE_BACKGROUND_BEGIN
	thFGD: THREAD_MODE_BACKGROUND_END
  end

;	I found it better not to issue these calls in (timer) ASTs.

  func	pr_pri
	pri : int
  is	fail if pri gt thFGD
	if pri lt thIDL
	   ;PUT("P%x ", pri) if pri ne prVpri
	   if prVpri eq PROCESS_MODE_BACKGROUND_BEGIN
	   .. SetPriorityClass(GetCurrentProcess(), PROCESS_MODE_BACKGROUND_END)
	   SetPriorityClass(GetCurrentProcess(), prApri[pri])
	   fail db_lst ("SetPriorityClass") if fail
	   prVpri = pri
	else
	   ;PUT("T%d ", pri) if pri ne prVthr
	   if prVthr eq THREAD_MODE_BACKGROUND_BEGIN
	   .. SetThreadPriority(GetCurrentThread(),THREAD_MODE_BACKGROUND_END)
	   SetThreadPriority(GetCurrentThread(), prApri[pri])
	   fail db_lst ("SetThreadPriority") if fail
	.. prVthr = pri
	fine
  end
end file
include rid:dbdef.h

  func main
	arg : * [] * char
	cnt : int
  is	prc : * prTacc = pr_acc ()
	prc->Pcmd = "c:\\bin\\she shapexxx"
	pr_cre (prc)
	PUT("cre=%d\n", that)
	pr_opr (prc, prSTS)
	PUT("sts=%d\n", that)
	pr_opr (prc, prWAI)
	PUT("wai=%d\n", that)
  end
