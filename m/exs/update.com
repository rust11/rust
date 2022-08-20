!	EXS:EXPAT.COM - Update EXPAT.SAV
!
!	@EXS:UPDATE [NOLOG] [ALL|LIST|LIBR|LATER]
!
!	define rt_exb m:\exs\exp ! windows logical required
!
@ops:up exs exp EXPAT.SAV 'p1' 'p2'
@exs:xindex
!
loop$:
hdr$ exmod
!ac$ eximg
rid$ expat
rid$ exdcl
rid$ excop
rid$ exdir
rid$ exdel
rid$ exxdp
!
mrg$
log$ EXPAT.SAV
link:
@@exs:eximg
link/exe:exp:expat/map:exp:expat/cross/bottom=4000/prompt
exp:expat,exp:eximg!	root
exp:exdcl,lib:crt/o:1!	region 1: DCL
ctb:vfdrv,lib:crt/o:1!	      or: VF
exp:excop,lib:crt/o:2!	region 2: copy
exp:exdir,lib:crt/o:2!		  directory
exp:exdel,lib:crt/o:2!		  type
exp:exxdp,lib:crt/o:2!		  xxdp
lib:crt
//
^C
copy exp:expat.sav sy:
end$:
