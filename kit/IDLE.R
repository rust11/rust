.if ne 0
file	idle - blink those lights
include	rid:rider
include	rid:medef
include	rid:tidef

;  RT-11 RMON.MAC idle pattern commentary:
;
; "A source of innocent merriment!"
;	- W.S. Gilbert, "Mikado"
; "Did nothing in particular, and did it very well"
;	- W.S. Gilbert, "Iolanthe"
; "To be idle is the ultimate purpose of the busy"
;	- Samuel Johnson, "The Idler"
; "I got plenty of nothin', and nothin's plenty fo' me!"
;	- George and Ira Gershwin, "Porgy and Bess"
;
;
;	%build
;	rider sks:idle/object:skb:
;	macro sks:idle.r/object:skb:idlem
;	link skb:(idle,idlem)/exe:skb:idle,lib:crt
;	set program/iopage skb:idle
;	%end

  init	cuAwai : [] int
  is	;90, 80, 70, 60, 50, 40, 40 
	;30, 30, 40, 50, 60, 70, 80
	50, 40, 30, 20, 30, 40, 50
	0
  end
	cuWAI := 10
	cuVidx : int = 0
	cuVwai : int = cuWAI

	cu_bin : (int)
	cu_lft : (int, int) int
	cu_rgt : (int, int) int
	cu_tim : (int) int
	cu_mrk : (int, int)

	SWR 	:= 0177570	; switch register address

  func	start
  is	swr : * word = SWR	; swr -> switch register 
	tim : int
	lft : int = 1		; left pattern
	rgt : int = 0140000	; right pattern
	pat : int = 0		; composite pattern
	cnt : int = 0		; life signal
				;
	repeat			;
	   pat = lft|rgt	; form composite display
	   cu_typ (pat)		; terminal display
	   tim = cu_tim (pat)	; work out the time period
	   PUT(" %d", tim)	;
	   cu_dis (pat, tim)	; display and wait
	   PUT(" %d", that)	; instructions counted
				;
	   lft = cu_lft (lft, 1);
	   rgt = cu_rgt (rgt, 1);
	forever			;
  end

  func	cu_typ
	pat : int
  is	cnt : int = 16
  	PUT("\r")
	while cnt--
	   PUT("@") if pat & BIT(15)
	   PUT("_") otherwise
	   pat <<= 1
	end
  end

  func	cu_lft
	pat : int
  	cnt : int
  is	tmp : int
  	while cnt--
	   tmp = pat
	   pat <<= 1
	   pat |= 1 if tmp & 0100000
	end
	reply pat
  end

  func	cu_rgt
	pat : int
  	cnt : int
  is	tmp : int
  	while cnt--
	   tmp = pat
	   pat >>= 1
	   pat &= 077777
	   pat |= 0100000 if tmp & 1
	end
	reply pat
  end

  func	cu_tim
	pat : int
	()  : int
  is	if (pat & 0100001) && !cuVwai--
	   cuVwai = cuWAI
	   cuVidx = 0 if !cuAwai[++cuVidx]
	end
	reply cuAwai[cuVidx] / 10
  end

end file
.endc
.title	idlem 
.include "lib:crt.mac"
$rpdef
smini$

;	CU_DIS - Display pattern, wait and count

	swr =	^o177570

  proc	cu.dis
	p1	pat,r0
	p2	cnt,r1
	mov	r1,c$utim+2	; low order ticks
	ror	c$uonc		; once-only?
	bcc	10$		; done
	call	rt.rst		; rust
	beqw	r0,10$		; nope
	call	rt.xmm		; rust/xm?
	beqw	r0,10$		; nope
	inc	c$urxm		; is rust/xm
	$stpri	#c$uemt,#0,#0,#^o401,#c$upre ; set process/priority=1
10$:	clr	c$udon		; clear the done flag
	.poke	#c$uemt,#swr,pat(sp)		; write the SWR
	.mrkt	#c$uemt,#c$utim,#cu$ast,#1	; mark time
	clr	r1		; clear instruction counter
20$:	mov	pat(sp),r0	; display pattern in r0 for swr
	wait			; wait for interrupt
	br	40$		;
30$:	mov	pat(sp),r2	; pass pattern to kernel routine
	$cmkrnl	#c$uemt,#cu$ker,pic=yes ; invoke kernel mode routine
40$:	inc	r1		; count instructions
	beqw	c$udon,20$	; wait for ast completion signal
	mov	r1,r0		; return instruction count
  end

;	CU$AST - marktime completion ast

cu$ast:	inc	c$udon		; mrkt ast - signal done
	return

;	CU$KER - kernel wait routine
;
;	The WAIT instruction is ignored in user-mode

cu$ker:	mov	rp.r2(r5),r0	; display pattern in r0
10$:	wait			; wait for interrupt
	inc	rp.r1(r5)	; count instruction
	tst	c$udon		; wait for done
	beq	10$		; more to go
	return

ccdat$
c$uemt:	.blkw	6
c$utim:	.word	0,0
c$udon:	.word	0
c$uonc:	.word	1
c$urxm:	.word	0
c$upre:	.word	0
cccod$

.end
.sbttl	RT-11 idle routine

.IF NE LIGH$T
	DEC	(PC)+		;The RT-11 lights routine!
LITECT:	 .WORD	1
	BNE	..NULJ		;Not too often
	ADD	#<512.>,LITECT	;Reset count, clear carry
40$:	ROL	70$		;Juggle the lights
	BNE	50$		;Not clear yet
	COM	70$		;Turn on lights, set Carry
50$:	BCC	60$		;Nothing fell off, keep moving
	ADD	#<100>,40$	;Reverse direction
	BIC	#<200>,40$	;ROL/ROR flip
60$:	BIT	#<LIGHT$>,CONFG2 ;Does CPU have a light register?
	BEQ	..NULJ		;No
	MOV	(PC)+,@(PC)+	;Put in lights (for 11/45)
70$:	 .WORD	0, SR
.ENDC ;NE LIGH$T
; EXECUTIVE IDLE LOOP
;
; THE EXECUTIVE IDLE LOOP IS ENTERED WHEN THERE ARE NO RUNNABLE TASKS.
; THE NULL TCB AT THE END OF THE TASK LIST IS ALWAYS GUARANTEED TO BE
; BLOCKED.  TWO FLAGS ARE SET FOR OTHER EXECUTIVE ROUTINES IN THE IDLE
; LOOP.
;
;    1.	THE ADDRESS OF THE NULL TCB (#$HEADR) IS SET INTO THE RESCHEDULE
;	POINTER ($RQSCH) TO PREVENT $DIRXT FROM EVER RETURNING TO SYSTEM
;	STATE WHILE THE EXEC IS IDLE.  THIS FORCES EXECUTION BACK TO THE
;	IDLE LOOP IN LIEU OF A REAL SCHEDULE REQUEST.
;
;   2.	AN IDLE FLAG IS SET ($IDLFL) FOR THE FORK ROUTINES TO CAUSE THEM
;	TO FORCE CONTROL BACK TO $DIRXT WHEN NECESSARY TO DEQUEUE A
;	FORK.  (IT IS IMPOSSIBLE FOR THE IDLE LOOP TO ALWAYS RETURN TO
;	$DIRXT WHEN NECESSARY BECAUSE OF A WINDOW BETWEEN THE CHECK OF
;	THE FORK LIST AND THE WAIT INSTRUCTION.)
;
 
	MOV	#$HEADR,$RQSCH	;PREVENT $DIRXT RETURN TO USER STATE
	MOV	#$IDLPT,R1	;POINT TO IDLE PATTERN WORD
	CLRB	$CURPR		;CLEAR CURRENT TASK PRIORITY
40$:				;REF LABEL
 
 
	.IF DF	P$$P45
 
	DECB	$IDLCT		;TIME TO MOVE PATTERN?
	BGE	45$		;IF GE NO
	MOVB	#4,$IDLCT	;RESET COUNT
	ASLB	(R1)+		;MOVE PATTERN ($IDLPT)
	RORB	(R1)		;($IDLPT+1)
	ADCB	-(R1)		;($IDLPT)
45$:	MOV	(R1),R0		;PUT IT WHERE IT CAN BE SEEN ($IDLPT)
 
	.ENDC
 
 
	INCB	-(R1)		;INDICATE IN IDLE STATE ($IDLFL)
	TST	$FRKHD		;FORK QUEUED SINCE LAST TIME IN $DIRXT?
	BNE	46$		;IF NE YES
	WAIT			;WAIT FOR INTERRUPT
	CLRB	(R1)+		;RESET IDLE FLAG ($IDLFL)
	BR	40$		;
46$:	CLRB	(R1)		;RESET IDLE FLAG ($IDLFL)
 
file	idle - blink those lights
include	rid:rider
include	rid:medef
include	rid:tidef

;  RT-11 RMON.MAC idle pattern commentary:
;
; "A source of innocent merriment!"
;	- W.S. Gilbert, "Mikado"
; "Did nothing in particular, and did it very well"
;	- W.S. Gilbert, "Iolanthe"
; "To be idle is the ultimate purpose of the busy"
;	- Samuel Johnson, "The Idler"
; "I got plenty of nothin', and nothin's plenty fo' me!"
;	- George and Ira Gershwin, "Porgy and Bess"
;
;
;	%build
;	rider sks:idle/object:skb:
;	link skb:idle,/exe:skb:,lib:crt
;	set program/iopage skb:idle
;	%end

  init	cuAwai : [] int
  is	90, 80, 70, 60, 50, 40, 40 
	30, 30, 40, 50, 60, 70, 80
	0
  end
	cuWAI := 10
	cuVidx : int = 0
	cuVwai : int = cuWAI

	cu_bin : (int)
	cu_lft : (int, int) int
	cu_rgt : (int, int) int
	cu_wai : (int) long

	SWR 	:= 0177570	; switch register address

 func	start
  is	swr : * word = SWR	; swr -> switch register 
	hdw : int		; ne => switch register present
	tmp : int		;
				;
	lft : int = 1		; left pattern
	rgt : int = 0140000	; right pattern
	pat : int = 0		; composite pattern
	cnt : int = 0		; life signal
				;
	hdw = me_pee(SWR,&tmp,2); do we have a switch register?
				;
	repeat			;
	   pat = lft|rgt	; form composite display
;	   *swr = pat if hdw	; switch register display
	   cu_dis (pat)		; terminal display
	   PUT(" %d    ", cnt++); show that we're active
				;
	   lft = cu_lft (lft, 1);
	   rgt = cu_rgt (rgt, 1);
				;
	   ti_wai (cu_wai ())	; wait n milliseconds (n : long)
	forever			;
  end

  func	cu_dis
	pat : int
  is	cnt : int = 16
  	PUT("\r")
	while cnt--
	   PUT("@") if pat & BIT(15)
	   PUT("_") otherwise
	   pat <<= 1
	end
  end

  func	cu_lft
	pat : int
  	cnt : int
  is	tmp : int
  	while cnt--
	   tmp = pat
	   pat <<= 1
	   pat |= 1 if tmp & 0100000
	end
	reply pat
  end

  func	cu_rgt
	pat : int
  	cnt : int
  is	tmp : int
  	while cnt--
	   tmp = pat
	   pat >>= 1
	   pat &= 077777
	   pat |= 0100000 if tmp & 1
	end
	reply pat
  end

  func	cu_wai
	pat : int
	()  : long
  is	if (pat & 0100001) && !cuVwai--
	   cuVwai = cuWAI
	   cuVidx = 0 if !cuAwai[++cuVidx]
	end
	reply cuAwai[cuVidx] * 3L
  end
