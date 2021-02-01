file	imrep - image report
include rid:rider
include rid:imdef

;	RUST IM_REP does not support bypass routines

imPrep	: * imTrep = im_con	; user bypass routine

code	im_rep - image report

  func	im_rep
	msg : * char			; e.g. "File not found [%s]"
	obj : * char			; e.g. "dev:myfile.doc"
	()  : int			; always fine at present
  is	reply (*imPrep)(msg, obj)	; they do it
  end

code	im_con - console message

  func	im_con
	msg : * char			; e.g. "F-File not found [%s]"
	obj : * char			; e.g. "dev:myfile.doc"
	()  : int			; always fine at present
  is	PUT ("%s%s-", imPpre, imPfac)	; prefix and facility
	PUT (msg, obj)			; the message and objects
	PUT ("\n")			; newline
	im_sev (msg)			; set severity
	fine
  end

code	im_sev - set image severity

  func	im_sev
	msg : * char
	()  : int			; severity
  is	case *msg			; handle severity
	of 'W' im_war ()		; warn them
	of 'E' im_err ()		; error
	of 'F' im_fat ()		; fatal
;sic]	of 'I' nothing			;
	end case			;
	fine				;
  end
end file
;	See if we still use these anywhere
code	im_dec - convert decimal

	imAbuf : [32] char = ""		; default static buffer

  func	im_dec
	val : int
	buf : * char
	()  : * char
  is	buf = imAbuf if !buf		; supply default
	FMT (buf, "%d", val)		;
	reply buf			;
  end


code	im_hex - convert hexadecimal

  func	im_hex
	val : int
	buf : * char
	()  : * char
  is	buf = imAbuf if !buf		; supply default
	FMT (buf, "%x", val)		;
	reply buf			;
  end
