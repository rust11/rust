! See ALL.COM
! Need to prune this list
!
!	DRS:UPDATE.COM - Update all drivers
!
mac$ := check$ ^1 drs:^1.mac drb:^1.obj @@drs:^1
mlb$ := check$ ^1 drs:^1.mac drb:^1.mlb @@drs:^1
@ops:updatx 'p1' 'p2'
!
! SJ only
!
LOOP$:
mlb$ drvmac!	driver macro library
mac$ alv!	alias
mac$ cpv!	ctrl-p
mac$ ctv!	ctrl-t
mac$ cyv!	ctrl-y
mac$ dbv!	db: and bg: debuggers - BGV broken
mac$ eiv!	eis emulator
mac$ flv!	flak
mac$ gtv!	E11 test, console/reset hooks
mac$ nlv!	null
mac$ opv!	output log
mac$ pmv!	performance monitor
mac$ slv!	single-line editor
mac$ tkv!	terminal clock
mac$ trv!	trace
mac$ ttv!	terminal
mac$ txv!	stx/etx
mac$ vmv!	virtual memory
!ac$ xmv!	limbo	
mac$ nfw!	NF: Windows special
!
! SJ/XM
!
mac$ ddp!	TU58
mac$ dlp!	RL01/RL02	
mac$ dup!	MSCP
mac$ dyp!	RX01/RX02
!ac$ epp!	Epson printer
mac$ fpp!	FPU driver (by Paul Lustgraaf)
mac$ hdp!	Hypodisk
mac$ ldv!	Logical disk
mac$ lpp!	Line printer (LP: and LS:)
mac$ mop!	Mouse
mac$ pcp! 	Papertape
mac$ rkp!	RK05
mac$ vv!	Virtual Volumes
!
! XM only
!
mac$ ibm!	Lab	
mac$ mqm!	Message queue
!ac$ vu!	Virtual Units ??? lots of errors
!
! Dummy drivers
!
mac$ duz!	
mac$ lpz!	
mac$ lsz!	
mac$ mtz!	
end$:
end$
