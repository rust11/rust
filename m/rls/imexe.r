file	imexe - execute image
include	rid:rider
include	rid:imdef
include	rid:dbdef
include	rid:fidef
include	rid:stdef
include	rid:mxdef
include	rid:wimod

;	im_exe	Execute a program -- wait for completion
;	im_spn	Spawn a program -- do not wait
;
;	Status codes are application specific.
;	DOS/Windows rules are:
;	0	success
;	1	error level 1
;	2	error level 2
;	etc

	STDOUT := (2)

code	im_exe - execute an image

  func	im_exe
	spc : * char
	cmd : * char
	flg : int
  is
	sup : STARTUPINFO = {0}
	inf : PROCESS_INFORMATION = {0}
	tmp : [mxLIN] char
	sts : LONG = 0
	opt : HANDLE = 0
	err : HANDLE = 0
	ptr : * char
	han : HANDLE

;	st_cop (spc, tmp)
	fi_def (spc, ".exe", tmp)
	fi_loc (tmp, tmp)
	st_app (" ", tmp)
	st_app (cmd, tmp)
	if flg && (ptr = st_fnd (" > ", tmp)) ne 
	   *ptr = 0
	   han = CreateFile (ptr+3, GENERIC_WRITE,
	        FILE_SHARE_WRITE, 0,CREATE_ALWAYS, 0, 0)
PUT("Handle=%X\n", han)
	   opt = GetStdHandle (STD_OUTPUT_HANDLE)
	   err = GetStdHandle (STD_ERROR_HANDLE)
	   SetStdHandle (STD_OUTPUT_HANDLE, han)
	   SetStdHandle (STD_ERROR_HANDLE, han)
PUT("SetStdHandle=%d\n", that)
	   CloseHandle (han)
	end

      repeat
;;;PUT("tmp=[%s]\n", tmp)

	sts = CreateProcess (<>, tmp,
	 <>, <>, 1, 0, <>, <>, &sup, &inf)
	quit if fail
;;;	quit db_lst ("im_exe") if fail
	WaitForSingleObject (inf.hProcess, INFINITE)
;sic]	ignore fail
	GetExitCodeProcess (inf.hProcess, &sts)
      never
	SetStdHandle (STD_OUTPUT_HANDLE, opt) if opt
	SetStdHandle (STD_ERROR_HANDLE, err) if err
	reply sts
  end
