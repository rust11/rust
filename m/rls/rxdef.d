header	rxdef - rad50 conversion

; csi	&_ABCDEFGHIJKLMNOPQRSTUVWXYZ$%*0123456789?&
; macro	&_ABCDEFGHIJKLMNOPQRSTUVWXYZ$._0123456789?&
;
;	oct dec macro csi decusC
;	00  00  space (_)
;	01  01   A
;	32  26	 Z
;	33  27	 $    ($)   ~	
;	34  28	 .     %    _
;	35  29	       *
;	36  30	 0
;	47  39	 9

	rx_pck : (*char, *WORD, int) *char	; pack words
	rx_unp : (WORD, *char) *char		; unpack words

	rx_scn : (*char, *WORD) *char		; scan file spec
	rx_par : (*char, *WORD, int, int)	; generic parse/scan
	rx_fmt : (*char, *WORD, *char) *char	; format file spec

end header
