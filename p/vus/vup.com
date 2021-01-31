!	squeeze	vip
!
goto 'P1'
!rider/header vus:vumod.d/obj:vub:vumod.h
!rider vus:vuroo/obj:vub:!	root
!macro vus:vucmd/obj:vub:!	csi translation
!rider vus:vuutl/obj:vub:!	utilities
!rider vus:vuboo/obj:vub:!	boot
!rider vus:vucop/obj:vub:!	copy/boot
rider vus:vucre/obj:vub:!	create/extend/truncate file
!rider vus:vuimg/obj:vub:!	image copy
!rider vus:vubad/obj:vub:!	bad block handling
!rider vus:vuini/obj:vub:!	initialize
!macro vus:vutem/obj:vub:!	template data
!macro vus:vuinf/obj:vub:!	program information
link:
r link
vub:vup,vup=/n/b:2000//
lib:crt
vub:vuinf
vub:vuroo
vub:vucmd
vub:vuutl
vub:vucop,vub:vuboo/o:1
vub:vucre/o:1
vub:vuimg/o:1
vub:vuini,vutem/o:1
vub:vubad/o:1
//
^C
goto end
copy:
copy vub:vup.sav sy:
end:
