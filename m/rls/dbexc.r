;	Should be per-thread
file	dbexc - exception handling
include	rid:rider
include	rid:wimod
include	rid:imdef
include	rid:dbdef
include	rid:imdef

	dbTptr := struct _EXCEPTION_POINTERS
	dbTres := long WINAPI
	db_exc : (*dbTptr) dbTres
	dbPprc : * dbTprc = db_rev

code	db_ini - setup debugging

  func	db_ini
  is	prv : * void
	db_hoo (db_rev)
  end

code	db_exi - exit debugging

  proc	db_exi
  is	nothing
  end

code	db_hoo - hook exception

  func	db_hoo 
	prc : * dbTprc			; procedure 
  is	dbPprc = prc
	SetUnhandledExceptionFilter (db_exc)
  end
code	db_exc - exception catcher

	dbTrec := struct _EXCEPTION_RECORD

  func	db_exc
	ptr : * dbTptr
	()  : dbTres
  is	rec : * EXCEPTION_RECORD = ptr->ExceptionRecord
	par : * LONG = rec->ExceptionInformation
	xip : * BYTE = rec->ExceptionAddress
	xsp : * LONG
	exc : dbTexc
	cod : int = rec->ExceptionCode
	PUT("%%%s-F-", imPfac)
   asm	mov  xsp,esp
	case cod
	of EXCEPTION_ACCESS_VIOLATION
	   PUT("Fetch access violation at %X", par[1]) if !par[0]
	   PUT("Store access violation at %X", par[1]) otherwise
	of EXCEPTION_BREAKPOINT
	   PUT("Breakpoint")
	of EXCEPTION_DATATYPE_MISALIGNMENT
	   PUT("Datatype Misalignment")
	of EXCEPTION_SINGLE_STEP
	   PUT("Single Step")
	of EXCEPTION_ARRAY_BOUNDS_EXCEEDED
	   PUT("Array Bounds Exceeded")
	of EXCEPTION_FLT_DENORMAL_OPERAND
	   PUT("Flt Denormal Operand")
	of EXCEPTION_FLT_DIVIDE_BY_ZERO
	   PUT("Flt Divide By Zero")
	of EXCEPTION_FLT_INEXACT_RESULT
	   PUT("Flt Inexact Result")
	of EXCEPTION_FLT_INVALID_OPERATION
	   PUT("Flt Invalid Operation")
	of EXCEPTION_FLT_OVERFLOW
	   PUT("Flt Overflow")
	of EXCEPTION_FLT_STACK_CHECK
	   PUT("Flt Stack Check")
	of EXCEPTION_FLT_UNDERFLOW
	   PUT("Flt Underflow")
	of EXCEPTION_INT_DIVIDE_BY_ZERO
	   PUT("Int Divide By Zero")
	of EXCEPTION_INT_OVERFLOW
	   PUT("Int Overflow")
	of EXCEPTION_PRIV_INSTRUCTION
	   PUT("Priv Instruction")
	of STATUS_NONCONTINUABLE_EXCEPTION
	   PUT("Noncontinuable Exception")
	of DBG_CONTROL_C
	   PUT("Dbg Control C")
	end case
	PUT("\n")
	GetModuleFileName (<>, exc.Aspc, mxSPC-1)
	exc.Pip = xip
	exc.Psp = xsp
	exc.Vcod = cod
	exc.Vflg = par[0]
	exc.Vadr = <*void>par[1]
	(*dbPprc) (&exc) if dbPprc
	ExitProcess (cod)
	TerminateProcess (GetCurrentProcess (), cod)
  end
end file

code	db_ast - debug ast

	dbTcal : (*dbTptr) *dbTptr
  func	db_ast
	ptr : * dbTptr
	()  : WINAPI long
  is	rec : * dbTrec
	rec = ptr->ExceptionRecord
	printf ("db %x: %d\n", rec->ExceptionAddress,
		 rec->ExceptionCode)
	fine
  end

end file

WINBASEAPI
LONG
WINAPI
UnhandledExceptionFilter(
    struct _EXCEPTION_POINTERS *ExceptionInfo
    );

typedef LONG (WINAPI *PTOP_LEVEL_EXCEPTION_FILTER)(
    struct _EXCEPTION_POINTERS *ExceptionInfo
    );
typedef PTOP_LEVEL_EXCEPTION_FILTER LPTOP_LEVEL_EXCEPTION_FILTER;

WINBASEAPI
LPTOP_LEVEL_EXCEPTION_FILTER
WINAPI
SetUnhandledExceptionFilter(
    LPTOP_LEVEL_EXCEPTION_FILTER lpTopLevelExceptionFilter
    );
	XRESULT := WIN

