file	dblog - debug log
include	rid:rider
include	rid:mxdef
include	rid:fidef
include	rid:imdef
include	rid:stdef
include	rid:lndef
include	rid:dbdef
include	rid:dblog
include	<errno.h>

;	Only required in hostile debug environments.
;
;	define DEBUGLOG off		no debugging
;			tt		terminal messages
;			<spec>		file spec


If Win
	GetLastError : (void) LONG
	SetLastError : (LONG) void
End

	dbUNK	:= 0
	dbOFF	:= 1
	dbTER	:= 2
	dbFIL	:= 3

	dbVfir	: int = 1
	dbVlog	: int = dbUNK
	dbHlog	: * FILE = <>

code	db_sav - save context

  proc	db_sav
	ctx : * dbTctx
  is	ctx->Vrts = errno
If Win
	ctx->Vsys = GetLastError ()
Else
	ctx->Vsys = 0
End
  end


  proc	db_res
	ctx : * dbTctx
  is	errno = ctx->Vrts
If Win
	SetLastError (ctx->Vsys)
End
  end

code	db_val - log int object

  func	db_val
	msg : * char
	val : int
  is	txt : [128] char 
	if st_fnd ("%", msg)
	   FMT (txt, msg, val)
	else
	.. FMT (txt, "%s %d", msg, val)
	db_msg (txt)
	fine
  end

code	db_str - log string

  func	db_str
	msg : * char
	obj : * char
  is	txt : [128] char 
	if st_fnd ("%", msg)
	   FMT (txt, msg, obj)
	else
	.. FMT (txt, "%s %s", msg, obj)
	db_msg (txt)
	fine
  end

code	db_err - log error

  func	db_err
	msg : * char
  is	spc : [mxSPC] char
	ctx : dbTctx
	txt : [128] char
	err : * char
	db_sav (&ctx)
	FMT (txt, "%s errno=%d system=%d", msg, ctx.Vrts, ctx.Vsys)
If Win
	FMT (st_end (txt), "=%s", dbw_err (ctx.Vsys))
End
	db_msg (txt)
;	db_res (&ctx)
 	fine
  end

code	db_msg - log message

  func	db_msg
	msg : * char
  is	txt : [128] char
	FMT (txt, "%%%s-D-%s\n", imPfac, msg)
	db_log (txt)
	fine
  end
code	db_log - write to debug log

  func	db_log
	txt : * char
  is	spc : [mxSPC] char
	ctx : dbTctx
	err : * char
	trn : int 
	db_sav (&ctx)
	if dbVlog eq dbUNK		; unknown state
	   trn = ln_trn (_dbLOG, spc, 0); translate it
	   st_low (spc) if trn		;
	   if !trn			;
	   || st_sam (spc, "off")	;
	      dbVlog = dbOFF		;
	   elif st_sam (spc, "tt")	;
	      dbVlog = dbTER		;
	   else				; got a file
	      dbHlog = fi_opn (spc, dbVfir ? "w" ?? "a+","") ; open new log file
	      dbVlog = dbFIL if fine	;
	      dbVlog = dbOFF otherwise	;
	.. .. dbVfir = 0			;  not first time anymore

	case dbVlog
	of dbUNK  dbVlog = dbOFF	;
	of dbTER  im_rep ("I-%s", txt)	;
	of dbFIL  fprintf (dbHlog, "%s", txt)
		  fflush (dbHlog)	; flush output
		  fclose (dbHlog)	;
		  dbVlog = dbUNK	; closed
	of dbOFF  nothing		;
	end case			;
;	db_res (&ctx)			; set system error
	fine
  end
