!	OPS:UP.COM - UPDATE generic 
!
!	@ops:up cts ctb crt.obj ['p1'] ['p2']
!	@ops:up cts ctb NONE	['p1'] ['p2']
!
!display "UP: ['P1'] ['P2'] ['P3'] ['P4'] ['P5']"
@ops:upzap
def$ := @ops:uptem def$ ^1 ^2 ^3 ^4 ^5
tem$ := @ops:uptem ^1 ^2 ^3 ^4 ^5
cli$ := @ops:upcli ^1 ^2 ^3
@ops:uptem init
if/blank='P1' goto end$
def$ 'P1' 'P2' 
if/blank='P3' goto end$
cli$ 'P3' 'P4' 'P5'
end$:
