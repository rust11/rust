If Log
	LOG (m)    := db_msg (m)
	LOGe(m)    := db_err (m)
	LOGs(m, o) := db_str (m, <*char>o)
	LOGv(m, o) := db_val (m, <int>o)
	LOGw(m)	   := db_log (m)
Else
	LOG (m)    :=
	LOGe(m)    :=
	LOGs(m, o) :=
	LOGv(m, o) :=
	LOGw(m)    :=
End
header	dblog - db logging

  type	dbTctx
  is	Vrts : long			; RTS error status (errno)
	Vsys : long			; system error status
	Vsev : long			; severity
  end

	db_sav : (*dbTctx) void		; save debug context
	db_res : (*dbTctx) void		; restore it

	_dbLOG	:= "DEBUGLOG"		; debug log file
	db_msg : (*char) int		; log message and object
	db_val : (*char, int) int	; log message and value
	db_str : (*char, *char) int	; log message and string
	db_err : (*char) int		; log message and error codes
	db_log : (*char) int		; raw write to debug log

end header
