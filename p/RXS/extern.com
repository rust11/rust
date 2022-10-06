!	SY:EXTERN.COM			!
!					!
!	RUST/XM system startup 		!
!					!
!	Configure system variables	!
!					!
display "?START-I-Using SY:EXTERN.COM"	! display command file name
set prompt Start>			! setup startup prompt
!set terminal noctrlc,noctrly		! make startup non-interruptable
set verify				! display command file during execution
set error none				! keep going no matter what
set node SHARE				! setup the network node name
!set clock 50_hertz			! set clock for 50 hertz - rarely required
!@sy:clock				! VAMP time-of-year call
!mark start				! start the timer
install/terminal/console/process:2/noeight/vt100 T02 ! install console terminal
set terminal ctrlt,debug		! [ctrl/t] [backspace]
set terminal ctrly			! remove for non-interruptable startup
!					!
!	Setup for par6 handlers		!
!					!
install/feature extern			! install external feature
delete vm:par6.sys			! delete temporary file
load/par6/replace dl:,dm:,du:		! replace system handler
load/par6 mm:,ms:,mt:,mu:		! load magtape driver
!					!
!	Configure processes		!
!					!
create/process login/nolog		! create interactive process
create/process login/nolog		!
!create/process login/nolog		!
!create/process login/nolog		!
!create/process login/nolog		!
!create/process login/nolog		!
!create/process login/nolog		!
!					!
!	Configure features		!
!					!
install/feature images			! image cache
!install/feature debug			! small debugger
install/feature debugs			! symbolic debugger
install/feature trace			! trace programs
install/feature logger			! terminal logging
install/feature mailer			! multi-terminal requests
install/feature plas			! rt-11/xm plas requests
install/feature sdata			! sdat/rcvd - send & tell
!install/feature real			! SHAREreal realtime
!install/feature rsx			! SHAREmcr RSX AME
!					!
!	Configure devices		!
!					!
!load dl0:,dl1:,dl2:			! cache non-removable media
!load/extern/nocache dy0:,dy1:		! don't cache removable media
mount/automount				! and mount them all
!					!
! MB:, RE: and LP: may be loaded as kernel or external handlers.
!					!
!mount/external/single lp: spool	! LP: line printer
!mount/external/single re: locks	! RE: record locking
!mount/external/single mb: terms	! MB: terminal handler
!					!
!	Configure virtual volumes	!
!					!
!load/external vv:			! vv: may be external
!mount vv0: dl1:usrdsk usr		! mount some virtual volumes
!mount vv1: dl1:scratc scr		! mount a scratch volume
!					!
!	Configure logical names		!
!					!
!@sy:groups				! setup standard group assignments
!set uic [1,4]				! reset system UIC
!set kernel logins			! enable SY:LOGINS.COM
!set kernel logout			! enable SY:LOGOUT.COM
!					!
!	Configure installed images	!
!					!
!@sy:images				! install images
!					!
!	Configure spooler		!
!					!
!create/process spool/working_set:16./image:sy:spool/nolog
!					!
!	Configure DL/DLV terminals	!
!					!
!install/terminal/csr:176510/vector:310/vt100 t03:
!install/terminal/csr:176520/vector:320/vt100 t04:
!install/terminal/csr:176530/vector:330/vt100 t05:
!					!
!	Configure DZ/DZV terminals	!
!					!
!install/terminal/csr=160600/vector=400 dza: ! dz controller
!					!
!install/terminal/vt100 dza0: t06:	! dza0:
!install/terminal/vt100 dza1: t07:	! dza1:
!install/terminal/vt100 dza2: t08:	! dza2:
!install/terminal/vt100 dza3: t09:	! dza3:
!					!
!	Configure DHV terminals		!
!					!
!install/terminal/csr=160500/vector=410 dha: ! dhv controller
!					!
!install/terminal/vt100 dha0: t10:	! dha0:
!install/terminal/vt100 dha1: t11:	! dha1:
!install/terminal/vt100 dha2: t12:	! dha2:
!install/terminal/vt100 dha3: t13:	! dha3:
!					!
!	Install packages		!
!					!
!@rsx					! install SHAREmcr
!@tsm					! install SHAREtsm
!@net					! install SHAREnet
!					!
!	Start interactive processes	!
!					!
set kernel interactive			! enable interactive logins
!uptime					! system up message (MAILER required)
!mark stop				! stop and display timer
!logout					! logout
