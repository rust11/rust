!	RTS:UPDATE.COM - Update RTB:RUST.SAV and RTB:RTX.TSK
!
!	@RTS:UPDATE [ALL|LIST|LISTALL|LINK]
!
!mlb$ := check$ ^1 rts:^1.mac rtb:^1.mlb @@rts:^1.mac
!mac$ := check$ ^1 rts:^1.mac rtb:^1.obj macro rts:^1/obj:rtb:^1
!drs$ := check$ ^1 drs:^1.mac drb:^1.obj @@drs:^1.mac
!cop$ := check$ ^1 ^1 ^2 copy/nolog ^1 ^2
!!
!@OPS:UPDATX 'P1' 'P2'
!!
!LOOP$:
!
!!rts:rtstb!	RTX stub. Needs RUST/XM RSX feature to assemble.
@ops:up rts rtb RUST.SAV 'p1' 'p2'
!
mlb$ rtmac!	RUST/SJ macro library
mac$ rtinf!	RUST image info
drs$ ldv!	rebuild LDV.SYS for RTX MOUNT/DISMOUNT
drs$ slv!	rebuild SLV.SYS for RTX WSIG patch
!
mac$ rtrtx!	RTX tertiary boot
mac$ rtrsx!	RTX RSX API
mac$ rtfap!	RTX FAP F11A front-end
mac$ rtfxv!	RTX resident FX:
mac$ rtldv!	RTX resident LD:
mac$ rtnfw!	RTX resident NF:
!
mac$ rtboo!	RUST/SJ tertiary boot
mac$ rtini!	RUST.INI/RTX.INI interpretation
!
mac$ rtmon!	monitor data/routines
mac$ rtusr!	device, I/O, ACP preprocessing
mac$ rtacp!	RT11A directory operations
mac$ rtemt!	EMT dispatcher
mac$ rtser!	system services
mac$ rttim!	timer
mac$ rtter!	terminal
mac$ rtimg!	images, kmon, exit path
mac$ rtsys!	system routines
mac$ rtcsi!	CSI interpreter
mac$ rterr!	errors/traps
mac$ rtdbg!	debug (optional)
mac$ rtfet!	fetch space
!
mrg$
!
!  RUST
!
log$ RUST.SAV
load op
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
unload op
sy:morph rts:elide.txt sy:oplog.txt tt:
!
!	Link again for debug absolute addresses
!
rust2:
load op
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
unload op
sy:morph rts:elide.txt sy:oplog.txt tt:
!
! RTX.SAV (for RTX.TSK)
!
log$ RTX.TSK
load op
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
!tb:rtdbg!	debugger (hasn't been used for decades)
rtb:rtfet!	fetch space for boot
//
^C
unload op
sy:morph rts:elide.txt sy:oplog.txt tt:
!
!	merge RTX.SAV and RTSTB.TSK to make RTX.TSK
!
rtb:rttsk!	merge
copy/nolog rtb:rtx.tsk sy:
!
end$:
