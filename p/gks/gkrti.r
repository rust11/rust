;***;	GKRTI - Initial RTI etc function
.if ne 0
file	gkrti - test RTI
include	rid:rider

;	%build
;	rider gks:gkrti/object:gkb:
;	macro gks:gkrti.r/object:gkb:gkrtt
;	link gkb:gkrt(i,t),lib:crt/exe:gkb:gkrti/map:gkb:gkrti/cross/bot:2000
;	%end

  func	start
  is	tst : int
	res : int 
	tst = 0340
	res = gk_rtt (tst)
	PUT("Test: %o, Got: %o\n", tst, res)
  end

end file
.endc

.title	gkrtt
.include "lib:crt.mac"
$psdef
smini$
cccod$

  proc	gk.rtt	<r2,r3,r4,r5>
	p1	tst
	mov	tst(sp),r1
	psh	tst
	psh	#10$
	rti
10$:	mov	@#^o177776,r0
  end

.end
