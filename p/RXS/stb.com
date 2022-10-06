!open log tmp:stb
!title	rxs:stb.com
!
!	p1	start label
!	p2	continue label - usually only
!
!	p2	copy output device
!	p3	copy'p3' from to
!
!	bsp:	RUST/XM backup
!
!		p1	p2
!	@stb	all		create, convert and update all modules
!	@stb	create only	create only
!	@stb	convert		convert and update all modules
!	@stb	convert only	convert only
!	@stb	update		update all modules
!	@stb	feature		update trace and all subsequent modules
!
start:	goto 'P1'		!select create, convert, update, or stb module
	display "?STB-E-Option not specified"
	set status error
	goto exit
!
!	Create new STB file
!
all:
create:	date
	run sy:global	rxs:stbdat=/g/d
	run sy:macro	rxb:stbdat=rxs:stbdat,stbmod
	goto 'P2'
!
!	Create new RUST/XM version
!
rust:	@rxs:link	
	goto 'P2'
!
!	Convert STB file
!
convert: display/query "RUSTX.STB/Convert; Are you sure? "
	set error warn
	@@rxs:stbmod
	copy rxb:rustx.obj lib:rustx.obj
	copy rxb:rustx.obj lib:share.obj
	set error error
	goto 'P2'
!
!	Update STB modules
!
update:
!
dcl:	@dcs:link

thunks:
	@@rfs:featur
	@@rfs:feapoo
	@@rfs:revers
!
!	features
!
feature:
plas:	@@rfs:plas.mac		link
!debug:	@@rfs:debug.mac		link
debugs:	@@rfs:debugs.mac	link
trace:	@@rfs:trace.mac		link
logger:	@@rfs:logger.mac	link
mailer:	@@rfs:mailer.mac	link
images:	@@rfs:images.mac	link
!real:	@@rfs:real.mac		link
!net:	@@rfs:net.mac		link
!netmul:@@rfs:netmul.mac	link
tsx:	@tss:tsx		link
rsx:	@rss:rsx		link
rst:	@@rss:rst		link
sdata:	@@rfs:sdata.mac		link
extern:	@@rfs:extern.mac	link
tildb:!	@@rfs:tildb.mac		link
tpnet:	@nts:tpser link tppser nng
!	@nts:tpser link wbpser nwb
!	@nts:tpser link wdpser nwd
!??	@@nts:tppavm link
	@@nts:ang link
!
!	drivers
!
mb:	@@drs:mbp.mac		link
mq:	@@drs:mqp.mac		link
!fa:	@@fas:fap.mas		link
tp:	@@nts:tpp.mac		link
!
!	utilities
!
util:
utilities:
consol:	@@cus:consol.mac	link
mount:	@mos:mount		link
!queue:	@@rfs:queue.mac		link
!queuex:@@rfs:queuex.mac	link
spool:	@@rfs:spool.mac		link
spoolx:	@@rfs:spoolx.mac	link
!f11a:	@fas:link
image:	@@ims:image		link
accoun:	@@acs:accoun		link
batch:	@@rfs:batch		link
!shut:	@@rfs:shut		link
!
!	exit via only
!
only:
exit:!	close log
