header	rider - DOS rider front-end (ridos.h)
include <stddef.h>			; NULL, size_t etc

	Dos	   := 1			; is dos
	Unx	   := 0			; not unix
	Vms	   := 0			; not vms
	Ztc	   ?= &__ZTC__		; Zortech compiler
	Stc	   ?= &__STDC__		; Ansii C
;	Msc	   ?=			; Microsoft compiler
;	Tbc	   ?=			; Borland TurboC compiler
;yuk]	__STDC__   ?= 0    If !&__STDC__; default standard C
	BIT (n)	   ?= (1<<(n)) If !&BIT	; bits
	type LONG  :  long unsigned	; unsigned types
	type WORD  :  short unsigned	;
	type BYTE  :  char unsigned	;
	type nat   :  int unsigned	; obselete
	FAR(t,s,o) := (<*far t>((<LONG>(s)<<16)|<WORD>(o)))
If Ztc
	SEG (a)	   := (<WORD>(<LONG>(a)>>16))
	OFF (a)    := (<WORD>(a))	;
	SGP (a)	   := ((<*WORD>(&a))[1]); segment of a pointer value
Else
;	far	   := __far
	SEG (a)	   := (*(<*__far WORD>&(a)+1))
	SGP (a)	   := (<*__far WORD>&(a)+1)
	OFF (a)	   := (*(<*__far WORD>&(a)))
End
	printf	   :  (*char const, ...) int
	sprintf	   :  (*char, *char const, ...) int
	sscanf	   :  (*char const, *char const, ...) int
	PUT	   := printf		; simplify life
	FMT	   := sprintf		;
	SCN	   := sscanf		;

end header
