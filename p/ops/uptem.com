!;???;	UPTEM - exit stp$/app$ code unclear whether active
!	OPS:UPTEM - Define operation templates
!
!	TEM$ := @OPS:UPTEM 'P1' 'P2' 'P3' 'P4'
!
!	@OPS:OP opr$ xxS xxB [build]
!	        P1   P2  P3  [P4]
!
!	For example:
!
!	TEM$ mac$ cts ctb build
!
!	mac$ := check$ ^1 cts:^1.mac ctb:^1.obj macro cts:^1/object:ctb:^1
!
!	mac$ XXX
!
!	check$ XXX cts:XXX.mac ctb:XXX.obj macro cts:XXX/object:ctb:XXX
!
!	Keywords supported:
!
!	mac$	MACRO
!	hdr$	Rider header
!	rid$	Rider
!	ccc$	C compiler
!	mar$	Maree
!	mlb$	MACRO library (build only)
!	cop$	Copy (build not supported)
!
!display "uptem ['p1'] ['p2'] ['p3'] ['p4]"
goto 'P1'
!
def$:
tem$ mac$ 'P2' 'P3' 'P4'
tem$ hdr$ 'P2' 'P3' 'P4'
tem$ rid$ 'P2' 'P3' 'P4'
tem$ ccc$ 'P2' 'P3' 'P4'
tem$ mlb$ 'P2' 'P3' build
tem$ mar$ 'P2' 'P3' 'P4'
goto end$

mac$:
app$ mac$
goto 'P4'
!mac$ := check$ ^1 'P2':^1.mac 'P3':^1.obj mac$x ^1
!mac$x := macro 'P2':^1/obj:'P3':^1
mac$ := check$ ^1 'P2':^1.mac 'P3':^1.obj macro 'P2':^1/obj:'P3':^1
goto end$
build:
mac$ := check$ ^1 'P2':^1.mac 'P3':^1.obj build 'P2':^1.mac
goto end$
cusp:
mac$ := check$ ^1 'P2':^1.mac 'P3':^1.sav build 'P2':^1.mac
goto end$
custom:
mac$ := check$ ^1 'P2':^1.mac 'P3':^1.obj cus$ ^1
goto end$

hdr$:
app$ hdr$
goto 'P4'
hdr$ := check$ ^1 'P2':^1.d 'P3':^1.h rider/header 'P2':^1/obj:'P3':^1
goto end$
build:
hdr$ := check$ ^1 'P2':^1.d 'P3':^1.h build 'P2':^1.d
goto end$
cusp:
hdr$ := check$ ^1 'P2':^1.d 'P3':^1.sav build 'P2':^1.r
goto end$

rid$:
app$ rid$
goto 'P4'
rid$ := check$ ^1 'P2':^1.r 'P3':^1.obj rider 'P2':^1/obj:'P3':^1/nodelete
goto end$
build:
rid$ := check$ ^1 'P2':^1.r 'P3':^1.obj build 'P2':^1.r
goto end$
cusp:
rid$ := check$ ^1 'P2':^1.r 'P3':^1.sav build 'P2':^1.r
goto end$

ccc$:
app$ ccc$
goto 'P4'
ccc$ := check$ ^1 'P2':^1.c 'P3':^1.obj cc 'P2':^1/obj:'P3':^1
goto end$
build:
ccc$ := check$ ^1 'P2':^1.c 'P3':^1.obj build 'P2':^1.c
goto end$
cusp:
ccc$ := check$ ^1 'P2':^1.c 'P3':^1.sav build 'P2':^1.c
goto end$

mar$:
app$ mar$
goto 'P4'
mar$ := check$ ^1 'P2':^1.mas 'P3':^1.obj maree 'P2':^1/obj:'P3':^1
goto end$
build:
mar$ := check$ ^1 'P2':^1.mas 'P3':^1.obj build 'P2':^1.mas
goto end$
cusp:
mar$ := check$ ^1 'P2':^1.mas 'P3':^1.sav build 'P2':^1.mas
goto end$

mlb$:
app$ mlb$
cusp:
goto 'P4'
display "?UPTEM-E-Only BUILD supported for MLB$"
exit
build:
mlb$ := check$ ^1 'P2':^1.mac 'P3':^1.mlb build 'P2':^1.mac
goto end$

cop$:
app$ cop$
goto 'P4'
cop$ := check$ ^1 ^1 ^2 copy/nolog ^1 ^2
goto end$
build:
display "?OP-E-BUILD not supported for COP$"
exit
cusp:
display "?OP-E-CUSP not supported for COP$"
exit

init:
app$ := stp$ ^1 ^2 ^3 ^4 ^5 ^6 ^7 ^8
stp$ := app$ := stp$ ^1 !^2 ^3 ^4 ^5 ^6 ^7 ^8
goto end$

add:
app$ 'p2'
goto end$

exit:
stp$ := if/blank=^1 goto skip$|^1 :=|stp$ ^2 ^3 ^4 ^5 ^6 ^7 ^8
app$
skip$:
@ops:upzap
end$:
