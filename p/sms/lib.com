!.title	sms:lib.com
!
!	ld%	data definitions
!	lr%	rsx definitions
!	ls%	RUST/XM public
!	lx%	executable internal
!
!run sy:strip smb:'p1'.mla=sms:'p1'.mac
!
! definitions
goto 'p1'
goto lib
copy:	
copy smb:share.mlb lib:share.mlb
copy smb:share.mlb upd:share.mlb
copy smb:share.mlb lib:rust.mlb
copy smb:share.mlb upd:rust.mlb
exit
!
lib:
!
!@@sms:lda/log! data A
!@@sms:ldb/log!	data B
!@@sms:ldc/log!	data C
!@@sms:ldd/log!	data D
!@@sms:lde/log!	data E
!@@sms:ldf/log!	data F
!@@sms:ldg/log!	data G
!@@sms:ldh/log!	data H
!@@sms:ldi/log! data I
!@@sms:ldj/log! data J
!@@sms:ldk/log!	data K
@@sms:ldl/log!	data L
!@@sms:ldm/log!	data M
!@@sms:ldn/log!	data N
!@@sms:ldo/log!	data O
!@@sms:ldp/log!	data P
!@@sms:ldq/log!	data Q
@@sms:ldr/log!	data R
!@@sms:lds/log!	data S
@@sms:ldt/log!	data T
!@@sms:ldu/log!	data U
@@sms:ldv/log!	data V
!@@sms:ldw/log!	data W
!@@sms:ldx/log!	data X
!!!sms:ldy/log!	data Y - unused
!!!sms:ldz/log!	data Z - unused
!
@@sms:lrs/log!	RSX, RST
!
!	Executable
!
!@@sms:lxi/log!	instructions
!@@sms:lxk/log!	kernel A..Z
!@@sms:lxm/log!	executable A..Z
!@@sms:lxr/log!	realtime
!@@sms:lxs/log!	expert and record-eleven
!
!	Utilities (conversion etc)
!
!@@sms:lua/log!	utilities
!
!	RUST/XM services
!
!@@sms:lsa/log!	RUST/XM services A..L	
!@@sms:lsm/log!	RUST/XM services M..Z
!!!sms:lsh/log!	RUST/XM handler services  (moved to DRS:DRVMAC.MAC);RXM
!
!
!	create distribution version
!
!library/macro:512./prompt/object:lib:distri.mlb/allocate:320. lib:distri.mlb
!
!	Exclude following two lines to create distributed version
!
libr:
@@sms:libver!			record version number
library/macro:512./prompt/object:smb:rust.mlb/allocate:350. smb:rust.mlb
smb:lrs.mla
!library/macro:512./prompt/object:skr:shpmac.mlb/allocate:320. skr:shpmac.mlb
!
smb:lda.mla
smb:ldb.mla
smb:ldc.mla
smb:ldd.mla
smb:lde.mla
smb:ldf.mla
smb:ldg.mla
smb:ldh.mla
smb:ldi.mla
smb:ldj.mla
smb:ldk.mla
smb:ldl.mla
smb:ldm.mla
smb:ldn.mla
smb:ldo.mla
smb:ldp.mla
smb:ldq.mla
smb:ldr.mla
smb:lds.mla
smb:ldt.mla
smb:ldu.mla
smb:ldv.mla
smb:ldw.mla
smb:ldx.mla
smb:lsa.mla
smb:lsm.mla
smb:lxi.mla
smb:lxk.mla
smb:lxm.mla
smb:lxr.mla
smb:lxs.mla
smb:lua.mla
//
copy smb:rust.mlb smb:share.mlb
