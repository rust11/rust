!title	cpu.com
!
!	Build CPU utility
!
! NOTE: Rebuild ESA, ENV and ERE every time.
!	Files are shared with ENV.COM and RUST/XM kernel.
!	Rebuild ENV after each compile
!
goto 'p1'
macro:				!
copy	rxs:envutl.mac rxs:envcnd.mac
build	rxs:esa			!	stand-alone utility
build	rxs:bda			!	data
build	rxs:esb			!	shape build file
build	rxs:env			!	main report
build	rxs:ede			!	device
build	rxs:ere			!	report
build	rxs:etx			!	text support
if "'p1'" goto end		!
!
!	link
!
link:				!	link
r link!
rxb:cpu=//!
rxb:esa!
rxb:esb!
rxb:bda!
rxb:ere!
rxb:env!
rxb:ede!
rxb:etx!
//!
^C!
if "'p1'" goto end		!
copy rxb:cpu.sav sy:cpu.sav	!
end:				!
