;	See SKS:QDMOD.R for some optimisations (MACRO is the real answer)
file	qdmod - quad integer arithmetic
include	rid:rider
include	rid:medef
include rid:qddef

;	%build
;	rider sks:qdmod/object:skb:qdmod/nodelete
;	%end
;
;	Unoptimised quad integer arithmetic support
;	Implemented to support quad time values
;	Its very slow, which doesn't usually matter
;	And it has a very big memory footprint
;	Which makes it unsuitable for many apps
;	The plan is to redo it all in optimized macro
;	rtnat.r has optimized RT-11 routines (but only for comparison)
;
;	Quads are represented as four 16-bit (unsigned) words,
;	stored in PDP-11 reverse word-order (as for longs)
;
;	quad:	.word	high-order	; sign bit is bit 15
;		.word	...
;		.word	...
;		.word	low-order	; quad bit 0 is bit 0

NBIT(x) := ((x)&0100000)

code	qd_clr - quad clear

  func	qd_clr
	dst : * WORD~
  is	cnt : int~ = 4
	while cnt
	   dst[--cnt] = 0
	end
  end

code	qd_tst - quad test

  func	qd_tst
	dst : * WORD~
  is	tmp : WORD~
	reply -1 if NBIT(dst[0])
	tmp = *dst++ | *dst++ | *dst++ | *dst++
	reply (tmp) ? 1 ?? 0
  end

code	qd_neg - quad negate

  func	qd_neg
	dst : * WORD~
  is	com : int~ = 0
	cnt : int = 4
	dst += 4
	while cnt--
	   --dst
	   *dst = -*dst if !com
	   *dst = ~(*dst) otherwise
	   com |= <int>*dst
	end
  end

code	qd_com - quad complement

  func	qd_com
	dst : * WORD~
  is	*dst++ = (~*dst)
	*dst++ = (~*dst)
	*dst++ = (~*dst)
	*dst++ = (~*dst)
  end

code	qd_rol - rotate left

  func	qd_rol
	dst : * WORD~
	cry : int
	()  : int			; carry
  is	tmp : int~ = 0
	car : int = 0
	cnt : int = 4
	res : int = NBIT(*dst) ? 1 ?? 0
	dst += 4
	while cnt--
	   tmp = *--dst
	   *dst = (*dst<<1) | car
	   car = NBIT(tmp) ? 1 ?? 0
	end
	dst[3] |= cry
	reply res
  end

code	qd_ror - rotate right

  func	qd_ror
	dst : * WORD~
  is	tmp : int~ = 0
	car : int = 0
	cnt : int = 4
	while cnt--
	   tmp = *dst
	   *dst = (tmp>>1) & 0077777
	   *dst |= 0100000 if car & 1
	   car = tmp
	   ++dst
	end
  end

code	qd_mov - move quad

  func	qd_mov
	src : * WORD~
	dst : * WORD~
  is	*dst++ = *src++
	*dst++ = *src++
	*dst++ = *src++
	*dst++ = *src++
  end

code	qd_add - quad add

  func	qd_awc		; add word with carry in/out
	lft : * WORD~
	rgt : * WORD~
	res : * WORD
	car : * WORD
	()  : WORD
  is	tmp : long = <long>*lft + <long>*rgt
	*res = <WORD>tmp
	*car = (tmp>>16)&1L
  end

  func	qd_add
	lft : * WORD
	rgt : * WORD
	res : * WORD
  is	tmp : [4] WORD~
	car : [1] WORD~
; was:	qd_clr (car)
	car[0] = 0
	qd_mov (rgt, tmp)

	qd_awc (lft+3, tmp+3, tmp+3, car)
	qd_awc (car, tmp+2, tmp+2, car)
	qd_awc (car, tmp+1, tmp+1, car)
	qd_awc (car, tmp, tmp, car)

	qd_awc (lft+2, tmp+2, tmp+2, car)
	qd_awc (car, tmp+1, tmp+1, car)
	qd_awc (car, tmp, tmp, car)

	qd_awc (lft+1, tmp+1, tmp+1, car)
	qd_awc (car, tmp, tmp, car)

	qd_awc (lft, tmp, tmp, car)
	qd_mov (tmp, res)
  end

code	qd_sub - quad sub

  func	qd_swc
	lft : * WORD~
	rgt : * WORD~
	res : * WORD
	car : * WORD
	()  : WORD
  is	tmp : long = <long>*rgt - <long>*lft
	*res = <WORD>tmp
	*car = (tmp>>16L)&1L
  end

  func	qd_sub
	lft : * WORD
	rgt : * WORD
	res : * WORD		; rgt - lft
  is	tmp : [4] WORD~
	car : [1] WORD~
	qd_clr (car)
	qd_mov (rgt, tmp)

	qd_swc (lft+3, tmp+3, tmp+3, car)
	qd_swc (car, tmp+2, tmp+2, car)
	qd_swc (car, tmp+1, tmp+1, car)
	qd_swc (car, tmp, tmp, car)

	qd_swc (lft+2, tmp+2, tmp+2, car)
	qd_swc (car, tmp+1, tmp+1, car)
	qd_swc (car, tmp, tmp, car)

	qd_swc (lft+1, tmp+1, tmp+1, car)
	qd_swc (car, tmp, tmp, car)

	qd_swc (lft, tmp, tmp, car)
	qd_mov (tmp, res)
  end

code	qd_cmp - quad compare

  func	qd_cmp
	lft : * WORD
	rgt : * WORD
	()  : int		; sgn (lft - rgt)
  is	dif : [4] WORD~
	res : int~
	qd_sub (rgt, lft, dif)
	reply qd_tst (dif)
  end

code	qd_mul - quad multiply

  func	qd_mul
	lft : * WORD~
	rgt : * WORD~
  	res : * WORD
  is	lop : [4] WORD
	rop : [4] WORD
	cnt : int = 64
	qd_mov (lft, lop)
	qd_mov (rgt, rop)
	qd_clr (res)

	while cnt--
	   if lop[3] & 1
	   .. qd_add (rop, res, res)
	   qd_ror (lop)
	   qd_rol (rop, 0)
	end
  end

code	qd_div - quad divide

  func	qd_div
	lft : * WORD~
	rgt : * WORD~
	quo : * WORD			; lft / rgt
	mod : * WORD			; lft % rgt (optional)
	()  : int			; 0 => divide by zero
  is	num : [4] WORD
	den : [4] WORD
	rem : [4] WORD
	nsn : int = lft[0]		; (nsn^dsn) ge => negative quotient
	dsn : int = rgt[0]		; sign of remainder
	cnt : int
	car : int

	qd_mov (lft, num)
	qd_mov (rgt, den)

	qd_neg (num) if NBIT(nsn)
	qd_neg (den) if NBIT(dsn)

	if !qd_tst (den)		; divide by zero
	   qd_clr (quo)
	   qd_clr (mod) if mod
	.. fail

	qd_mov (num, quo)
	qd_clr (rem)

	cnt = 65, car = 0
	while cnt--
	   qd_rol (rem, car)
	   if qd_cmp (rem, den) ge
	      car = 1
	      qd_sub (den, rem, rem)
	   else
	   .. car = 0
	   car = qd_rol (quo, car)
	end
	qd_neg (quo) if NBIT(nsn^dsn)
	qd_neg (rem) if dsn lt
	qd_mov (rem, mod) if mod
	fine
  end
