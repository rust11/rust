! RUST.COM - Build RTB:RUST.SAV and RTB:RTX.TSK system images
!
@@rts:rtmac!		RUST/SJ macro library
!@@rts:rtinf		RUST image info
!@@drs:ldv!		rebuild LDV.SYS for RTX MOUNT/DISMOUNT
!@@drs:slv!		rebuild SLV.SYS for RTX WSIG patch
!!rts:rtstb!		RTX stub. Needs RUST/XM RSX feature to assemble.
!
goto 'P1'
r macro
!rtb:rtrtx=rts:rtrtx!	RTX tertiary boot
!rtb:rtrsx=rts:rtrsx!	RTX RSX API
!rtb:rtfap=rts:rtfap!	RTX FAP F11A front-end
!rtb:rtfxv=rts:rtfxv!	RTX resident FX:
!rtb:rtldv=rts:rtldv!	RTX resident LD:
!rtb:rtnfw=rts:rtnfw!	RTX resident NF:
!
!rtb:rtboo=rts:rtboo!	RUST/SJ tertiary boot
!rtb:rtini=rts:rtini!	RUST.INI/RTX.INI interpretation
!
!rtb:rtmon=rts:rtmon!	monitor data/routines
!rtb:rtusr=rts:rtusr!	device, I/O, ACP preprocessing
!rtb:rtacp=rts:rtacp!	RT11A directory operations
!rtb:rtemt=rts:rtemt!	EMT dispatcher
!rtb:rtser=rts:rtser!	system services
!rtb:rttim=rts:rttim!	timer
!rtb:rtter=rts:rtter!	terminal
rtb:rtimg=rts:rtimg!	images, kmon, exit path
!rtb:rtsys=rts:rtsys!	system routines
!rtb:rtcsi=rts:rtcsi!	CSI interpreter
!rtb:rterr=rts:rterr!	errors/traps
!rtb:rtdbg=rts:rtdbg!	debug (optional)
!rtb:rtfet=rts:rtfet!	fetch space
^C
!
!  RUST
!
link:
display "RUST1"
r link
rtb:rust.sav,rustr=/r/n//
rtb:rtinf!	image info
rtb:rtboo!	boot
rtb:rtmon!	monitor data/routines
rtb:rtini!	.ini file
rtb:rtusr!	usr
rtb:rtacp!	rt11x
rtb:rtsys!	system routines
rtb:rtemt!	emt dispatcher
rtb:rtser!	system services
rtb:rttim!	timer
rtb:rtter!	terminal
rtb:rtimg!	images and commands
rtb:rtcsi!	command string interpreter
rtb:rterr!	errors/traps
!rtb:rtdbg!	debugger
rtb:rtfet!	fetch space for boot
//
^C
!	Link again for debug absolute addresses
!
rust2:
r link
rtb:rust.sys,rust=/h:160000/n//
rtb:rtinf!	image info
rtb:rtboo!	boot
rtb:rtmon!	monitor data/routines
rtb:rtini!	.ini file
rtb:rtusr!	usr
rtb:rtacp!	rt11x
rtb:rtsys!	system routines
rtb:rtemt!	emt dispatcher
rtb:rtser!	system services
rtb:rttim!	timer
rtb:rtter!	terminal
rtb:rtimg!	images and commands
rtb:rtcsi!	command string interpreter
rtb:rterr!	errors/traps
!rtb:rtdbg!	debugger
rtb:rtfet!	fetch space for boot
//
^C
!
! RTX.SAV (for RTX.TSK)
!
r link
rtb:rtx.sav,rtx=/h:177100/n//!		RSX
!rtb:rtx.sav,rtx=/h:160000/n//!		RUST/XM
rtb:rtinf!	image info
rtb:rtrtx!	RTX boot
rtb:rtrsx!	RTX boot
rtb:rtnfw!	resident RTX nf:
rtb:rtfxv!	resident RTX fx:
rtb:rtldv!	resident RTX ld:
rtb:rtmon!	monitor  data/routines
rtb:rtini!	.ini file
rtb:rtusr!	usr
rtb:rtacp!	RT11X
rtb:rtfap!	F11A front-end
rtb:rtsys!	system routines
rtb:rtemt!	emt dispatcher
rtb:rtser!	system services
rtb:rttim!	timer
rtb:rtter!	terminal
rtb:rtimg!	images and commands
rtb:rtcsi!	command string interpreter
rtb:rterr!	errors/traps
!rtb:rtdbg!	debugger
rtb:rtfet!	fetch space for boot
//
^C
!
!	merge RTX.SAV and RTSTB.TSK to make RTX.TSK
!
rtb:rttsk!	merge
copy/nolog rtb:rtx.tsk hd1:
end:
