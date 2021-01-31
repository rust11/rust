OPS: - RUST update facility

These command files implement the RUST module update facility.
The example below builds the VUP utility. 

!	VUS:UPDATE.COM - Update VUP.SAV
!
!	@VUS:UPDATE [NOLOG] [ALL|LIST|LIBR|LATER]
!
@ops:up vus vub VUP.SAV 'p1' 'p2'
!
LOOP$:
hdr$ vumod!	definitions
rid$ vuroo!	root
mac$ vucmd!	CSI command
rid$ vuboo!	boot
rid$ vucop!	copy/boot
rid$ vuimg!	copy/device
rid$ vucre!	create
rid$ vubad!	dir/bad
rid$ vuini!	initialize
mac$ vutem!	templates
mac$ vuinf!	image info
rid$ vuutl!	utility routines
!
mrg$
log$ VUP.SAV
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
end$:
