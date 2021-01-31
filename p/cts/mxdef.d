header	mxdef - sensible maxima for sensible programs

;	string buffer sizes (including trailing zero)

	mxIDT	:= 64		; identifier (was mxNAM)
	mxLIN	:= 128		; line
				; RT RSX
	mxNOD	:= 6		; 0  5   NOD::
	mxDEV	:= 6		; 4  4   DDN:
	mxDIR	:= 32		; 28 28  \6\6\6\6\
	mxNAM	:= 10		; 6  9   filnam - filnametc
	mxTYP	:= 4		; 4  4   .TYP
	mxVER	:= 6		; 0  4   ;nnn
	mxSPC	:= 48		; 45 57
	mxEXP	:= 64		; expansion - with logical directories
	mxPTH	:= 40		;

end header	
