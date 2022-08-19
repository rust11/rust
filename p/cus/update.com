!	@CUS:UPDATE.COM - Build CUS: system cusps
!
!	@CUS:UPDATE [NOLOG] [ALL|LIST|LIBR|LATER]
!
@ops:up cus cub cusp 'P1' 'P2'
tem$ mac$ cus cub build
tem$ rid$ cus cub build
!
mac$ consol
!mac$ clock
mac$ datime
mac$ erase
mac$ handle
!ac$ mlb
!?c$ progra
!ac$ psect
mac$ radix
!ac$ rate
mac$ setup
mac$ volume
!
!!!rid$ boot
rid$ build
rid$ calc
rid$ dump
rid$ later
rid$ mark
rid$ md
rid$ patch
rid$ rd
rid$ search
rid$ split
rid$ touch
end$
