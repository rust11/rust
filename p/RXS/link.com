set tt quiet
!	SPS:LINK.COM - Link RUST/XM
!
!	Par7	I/O page
!	Par6	Drivers
!	Par5	Pool
!	Par4	Pool
!	Par3	Pool (Debug)
!	Par2	PHD  (Boot)
!	Par1	REQ SYS UTL (Env) Realtime
!	Par0	KER
r link
rxb:rustx,rxb:rustx,rxb:rustx/N/Q=//
!cub:bootm
rxb:stbdat
!		    KER section
rxb:kda!	kedat	kernel data
rxb:kii!	keimg	image info
rxb:kco!	kecon	kernel console
rxb:kqu!	keque	queues
rxb:kpo!	kepoo	pool
rxb:kev!	keevt	events
rxb:kve!	kevec	vectors
rxb:kin!	keint	interrupts/scheduler/asts
rxb:kte!	keter	terminal
rxb:kti!	ketim	timer
!		    MON routines
rxb:mna!     G	rtnam	logical names	
rxb:mio!     G	iodon	I/O done
rxb:mix!     G	ioutl	I/O utilities
rxb:mch!	rtchn	RT-11 channel mirror
rxb:mut!     G	mnutl	utilities
rxb:eve!     G	keeve	EVE
rxb:ktv!     G  kecal	Various call interfaces
rxb:kdh!	kedhv	DHV terminal support
rxb:kdv!	kecal	Driver interfaces
rxb:kerfre!				
rxb:kersec!	    KER roundup
rxb:reqfil/O:1!	    REQ roundup
!
rxb:reqsec/O:1!	    REQ overlay
rxb:mep!	rtemt	EMT processor
rxb:rmi!	rtmix	RT-11 mixed requests
rxb:rch!	rtchn	RT-11 channels
rxb:rio!	rtiop	RT-11 I/O
rxb:rte!	rtter	RT-11 terminal
rxb:red!     G	teedt	Terminal command editor
rxb:rcf!	rtcom	RT-11 command files
rxb:rim!	rtimg	RT-11 images
rxb:rcl!     G	tecmd	Terminal kernel commands
rxb:reqend
!
rxb:acpsec/O:1
rxb:acp!	acdis	RT-11 ACP front-end dispatch
rxb:rac!   	rtacp	RT-11 request preprocessing
rxb:rax!     G	aceng	file system engine 		
rxb:rsp!     G	acspo	spooler specials
rxb:rt11a!	acrta	RT-11 file system
rxb:rt11n!	acrtn	null file system
rxb:rt11s!	acrts	RT-11 stranger file system
rxb:rsi!	rtcsi	RT-11 CSI 
rxb:mer!	rterr	errors
rxb:acpend
!
rxb:syssec/O:1!	    SYS overlay (native)
rxb:sys!	ntsys	system process front-end & dispatcher
rxb:sda!	ntdat	data
rxb:smi!	rtmix	mixed services
rxb:sut!	nautl	name utilities
rxb:syx!	
rxb:sdp!    G	prdel	delete process
rxb:scp!    G ->prcre	create process
rxb:sbp!    G	prbld	build process structures
rxb:spr!    G	prcre	create process
rxb:sph!    G	prhdr	create process header
rxb:phd!    G	prtem	process header template
rxb:sysend
!
rxb:utlsec/O:1!	    UTL overlay
rxb:utl!	utdis	UTL request dispatcher
rxb:rti!	rttim	Timer requests
rxb:dtt!	dvttp	TT:
rxb:dvm!	dvvmp	VM:
rxb:dnl!	dvnlp	NL:
rxb:utx!	utnam	utilities
rxb:upo!	utpoo	pool
rxb:sjo!	rtjob	gtjb
rxb:udr!	dvutl	drivers
rxb:rsh!	utshr	SHARE-11 compatibility
rxb:rkm!	utkmn	KMON compatibility
rxb:ucl!	utcli	CLI utilities
rxb:urt!	rtrea	realtime requests
rxb:xev!	keevtz	KEEVT KEV external
rxb:xdh!	kedhvz	KEDHV KDH external
rxb:sna!	ntnam	logical names
rxb:rsf!	rtspf	special functions
!
rxb:envsec/O:1!	    ENV overlay
rxb:env!	enroo	Environment check
rxb:ere!	enrep	Report
rxb:ede!	endev	Devices
rxb:etx!	enopt	Text output
rxb:envend
!
rxb:boofil/O:2!	    BOO roundup
rxb:boosec/O:2!	    BOO overlay
rxb:boo!	boroo	boot SHAREplus
rxb:bpr!	boprc	build process?
rxb:bde!	bodev	build devices
rxb:bvm!	bovmd	build vm directory
rxb:bpo!	bopoo	build pool
rxb:bke!	boker	build kernel
rxb:bda!	bodat	build data
rxb:esb!	boshp	system build
rxb:booend
!
rxb:poosec/O:3!	    POO section
!rxb:kdv!		Kernel development - patchs
rxb:kdb!	kedbg	kernel debugger - must be last - may be overwritten
//
kerbas:1400!		KER starts at 1400
kersec:17776!		REQ at par1-2

!Blank line above is required for LINK
^C
!