!show log
load tt                 ! must be present and first install/load
load sl
define hom sy
set default nf7
define cf SY
define wf SY
define dl fx
syx := define sy dl:\001064\
dl2 := dcl mount/over=ident dl2:
dc*l := cub:dcx
mc*r := cub:mcx
ac*cess := sy:ldv.sys LD*:,^1,^1
deac*ess := sy:ldv.sys ^1/d
!dcl := sy:rtx dcl
!mcr := sy:rtx mcr
qu*it := sy:rtx quit
