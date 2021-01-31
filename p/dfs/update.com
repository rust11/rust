!	DFS:UPDATE.COM - Build and update DFB:DIFFER.SAV
!
@ops:up dfs dfb differ.sav 'p1' 'p2'
!
mac$ sdinf
hdr$ sdmod
rid$ sdroo
rid$ sdcli
rid$ sdwld
rid$ sdmrg
rid$ sdchg
rid$ sdpar
!id$ sdslp

mrg$
LINK:
log$ DIFFER.SAV
link /exe:dfb:differ/map:dfb:differ/cross/bottom=1400/prompt
dfb:sdroo
dfb:sdwld
dfb:sdcli/o:1
dfb:sdmrg/o:1
dfb:sdchg/o:1
dfb:sdpar/o:1
!!!:sdslp/o:1
lib:crt,ridlib
//
end$:
