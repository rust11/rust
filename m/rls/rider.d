header	rider - common header
include sci:stddef			; NULL, size_t etc

	Cpp	   ?= __cplusplus	; C++
	Ztc	   ?= &__ZTC__		; Zortech compiler
	Syc	   ?= &__SC__		; Symantec C
	Stc	   ?= &__STDC__		; Standard Ansii C
	Wdw	   ?= &_WINDOWS		; Windows environment
	Wnt	   ?= &__NT__		; Windows NT
	Wtt	   ?= _WIN32		; Windows/32
	Msc	   ?= &_MSC_VER		; Microsoft compiler
	Os2	   ?= &__OS2__		; OS/2

	Dos	   := 0			; is dos
	Win	   := 1			; any windows
	Unx	   := 0			; not unix
	Vms	   := 0			; not vms
	Pdp	   := 0			; not pdp-11

	BIT (n)	   ?= (1<<(n)) If !&BIT	; bits
	type byte  :  char signed	;
	type word  :  short signed	;
;sic]	type long  :  long signed	;
;	type quad  :  ...		;
	type BYTE  :  char unsigned	;
	type WORD  :  short unsigned	;
	type LONG  :  long unsigned	; unsigned types
;	type QUAD  :  ...		;
	type nat   :  int unsigned	; obsolete
	type bool  :  int		;

If Dos
	FAR(t,s,o) := (<*far t>((<LONG>(s)<<16)|<WORD>(o)))
If Ztc
	SEG (a)	   := (<WORD>(<LONG>(a)>>16))
	OFF (a)    := (<WORD>(a))	;
	SGP (a)	   := ((<*WORD>(&a))[1]); segment of a pointer value
Elif Msc				; Msc C
	SEG (a)	   := (*(<*__far WORD>&(a)+1))
	SGP (a)	   := (<*__far WORD>&(a)+1)
	OFF (a)	   := (*(<*__far WORD>&(a)))
End
End

If Syc || Wtt
	FARW	   :=
Else
	FARW	   := _far
End

If Win					;
	NOMINMAX   := 1			; disable min/max macros
	wiTcha	   := char		; windows CHAR
	wiTsho	   := short	; word	; windows SHORT
	wiTlng	   := long		; windows LONG
End					;

If Cpp
	CC	   := __cdecl		; KRC
	puts	   :  (*char const) __cdecl int
	printf	   :  (*char const, ...) __cdecl int
	sprintf	   :  (*char, *char const, ...) __cdecl int
	sscanf	   :  (*char const, *char const, ...) __cdecl int
Else
	CC	   :=			; nothing
	puts	   :  (*char const) int
	printf	   :  (*char const, ...) int
	sprintf	   :  (*char, *char const, ...) int
	sscanf	   :  (*char const, *char const, ...) int
End
	PUT	   := printf		; simplify life
	FMT	   := sprintf		;
	SCN	   := sscanf		;
	MAX (a,b)  ?= (((a) gt (b)) ? (a) ?? (b)) If !&MAX
	MIN (a,b)  ?= (((a) lt (b)) ? (a) ?? (b)) If !&MIN
	ABS (a)	   ?= (((a) gt 0) ? (a) ?? -(a))  If !&ABS
	SGN (a)	   ?= (((a) eq 0) ? 0 ?? (((a) gt 0) ? 1 ?? -1)) If !&SGN
	XOR (a,b)  ?= ((a) ^ (b)) If !&XOR

end header
end file
;If Ztc
;  huge		   :=			; no huge support
;End					;
;  type	voidL	   : huge void		; 
;  type	charL	   : huge char		; 
If Wdw			
;		long FAR PASCAL __export
;	()  :	__export PASCAL _far int


;	LONGW	   := long		;
;yuk]	__STDC__   ?= 0    If !&__STDC__; default standard C
;	Dll	   ?= &_DLL		; Microsoft DLL
 type	PFI	   :  pascal FARW int	;
 type	PFL	   :  pascal FARW long	;
 type	PFW	   :  pascal FARW WORD	;
 type	PFV	   :  pascal FARW void	;
 type	PFVP	   :  pascal FARW void*

;	PFI	   := int _far PASCAL
;	PFL	   := long _far PASCAL
;	PFW	   := word _far PASCAL
	XPFI	   := PFI __export	;
	XPFL	   := PFL __export	;
	XPFW	   := PFW __export	;
End
