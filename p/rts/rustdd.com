!
! RUST.COM - RUST/SJ DD: startup command file
!
set tt noquiet			! show progress
install nl			! install null driver
load/auto ei			! check for EIS
load/auto vm			! check for VM:
if/not/device=VM: goto no_vm	! no such beast
r vup!				! avoid DCL
vm:*=/z/y!			! init VM:
^C
r vip!				!
vm:dcl.sav=sy:dcl.sav!		! copy usual suspects
vm:vip.sav=sy:vip.sav!		!
vm:vir.sav=sy:vir.sav!		!
vm:vup.sav=sy:vup.sav!		!
^C				!
define/path sy vm,sy		! avoid DD:
define/path dk vm,dk		! likewise
reset				! make path active
no_vm:				! common
install/auto dl,dy,du,rk	! install others
install/auto nf,ld,lp		! 
!install dd,ls			! can't be automated
!load ld			! must be loaded for automation
load/auto nf			! load network
set edit			! load SL line editor	
r clock				! try to get the time
!
!define/translated tmp sy	! assume no tmp directory
!if/file=sy:tmp.dsk define tmp sy:\tmp\
!define/translated lib sy	! assume no lib directory
!if/file=sy:lib.dsk define lib sy:\lib\
