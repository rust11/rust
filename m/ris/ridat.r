file	ridat - compiler dependent data
include rid:rider
include rib:eddef
include rib:ridef


	quFdec : int = 0		;
;?V4
	quFdos : int = 1;Dos || Win || Wnt;
	quFunx : int = 0		;
	quFver : int = 0		;
	quFlin : int = 0		;

	riPcur : * riTlin = NULL	; current line
	riPnxt : * riTlin = NULL	; next line
					;
	riPswd	: * "short"		; word
	riPuwd	: * "short unsigned"	; WORD
If Vms
	riPsop	: * "tt:"		; standard output
Else
	riPsop	: * "con"		; standard output
End
	riVdbg	: int = 0		;
	riVpre	: int = 0		; in preprocessor conditional
