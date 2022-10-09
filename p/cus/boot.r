;	RUSTX to handle suffix
;	Cleanup bo$onc
;	Identify early versions
;	Fixup SHOW captions
;	CSISPC
;???;	CUS:BOOT - boot> set x.y/??? ; no error message for "/???"
.title	boot - RUST bootstrap manager
.include "lib:rust.mac"

;---;	BOOT - stack location problem with RUSTx embedded boot
;+++;	BOOT - Use NOAUTO instead of NOIMAGE
;+++;	BOOT - Add boot-time UI under BOOT
;+++;	BOOT - Add COPY/BOOT
;!!!;	BOOT - BOOT>BOOT completed

;???	Move all interactive stuff to BOOT extension
;???	Move back system detection logic

sec$c=1		; use inc instead of bis to set cbit
loo$c=1		; shorten lookup
csp$c=0		; .CSISPC attempt
		;
h50$c=1		; default to 50 hertz
rxm$c=0		; default to RUST/SJ boot
qui$c=0		; default to NOQUIET
		;
rst$c=0		; restore monitor after boot driver fault
stk$c=0		; stack location

suf$c=0		; boot suffix correction
mnm$c=0		; move monitor name to rmon
ctr$c=0		; ctrl/h, ctrl/r support
pwf$c=0		; power-fail trap (redundant)
seg$c=0		; additional directory segment checks
clk$c=0		; set config for clock detected
mtp$c=0		; .mtps #0
hgh$c=0		; recover boot block after boot read fail (redundant)

;	BOOT.SYS is both a bootable and executable image.
;
;	When booted it acts as a subset RT-11 monitor. The
;	usual task is to then RUN RUST.SAV or RUSTX.SAV.
;
;	When executed with RUN etc it acts as a configuration
;	utility which is used to specify the name of the 
;	executable image (RUST.SAV or RUSTX.SAV).
;
; ???	When executed under BOOT.SYS itself it acts as a 
;	bootstrap manager.
;
;	Build BOOT utility
;
;	%build
;	!@@cts:rtboo
;	macro cus:boot.r/object:cub:bootm
;	rider cus:boot  /object:cub:bootr/nodelete
;	link  cub:boot(m,r),lib:crt/exe:cub:boot/map:cub:boot/cross
;	set   program/traps/loop/jsw=41000 cub:boot
;	!
;	copy cub:boot.sav cub:rust.sys
;	cub:rust.sys
;	set cub:rust.sys/image=rust.sav/suffix=V
;	exit
;	!
;	copy cub:boot.sav cub:rustx.sys
;	cub:rustx.sys
;	set cub:rustx.sys/image=rustx.sav/suffix=P
;	exit
;	end:
;	%end
.sbttl	macros

$brdef		;boot area
$chdef		;channel
$cldef		;cli
$cndef		;config
$cpdef		;cpu types
$dedef		;devices
$dsdef		;device status
$emdef		;emts
$esdef		;error severity
$fndef		;filenames
$erdef		;errors
$hwdef		;hardware
$imdef		;image
$iodef		;i/o
$jbdef		;jsw
$jsdef		;jsw
$kjdef		;j11
$kwdef		;clocks
$mmdef
$psdef		;psw
$rmdef		;rmon
$rtdef		;rt11a
$sgdef		;sysgen
$tcdef		;terminal config
$txdef		;text
$vedef		;vectors
.asect		; entire module is an asect

meta	<bosav$><jsr r5,bo$sav>
meta	<bores$><jsr r5,bo$res>
meta	<bofat$ nam stk=-word><jsr r2,bo$fat><.byte bo'nam'.,stk+word>
meta	<borot$ cnt lim><jsr r3,bo$rot><.byte cnt,lim>
meta	<asect$ adr val><.=adr><val>
meta	<limit$ lim><assume . le lim>

asect$	0	<.rad50 /MON/>		; identify monitor image
.if eq stk$c
asect$	j$busp	c$ustk			; BOOT.SAV stack
.endc
asect$	j$bjsw	jsovr$			; set overlay bit
asect$	400				; image ident area

$imgdef	BOOT 4 0
$imginf	fun=sbo cre=hammo aut=ijh use=<RUST bootstrap manager>
$imgham	yrs=<1986,1987,1988,2004,2011,2022> oth=<BOOT>
;	%date
$imgdat	<10-Oct-2022 03:49:08>   
;	%edit
$imgedt	<438  >

;	Memory map

	asect$	1000
	b$obuf = 1000
	b$osec:
	b$olow=.-<512.*3>-256.		; low address of boot real estate
	b$ostk=.-<512.*3>-82.-32.	; boot stack
	b$olin=.-<512.*3>-82.		; input line
	b$olnx=.-<512.*3>-1		; end of input line
	b$oseg=.-<512.*3>		; boot directory segment buffer
	b$oswp=.-512.			; low memory swap buffer
	r$mmon=.		;000	; 67,0 - not RUST monitor
	r$mcsw=.+4		;004	; csw area - once-only code

;	Relocation 

	meta	<.wordr a><rel .word a off=0>
	meta	<movr a,b><rel mov a,b>

	upctr. = 0

	.macro	rel a b c off=2
	.irp upx.,<\upctr.>
	up'upx. = .+off
	.endr
	upctr. = upctr. + 1
	.if nb c
	a	b,c
	.iff
	a	b
	.endc
	.endm

	.macro	reloc$
	upmid. = upctr.
	b$oloc = .
	. = b$orel
	upx. = 0
	.rept upmid.
	.irp	upy.,<\upx.>
	.word	up'upy.
	.endr
	upx. = upx. + 1
	.endr
	.word	0
	rmfre. == <r$mmon+rm.syu>-.
	limit$	r$mmon+rm.syu		; end of csw area
	. = b$oloc
	.endm

	.macro	bofre$	lab, off
	assume <.-r$mmon> le off
	lab =  <r$mmon+off>-.
	asect$	r$mmon+off
	.endm
.sbttl	boot start and rmon

;	RT-11 has a fixed offset database (RMON) which we replicate.
;	Once-only start-up code is stuffed into the dynamic areas of RMON.

bo$sec::nop				; RUST/BT RMON signature
	mov	#bo$clk,v$eclk		; point to clock ps
	clr	v$eclk+ve.ps		;
	clr	r5			; location zero
	mov	(r5),b$rdup		; save DUP flags
10$:	clr	(r5)+		;000	; trap catcher
	clr	(r5)+		;002	; trap catcher
	mov	#bo$cat,(r5)+	;004	; bus trap
	clr	(r5)+		;006	; cleared
	mov	#bo$cat,(r5)+	;010	; cpu trap
	clr	(r5)+		;012	; cleared

	bvcw	@#ps,15$		; yep - we have a PS
	mov	#bomf0.,b$omfp		; nope - use MTPS instead
	mov	#bomf1.,b$omfp+word	; mfps 2(sp)
15$:	bis	#100,@#h$wlks	;r2=100	; check & set clock
	bvs	20$			; no clock register
	bis	#cnkwc$,r$mcfg		; we have a clock
					;
20$:	bvcw	(r5)+,20$		; size kernel memory
	tst	-(r5)			; backup

;	Copy ourselves to top of memory
;
;	o Copies the boot block to the swap buffer b$oswp.
;
;	r5 -> 160000 (typical end-of-memory)
;	r0 -> b$renx+2 	end of primary/secondary/extension

	mov	#b$renx+2,r0		;
30$:	mov	-(r0),-(r5)		;
	bnew	r0,30$			;

;	Relocate high copy 
;
;	r5 ->	relocation base of high memory copy

	mov	#b$orel,r0		; relocation list
40$:	mov	(r0)+,r2		; get the next
	beq	50$			; all done
	add	r5,r2			; relocate pointer
	add	r5,(r2)			; relocate value
	br	40$			;
50$:	add	#bo$onc,r5		; where we continue
	jmp	(r5)			; continue

;	Relocation table inserted here by .wordr and movr macros

b$orel:					; relocation table inserted here

	bofre$	boSYU. rm.syu		; report free space in link map

;	Remainder of RMON table

				;offset	; boot device unit
r$msyu:	.byte	0		;274	; system device unit (in high byte)
b$osyu:	.byte	0		;275	; boot address of r$msyu
r$msyv:	.byte	5		;276	; system version - always RT-11 version
r$msup:	.byte	33		;277	; system update
r$mcfg:	.word	0			; config
r$mscr:	.word	0		;302	; GT control block address - unused
r$mtks:	.word	h$wtks		;304	; console addresses
r$mtkb:	.word	h$wtkb		;306	;
r$mtps:	.word	h$wtps		;310	;
r$mtpb:	.word	h$wtpb		;312	;

bo$sav:	pshs	<r4,r3,r2,r1,r0>	; save registers
	jmp	(r5)			; destroys r5

bo$res:	bit	(sp),(sp)+		; skip, don't change c-bit
	pops	<r0,r1,r2,r3,r4>	; restore registers
	rts	r5			;
					; move from/to psw
bo$mfp:	psh	(sp)			; make space for it
b$omfp:	bomf0.=nop			; nop
	bomf1.=mfps+66			; mfps 2(sp)
	mov	@#ps,word(sp)		; nop mfps 2(sp)
	return				;

	bofre$	boMTP. rm.mtp		; report free space in link map
r$mmtp:	br	bo$mtp		;360	; move to ps
r$mmfp:	br	bo$mfp		;362	; move from ps
r$msyi:	.word	desyi.		;364	; system device index
b$oqui::.byte	0		;366	; identify flag (BOOT V2.4)
b$orun::.byte	1		;367	; run image
r$mcf2:	.word	0		;370	; confg2 - extension config word
r$msyg:	.word	sgfpu$		;372	; sysgen options - from boot impure

	stack	pc ps			;	
	assume	vbit eq 2		;	
	assume	sp.ps eq 2		; and so is rti
bo$cat:	bis	(pc),sp.ps(sp)	;374	; set return vbit (bis #2,2(sp))
bo$mtp:	rti			;400	; (pop (sp),sev,return)
	.word	0		;402	; unused

r$mpnp:	.word	b$opnm-r$mmon	;404	; pname table offset
r$mmnm:	.rad50	/BOOT  /	;406 ?	; monitor name
r$msuf:	.rad50	/  V/		;412 ?	; driver suffix
b$opnm:	.rad50	"TT "		;414	; pname table
b$osnm:	.rad50	"SY "		;416	; system device permanent name
r$mmes:	.word	1600		;420\	; sj/fb memory size in pages - constant
b$ompt:	.word	0		;422/	; dummy memory map
r$mtcf:	.wordr	b$otcf		;424 ?	; pointer to ttcnfg
	.word	0		;426	; unused
r$mmpt:	.word	b$ompt-r$mmon	;430	; offset to memory map
.sbttl	vectors

;	Fill in vectors before/after image activation
;
;	r2	must be safe
;	r3 =	base location

bo$vez:	clr	r3			; block zero (no relocation)
bo$vec:	mov	#bic,(r3)		; bic r0,r0
	mov	#emexi.,word(r3)	; .exit
	movr	#r$mmon,jb.sys(r3) 	; rmon address
	movr	#b$ovec,r0		; get the relocation list
10$:	mov	(r0)+,r1		; get the next
	beq	20$			; is no next - r1=0
	add	r3,r1			;
	mov	(r0)+,(r1)+		; move in one
	clr	(r1)+			; clear the next
	br	10$			;
20$:	.if ne mtp$c
	.mtps	#0			; clear PS
	.endc
	return				;

;	Vector fill & relocate data
;
;	This data is restored after each exit. Supports bootstraps
;	and maintenance programs which overwrite the vectors.

meta	<borel$ boo vec><.word vec><.wordr boo>
b$ovec:	borel$	bo$bus,v$ebus		; bus vector
	borel$	bo$cpu,v$ecpu		; cpu vector
	borel$	bo$emt,v$eemt		; emt vector
	b$opev=.-<word*2>		; patch point
	borel$	bo$clk,v$eclk		; clock vector
	borel$	bo$clk,k$pvec		; programmable clock
	borel$	bo$bus,v$emmu		; mmu vector
	borel$	bo$fpu,v$efpu		; fpu vector
	.if ne	pwf$c			;
	borel$	bo$pwf,v$epow		; power fail
	.endc				;
	.word	0			;

;	Once-only code that won't fit in RMON table

bo$onc:

;	RUST/XM needs the following to boot.

	mov	b$rdvn,r0		; b$rdvn - with wrong suffix
	mov	r0,b$osnm		;
10$:	sub	#40.,r0			; get it down to the suffix
	bhis	10$			; more
	add	#40.,r0			; bump it back
	sub	r0,b$osnm		; b$osnm - minus suffix

	.if ne mnm$c
	mov	b$rfn0,r$mmnm		; monitor name
	mov	b$rfn1,r$mmnm+word	;
	mov	b$rsfx,r$msuf		; suffix
	.endc

	beqw	b$rers,#<^rERA>,30$	; no era
	clr	b$rera			;
30$:	fall	bo$rst
.sbttl	Command processor and image exit

;	Image exit - reset monitor

bo$exi:					; app exit
bo$rst:	mov	(pc)+,sp		; our stack
b$pstk:	.wordr	b$ostk			; system stack
	call	bo$vez			; reset vectors
	mov	@#v$ebus,b$oswp+v$ebus 	; two are done by hand
	mov	@#v$eclk,b$oswp+v$eclk	; for traps during read swaps
	.if ne hgh$c			; (which should not occur)
	call	bo$hgh			; force boot block high
	.endc

	clr	(pc)+			; clear flags
b$olfd:	.word	0			; no line feed pending
	tst	b$octc			; already done this?
	bpl	bo$com			; yep
	bneb	b$oqui,10$ 		; /QUIET - don't display "BOOT V2.3"
	movr	#b$rnam,r0		; setup for print
	.print				;
10$:	mov	#ctrlc,(pc)+		; signal title done, let ctrl/c thru
b$octc:	.word	-1			; done the tertiary stuff
	bneb	b$orun,bo$run		; run the startup image
	fall	bo$com

;	Get a boot command
;
;	Invoked by NOIMAGE, .EXIT, boot fail or [ctrl/c]
;
;	boot> image[.sav]

bo$com:	movr	#b$olin,r1		; point to the line
	movr	#b$oprm,r2		; the prompt
10$:	.gtlin	r1,r2			; get the command
	tstb	(r1)			; got a null line?
	beq	10$			; yes
	movr	#b$oimg+fn.fil,r0	; set the image name pointer
	call	bo$fil			; get a file spec
	tstb	(r1)			; did the command terminate?
	bne	20$			; no
	tst	(r0)			; did we get a file?
	bne	bo$run			; yes - load it
20$:	bofat$	xic			; command error
.sbttl	load image

;	Chain to image

bo$chn:	mov	b$pstk,sp		; reset the stack
	call	bo$vez			; reset vectors
	jsr	r0,bo$loa		;
b$ochn:	.byte	imchn.,emloo.		; chain lookup
	.word	500			; chain file spec
;sic]	.word	0			; sequence - ignored

;	Run image

bo$run:	jsr	r0,bo$loa		; load file
	.byte	imchn.,emloo.		; lookup
	.wordr	b$oimg			; image spec
;sic]	.word	0			; sequence - ignored

;	Load image
;
;	r0 ->	emt .lookup block

bo$loa:	emt	375			; look it up
	bcs	40$			; file not found
	movr	#b$otrr,r0		; read the root
	emt	375			;
	bcs	30$			; error reading block zero

	mov	#b$obuf,r3		; point to the buffer
	call	bo$vec			; fill in vectors etc.
	jsr	r3,bo$mbl		; move down block zero
	.word	b$obuf			; source
	.word	0			; destination
	.word	256.			; count
					;
	mov	@#j$btop,r1		; c=0 - get the program size
	assume	b$obuf eq 1000		;
	sub	r3,r1			; remove what we have
	blo	10$			; its all in (remember settop)
;sic]	clc				;
	ror	r1			; make it words
	inc	r1			; one more for settop logic
	mov	r1,b$otwc		; setup the word count
	movr	#b$otir,r0		; read it
	emt	375			;
	bcs	30$			; i/o error

;	Go
;
;	r3 ->	block zero buffer
;	r5 =	^rboo

10$:	mov	@#j$busp,sp		; setup their stack
	clr	@#j$bcct		; no command in buffer
	mov	#^rboo,r5		; this is boot
	mov	@#j$bupc,pc		; and start the program
					;
30$:	bofat$	xio			; I/O error
40$:	bofat$	xfn			; file not found

;	Image lookup & read data

b$otrr:	.byte	imchn.,emrea.		; read image root
	.word	0			; block number
	.word	b$obuf			; buffer address
	.word	256.			; word count
;sic]	.word	0			; wait - ignored

b$otir:	.byte	imchn.,emrea.		; read image 
	.word	1			; block number
	.word	1000			; buffer
b$otwc:	.word	0			; word count
;sic]	.word	0			; wait - ignored
.sbttl	emt dispatch

;	Dispatch program request
;
;	r0	request r0 for old emts
;	r1	zero
;	r2	computed emt code
;	r3	word(r5) for emt 375 requests
;	r4 ->	channel
;	r5 	request r0 - copied to r0 on exit
;	cbit	clear

b$oclf:	.byte	clccl$			; cliflg - cli flags
b$oclt:	.byte	-1			; clityp - cli type
b$otcf:	.word	tc0xn$!tc0lm$!tc0sc$	; ttcnfg - terminal config
bo$emt:	bic	#cbit,word(sp)		; clear the error bit
	bosav$				; save all registers
	stack	r0 r1 r2 r3 r4 r5 pc ps	; 
	clrb	@#j$berr		; assume error code 0
	mov	r0,r5			; r5 -> emt code or area
	mov	sp.pc(sp),r1		; get the emt
	mov	-(r1),r2		; r2 = emt code byte
	movr	#b$oemt,r1		; r1 -> dispatch list
	cmpb	r2,#374			; old/374/375/376?
	blo	20$			; old emt
	beq	10$			; 374
	cmpb	r2,#376			; 375 or 376?
	beq	bo$ovx			; 376 - error from overlay handler
	add	#b$o375-b$o374,r1	; 375
	mov	(r5),r0			; r0 = subcode ! channel
	mov	word(r5),r3		; r3 = word(r5)
10$:	add	#b$o374-b$oemt,r1	; 374
	mov	r0,r2			; r2 = subcode ! channel
	movb	r0,r0			; isolate channel
	asl	r0			; multiply by 10
	mov	r0,r4			; *2
	asl	r0			;
	asl	r0			;
	add	r0,r4			; *10.
     	add	r$pcsw,r4		; r4 -> channel
	swab	r2			; r2 = subcode
20$:	bic	#^c377,r2		; isolate subcode
	clr	-(sp)			; dispatch address
	stack	rou r0 r1 r2 r3 r4 r5 pc ps
30$:	movb	(r1)+,(sp)		; (sp) = address
	beq	40$			; end of table - check invalid
;
	cmpb	r2,(r1)+		; this the one?
	bne	30$			; no
	clr	r1			; r1 = 0
	asl	(sp)			; make a word offset
    rel	add	#b$oemd,(sp)		; add in the base address
	call	@(sp)+			; yes - do it
	br	bo$ems			; success returns
					;
40$:	cmpb	r2,(r1)			; is this one invalid?
	beq	bo$emf			; yes - return error code
	tstb	(r1)+			; end of the list?
	bne	40$			; no - look again
	cmpb	r2,(r1)+		; below minimum code?
	blo	bo$emf			; yes
	cmpb	r2,(r1)+		; above maximum code?
	bhi	bo$emf			; yes
	br	bo$emq			; no - just ignore it
.sbttl	emt return

;	EMT return path
;
;	bo$emr	test cbit
;	bo$emf	fail
;	bo$emq	quit - no error
;	bo$ems	success - stack popped

	stack	ret r0 r1 r2 r3 r4 r5 pc ps
bo$emr:	bcc	bo$emq			; return
bo$emf:
	.if ne	sec$c
	inc	sp.ps(sp)		; rti c=1
	.iff
	bis	#cbit,sp.ps(sp)		; fail
	.endc
bo$emq:	tst	(sp)+			; quiet
	stack	r0 r1 r2 r3 r4 r5 pc ps	;
bo$ems:	mov	r5,(sp)			; restore r0
	call	bo$chk			; check for an abort
	bores$				; restore all registers
	rti				; and quit

	stack	ret r0 r1 r2 r3 r4 r5 pc ps
bo$ovx:	bofat$	xio sp.pc		; i/o error

;	EMT list
;
; list:	.byte	offset, subcode		valid subcodes
;	...
;	.byte	0
;	.byte	subcode, subcode, ...	invalid subcodes - may not be zero
;	.byte	0
;	.byte	minimum			minumum subcode
;	.byte	maximum			maximum subcode

meta	<boemt$ cod adr><.byte adr-b$oemd/word,cod>
b$oemt:	boemt$	217	bo$ovl		; read overlay
	boemt$	340	bo$tti		; ttyin
	boemt$	341	bo$tto		; ttyout
	boemt$	342	bo$dst		; dstatu
	boemt$	343	bo$fet		; fetch
	boemt$	344	bo$csi		; csigen
	boemt$	345	bo$gln		; csispc & gtlin
	boemt$	350	bo$exj		; exit (jump)
	boemt$	351	bo$pri		; print
	boemt$	353	bo$qst		; qset
	boemt$	354	bo$sto		; settop

	.byte	0,0			; invalid done in routines
	.byte	340,377			; minimum & maximum
b$o374:	boemt$	0	bo$wai		; wait - dummy for search logic
	boemt$	10	bo$chj		; chain
	boemt$	12	bo$dat		; date
	.byte	0,0			; all are valid
;	.byte	0,em74h.+2		; limits (+2 for new releases)
	.byte	0,em74h.		; limits
b$o375:	boemt$	1	bo$loj		; lookup
	boemt$	3	bo$trp		; trpset
	boemt$	10	bo$rea		; read
	boemt$	20	bo$gjb		; gtjb
	boemt$	21	bo$gtm		; gtim
	boemt$	27	bo$cst		; cstat
	boemt$	34	bo$gvl		; gval
	boemt$	40	bo$sdt		; sdttm/gtimx/stimx
	.byte	0,2,4,5,6,0		; enter rename savest reopen
	.byte	11,32,0			; write spfun
;	.byte	0,em75h.+2		; limits (+2 for new releases)
	.byte	0,em75h.		; limits
	.even				;
b$oemd=.-2				; sic] emt dispatch base
.sbttl	print, ttyout, ttyin

;	Print & ttyout
;
;	r0	request r0 for old emts
;	r1	zero
;	r2
;	r3	word(r5) for emt 375 requests
;	r4 ->	channel
;	r5 	request r0 - restored to r0 on exit
;	cbit	clear
;
;	r0 ->	string
;
;	r0	undefined
;	r1 ->	past last byte

	.enabl	lsb			;
bo$pri:	mov	r0,r1			; get a copy
10$:	movb	(r1)+,r0		; get the next
	beq	bo$new			; done - do new line
	cmpb	r0,#200			; this the last?
	beq	20$			; yes
	call	bo$put			; display it
	br	10$			;
bo$new:	mov	#cr*256.+lf,r0		; yes
	call	(pc)			; cr then lf
	swab	r0			; get the next
bo$tto:	callr	bo$put			; display the character

;	ttinr
;
;	Does not support rubout or convert to upper case

bo$tti:	movr	#b$olfd,r3		; point to the line feed
	mov	(r3),r5			; got a line feed?
	bne	bo$cr3			; yes - clear it and quit
	call	bo$chk			; get the character
	bcs	bo$emf			; no character
	mov	r0,r5			; return the character
	cmpb	r5,#cr			; this a return?
	bne	20$			; no
	movb	#lf,(r3)		; yes - linefeed next time
20$:	return				;
	.dsabl	lsb			;
;+++;	BOOT - .csispc to support a single file and no switches
.sbttl	csi, gtlin

;	Pick up the parameters for CSI requests and report an error
;	Process gtlin requests
;	Convert input to uppercase after echo

bo$gln:	stack	ret r0 r1 r2 r3 r4 r5 pc ps str prm flg lin bbs
;o$csi:	stack	ret r0 r1 r2 r3 r4 r5 pc ps str prm flg bbs
bo$csi:	stack	ret r0 r1 r2 r3 r4 r5 pc ps cmd ext out bbs
	borot$	3 sp.bbs		; get the first three
	stack	prm flg lin ret r0 etc	; if line buffer
	stack	prm flg ret r0 etc	;
	stack	cmd ext out
;sic]	pop	r2			; r2 = str (zero)	str
	pop	r4			; r4 -> the prompt	typ
	pop	r0			; r0 -> the flag	out
	asr	r0			; is it set for another parameter?
bpt
	bcc	5$;bo$emf		; no - and its not gtlin
	stack	ret r0 r1 r2 r3 r4 r5 pc ps lin bbs
	borot$	1 sp.bbs		; get the line buffer address
;sic]	pop	r2			; r2 -> the buffer
5$:	asr	r0			; was this csispc?
.if ne csp$c
	bne	70$			; yes
.iff
	bne	bo$emf			; yes
.endc
					; get line
	mov	r2,r1			; r1 -> buffer
	mov	r4,r0			; got a prompt?
	beq	20$			; no
10$:	.print				; yes
20$:	call	bo$chk			; get a character
	bcs	20$			; nothing doing
	cmpb	r0,#cr			; terminate on lf
	beq	50$			;
	cmpb	r0,#rubout		; this a delete?
	bne	30$			; no
	cmp	r1,r2			; at start of line?
	beq	20$			; yes
	dec	r1			; no
	movr	#60$,r0			; nope - do rubout
	br	10$			; rub it out
30$:rel	cmp	r1,#b$olnx		; any more space in line?
	bhis	20$			; no - refuse it
	.ttoutr				; no - display it
	cmpb	r0,#'a			; this lowercase?
	blo	40$			; no
	cmpb	r0,#'z			; really?
	bhi	40$			; no
	sub	#'a-'A,r0		; yes
40$:	movb	r0,(r1)+		; store it
	br	20$			; look again
50$:	clrb	(r1)			; terminate it
	br	bo$new			; new line and return
60$:	.byte	bs,space,bs,200		; rubout
.if ne csp$c
70$:	jmp	bo$csp
.endc
.sbttl	cstat, exit, settop, date, trpset, gtim, gval

;	cstat

bo$cst:	mov	r3,r5			; return address in r0
	mov	(r4)+,(r3)+		; ch.csw 
	bpl	bo$emf			; oops - channel not open
	mov	(r4)+,(r3)+		; ch.sbl
	mov	(r4)+,(r3)+		; ch.len
	mov	(r4)+,(r3)+		; ch.use
	movb	byte(r4),(r3)+		; ch.uni
	clrb	(r3)+			;
	mov	b$opnm+desyi.,(r3)+	; system device name
	return

;	settop
;
;	r5 	new top address

bo$sto:	cmp	b$ousr,r5		; value ok?
	bhis	30$			; yes
	mov	b$ousr,r5		; return the value
30$:	mov	r5,@#j$btop		; return low location
	return				;

;	date

bo$dat:	mov	b$rdat,r5		; return the date
bo$wai:	return				; dummy wait routine

;	trpset

bo$trp:	mov	r3,b$otrp		; setup the trap location
	return				;

;	sdttm/gtimx

bo$sdt: bneb	(r5),#1,10$		; not .gtimx
	mov	b$rdat,(r3)+		; date
	call	bo$gtm			; time
	mov	b$rera,(r3)+		; era
10$:	return

;	gtim

bo$gtm:	mov	b$rhot,(r3)+		; high order
	mov	b$rlot,(r3)+		; low order
	return

;	gval
;
;	34	0	gval
;		1	peek
;		2	pval	ignored
;		3	poke	ignored

bo$gvl:	cmpb	(r5),#1			; what is it?
	bhi	20$			; pval or poke
	beq	10$			; peek
    	add	@#j$bsys,r3		; relocate it
10$:	mov	(r3),r5			; return value in r0
20$:	return				;
.sbttl	gtjb, dstat, fetch, qset

;	gtjb

bo$gjb:	mov	r3,r5			; return block address in r0
	clr	(r3)+			; job number
	mov	b$ousr,(r3)+		; high limit
	clr	(r3)+			; low limit
	mov	(pc)+,(r3)+		; csw area pointer
r$pcsw:	.wordr	r$mcsw			; 
	clr	(r3)+			; clear impure address
	clr	(r3)+			; no multiterminal
bo$cr3:	clr	(r3)+			; no virtual high limit
	return				;

;	dstat				
;
;	r0 ->	device name
;	0(sp)	dblk!phyflg
;
;	The information is about an imaginary RT11A disk.
;	It is sufficient to convince a program that the disk is loaded.
;	All logical names translate to SY: - no device name check is made.

	stack	ret r0 r1 r2 r3 r4 r5 pc ps buf bbs
	.enabl	lsb			;
bo$dst:
	borot$	1 sp.bbs		; rotate the stack one place
;sic]	pop	r2			; r2 = buffer
	call	10$			; clean up address, return it in r5
	mov	#dsrta$+377,(r2)+	; de.sta - rt-11 disk
	mov	#100,(r2)+		; de.hsz - it is very small
	mov	pc,(r2)+		; de.ent - it is loaded here
	mov	pc,(r2)+		; de.dsz - and it is quite large
	return				;

;	fetch & qset
;
;	Pickup the parameter and ignore it

bo$fet:
bo$qst:	stack	ret r0 r1 r2 r3 r4 r5 pc ps buf bbs
	borot$	1 sp.bbs		; rotate the stack one place
;sic]	pop	r2			; r2 = buffer
10$:	bic	#1,r2			; clean up the address
	mov	r2,r5			; and return it
20$:	return				;
	.dsabl	lsb			;

;	chain and exit

bo$exj:	jmp	bo$exi			; exit (jump)
bo$chj:	jmp	bo$chn			; chain (jump)
.sbttl	lookup 

;	r0	request r0 for old emts
;	r1	zero
;	r2
;	r3	word(r5) for emt 375 requests
;	r4 ->	channel
;	r5 	request r0 - restored to r0 on exit
;	cbit	clear
;
;	r5 ->	chn ! cod
;		filespec address
;
;	r1 =	start block
;	r2 ->	entry
;	r3 ->	fn.fil(dblk)
;	r4 ->	channel
;	r5 ->	chn ! cod

	.enabl	lsb
bo$loo:	clr	(r4)			; channel not open
;sic]	mov	word(r5),r3		; r3 -> filespec
	tst	(r3)+			; r3 -> fn.fil(r3)
	clr	r5		; r1=0	; assume non-file open
	tst	(r3)			; non file open?
	beq	60$			; yes - we are done
	mov	#1,r0			; first segment

;	Next segment

10$:	asl	r0			; *2
	cmp	(r0)+,(r0)+		; +4
	mov	#512.,r1		; word count
	movr	#b$oseg,r2		; buffer address
	beqw	r0,r$mblk,15$		; already have the segment
	mov	r1,(pc)+		; invalidate directory buffer
r$mblk:	.word	0			;
	call	bo$red			; call the read routine
	bcs	bo$xdi			; oops - directory i/o error
	mov	r0,r$mblk		; remember directory segment
	assume	rt.hbs-word eq rt.blk	;

15$:	add	#rt.blk,r2		; point at first entry
	mov	(r2)+,r1		; rt.blk - get first start block

;	Entry loop

20$:	bit	#rtiv$p,(r2)		; this a valid directory?
	bne	bo$xdf			; no
	bit	#rtend$,(r2)		; end of segment?
	bne	40$			; yes - get next segment
	.if ne seg$c
   rel	cmp	r2,#b$oseg+1024.	; exact end of segment buffer?
	beq	40$			; yes
	bhi	bo$xdf			; invalid directory
	.endc
	mov	r2,r0			; r0 -> sta fil nam len
	bit	#rtper$,(r0)+		; rt.sta - permanent entry?
	beq	30$			; no
					;
	mov	r3,r5			; get a copy
	bnew	(r5)+,(r0)+,30$		; compare filnamtyp
	bnew	(r5)+,(r0)+,30$		;
	beqw	(r5)+,(r0)+,50$		;
					
;	Next entry
 
30$:	add	rt.len(r2),r1		; increment start block
	add	#rt.ebs,r2		; next entry
	add	b$oseg+rt.ext,r2	; add in extra bytes
	br	20$			; look at the next

;	Next segment

40$:	mov	b$oseg+rt.nxt,r0	; get the next segment
	bmi	bo$xdf			; ridic segment number
	bne	10$			; more segments
	jmp	bo$emf			; file not found
					
;	Setup channel
;
;	r1	start block
;	r5	length (zero for non-file)

50$:	mov	(r0),r5			; rt.len - return length in r0
60$:	mov	#csact$+desyi.,(r4)+	; rt.csw
	mov	r1,(r4)+		; rt.sbl - zero for non-file
	mov	r5,(r4)+		; rt.len - zero for non-file
	clr	(r4)+			; rt.use
	mov	r$msyu,(r4)+		; rt.uni - in high-byte
bo$rt2:	return				; found
	.dsabl	lsb
					;
	stack	ret r0 r1 r2 r3 r4 r5 pc ps
bo$xdi:	bofat$	xio sp.pc		; directory I/O error
bo$xdf:	bofat$	xdf sp.pc		; directory format error
.sbttl	read & overlay read

;	EMT 217 read supported for overlays.
;
;	r0	virtual block
;	sp.buf	buffer address
;	sp.wct	word count
;	sp.com	completion - ignored

	stack	ret r0 r1 r2 r3 r4 r5 pc ps buf wct com bbs
bo$ovl:	borot$	3 sp.bbs		; rotate the stack
	stack	buf wct com ret r0 r1 r2 r3 r4 r5 pc ps bbs
	losbl.=<ch.bbs*imchn.>+ch.sbl	;
 	add	r$mcsw+losbl.,r0	; r0 = block
;sic]	pop	r2			; r2 = buffer
	pop	r1			; r1 = word count
	tst	(sp)+			; forget the ast
	br	bo$rec			;

;	EMT 375 read
;
;	r4 ->	channel
;	r5 ->	cod!chn	channel number
;		blk	virtual block
;		buf	buffer address
;		wct	word count
;		com	completion - ignored

bo$loj:	br	bo$loo			; branch across read routine
bo$rea:	tst	(r5)+			; skip the channel & code
	mov	(r5)+,r0		; r0 = virtual block number
	mov	(r5)+,r2		; r2 = buffer address
	mov	(r5)+,r1		; r1 = word count
					;
	mov	ch.sbl(r4),r3		; r3 = logical start block
	beq	10$			; non-file access
	mov	ch.len(r4),r5		; r5 = file length in blocks
	sub	r0,r5			; subtract start block
	blos	20$			; end of file error
	swab	r5			; get block count
	bne	10$			; 256+ is big enough for anything
	cmp	r5,r1			; compare remainder with wordcount
	bhis	10$			; fine
	mov	r5,r1			; truncate request
10$:	add	r3,r0			; r0 = logical block number
	br	bo$rec			;
20$:	clr	r5			; end of file - no data read
	jmp	bo$emf			; failed

;	Read common
;
;	Common overlay & emt read
;
;	r0	logical block
;	r1	word count
;	r2	buffer address
;	r3:r4	preserved
;
;	r5	actual wordcount - returned in r0

bo$rec:	mov	r1,r5			; get the word count
   rel	psh	#bo$emr			; return to bo$emr
	fall	bo$red			; read the data
.sbttl	read primitive

;	r0 =	logical block number
;	r1 =	word count
;	r2 ->	buffer address
;	r0:r5	preserved
;
;	Called from bo$rec and bo$loo
;	Save the stack, setup read stack
;	Swap block zero and swap buffer copy of boot driver
;	Save and setup b$rdvu - setup r$msyu 
;	Issue the read operation
;	Swap back swap buffer and block zero
;	Restore b$rdvu unless modified by read operation

bo$red:	bosav$				; save all registers
	mov	sp,40$			; save the stack
	stack	r0 r1 r2 r3 r4 r5	;
   rel	cmp	sp,#b$olow		; using the monitor stack?
b$ousr=.-2
	bhis	10$			; yes - dont swap
    	mov	b$pstk,sp		; no - use system stack
					;
10$:	.mtps	#340			;
	mov	#b$rdvu,r4		; save low version
	mov	(r4),-(sp)		; save location
	mov	b$rdvu,(r4)		; set it up (with high version)
	movb	(r4),b$osyu		; build monitor copy
	clr	-(sp)			; assume restore
	sub	r2,r4			; can read modify area?
	bcs	15$			; nope
	psh	r1			; words
	asl	(sp)			; bytes
	sub	(sp)+,r4		; will read modifiy @#4722?
	adc	(sp)			; c=1 if true
15$:	stack	flg,sav			;
					;
	call	bo$swp			; swap once
	mov	#jmp+37,@#br$ioe	; catch I/O errors
	movr	#20$,@#br$ioe+word 	; jmp @#20$
	call	@b$rrea			; call the read routine
					; all registers lost
	tst	(pc)+			; returns only if okay
20$:	sec				; errors patched to come here
	call	bo$swp			; swap back again
	adc	r4			; setup the cbit
	assume	ioher. eq 1		; r4 = 0 or 1
	movb	r4,@#j$berr		; set I/O error code if one occurred
	stack	flg,sav			;
	asr	(sp)+			; reset device unit word?
	bcs	50$			; nope
	stack	sav			;
	mov	(sp),@#b$rdvu		; yes - restore it
					; (no need to pop dvu)
50$:	mov	(pc)+,sp		; reset the stack
40$:	.word	0			; saved stack
	.mtps	#0			;
	rorb	r4			; reset the cbit
	bores$				; restore all registers
	return				; return to caller

;	Swap boot block and image low memory
;
;	cbit not modified
;	r4 low byte cleared

	.enabl	lsb
	.if ne hgh$c
bo$hgh:	bpcw	#1,b$ohgh,20$		;boot block is already high
	.endc
bo$swp:	bic	r4,r4			;c=? block zero
	.if ne hgh$c			;c=?
	inc	(pc)+			;c=?
b$ohgh:	.word	0			;c=? even = high, odd = low
	.endc				;c=?
	movr	#b$oswp,r5		;c=? get swap buffer
10$:	psh	(r4)			;c=? save low value
	mov	(r5),(r4)+		;c=? replace it
	pop	(r5)+			;c=? swap it
	bit	#777,r4			;c=? all done?
	bne	10$			;c=? no
20$:	return				;c=? r4+0 is clear
	.dsabl	lsb
.if ne csp$c
.sbttl	csispc 

;	Here because of branch distances
;
;	r2 ->	string
;	r4 ->	default types
;	r0 ->	output specs

bo$csp:	asl r0
bpt
	add	#3*5*2,r0	; r0 -> rad50 output
	mov	#^rsy,(r0)+	; r0 -> fil in devfilnamtyp
	mov	r2,r1		; r1 -> string
	mov	6(r4),r2	; r2 = default type
	call	bo$fil		; translate the spec
;	beqw	(r0),bo$emj	;
	return
.endc
.sbttl	traps

;	Traps may be lost if they occur during boot read routines.
;	We could (should) set PR7 to block interrupts at this time.
;
;	b$otrp	trap routine address
;	c=0	bus/mmu error
;	c=1	cpu error
;
;	b$otrp is not cleared - thus program can loop

	.enabl	lsb			;
bo$cpu:	sec				; cpu error
bo$mmu:					; mmu error
bo$bus:	psh	b$otrp			; c=? -	get the trap location
	beq	10$			; c=? -	no routine - crash
	bic	(pc),(pc)+		; c=? -	this is almost original
b$otrp:	.word	0			; 	trap location
	return				; c=? -	enter bus/cpu/mmu sst
10$:	bcs	20$			; cpu error
	stack	nul pc ps		;
	bofat$	xbu sp.pc		; bus error
20$:	bofat$	xcp sp.pc		; cpu error
	.dsabl	lsb			;
					;
bo$clk:	add	#1,b$rlot		; low order
	adc	b$rhot			; high order
	.if eq clk$c
	bis	#cnclo$,r$mcfg		; evidence of a clock
	.endc
bo$fpu:	rti				; ignore FPU traps (Unix)
					;
	.if ne	pwf$c			;
	stack	pc ps			;
bo$pwf:	bofat$	xpf sp.pc		; powerfail
	.endc				;
.sbttl	errors

;	Secondary and tertiary boot messages.
;
;	bofat$	cod stk
;
;	jsr	r2,bo$fat
;	.byte	cod		error code
;	.byte	stk		stack depth to pc
;
;	r0/r1	print
;	r2 ->	message string
;	r3 ->	stack pc
;	r4 ->	print routine
;	r5 	safe

	stack	r2 etc			;
bo$fat:	movr	#b$omsg.,r0		;sic] get the message header	
	movr	#bo$pri,r4 		; point to the print routine
	psh	r0			; save it
	stack	r0 r2 etc		;
	call	(r4)			; print the header
					;
	movb	(r2)+,r0		; get the offset
	add	(sp)+,r0		; r0 -> message
	stack	r2 etc			;
	movb	(r2)+,r3		; stack offset
	add	sp,r3			; r3 -> stack pc
	mov	r2,(sp)			; return address
					;
	stack	ret etc			;
	call	(r4)			; print the message
	tstb	(r1)			; need " error" added?
	bmi	10$			; no - just location
	beq	20$			; no - nothing
	movr	#b$oerr,r0 		; yes
	call	(r4)			; print " error "
					;
10$:	mov	(r3),r1			; r1 = error pc
	call	bo$num			; display the location
					;
20$: 	movr	#b$oimm,r0		; point to the filename
	call	(r4)			; display the name & newline
.if ne 0
	call	bo$chk			;
	.if ne	rst$c			; restore 
	bmiw	pc,bo$rsj		; restore
	call	bo$swp			; swap the driver back
	.iff
	tst	pc			; are we in the secondary boot
	bmi	bo$rsj			; yes - cannot recover
	.endc
bo$hlt:	halt				;
.endc
bo$rsj:	jmp	bo$rst			; restore monitor and prompt
	.if ne ctr$c
bo$rom:	jmp	@#173000		; start bootstrap rom
	.endc

;	Display a number
;
;	r1	number
;	r0	burnt
;	r2/r3	burnt

bo$num:	mov	#111111,r3 	; loop control
	clr	r2		; there once was a glichette named brigette
10$:	clr	r0		; who fancied the occassional fidget
20$:	asl	r1		; well, its fetch a bit here
	rol	r0		; and fudge a bit there
	asl	r3		; when it itches, ya just find ya digit
	bcc	20$		; keep fiddling
	beq	30$		; must print the final digit
	bis	r0,r2		; set the print flag
	beq	10$		; nothing to print so far
30$:	add	#'0,r0		; start or continue printing
	call	bo$tto		; display the character
	tst	r3		; done all digits ?
	bne	10$		; nope, go scritch it
	return			;
.sbttl	messages

;	.ascii	"message"	message string
;	.byte	>0		 error <pc> filnam.typ
;	.byte	<1		<pc> filnam.typ
;	.byte	0		filnam.typ
;
;	Messages that end with <200> have " error" appended

meta	<bomsg$ nam ctl><bo'nam'.=.-b$omsg><b$o'nam: ctl>
b$omsg:	.ascii	<cr><lf>"?BOOT-U-"<200>	;
b$oerr:	.ascii	" error "<200>		;
b$oimm:;.ascii	" "			; " filnam.typ"
	.byte	0			;
					;
bomsg$	xbu	<.ascii	"Bus"<200>>	; Bus error
;omsg$	xtp	<.ascii	"T11"<200>>	; Falcon error
bomsg$	xcp	<.ascii	"Cpu"<200>>	; CPU error
bomsg$	xio	<.ascii	"I/O"<200>>	; I/O error
bomsg$	xdf	<.ascii	"Directory"<200>>; Bad directory
bomsg$	xic	<.ascii	"Command"<200>>	; command error
bomsg$	xfn	<.ascii	"File not found"<200><0>> ; File not found
.if ne pwf$c
bomsg$	xpf	<.ascii	"Power"<200>>	; Power error
.endc
	.even
.sbttl	terminal 

;	Terminal output
;
;	Handles [ctrl/q] [ctrl/s] protocol
;
;	r0	character to write

bo$put:	psh	r0			; save the output character
10$:	call	bo$chk			; handle ctrl/q & ctrl/s
	tstb	@r$mtps			; ready yet?
	bpl	10$			; no
	pop	r0			; get the character back
	movb	r0,@r$mtpb		; move it in
	return				; c=0

;	Check terminal input
;
;	Check for [ctrl/q] & [ctrl/s]
;	Check for [ctrl/c] abort

bo$chk:	.enabl	lsb			; check terminal
10$:	call	bo$get			; get another
	bcs	30$			; nothing doing - ignore it
	beq	10$			; ignore spurious ctrl/q
	.if ne ctr$c
	beqb	r0,#ctrlr,bo$rom	; ^R -> ROM boot
	beqb	r0,#ctrlh,bo$hlt	; ^H -> HALT
	.endc
	beqb	r0,b$octc,40$		; ^C -> abort
	bneb	r0,#ctrls,50$		; not ctrl/s
20$:	call	bo$get			; get another
	bcs	20$			; none there
	bne	20$			; not ctrl/q
30$:	sec				; c=1 => no character
	return
40$:	call	bo$new			; ctrl/c abort
	br	bo$rsj			; restart

bo$get:	tstb	@r$mtks			; get one
	bpl	30$			; none there
	movb	@r$mtkb,r0		; get it
	bic	#^c177,r0		; clean it up
	cmp	r0,#ctrlq		; check for ctrl/q
50$:	clc				; got one
	return				;
	.dsabl	lsb			;
.sbttl	filename, rad50

;	Convert filename
;
;	r0 ->	filespec+fn.nam
;	r1 ->	ascii string - popped past
;	r2 =	default type
;
;	r3:r4	burnt

	.enabl	lsb
bo$fil:	psh	r0			; save r0
	mov	r2,6(r0)		; default type
	movr	#bo$pck,r4		;
10$:	mov	(sp),r0			; get back the name
	jsr	r5,(r4)			; get the first
	.byte	3,':			; look for a colon
	beq	10$			; ignore devices
	jsr	r5,(r4)			; get the next
	.byte	3,'.			; look for a dot
	bne	20$			; no type
	jsr	r5,(r4)			; get the type
	.byte	3,-1			; dont skip anything
20$:	pop	r0			; get back the pointer
	return
	.dsabl	lsb

;	Convert ascii to rad50
;
;	jsr	r5,bo$pck
;	.byte	cnt		number to convert - always 3
;	.byte	ter		terminating character to match
;
;	r0 ->	output word - popped
;	r1 ->	input string
;	r2:r3	destroyed
;
;	z=0	next char does not match
;	z=1	next char matched and skipped

	.enabl	lsb
bo$pck: psh	(r5)+			; get the counter and terminator
	clr	(r0)			; clear it first
10$:	mov	#39.,r3			; multiply by 40.
	mov	(r0),r2			; get the value
20$:	add	r2,(r0)			; once
	dec	r3			; count it
	bne	20$			; more

	movr	#b$orad,r3		; get the states list
30$:	movb	(r3)+,r2		; get the next offset
	beq	40$			; forget it
	bpl	30$			; skip range parameters
	cmpb	(r1),(r3)+		; check the range
	blo	30$			; its too low
	cmpb	(r1),(r3)+		; too high
	bhi	30$			;
	movb	(r1)+,r3		; accept the character
	add	r3,r2			; and compute the present value
	add	r2,(r0)			; add in the new value
40$:	decb	(sp)			; got more?
	bne	10$			; do another sign
	tst	(r0)+			; pop past the word
	swab	(sp)			; look at the terminator
	cmpb	(r1)+,(sp)+		; is this the terminator?
	beq	50$			; yes - z=1
	dec	r1			; no - z=0 - backup
50$:	rts	r5			;
b$orad:	.byte	-22,'0,'9,-100,'A,'Z,-140,'a,'z,-11,'$,'$,0
	.even
	.dsabl	lsb
.sbttl	stack rotate, move block

;	Rotate the stack 
;
;	BO$ROT handles stack rotates for EMTs with stack parameters.
;
;	r0	unchanged
;	r1:r2	burnt
;	r2	returns first of the stack
;	r3	burnt
;	r4:r5	unchanged
;
;	borot$	cnt lim
;
;	jsr	r3,bo$rot
;	.byte	cnt		number of words to rotate
;	.byte	lim		usually sp.bbs
;
;	stack	ret r0 r1 r2 r3 r4 r5 pc ps p1 p2 p3 bbs
;	borot$	3 sp.bbs
;	r2 = p1
;	stack	p2 p3 ret r0 r1 r2 r3 r4 r5 pc ps bbs
;
;	Call pushs r3 on the stack. This is used to rotate the top word.
;	Thus the offset to SP.BBS is really to the last parameter.

bo$rot:	movb	(r3)+,r2		; r2 is the count
10$:	movb	(r3),r1			; point to it
	add	sp,r1			; sp -> top of stack
	mov	(r1),(sp)		; rotate to the bottom
20$:	mov	-(r1),word(r1)		; move one up
	cmp	r1,sp			; moved them all?
	bne	20$			; no
	dec	r2			; got another
	bne	10$			; yes
	cmpb	(r3)+,(sp)+		; inc r3 and pop dummy
	pop	r2			; return top word in r2
	jmp	(r3)			; go back to them

;	Move block
;
;	jsr	r3,bo$mbl
;	.word	source
;	.word	destination
;	.word	count
;
;	r0	source
;	r1	destination
;	r2	count

bo$mbl:	mov	(r3)+,r0		;move block source
	mov	(r3)+,r1		;destination
bo$m01:	mov	(r3)+,r2		;count
10$:	mov	(r0)+,(r1)+		;move one
	bvs	20$			;memory error during startup
	sobw	r2,10$			;count it
	rts	r3			;
20$:	bofat$	xbu			;bus error
;???;	BOOT release ident string below
;???;	BOOT - 1024. byte buffer at end of image
.sbttl	bootstrap setup data

reloc$				; build relocation table.

;	RUST information area

b$rfre: brfre. == b$rims-.
limit$	b$rims			; don't overwrite boot signature area
asect$	b$rims			;
	b$oima:	.asciz "RUST.SAV" ;	- Executable ascii name
		.byte	0,0,0	;	- See GTLIN

;	RT-11/RUST information area

asect$	b$rtmv	0		;retver - RTEM version (rts$id)
asect$	b$rdvn	0		;b$devn - device name in rad50 with suffix
asect$	b$rdvs	0		;b$devs - device name without suffix
asect$	b$rdvu	<.rad50 "bot">	;b$devu - device unit bot=bootable, rte=>rtem
asect$	b$rfn0	<.rad50 "boo">	;b$fnam - filename 0 (e.g. /RT1/
asect$	b$rfn1	<.rad50 "t  ">	;	- filename 1 (e.g. /1FB/)
asect$	b$rrea	0		;b$read - read routine start address
asect$	b$rhto	0		;syhtop - system handler top address (unused)
asect$	b$rdup	0		;dupflg - copied from @#0 - 0 if from DUP
asect$	b$rrms	2048.		;$rmsiz - v3/v5 monitor size in bytes
				;bstrng	- v3/v5 boot string - 28. bytes maximum
asect$	b$rnam	<.asciz "BOOT V2.4"> ;  - BOOT ident string
b$oprm:	.ascii <cr>"boot> "<200>;	 boot prompt
				;	- some free bytes here
asect$	b$rimg			;	- BOOT image
	.if ne rxm$c
	b$oimg:	.rad50	/SY RUSTX SAV/ ;-
	.iff
	b$oimg:	.rad50	/SY RUST  SAV/ ;-
	.endc
asect$	b$rrst	<.rad50 "RST">	;	- RUST ident (not standard RT-11)
;asect	b$rdvs	0		;b$devs - device suffix in rad50
	.if ne rxm$c
asect$	b$rsfx	<.rad50	"  P">	;suffx	- v5 rad50 handler suffix
	.iff
asect$	b$rsfx	<.rad50	"  V">	;suffx	- v5 rad50 handler suffix
	.endc
asect$	b$rsyg	;sgmmu$		;syop	- v5 sysgen options (probably v4 too)
				;	- v3 swap file size (zero)

;	This area follows the 1024. word boot in memory.
;	It is constructed by the RT-11/RUST/V11 boot loaders.
;	The area is absent when hard booting (except under V11)

asect$	b$rhot	0		;btime  - time booted (if from DUP)
asect$	b$rlot	0		;	- low order time
asect$	b$rdat	0		;bdate  - date booted
	.rad50	/ERA/		;	- extended date signature
asect$	b$rera	0		;	- extended date

b$otop:				; end of boot area

.if eq stk$c
	.if ne stk$c
	c$ustk = .+2000
	.iff
	.blkb	2000		; cusp stack
c$ustk:
	.endc
.endc

.end

end macro
file	BOOT - RUST boot utility
include	rid:rider
include rid:bxdef
include rid:ctdef
include	rid:dcdef
include rid:fidef
include rid:fsdef
include rid:imdef
include rid:medef
include rid:mxdef
include rid:osdef
include	rid:rtboo
include	rid:rtcla
include rid:rtrea
include rid:rxdef
include rid:stdef
boo$c := 1
include	rid:rtmon

;&&&;	Include secondary boot in RUST/RUSTX
;&&&;	SET/RUST/RUSTX

data	control block

  type	cuTctl
  is	Pdcl : * dcTdcl
	Pboo : * rtTmon		; boot image
	Aboo : [mxSPC] char	; boot spec
	Hboo : * FILE 		; boot file
	Vblk : int		; file block
	Icla : rtTcla		; boot file class
				;
	Vtyp : int		; cuSLF/cuDEV/cuFIL
	Vsys : int		; cuRTA/cuRST
				;
	Q50h : int		; /50_hertz
	Q60h : int		; /60_hertz
	Qfor : int		; /foreign
	Aimg : [mxSPC] char	; /image=spec
	Qnim : int		; /noimage
	Qqui : int		; /quiet
	Qnqu : int		; /noquiet
	Qrun : int		; /run
	Qnrn : int		; /norun
	Qrsj : int		; /rust
	Qrxm : int		; /rustx
	Qslf : int		; /self
	Asuf : [4] char		; /suffix=char 
	Qnsf : int		; /nosuffix
  end
	ctl : cuTctl = {0}

 	cuDEV  := 0		; device - Vtyp
	cuFIL  := 1		; file
	cuSLF  := 2		; self
				;
	cuRTA  := 1		; RT-11  - Vsys
	cuRST  := 2		; RUST

	boSPC  := 12		; spec length
	boIMG  := 8		; image name length
	bo50H  := 040		; 50 hertz (60 is the complement)
	boRST  := 071614	; .rad50 /rst/ signature
	boSY   := 075250	; .rad50 /sy /

	cm_boo : dcTfun		; boot file
	cm_set : dcTfun		; SET
	cm_sho : dcTfun		; SHOW

	cu_get : ()		; get boot from file
	cu_put : ()		; put boot to file


data	cuAdcl - DCL processing

  init	cuAhlp : [] * char
  is   "BOOT - RUST generic boot BOOT.SYS V4.1"
       ""
       "BOOT dev:|file		Boot device or file"
       "EXIT			Return to system"
       "HELP			Display this help frame"
       "SHOW SELF|dev:|file	Display bootstrap setup"
       "SET  SELF|dev:|file	Configure bootstrap"
       " /[NO]IMAGE=spec	Set (clear) bootstrap image filespec"
       " /[NO]QUIET 	  	Enable (disable) startup identification"
       " /[NO]RUN 	  	Do (don't) run the monitor image"
       " /[NO]SUFFIX=char	Set (clear) default driver suffix"
       " /50HERTZ|60HERTZ  	Set bootstrap for 50 or 60 hertz clock"
       " /RUST			Set /IMAGE=RUST.SAV/SUFFIX=V"
       " /RUSTX			Set /IMAGE=RUSTX.SAV/SUFFIX=P"
	<>
  end

  init	cuAdcl : [] dcTitm
 ;level symbol		task	P1	 V1 type|flags
  is 1,	"EX*IT",	dc_exi, <>, 	 0, dcEOL_
     1,	"HE*LP",	dc_hlp, cuAhlp,	 0, dcEOL_

     1,	"BO*OT",	dc_act, <>,  	 0, dcNST_
      2,  <>,		dc_fld, ctl.Aboo,16,dcSPC
      2,  <>,		cm_boo, <>, 	 0, dcEOL_
      2, "/FO*REIGN",	dc_set,&ctl.Qfor,1, 0
;     2, "/SE*LF",	dc_set,&ctl.Qslf,1, 0
     1,	"SH*OW",	dc_act, <>,	 0, dcNST_
      2,   <>,		dc_fld, ctl.Aboo,16,dcSPC
      2,   <>,		cm_sho, <>,	 0, dcEOL_
     1,	"SE*T",		dc_act, <>,	 0, dcNST_
      2,   <>,		dc_fld, ctl.Aboo,16,dcSPC
      2,   <>,		cm_set, <>,	 0, dcEOL_
      2,  "/50*HERTZ",	dc_set,&ctl.Q50h,1, 0
      2,  "/60*HERTZ",	dc_set,&ctl.Q60h,1, 0
      2,  "/IM*AGE",	dc_fld, ctl.Aimg,32,dcSPC|dcASS_
      2,  "/NO*IMAGE",	dc_set,&ctl.Qnim,1, 0
      2,  "/QU*IET",	dc_set,&ctl.Qqui,1, 0
      2,  "/NOQU*IET",	dc_set,&ctl.Qnqu,1, 0
      2,  "/RU*N",	dc_set,&ctl.Qrun,1, 0
      2,  "/NOR*UN",	dc_set,&ctl.Qnrn,1, 0
      2,  "/RUST",	dc_set,&ctl.Qrsj,1, 0
      2,  "/RUSTX",	dc_set,&ctl.Qrxm,1, 0
      2,  "/SU*FFIX",	dc_fld, ctl.Asuf,4, dcSTR|dcASS_
      2,  "/NOSU*FFIX",	dc_set,&ctl.Qnsf,1, 0
     0,	 <>,		<>,	<>,	 0, 0
  end


code	bootstrap manager

  func	start
  is	dcl : * dcTdcl
	ops : rtTops 

	im_ini ("BOOT")			;
	cc_stk (2048)			; get a bigger stack
	ctl.Pboo = me_alc (2048)	; boot buffer
					;
;	ctl.Vboo = rt_ops(&ops) eq osRBT; activated by RUST/BT
;	if ctl.Vboo			;
;	   PUT("Shell\n")		; acts as boot shell
;	end				;
					;
	ctl.Pboo = me_alc (2048)	; boot buffer
					;
	dcl = ctl.Pdcl = dc_alc ()	;
	dcl->Venv = dcCLI_|dcCLS_	;
	dc_eng (dcl, cuAdcl, "BOOT> ") 	; dcl dispatches commands
  end


code	cm_set - configure boot

;	set
;	set dev:[file] 
;	set self

 func	cm_set
	dcl : * dcTdcl
  is	boo : * rtTmon = ctl.Pboo
	suf : * char = ctl.Asuf
	spc : [mxSPC] char
	nam : [mxSPC] char
	img : [4] word
	cas : int = cuDEV		; assume device

	fine if !cu_get ()		; get the image 
	if ctl.Vsys ne cuRST
	.. fail im_rep ("E-Not a RUST bootstrap image [%s]", ctl.Aboo)
	cu_def ()			; setup defaults

      begin
	boo->Vcfg |= bo50H if ctl.Q50h
	boo->Vcfg &= ~bo50H if ctl.Q60h
	boo->Vqui = 1 if ctl.Qqui
	boo->Vqui = 0 if ctl.Qnqu
	boo->Vrun = 1 if ctl.Qrun
	boo->Vrun = 0 if ctl.Qnrn
	boo->Aimg[0] = 0 if ctl.Qnim
	boo->Vsfx = 0 if ctl.Qnsf

	if *suf
	   st_upr (suf)
	   if st_len (suf) ne 1
	   || !ct_alp (*suf)
	   .. quit im_rep ("E-Invalid suffix [%s]", suf)
	.. boo->Vsfx = *suf - '@'

	if ctl.Aimg[0]
	   me_clr (spc, mxSPC)
	   fi_def (ctl.Aimg, ".SYS", spc)
	   st_upr (spc)
	   fs_ext (spc, nam, fsNAM_|fsTYP_)
	   me_cop (nam, boo->Aims, boSPC)

	   rx_scn (spc, img)
	   img[0] = boSY
	   me_cop (img, boo->Aimg, boIMG)
	end
	fine cu_put ()
      end block
	fi_prg (ctl.Hboo)
  end

code	cu_def - apply /rust[x] defaults

  func	cu_def
  is	if ctl.Qrsj
	   st_cop ("RUST", ctl.Aimg)
	   st_cop ("V", ctl.Asuf)
	elif ctl.Qrxm
	   st_cop ("RUSTX", ctl.Aimg)
	   st_cop ("P", ctl.Asuf)
	else
	   exit
 	end
	ctl.Qnqu = 1
	ctl.Qrun = 1
  end


code	cm_sho - show command

  func	cm_sho
	dcl : * dcTdcl~
  is	boo : * rtTmon = ctl.Pboo
	nam : * char = boo->Anam
	img : * char = boo->Aims
	suf : [4] char
	ops : [mxSPC] char

	fine if !cu_get ()
	fi_prg (ctl.Hboo)

	if ctl.Vsys eq cuRTA
	   (*nam eq 015) ? nam+2 ?? nam
	   PUT("System: %s\n", that)

	   rx_fmt ("%r%r", boo->Aops, ops) 
 	   PUT("Image:  %s.SYS\n", ops)
	else
	   PUT("Proxy:  %s\n", nam)

	   *img ? img ?? "(none)"
 	   PUT("Image:  %s\n", that)
	end

	boo->Vsfx ? boo->Vsfx + '@' ?? 0
	PUT("Suffix: \"%c\"\n", that)

	(boo->Vcfg & bo50H) ? 50 ?? 60
	PUT("Clock:  %d Hertz\n", that)

	cu_opt (boo->Vsgb)

	fine if ctl.Vsys eq cuRTA

	PUT("Start:  ")
	PUT("No") if !boo->Vqui
	PUT("Quiet ")
	PUT("No") if !boo->Vrun
	PUT("Run\n")

	fine
  end


code	cu_opt - display sysgen options

	sgERL$ := 01
	sgMMG$ := 02
	sgTIM$ := 04
	sgRTM$ := 010
	sgFPU$ := 0400
	sgMPT$ := 01000
	sgSJT$ := 02000
	sgMTT$ := 020000
	sgSJB$ := 040000
	sgTSX$ := 0100000

	TST(x) := (opt & x)

  func	cu_opt
	opt : int
  is	fine if !opt
	PUT("Sysgen: ")
	PUT("ERLG ")  if TST(sgERL$)
	PUT("MMGT ")  if TST(sgMMG$)
	PUT("TIMIT ") if TST(sgTIM$)
	PUT("RTEM ")  if TST(sgRTM$)
	PUT("FPU ")   if TST(sgFPU$)
	PUT("MPTY ")  if TST(sgMPT$)
	PUT("TIMER ") if TST(sgSJT$)
	PUT("MTTY ")  if TST(sgMTT$)
	PUT("STASK ") if TST(sgSJB$)
	PUT("TSX ")   if TST(sgTSX$)
	PUT("\n")
  end


code	cu_get - get boot image

	cuSUB_ := (fcDIR_|fcDSK_|fcSUB_); \subdisk\
	cuCON_ := (fcCON_|fcFIL_|fcDSK_); file.DSK

  func	cu_get
  is	spc : * char = ctl.Aboo
	cla : * rtTcla~ = &ctl.Icla
	boo : * rtTmon~ = ctl.Pboo
	fil : * FILE

	st_low (spc)		
	if !*spc || st_sam (spc, "self")		;
	   fil = ctl.Hboo = fi_img ()	; image channel
	   ctl.Vblk = 1		;
	   ctl.Vtyp = cuSLF		; is self
	else
	   fi_def (spc, "sy:.sys", spc)
	   fil = ctl.Hboo = fi_opn (spc, "rb", "")	
	   pass fail

	   rt_cla (fil, cla)
	   if cla->Vflg eq cuSUB_
	   || cla->Vflg eq cuCON_
	   || cla->Vflg & fcDEV_
	      ctl.Vblk = 2
	      ctl.Vtyp = cuDEV
	   else
	      ctl.Vblk = 1
	   .. ctl.Vtyp = cuFIL
	end

	rt_rea (fil, ctl.Vblk, boo, 1024, rtWAI)
	fail im_rep ("E-Error reading boot file [%s]", ctl.Aboo) if fail

	if boo->Amon[0] eq 012737	; mov #,@#100
	&& boo->Amon[2] eq 0100		; mov #x,v$eclk
	   ctl.Vsys = cuRTA		; RT-11
					;
	elif boo->Amon[0] eq 0240	; nop
	&& boo->Amon[1] eq 012767	; mov #x,v$eclk
	&& boo->Vrst eq boRST		; .rad50 /rst/
	   ctl.Vsys = cuRST		; RUST
	else
	.. fail im_rep ("E-Not a bootstrap image [%s]", ctl.Aboo)
	fine
  end


code	cu_put - write boot

  func	cu_put
  is	rt_wri (ctl.Hboo, ctl.Vblk, ctl.Pboo, 1024, rtWAI)
	pass fine
	fail im_rep ("E-Error writing boot file [%s]", ctl.Aboo)
  end


code	cm_boo - boot device or file

;	BOOT dev:/FOREIGN/NOQUERY/WAIT
;
;???	BOOT spec/DRIVER=dd
;???	Check SWAP.SYS (VUBOO)
;???	Check BOOT.SYS
;???	/NOQUERY
;???	/WAIT

  func	cm_boo
  is	spc : * char = ctl.Aboo
	spc = <> if !*spc
	rs_exi () if rs_det ()		; RTX 
	rt_boo (spc, ctl.Qfor, <>)	;
  end
