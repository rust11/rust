!
! RUSTNF.COM - RUST/SJ NF: startup command file
!
!set tt noquiet			!
remove tt			! reinstall TT:
install tt			!
install nl			!
load/auto ei			!
install/auto dl,dy,du,rk	! install others
install/auto vm,ld,lp		! 
!install dd,ls			! can't be automated
!load ld			! must be loaded for automation
set edit			! load SL line editor	
!
define/translated tmp sy	! assume no tmp directory
if/file=sy:tmp.dsk define tmp sy:\tmp\
define/translated lib sy	! assume no lib directory
if/file=sy:lib.dsk define lib sy:\lib\
!
!show volume/verify sy:		! check SY: for errors
clock				! try to get the time
