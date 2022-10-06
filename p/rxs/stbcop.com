!	STBCOP.COM
!
!	@stbcop label out-path options
!
!	p1	copy or test or ...
!	p2	out-path
!	p3	device options


	goto 'p1'
	goto help

copy:	if/not/blank:'p2' goto copdev
	display	"?STB-E-Must specify DEV: for COPY operation"
	set status error
	goto exit

copdev:	assign 'p2' o!		assign DEV: to O:
	goto common!		go copy the files

test:	assign dl2 o!		copy to dl2:
	goto common

system:	assign	dl0 o!		copy to system
	goto common
!
field:	assign	dy1 o!		copy to floppy
	goto common
!
save:	assign	vx bsp!
	assign	bsp o!		select output device
	goto common!		copy
!
common:
!
!	features
!
copy'p3'	sub:plas.fea	o:plas.fea
copy'p3'	sub:debug.fea	o:debug.fea
copy'p3'	sub:debugs.fea	o:debugs.fea
copy'p3'	sub:trace.fea	o:trace.fea
copy'p3'	sub:logger.fea	o:logger.fea
copy'p3'	sub:mailer.fea	o:mailer.fea
copy'p3'	sub:images.fea	o:images.fea
copy'p3'	sub:real.fea	o:real.fea
copy'p3'	sub:net.fea	o:net.fea
copy'p3'	sub:netmul.fea	o:netmul.fea
copy'p3'	tsb:tsx.fea	o:tsx.fea
copy'p3'	rsb:rsx.fea	o:rsx.fea
copy'p3'	rsb:rst.fea	o:rst.fea
copy'p3'	sub:sdata.fea	o:sdata.fea
copy'p3'	sub:extern.fea	o:extern.fea
copy'p3'	ntb:tppser.sav 	o:tppser.sav
copy'p3'	ntb:tppacp.sav	o:tppacp.sav
copy'p3'	ntb:tppavm.sav	o:tppavm.sav
!
!	drivers
!
copy'p3'	drb:mbp.sys	o:mbp.sys/system
!opy'p3'	fab:fap.sys	o:fap.sys/system
copy'p3'	drb:mqp.sys	o:mqp.sys/system
copy'p3'	ntb:tpp.sys	o:tpp.sys/system
!
!	utilities
!
copy'p3'	utb:consol.sav	o:consol.sav
copy'p3'	mob:mount.sav	o:mount.sav
copy'p3'	sub:queue.sav	o:queue.sav
copy'p3'	sub:queuex.sav	o:queuex.sav
copy'p3'	sub:spool.sav	o:spool.sav
copy'p3'	sub:spoolx.sav	o:spoolx.sav
!opy'p3'	fab:f11a.sav	o:f11a.sav
copy'p3'	imb:image.sav	o:image.sav
copy'p3'	acb:accoun.sav	o:accoun.sav
copy'p3'	sub:batch.sav	o:batch.sav
copy'p3'	sub:shut.sav	o:shut.sav
!
!	runtime
!
copy'p3'	rxb:rustx.sav	o:rustx.sav
copy'p3'	dcb:dcl.sys	o:dcl.sys/system
goto exit

help:
display "?STBCOP-I-Copy STB files"
display ""
display " @rxs:stbcop CMD DST"
display ""
display " CMD = Command (e.g. COPY,...)"
display " DST = Destination volume (no colon)"
display ""
display " @rxs:stbcop copy hd1"
exit:!	close log

