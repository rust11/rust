lex
clu
!clp	clf	vcl
!req
!	img
!
!namdef
!xabdef
!stm
!title	evs:eve.com
!
!	Build EVE
!
eve := _build evs:^.mar
asse*mble := vax macro
!
!	Links
!
!eve	lib!	macro library
!eve	eve!	EVE system image
!
!	Exec modules
!
eve	sys!	system service vector
eve	ptr!	pointers
eve	ker!nsd	kernel data
eve	exc!	exception dispatcher
eve	dyn!	dynamic memory
!eve	mmg!	memory management
!eve	pag!	page fault
!!eve	sch!	scheduler
!eve	prc!	process control
!eve	cre!	process creation
eve	exi!	image exit
!	del!	process deletion
!
eve	ser!	system service dispatcher
eve	tra!	system service trace
eve	cvt!	common conversions
!eve	rms!	rms dispatcher
!
eve	fac!	file access system
eve	rap!	record buffer operations
eve	fcb!	file control blocks
!!eve	atr!	determine file attributes - crap
eve	dev!	device related routines
eve	qio!	qio & qiow
eve	ioq!	ioq subsystem
eve	dsk!	disk i/o
eve	ter!	terminal i/o
eve	vac!	vamp access
eve	vwb!	vamp wb-11
!
!	System calls
!
!eve	log!	logical names
!!eve	efn!	event flags
eve	chn!	channel services
!!eve	dev!	device services
!eve	reg!	expand/contract region
!!eve	mmg!	mmg services
!!eve	tim!	time operations
eve	fao!	fao operations
eve	msg!	message services
!eve	crp!	create process
eve	img!	image activate
!
!	File and record
!
!eve	acp!	acp routines
eve	rms!	rms dispatch
eve	fab!	fab operations
eve	rab!	rab operations
eve	nam!	nam operations
!!	xab!	xab operations
!!eve	fib!	fib operations
!eve	ipt!	stream input
eve	opt!	stream output
!
!
!	Secondary boot
!
!!eve	evb!	EVE primary boot - reserved
!!eve	acb!	Boot ACP
!!eve	vxb!	VX: boot
!!eve	evs!	EVE secondary boot
eve	gen!	Generate components
eve	ini!	test stuff
!eve	sol!	Build EVEsolo
eve	con!	Console terminal
eve	bug!	Debugger
eve	rev!	Reverse compile
eve	top!	Top module
!
!eve	scb!	system control block
!eve	isp!	interrupt stack
!eve	shd!	system process header
!
!eve	buf!	primary buffer space
!eve	bus!	primary bus space
!
!	prot.mar	Prototype code
         