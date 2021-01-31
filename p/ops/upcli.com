!	OPS:UPCLI.COM - UPDATE command 
!
!	cli$ 'P1' 'P2' 'P3'
!
!	P1	dfb:srcdif.sav
!	P2	[LATER|ALL|...]
!	P3	[BUILD]
!
!	...
!	DONE$
!
!	END$:
!
mrg$ := done$
!
do$ := dolink$|display "^1"|^2 ^3 ^4
done$ :=  @ops:upzap|goto end$|
dolink$ := done$ := @ops:upzap
checkt$ := sy:later ^1,'P1'/s|if/not/suc goto skip1$|dolink$|skip1$:
checko$ := sy:later ^2,^3|if/not/suc goto skip$|do$ ^1 ^4 ^5 ^6|skip$:
!heck$ := sy:later ^2,^3|if/not/suc goto skip$|do$ ^1 ^4 ^5 ^6|skip$:
check$ := checkO$ ^1 ^2 ^3 ^4 ^5 ^6|checkT$ ^3
!
if "'P1'" ne "NONE" goto skip$
checkt$ :=
check$ := checkO$ ^1 ^2 ^3 ^4 ^5 ^6
skip$:
!
log$ := display "^1"
nolog$ := log$ := nop:|last$ := display "^1"|do$ := ^2 ^3 ^4
!
end$ := @ops:uptem exit
!
goto 'P2'
goto LOOP$ 

NOLOG:
nolog$
goto 'P3'
goto LOOP$

ALL:	
log$ all
check$ := do$ ^1 ^4 ^5 ^6
goto LOOP$

HELP:
display "@xxs:update [NOLOG] [ALL|HELP|LIST|LINK|LATER|MAINT]"
exit

LIST:
check$ := sy:later ^2,^3|if/not/suc goto skip$|display "^1"|skip$:
goto LOOP$

LATER:
check$ := sy:later ^2,^3/v
goto LOOP$

MAINT:
check$ := sy:later ^2,^3/m
goto LOOP$

loop$:
