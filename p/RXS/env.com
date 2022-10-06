!title	env.com
!
!	build ENV utility
!
goto 'p1'
macro:				!
copy	rxs:envshp.mac rxs:envcnd.mac
build	rxs:esa			! enutl	stand-alone utility
build	rxs:bda			!	data
build	rxs:esb			! enshp	shape build file
build	rxs:env			! enroo	main report
build	rxs:ede			! endev	device
build	rxs:ere			! enrep	report
build	rxs:etx			! entxt	text support
!
!	link
!
link:				!	link
r link!
rxb:env=//!
rxb:esa!
rxb:esb!
rxb:bda!
rxb:ere!
rxb:env!
rxb:ede!
rxb:etx!
//!
^C!
goto end
if "'p1'" goto end		!
copy rxb:env.sav sy:env.sav	!
end:				!
