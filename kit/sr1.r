.if ne 0
file	sr1 - test mmu sr1
include rid:rider
include rid:cldef
include rid:eldef
include rid:mxdef

;	Each test is performed with the condition codes initially
;	clear and again with the condition codes set. Results of
;	the second test are only displayed if the condition codes
;	are altered by the test.

;	%build
;	rider ets:sr1/object:etb:
;	macro ets:sr1.r/object:etb:sr1mac
;	link etb:sr(1,1mac),lib:crt/exe:etb:sr1/map:etb:sr1/cross/bot:2000
;	%end

  type	cuTpha			; phase descriptor
  is	Vr0  : elTwrd
	Vr1  : elTwrd
	Vsp  : elTwrd
	Vpc  : elTwrd
	Vps  : elTwrd
	Ammu : [4] elTwrd
  end

  type	cuTtst			; test
  is	Ptit : * char
	Vadj : elTwrd
	Pfun : elTwrd
	Ptst : elTwrd
	Ptrp : elTwrd
	Vvec : elTwrd
	Ibef : cuTpha
	Iaft : cuTpha
  end

	cu_ini : ()
	cu_dis : (*cuTtst, int) 
	cu_sho : (*cuTtst, *char, *cuTpha, int)
	cu_rep : (*cuTtst)
	cu_lin : (int)

	cuAlst : [] * cuTtst+
	cuVlin : int = 0

  func	start
  is	lst : ** cuTtst = cuAlst 
	tst : * cuTtst
	buf : [mxLIN] char
	im_ini ("SR1")			; for messages
	cu_ini ()			; initialize SR3
     while *lst ne
	tst = *lst++
	cu_lin ()			; prompt
	if cuVlin gt (24-6) 
	   cuVlin = 0
	.. cl_cmd ("More? ", buf)
	PUT(tst->Ptit)			; test title
	cu_lin ()
	cu_dis (tst, 0)			; test with cc's clear
	cu_rep (tst)			; report it
	cu_dis (tst, 1)			; test with cc's set
	if (tst->Ibef.Vps&0xf) ne (tst->Iaft.Vps&0xf)
	   cu_lin ()
	.. cu_rep (tst)			; cc's are different
     end
  end

  func	cu_rep
	tst : * cuTtst
  is	cu_sho (tst, &tst->Ibef, "Before: ", 0)
	cu_sho (tst, &tst->Iaft, "After:  ", 1)
   end

  func	cu_sho
	tst : * cuTtst
	pha : * cuTpha
	tit : * char
	flg : int
  is	PUT("%s", tit)
	PUT("R0=%o ", pha->Vr0)
;	PUT("R1=%o ", pha->Vr1)
	PUT("SP=%o ", pha->Vsp)
	PUT("PC=%o ", pha->Vpc)
	PUT("PS=%o ", pha->Vps)
	PUT((pha->Vps&010) ? "N" ?? "-")
	PUT((pha->Vps&04) ? "Z" ?? "-")
	PUT((pha->Vps&02) ? "V" ?? "-")
	PUT((pha->Vps&01) ? "C" ?? "-")
	if flg
	   cu_lin ()
	   PUT("Vec=")
	   case tst->Vvec
	   of 04    PUT("BUS ")
	   of 010   PUT("CPU ")
	   of 0250  PUT("MMU ")
	   of -1    PUT("NONE ")
	   of other PUT("%o ", tst->Vvec)
	   end case

	   PUT("SR0=%o ", pha->Ammu[0])
	   PUT("SR1=[%o|", (pha->Ammu[1]>>8)&0377)
	   PUT("%o] ", pha->Ammu[1]&0377)
	   PUT("SR2=%o ", pha->Ammu[2])
	end
	cu_lin ()
  end

  func	cu_lin 
  is	PUT("\n")
	++cuVlin
  end

end file
.endc
.title	sr1 - test MMU sr1
.include "lib:crt.mac"
$jbdef
$jsdef
$kwdef
$mmdef
$psdef
$vedef
smini$

cuAlst::.word	c$ut00
	.word	c$ut01
	.word	c$ut02
	.word	c$ut03
	.word	c$ut04
	.word	c$ut05
	.word	c$ut06
	.word	c$ut07
	.word	c$ut08
	.word	c$ut09
	.word	c$ut10
	.word	c$ut11
	.word	c$ut12
	.word	c$ut13
	.word	c$ut14
	.word	c$ut15
	.word	c$ut16
	.word	c$ut17
	.word	c$ut18
	.word	c$ut19
	.word	c$ut20
	.word	c$ut21
	.word	c$ut22
	.word	c$ut23
	.word	0

;	Test phase: before/after	
;	Same as cuTdsc

map	ph.r0,,0
map	ph.r1
map	ph.sp
map	ph.pc
map	ph.ps
map	ph.mmu,4*2
map	ph.bbs

;	Test structure
;	Same as cuTtst

map	ts.tit,,0
map	ts.adj
map	ts.fun
map	ts.tst
map	ts.trp
map	ts.vec
map	ts.bef,ph.bbs
map	ts.aft,ph.bbs
map	ts.bbs

c$ucnd:	.word	0		; condition codes for test
c$ustk:	.word	0		; restore stack

  proc	cu.ini			; init macro environment
	call	xm$sr3		; uses trap mechanism
  end
.sbttl	cu.dis - dispatch test

;	Test routines act as co-routines to cu.dis
;	JMP rather than CALL/RETURN transfers control

  proc	cu.dis	<r2,r3,r4,r5>
	p1	tst,r5			; r5 -> test
	p2	cnd			; condition codes
	mov	sp,c$ustk		; save stack for crashes
	mov	r5,r4			; r4 -> before (after later)
	add	#ts.bef,r4		;
	clr	c$ucnd			; assume condition codes off
	beqw	cnd(sp),10$		; off?
	mov	#^o17,c$ucnd		; on
					;
10$:	call	xm$map			; map memory management
					;
	clr	m$kid4			; zap kernel par 4
	clr	m$uid4			; zap user par 4
	mov	#m$mpa4,r0		; r0 -> par 4
	add	ts.adj(r5),r0		; adjust both
	mov	r0,r1			; r1 = r0
	mov	r0,ph.r0(r4)		; save r0/r1
	mov	r1,ph.r1(r4)		;
	mov	sp,ph.sp(r4)		; stack
	mov	ts.tst(r5),ph.pc(r4)	; test start (may be modified)
	mov	psw,ph.ps(r4)		; save psw
	bic	#^o17,ph.ps(r4)		; fixup condition codes 
	bis	c$ucnd,ph.ps(r4)	;
	call	cu$mmu			; save sr0..sr3
	call	tr$cat			; catch traps
;	spl	7			; no interrupts, we're british
	clr	t$rvec			; zap vector
	mov	#-1,t$rsem		; let traps through
	jmp	@ts.fun(r5)		; continue in function

cu$blk:					; here if nothing happened
cu$dst:	clr	t$rsem			; here if transfer succeeded
	mov	#-1,t$rvec		; remember it
	clr	-(sp)			; setup dummy interrupt
	clr	-(sp)			;

	stack	pc,ps			; interrupt stack
cu$trp:					; here for expected trap
	clr	t$rsem			; no more traps permitted
	call	tr$res			; restore trap stuff
	mov	r5,r4			; r4 -> AFTER phaze
	add	#ts.aft,r4		; 
	mov	t$rvec,ts.vec(r5)	; save interupt vector (bus,mmu)
	mov	r0,ph.r0(r4)		; save r0/r1
	mov	r1,ph.r1(r4)		;
	mov	sp.pc(sp),ph.pc(r4)	; save pc/ps
	mov	sp.ps(sp),ph.ps(r4)	;
	add	#4,sp			; drop interrupt frame
	mov	sp,ph.sp(r4)		; save sp
	mov	c$ustk,sp		; recover original stack
	call	cu$mmu			; copy mmu registers
	jmp	@ts.trp(r5)		; do the trap routine
cu$exi:	call	xm$res			; restore mmu
	end

;	copy mmu registers

cu$mmu:	mov	m$msr0,ph.mmu+0(r4)	; save sr0/sr1/sr2
	mov	m$msr1,ph.mmu+2(r4)	;
	mov	m$msr2,ph.mmu+4(r4)	;
	clr	ph.mmu+6(r4)		; assume no sr3
	call	xm$sr3			; check for sr3
	bcs	10$			; have none
	mov	m$msr3,ph.mmu+6(r4)	; save sr3
10$:	return
.sbttl	trap catcher

;	Modified local copy of the diagnostic trap catcher.
;	Note that the library xm$sr3 routine calls the library version.

t$rsem:	.word	0			; trap semaphore
t$rvec:	.word	0			; trap vector
t$rbus:	.word	0			; saved bus vector
t$rcpu:	.word	0
t$rmmu:	.word	0

tr$cat:	bnew	t$rbus,10$		; once only
	mov	@#v$ebus,t$rbus		; save them
	mov	@#v$ecpu,t$rcpu		;
	mov	@#v$emmu,t$rmmu		;
10$:	mov	#tr$bus,@#v$ebus	; catch bus traps
	mov	#tr$cpu,@#v$ecpu	; catch cpu traps
	mov	#tr$mmu,@#v$emmu	; catch cpu traps
	return

tr$res:	clr	t$rsem			; turn off semaphore
	mov	t$rbus,@#v$ebus		; restore bus trap
	mov	t$rcpu,@#v$ecpu		; restore cpu trap
	mov	t$rmmu,@#v$emmu		; restore mmu trap
	return

tr$bus:	mov	#v$ebus,t$rvec		; bus trap
	br	tr$trp			; join common
tr$cpu:	mov	#v$ecpu,t$rvec		; ditto
	br	tr$trp			;
tr$mmu:	mov	#v$emmu,t$rvec		; ditto
	fall	tr$trp			;

	stack	pc,psw
tr$trp:	inc	t$rsem			; accepting traps?
	beq	10$			; yes
	HALT				; nope stray/double trap
	clr	psw			; clean up
	mov	#-2,t$rvec		; stray/double trap
10$:	jmp	cu$trp
.sbttl	test macros

;	These macros are used to construct the tests.
;
;	tshdr$ constructs the test driver table.

	.macro	tshdr$	tst, adj=0
c$ut'tst::
	.word	10$		; title
	.word	adj		; r0 adjustment
	.word	fu$t'tst	; function
	.word	ts$t'tst	; test
	.word	tr$t'tst	; trap
	.blkb	ph.bbs		; before
	.blkb	ph.bbs		; after
	.endm

	.macro	tsblk$		; blank - no trap
	jmp	cu$blk
	.endm

	.macro	tsdst$		; blank - reached destination
	jmp	cu$dst
	.endm

	.macro	tsexi$		; exit trap
	jmp	cu$exi
	.endm

	.macro	tscnd$		; set condition codes
	mtps	c$ucnd
	.endm
.sbttl	c$ut00

;	The source field traps.
;	R0 should advanced by 2, as shown by [0|20].
;	The condition codes are not updated.
;
; J11	Test00: mov *(r0)+,(r0)+
; SimH	Before: R0=100000 SP=1542 PC=4204 PS=30000 ----
;	After:  R0=100002 SP=1542 PC=4206 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|20] SR2=4204

	tshdr$	00
10$:	.asciz /Test00: mov *(r0)+,(r0)+/
	.even

fu$t00:				; function
	tscnd$			; condition codes
ts$t00:	tst	(r0)+		; test
	tsblk$			; blank (no trap fired)
tr$t00:	tsexi$			; trap
.sbttl	c$ut01

;	In TEST01 the trap occurs on the destination field.
;	R0 should be incremented by 4, as shown by [20|20].
;	The condition codes are updated before the fault.
;
; J11	Test01: mov (r0)+,*(r0)+
; SimH	Before: R0=77776 SP=1542 PC=4332 PS=30000  ----
;	After:  R0=100002 SP=1542 PC=4334 PS=30004 -Z--
;	Vec=MMU SR0=100011 SR1=[20|20] SR2=4332
;
;	Before: R0=77776 SP=1542 PC=4332 PS=30017  NZVC
;	After:  R0=100002 SP=1542 PC=4334 PS=30005 -Z-C
;	Vec=MMU SR0=100011 SR1=[20|20] SR2=4332

	tshdr$	01, -2
10$:	.asciz /Test01: mov (r0)+,*(r0)+/
	.even

fu$t01:	clr	(r0)		; clear the value to be moved
	tscnd$			; condition codes
ts$t01:	mov	(r0)+,(r0)+	; test
	tsblk$			; blank
tr$t01:	tsexi$			; trap
.sbttl	c$ut02

;	In TEST02 the trap occurs on the source field (r0)+.
;	R0 is expected to advance by 4, as shown by [20|20]
;	Nothing is pushed on the stack.
;
; J11	TEST02: mfpi *(r0)+
; SimH	Before: R0=100000 SP=1542 PC=4452 PS=30000 ----
;	After:  R0=100002 SP=1542 PC=4454 PS=30000 ----
;	Vec=MMU SR0=100151 SR1=[0|20] SR2=4452

	tshdr$	02
10$:	.asciz /Test02: mfpi *(r0)+/
	.even

fu$t02:	tscnd$			; condition codes
ts$t02:	mfpi	(r0)+
	tsblk$			; blank
tr$t02:	tsexi$			; trap
.sbttl	c$ut03 ???

;	NOTE: The fault trap will overwrite a kernel stack operand.
;
;	R0 increments and the stack operand is popped 
;
;	The usual order of operands in SR1 is reversed.
;	The destination is usually in the low byte.
;	We see [20|26] rather than [26|20].
;
; J11	Test03: mtpi *(r0)+
; SimH	Before: R0=100000 SP=1540 PC=4602 PS=30000 ----
;	After:  R0=100002 SP=1542 PC=4604 PS=30004 -Z--
;	Vec=MMU SR0=100151 SR1=[20|26] SR2=4602
;	
;	Before: R0=100000 SP=1540 PC=4602 PS=30017 NZVC
;	After:  R0=100002 SP=1542 PC=4604 PS=30005 -Z-C
;	Vec=MMU SR0=100151 SR1=[20|26] SR2=4602
;
; E11	Pops the stack. No recovery information.

	tshdr$	03
10$:	.asciz /Test03: mtpi *(r0)+/
	.even

fu$t03:	clr	-(sp)		; mtpi operand
	sub	#2,ph.sp(r4)	; adjust reported stack
	tscnd$			; condition codes
ts$t03:;mov	(sp)+,(r0)+
	mtpi	(r0)+
	tsblk$			; blank
tr$t03:	tsexi$			; trap
.sbttl	c$ut04

;	JMP instruction succeeds
;	MMU trap occurs at next instruction fetch
;
; J11	Test04: jmp @#100000*   ; 100000 is BADADR
; SimH	Before: R0=100000 SP=1542 PC=4754 PS=30000 ----
;	After:  R0=100000 SP=1542 PC=100000 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|0] SR2=100000

	tshdr$	04
10$:	.asciz /Test04: jmp @#100000*	; 100000 is BADADR/
	.even

fu$t04:.enabl	lsb		; function
	mov	r0,20$		; setup invalid address
	tscnd$			; condition codes
ts$t04:	jmp	@(pc)+		; 
20$:	.word	0		; plugged with address
	tsblk$			; blank
tr$t04:	tsexi$			; trap
	.dsabl	lsb
.sbttl	c$ut05 ???PC

;	NOTE: SimH/J11 difference. Benign.
;
;	The second word of the jump instruction is missing.
;	J11 does not record the PC increment ([0|0])
;	SimH does record the increment ([0|27])
;
; J11	Test05: jmp @#*xxxxxx   ; xxxxxx is in gap.
; 	Before: R0=77776 SP=1542 PC=77776 PS=30000 ----
;	After:  R0=77776 SP=1542 PC=100002 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|0] SR2=77776
;
; SimH	Test05: jmp @#*xxxxxx   ; xxxxxx is in gap.
; 	Before: R0=77776 SP=1542 PC=77776 PS=30000 ----
;	After:  R0=77776 SP=1542 PC=100002 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|27] SR2=77776

	tshdr$	05, -2
10$:	.asciz /Test05: jmp @#*xxxxxx	; xxxxxx is in gap./
	.even

fu$t05:	mov	r0,ph.pc(r4)	; fixup test BEFORE pc
	mov	#^o137,(r0)	; "jmp @#" instruction
	tscnd$			; cc's
ts$t05:	jmp	(r0)		; ts$t05 is a dummy
	tsblk$
tr$t05:	tsexi$
.sbttl	c$ut06 ???PC

;	NOTE: J11/SimH difference. Innocuous.
;	NOTE: Is difference generic?
;
;	The fault occurs on the destination. Both registers increment.
;	The J11 does not record the PC increment. SimH does.	
;
; 	Test06: mov (pc)+,*(r0)+
; 	Before: R0=100000 SP=1542 PC=5262 PS=30000 ----
;	After:  R0=100002 SP=1542 PC=5266 PS=30000 ----
; J11	Vec=MMU SR0=100011 SR1=[0|20]  SR2=5262
; SimH	Vec=MMU SR0=100011 SR1=[20|27] SR2=5262
;	
;	Before: R0=100000 SP=1542 PC=5262 PS=30017 NZVC
;	After:  R0=100002 SP=1542 PC=5266 PS=30001 ---C
; J11	Vec=MMU SR0=100011 SR1=[0|20]  SR2=5262
; SimH	Vec=MMU SR0=100011 SR1=[20|27] SR2=5262
;	
	tshdr$	06
10$:	.asciz /Test06: mov (pc)+,*(r0)+/
	.even

fu$t06:	tscnd$
ts$t06:	mov	(pc)+,(r0)+
	.word	nop
	tsblk$
tr$t06:	tsexi$
.sbttl	c$ut07 ???FPP

;	NOTE: I haven't checked the FP condition codes.
;	NOTE: J11/SimH different. Benign.
;
;	The J11 FPU does not inc/dec registers or update SR1.
;	SimH's FPU inc/dec's registers and updates SR1.

; J11 	Test07: ldf *(r0)+,ac0 ; 32-bit
; 	Before: R0=100000 SP=1542 PC=5422 PS=30000 ----
;	After:  R0=100000 SP=1542 PC=5424 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|0] SR2=5422
;
; SimH	Test07: ldf *(r0)+,ac0 ; 32-bit
; 	Before: R0=100000 SP=1542 PC=5422 PS=30000 ----
;	After:  R0=100004 SP=1542 PC=5424 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|40] SR2=5422

	tshdr$	07
10$:	.asciz /Test07: ldf *(r0)+,ac0 ; 32-bit/
	.even

fu$t07:	setf
	tscnd$
ts$t07:	ldf	(r0)+,%0
	tsblk$
tr$t07:	tsexi$
.sbttl	c$ut08 ???FPP

;	See TEST07
;
; J11	Test08: ldf *(r0)+,ac0 ; 32-bit
; 	Before: R0=77776 SP=1542 PC=5560 PS=30000 ----
;	After:  R0=77776 SP=1542 PC=5562 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|0] SR2=5560
;
; SimH	Test08: ldf *(r0)+,ac0 ; 32-bit
; 	Before: R0=77776 SP=1542 PC=5560 PS=30000 ----
;	After:  R0=100002 SP=1542 PC=5562 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|40] SR2=5560

	tshdr$	08, -2
10$:	.asciz /Test08: ldf *(r0)+,ac0 ; 32-bit/
	.even

fu$t08:	setf
	tscnd$
ts$t08:	ldf	(r0)+,%0
	tsblk$
tr$t08:	tsexi$
.sbttl	c$ut09 ???FPP

;	See TEST07
;
; J11	Test09: ldf *(r0)+,ac0 ; 64-bit
; 	Before: R0=100000 SP=1542 PC=5716 PS=30000 ----
;	After:  R0=100000 SP=1542 PC=5720 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|0] SR2=5716
;
; SimH	Test09: ldf *(r0)+,ac0 ; 64-bit
; 	Before: R0=100000 SP=1542 PC=5716 PS=30000 ----
;	After:  R0=100010 SP=1542 PC=5720 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|100] SR2=5716

	tshdr$	09
10$:	.asciz /Test09: ldf *(r0)+,ac0 ; 64-bit/
	.even

fu$t09:	setd
	tscnd$
ts$t09:	ldf	(r0)+,%0
	tsblk$
tr$t09:	tsexi$
.sbttl	c$ut10 ???FPP

;	See TEST07
;
; J11	Test10: ldd *(r0)+,ac0 ; 64-bit
; 	Before: R0=77774 SP=1542 PC=6054 PS=30000 ----
;	After:  R0=77774 SP=1542 PC=6056 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|0] SR2=6054
;
; SimH	Test10: ldd *(r0)+,ac0 ; 64-bit
; 	Before: R0=77774 SP=1542 PC=6054 PS=30000 ----
;	After:  R0=100004 SP=1542 PC=6056 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|100] SR2=6054

	tshdr$	10,-4
10$:	.asciz /Test10: ldd *(r0)+,ac0 ; 64-bit/
	.even

fu$t10:	setd
	tscnd$
ts$t10:	ldf	(r0)+,%0
	tsblk$
tr$t10:	tsexi$
.sbttl	c$ut11 ???FPP

;	See TEST07
;
; J11	Test11: std ac0,(r0)+ ; 64-bit
; 	Before: R0=77774 SP=1542 PC=6216 PS=30000 ----
;	After:  R0=77774 SP=1542 PC=6220 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|0] SR2=6216
;
; SimH	Test11: std ac0,(r0)+ ; 64-bit
; 	Before: R0=77774 SP=1542 PC=6216 PS=30000 ----
;	After:  R0=100004 SP=1542 PC=6220 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|100] SR2=6216

	tshdr$	11, -4
10$:	.asciz /Test11: std ac0,(r0)+ ; 64-bit/
	.even

	.enabl	lsb
fu$t11:	setd
	ldd	10$,%0	; get some fp value
	tscnd$
ts$t11:	std	%0,(r0)+
	tsblk$
tr$t11:	tsexi$

10$:	.word	0,-1,-1,-1
	.dsabl	lsb
.sbttl	c$ut12

;	Bus test (trap to 4)
;	SR0..SR2 information is irrelevant.
;
; J11	Test12: ldd *(r0)+,ac0 ; bus error
; SimH	Before: R0=100000 SP=1542 PC=160000 PS=30000 ----
;	After:  R0=160010 SP=1542 PC=6402 PS=30000 ----
;	Vec=BUS SR0=11 SR1=[0|0] SR2=3660

	tshdr$	12
10$:	.asciz /Test12: ldd *(r0)+,ac0 ; bus error/
	.even

fu$t12:	mov	#^o160000,r0
	mov	r0,ph.pc(r4)
	setd
	tscnd$
ts$t12:	ldd	(r0)+,%0
	tsblk$
tr$t12:	tsexi$
.sbttl	c$ut13

;	EIS test. Source field faults.
;
; J11	Test13: mul *(r0)+,r2
; SimH	Before: R0=100000 SP=1542 PC=6522 PS=30000 ----
;	After:  R0=100002 SP=1542 PC=6524 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|20] SR2=6522

	tshdr$	13
10$:	.asciz /Test13: mul *(r0)+,r2/
	.even

fu$t13:	tscnd$
ts$t13:	mul	(r0)+,r2
	tsblk$
tr$t13:	tsexi$
.sbttl	c$ut14

;	Another bus test.
;
; J11	Test14: tst *(r0)+ ; bus error
; SimH	Before: R0=160000 SP=1542 PC=6670 PS=30000 ----
;	After:  R0=160002 SP=1542 PC=6672 PS=30000 ----
;	Vec=BUS SR0=11 SR1=[0|0] SR2=3660

	tshdr$	14
10$:	.asciz /Test14: tst *(r0)+ ; bus error/
	.even

fu$t14:	mov	#^o160000,r0
	mov	r0,ph.r0(r4)
	setd
	tscnd$
ts$t14:	tst	(r0)+
	tsblk$
tr$t14:	tsexi$
.sbttl	c$ut15

;	RTI to an unmapped address.
;	RTI instruction succeeds. 
;	Following instruction fails.
;
; J11	Test15: *rti
; SimH	Before: R0=100004 SP=1542 PC=7006 PS=0 ----
;	After:  R0=100004 SP=1542 PC=100004 PS=0 ----
;	Vec=MMU SR0=100011 SR1=[0|0] SR2=100004
;	
;	Before: R0=100004 SP=1542 PC=7006 PS=17 NZVC
;	After:  R0=100004 SP=1542 PC=100004 PS=0 ----
;	Vec=MMU SR0=100011 SR1=[0|0] SR2=100004

	tshdr$	15, 4
10$:	.asciz /Test15: *rti/
	.even

fu$t15:	clr	@#psw		; cleanup psw for rti
	bic	#^o170000,ph.ps(r4); ditto
	clr	-(sp)		; ps
	psh	r0		; pc
	tscnd$
ts$t15:	rti
	tsblk$
tr$t15:	tsexi$
.sbttl	c$ut16	???

;	NOTE: J11/SimH different. 
;
;	This is an RTI with the user mode stack crossing the gap,
;	i.e. the RTI PC is mapped but the RTI PSW is not.
;
;	J11 incs SP twice and records them [26|26]
;	In kernel mode the MMU trap will overwrite the popped RTI PC/PSW.
;
;	SimH does not pop PC/PSW and does not record incs: [0,0]
;	In kernel mode an MMU trap will not overwrite the RTI PC/PSW.
;
; J11	Test16: *rti  ; [pc,*ps] r0 = user mode stack (unmapped)
; 	Before: R0=77776 SP=77776 PC=7236 PS=170340 ----
;	After:  R0=77776 SP=100002 PC=7240 PS=170340 ----
;	Vec=MMU SR0=100151 SR1=[26|26] SR2=7236
;
; SimH	Test16: *rti  ; [pc,*ps] r0 = user mode stack (unmapped)
; 	Before: R0=77776 SP=77776 PC=7236 PS=170340 ----
;	After:  R0=77776 SP=77776 PC=7240 PS=170340 ----
;	Vec=MMU SR0=100151 SR1=[0|0] SR2=7236

	tshdr$	16, -2
10$:	.asciz /Test16: *rti  ; [pc,*ps] r0 = user mode stack (unmapped)/
	.even

; r0->	 77776	.word	10$
;	100000	xxxxxx	; unmapped

	.enabl	lsb
fu$t16:	mov	#mmpum$!^o340,@#psw	; previous user mode
	psh	r0			; user mode sp = 77776
	mtpi	sp			;	
	mov	#mmcum$!mmpum$!^o340,@#psw ; current user mode
	mov	#10$,(r0)		; dummy RTI destination
	tscnd$				; set condition codes
	mov	@#psw,ph.ps(r4)		; get the composite
	mov	r0,ph.sp(r4)		; save them
	tscnd$				; set them again
ts$t16:	rti
	tsblk$
10$:	tsdst$
	.dsabl	lsb

tr$t16:	mov	#mmpum$!^o340,psw	; previous user mode
	mfpi	sp			; get user mode sp
	pop	ph.sp(r4)		; save it
	clr	@#psw			; clear user mode
	tsexi$
.sbttl	c$ut17

;	NOTE: J11/SimH different.
;
;	As in TEST16, J11 incs SP and updates SR1 [0|26].
;	Popped return address will be overwritten in kernel mode.
;
;	SimH does not pop stack or record [0|0]
;	Return address is not overwritten.
;
; J11	Test17: *return  ; [*pc] r0 = user mode stack (unmapped)
; 	Before: R0=100000 SP=100000 PC=7512 PS=170340 ----
;	After:  R0=100000 SP=100002 PC=7514 PS=170340 ----
;	Vec=MMU SR0=100151 SR1=[0|26] SR2=7512
;	
; SimH	Test17: *return  ; [*pc] r0 = user mode stack (unmapped)
; 	Before: R0=100000 SP=100000 PC=7512 PS=170340 ----
;	After:  R0=100000 SP=100000 PC=7514 PS=170340 ----
;	Vec=MMU SR0=100151 SR1=[0|0] SR2=7512

	tshdr$	17
10$:	.asciz /Test17: *return  ; [*pc] r0 = user mode stack (unmapped)/
	.even

; r0->	100000	xxxxxx	; unmapped

	.enabl	lsb
fu$t17:	mov	#mmpum$!^o340,@#psw	; previous user mode
	psh	r0			; user mode sp = 77776
	mtpi	sp			;	
	mov	#mmcum$!mmpum$!^o340,@#psw ; current user mode
	tscnd$				; set condition codes
	mov	@#psw,ph.ps(r4)		; get the composite
	mov	r0,ph.sp(r4)		; save them
	tscnd$				; set them again
ts$t17:	return
	tsblk$
10$:	tsdst$
	.dsabl	lsb

tr$t17:	mov	#mmpum$!^o340,psw	; previous user mode
	mfpi	sp			; get user mode sp
	pop	ph.sp(r4)		; save it
	clr	@#psw			; clear user mode
	tsexi$
.sbttl	c$ut18

;	ASHC presents no condition code problems.
;
; J11	Test18: ashc (r0),r2
; SimH	Before: R0=100000 SP=1542 PC=7660 PS=30000 ----
;	After:  R0=100002 SP=1542 PC=7662 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|20] SR2=7660

	tshdr$	18
10$:	.asciz /Test18: ashc (r0)+,r2/
	.even

fu$t18:	tscnd$
ts$t18:	ashc	(r0)+,r2
	tsblk$
tr$t18:	tsexi$
.sbttl	c$ut19

;	Condition code test. Fine.
;
; J11	Test19: ror (r0)+
; SimH	Before: R0=100000 SP=1542 PC=7776 PS=30000 ----
;	After:  R0=100002 SP=1542 PC=10000 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|20] SR2=7776

	tshdr$	19
10$:	.asciz /Test19: ror (r0)+/
	.even

fu$t19:	tscnd$
ts$t19:	ror	(r0)+
	tsblk$
tr$t19:	tsexi$
.sbttl	c$ut20

;	Condition code test. Fine.
;
; J11	Test20: adc (r0)+
; SimH	Before: R0=100000 SP=1542 PC=10114 PS=30000 ----
;	After:  R0=100002 SP=1542 PC=10116 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|20] SR2=10114

	tshdr$	20
10$:	.asciz /Test20: adc (r0)+/
	.even

fu$t20:	tscnd$
ts$t20:	adc	(r0)+
	tsblk$
tr$t20:	tsexi$
.sbttl	c$ut21 ???

;	NOTE: MFPx alters the condition codes. Recovery fails.
;
;	o  Use of MFPx is probably not expected to fail since
;	   would usually be preceded by an O/S address check.
;	o  In any case, MFPx usage probably doesn't rely on
;	   the propagation of the C-bit across the instruction.
;
;	Condition code test. Condition codes are altered.
;
; J11	Test21: mfps (r0)+
; SimH	Before: R0=100000 SP=1542 PC=10234 PS=30000 ----
;	After:  R0=100001 SP=1542 PC=10236 PS=30004 -Z--
;	Vec=MMU SR0=100011 SR1=[0|10] SR2=10234
;	
;	Before: R0=100000 SP=1542 PC=10234 PS=30017 NZVC
;	After:  R0=100001 SP=1542 PC=10236 PS=30001 ---C
;	Vec=MMU SR0=100011 SR1=[0|10] SR2=10234
	
	tshdr$	21
10$:	.asciz /Test21: mfps (r0)+/
	.even

fu$t21:	tscnd$
ts$t21:	mfps	(r0)+
	tsblk$
tr$t21:	tsexi$
.sbttl	c$ut22

;	Condition code test. Fine.
;
; J11	Test22: mtps (r0)+
; SimH	Before: R0=100000 SP=1542 PC=10354 PS=30000 ----
;	After:  R0=100001 SP=1542 PC=10356 PS=30000 ----
;	Vec=MMU SR0=100011 SR1=[0|10] SR2=10354

	tshdr$	22
10$:	.asciz /Test22: mtps (r0)+/
	.even

fu$t22:	tscnd$
ts$t22:	mtps	(r0)+
	tsblk$
tr$t22:	tsexi$

.sbttl	c$ut23

;	Condition code test. Benign.
;	Alters condition codes, but not N. Recovery will succeed.
;
; J11	Test23: sxt (r0)+
; SimH	Before: R0=100000 SP=1542 PC=10472 PS=30000 ----
;	After:  R0=100002 SP=1542 PC=10474 PS=30004 -Z--
;	Vec=MMU SR0=100011 SR1=[0|20] SR2=10472
;	
;	Before: R0=100000 SP=1542 PC=10472 PS=30017 NZVC
;	After:  R0=100002 SP=1542 PC=10474 PS=30011 N--C
;	Vec=MMU SR0=100011 SR1=[0|20] SR2=10472

	tshdr$	23
10$:	.asciz /Test23: sxt (r0)+/
	.even

fu$t23:	tscnd$
ts$t23:	sxt	(r0)+
	tsblk$
tr$t23:	tsexi$

.end
