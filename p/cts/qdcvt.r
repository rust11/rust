file	qdcvt - quad integer conversion
include	rid:rider
include	rid:medef
include rid:qddef

;	Unoptimised quad integer arithmetic support
;	Implemented to support quad time values;
;
;	Quads are represented as four 16-bit (unsigned) words,
;	stored in PDP-11 reverse word-order (as for longs)
;
;	quad:	.word	high-order	; sign bit is bit 15
;		.word	...
;		.word	..
;		.word	low-order	; quad bit 0 is bit 0

code	qd_lqu - long to quad, unsigned

  func	qd_lqu
	lng : long
	qua : * WORD~
  is	ptr : * WORD~ = <*WORD>&lng
	qd_clr (qua)
	qua[3] = ptr[1]
	qua[2] = ptr[0]
  end

code	qd_lqs - long to quad, signed

  func	qd_lqs
	lng : long~
	qua : * WORD~
  is	qd_lqu (lng, qua)
	qua[1] = qua[0] = -1 if lng lt
  end

code	qd_qtl - quad to long

  func	qd_qtl
	qua : * WORD~
	lng : * long~
  is	ptr : * WORD~ = <*WORD>lng
	ptr[1] = qua[3]
	ptr[0] = qua[2]
  end
