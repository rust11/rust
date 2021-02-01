file	rider.h - PDP-11 rider front-end
#ifndef __STDC__
	__STDC__ := 0			; force resolution
#endif
;#ifdef WHITE
;	pdp11	:= 1
;	rt11	:= 1
;	void	:= char			; implement void keyword
;#endif
;
;#ifdef pdp11				; pdp 
;	szKcha	:= 1			; pdp	- 1 byte per character
;	szKint	:= 2			; pdp	- 2 bytes per integer
;	szKlng	:= 4			; pdp	- 4 bytes per long integer
;#endif
