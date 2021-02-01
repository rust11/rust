!	RIS:UPDATE.COM - Build and update RIP:RIDER.SAV
!
define rib rip
@ops:up ris rip RIDER.SAV 'P1' 'P2'
!
hdr$ ridef
hdr$ eddef
rid$ riroo
rid$ ripar
rid$ ricvt
rid$ rifun
rid$ ristm
rid$ ricas
rid$ ridef
rid$ rityp
rid$ ribuf
rid$ riput
rid$ ripre
rid$ riutl
rid$ rienu
rid$ riloo
rid$ ridat
rid$ edmod
rid$ edloc
!
mrg$
log$ RIDER.SAV
link:
link/bot:6000/glob/exe:rip:rider/map:rip:rider/prompt
rip:riroo
rip:ripar
rip:ricvt
rip:rifun
rip:ristm
rip:ricas
rip:ribuf
rip:riput
rip:ridef
rip:rityp
rip:ripre
rip:riutl
rip:rienu
rip:riloo
rip:ridat
rip:edmod
rip:edloc
lib:crt
//
^C
end$:
