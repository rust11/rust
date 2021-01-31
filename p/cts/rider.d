header	rider - common header
;CRT := 1				; CRT doesn't use <stdio>
Crt := 1				; How it should have been

;	%build
;	rider/header cts:rider.d/object:rid:rider.h
;	%end

	Win	   := 0			; not windows
	Wnt	   := 0			; not windows/nt
	Dos	   := 0			; not dos
	Vms	   := 0			; not vms
	Pdp	   := 1			; pdp-11
If &WHITE
	Dcc	   := 0			; not decus 
	Wcc	   := 1			; is whitesmiths 
	esCexi	   := 1			; success exit
Else
	Dcc	   := 1			; is decus
	Wcc        := 0			; not whitesmiths
	esCexi	   := 1			; success exit
End

	type byte  :   char  ; signed	;
	type word  :   short ; signed	;
;sic]	type long  :   long  ; signed	;
;	type quad  :   ...		;
;	type size  :   unsigned		;
If Dcc					; DECUS
	BYTE := char			; no unsigned bytes
	WORD := unsigned int		;
	LONG := long			; no unsigned longs
;	void				; DECUS has void
;	nat := unsigned int		; obselete
Else
	type BYTE  :   char unsigned	;
	type WORD  :   short unsigned	;
	type LONG  :   long unsigned	;
	void 	   :=  char		;
;	type nat   :   int unsigned	; obsolete
End
	type bool  :   int		;

	BIT (n)	   ?= (1<<(n)) If !&BIT	; bits
	PUT	   := printf		; simplify life
	FMT	   := sprintf		; FMT(*opt,"ctl",objs)
	SCN	   := sscanf		; SCN(*ipt,"ctl",objs)
	MAX (a,b)  ?= (((a) gt (b)) ? (a) ?? (b)) If !&MAX
	MIN (a,b)  ?= (((a) lt (b)) ? (a) ?? (b)) If !&MIN
	ABS (a)	   ?= (((a) gt 0) ? (a) ?? -(a))  If !&ABS

	Adr(t,v) := PUT("%s=%o\n", t, v)
	Val(t,v) := PUT("%s=%d\n", t, v)
	Str(t,s) := PUT("%s=%s\n", t, s)

  type	FILE 	: * void		; anonymous
	NULL	:= (0)			;
	EOF	:= (-1)			;
	stdin	: * FILE+		;
	stdout	: * FILE+		;

end header
