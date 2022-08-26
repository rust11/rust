!	GKS:UPDATE.COM - Update GEEK utility
!
!	@GKS:UPDATE [ALL|LIST|LINK|LATER]
!
@ops:up gks gkb gks:geek.sav 'P1' 'P2'
!mac$ := check$ ^1 gks:^1.mac gkb:^1.obj macro gks:^1/object:gkb:^1
!rid$ := check$ ^1 gks:^1.r gkb:^1.obj rider gks:^1/object:gkb:^1
!hdr$ := check$ ^1 gks:^1.d gkb:^1.h rider gks:^1/header:gkb:^1
!@ops:updatx 'P1' 'P2'
!
LOOP$:
hdr$ gkmod
rid$ geek
mac$ gkimg
mac$ gkbau
!ac$ gkdev
rid$ gkdlv
mac$ gkflk
rid$ gkkbd
mac$ gklow
mac$ gkmac
mac$ gkmch
!ac$ gkmem
mac$ gkmmu
rid$ gkpdp
mac$ gkrad
rid$ gkrmn
rid$ gkrtx
mac$ gksim
mac$ gkslo
mac$ gksna
rid$ gkcfg
mac$ gkvec
!
LINK:
log$ GKB:GEEK.SAV

link /exe:gkb:geek/map:gkb:geek/prompt/cross/bottom:2000
gkb:geek
gkb:gkimg
lib:output
lib:crt
gkb:gkkbd/o:1
gkb:gksim
gkb:gksna
gkb:gkflk
gkb:gkrmn
gkb:gkbau/o:1
gkb:gkpdp
gkb:gkmem/o:1
gkb:gkmmu
gkb:gklow
!kb:gkdev
gkb:gkdlv/o:1
gkb:gkcfg/o:1
gkb:gkrtx
gkb:gkslo
gkb:gkrad/o:1
gkb:gkvec/o:1
gkb:gkmch/o:1
rvb:bda,ere
rvb:env,etx!
//
end$:
end$
