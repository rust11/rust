! KMS:ALL.COM - Compile DCL.SAV
!
set error error
delete kmb:*.*/noquery
!
library/macro kmb:dclmac kms:dclmac
!
r macro
kmb:kg=kms:kp,kg!			globals
kmb:kmon=kms:kp,kmon!			kmon, search, errors
kmb:main=kms:kp,dcs:main!	DCS	kmon, search, errors
kmb:host=kms:kp,host!			host/kernel adaptor
kmb:vax=kms:kp,vax!			vax connection
kmb:conver=kms:kp,DCS:CONVER!*	DCS	common conversion routines
kmb:symbol=kms:kp,symbol!		kmon symbol table
kmb:value=kms:kp,DCS:VALUE! 	DCS	parameter and end of line handling
kmb:entry=DCS:KP,ENTRY! 	DCS	variables and initialization
kmb:text=DCS:KP,TEXT!		DCS	inline Editor
kmb:factor=DCS:KP,FACTOR!	DCS	dcls factorize support
kmb:rights=kms:kp,rights!		check system rights
kmb:build=DCS:KP,BUILD!		DCS	build command
kmb:goto=kms:rsj,DCS:GOTO!	DCS	if, then, goto
kmb:hook=kms:kp,hook
kmb:comman=kms:kp,DCS:COMMAN!*	DCS	command builder
kmb:atfile=kms:kp,atfile!		@, call, start-up
kmb:displa=DCS:KP,DISPLA!	DCS	display, debug, if
kmb:debug=kms:kp,debug! 		debug interpreter
kmb:overla=kms:kp,overla!		dummy to clear overlay id
kmb:copy=DCS:KP,GETCHR,COPY!	DCS	copy, append
kmb:rename=DCS:KP,GETCHR,RENAME!DCS	rename, protect, unprotect
kmb:delete=kms:kp,delete!	DCS	delete
kmb:dir=DCS:KP,DIR!		DCS	dir
kmb:print=kms:kp,print! 	DCS	print, type, press
kmb:squeez=kms:rsj,DCS:SQUEEZ!	DCS	squeeze, init
kmb:dump=DCS:KP,DUMP,FILES!	DCS	dump, differences
kmb:macro=DCS:KP,MACRO,FILES!	DCS	macro
kmb:fortra=DCS:FORTRA,FILES! 	DCS	fortran
kmb:dibol=DCS:KP,DIBOL,FILES!	DCS	dibol
kmb:compil=DCS:KP,COMPIL,FILES! DCS 	compile
kmb:execut=DCS:KP,EXECUT,FILES! DCS 	execute
kmb:link=DCS:KP,LINK,FILES!	DCS	link
kmb:librar=DCS:KP,LIBRAR!	DCS	librarian
kmb:mount=kms:kp,device,unpack,number,mount2!		mount, dismount
kmb:assign=kms:kp,device,trans,unpack,assign!		assign, deassign
kmb:show=kms:kp,ses:mpl/M,kms:device,trans,unpack,show!show
kmb:shodev=kms:kp,ses:mpl/M,kms:device,unpack,shodev!	show devices
kmb:pool=kms:kp,ses:mpl/M,kms:device,unpack,pool!	pool
kmb:load=kms:kp,kms:device,kms:load!	load,install,remove
kmb:set=ses:mpl/M,kms:kp,set!		set, show
kmb:other=kms:kp,other! 		all the other commands
kmb:users=kms:kp,DCS:USERS!*	DCS	user-defined command
kmb:meta=kms:kp,DCS:META!*	DCS	define/delete user commands
kmb:help=kms:kp,DCS:HELP!	DCS	help
kmb:clock=kms:kp,clock!!		show date/time
kmb:day=kms:kp,day!			get date/time, wait
kmb:send=kms:kp,send!			send, tell
kmb:gt=kms:kp,gt!			gt
kmb:edit=DCS:KP,EDIT!	 	DCS	edit
kmb:patch=kms:kp,patch! 		patch
kmb:boot=kms:kp,boot!			boot
kmb:usr=kms:kp,cc,usr,usf!		jobspace usr		
!!!!:news=kms:kp,news!			show news, date and time
!!!!:decode=kms:kp,decode!		license check
!!!!:reboot=kms:kp,reboot!		boot
!!!!:kernel=kms:kp,ses:mpl/M,kms:device,kernel!		install/kernel
!!!!:spool=kms:kp,unpack,spool!		set spool, start, stop
!!!!:login=kms:kp,login! 		login, logout, authorize
!!!!:login1=ses:mpl/M,kms:kp,kms:login1!read uaf
!!!!:login2=ses:mpl/M,kms:kp,kms:login2!read users.sys
!!!!:reset=kms:kp,reset! 		reset
^C
@@kms:imgdat
!
r link
kmb:dcl,kmb:dcl/n=kmb:kg,kmon,host,vax,value,entry//
kmb:conver,text,symbol,comman,users,imgdat
!kmb:goto!
kmb:overla!				this must be the last root file
kmb:factor/O:1!				this is tiny
kmb:rights/O:1!				this is also small
kmb:build/O:1!				so is this
kmb:other/O:2!				this is frequent
kmb:atfile/O:3!				this is the rest
kmb:goto/O:3
kmb:copy/O:3
kmb:dir/O:3
kmb:delete,rename,print/O:3
kmb:squeez,dump/O:3
kmb:macro/O:3
kmb:fortra/O:3
kmb:dibol/O:3
kmb:compil/O:3
kmb:execut/O:3
kmb:link/O:3
kmb:librar/O:3
kmb:set/O:3
kmb:mount/O:3
kmb:assign/O:3
kmb:show/O:3
kmb:shodev/O:3
kmb:pool/O:3
kmb:load/O:3
!!!:kernel/O:3
!!!:news,clock,day/O:3
kmb:clock,day/O:3
kmb:edit,help,patch/O:3
kmb:send,displa/O:3
kmb:meta,gt/O:3
!!!:spool/O:3
!!!:login,reset,login1,login2,lib:remlib/O:3
kmb:boot/O:3
!!!:reboot/O:3
kmb:usr/O:3
!!!:decode/O:4
//
^C
