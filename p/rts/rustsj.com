!
! RUST.COM - RUST/SJ standard startup command file
!
!set tt noquiet			! display startup command file
install nl			! TT: SY: NL: ...
load/auto ei			! automated EIS support
install/auto dl,dy,du,rk	! automated device installation
install/auto nf,vm,ld,lp	! 
!install dd,ls			! can't be automated
!load ld			! must be loaded for automation
load/auto nf			! load network
clock				! try to get the time
set edit			! load SL line editor	
define hom sy			! default hom: assignment
if/device=nf goto volume	! use nf: for tmp: and lib:
define/translated tmp sy	! assume no tmp directory
if/file=sy:tmp.dsk define tmp sy:\tmp\
define/translated lib sy	! assume no lib directory
if/file=sy:lib.dsk define lib sy:\lib\
volume:				!
show volume/verify sy:		! check system volume for errors
