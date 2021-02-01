!	SMS:RUST.COM - Update RUST MACRO libraries
!
!	@SMS:UPDATE [ALL|LIST|LINK|LIBR|SCAN]
!
!	SCAN checks each file for .MACRO/.ENDM etc errors
!
!	ld%	data definitions
!	lr%	rsx definitions
!	ls%	RUST/XM public
!	lx%	executable internal
!
@ops:up sms smb rust.mlb 'P1' 'P2'
mlb$ := check$ ^1 sms:^1.mac smb:^1.mla build sms:^1
goto loop$
!
SCAN:
mlb$ := log$ "^1"|libr/mac tmp:a.a smb:^1.mla
!
LOOP$:
mlb$ lda!	data A
mlb$ ldb!	data B
mlb$ ldc!	data C
mlb$ ldd!	data D
mlb$ lde!	data E
mlb$ ldf!	data F
mlb$ ldg!	data G
mlb$ ldh!	data H
mlb$ ldi!	data I
mlb$ ldj!	data J
mlb$ ldk!	data K
mlb$ ldl!	data L
mlb$ ldm!	data M
mlb$ ldn!	data N
mlb$ ldo!	data O
mlb$ ldp!	data P
mlb$ ldq!	data Q
mlb$ ldr!	data R
mlb$ lds!	data S
mlb$ ldt!	data T
mlb$ ldu!	data U
mlb$ ldv!	data V
mlb$ ldw!	data W
mlb$ ldx!	data X
!!!$ ldy!	data Y - unused
!!!$ ldz!	data Z - unused
!
mlb$ lrs!	RSX, RST
!
!	Executable
!
mlb$ lxi!	instructions
mlb$ lxk!	kernel A..Z
mlb$ lxm!	executable A..Z
mlb$ lxr!	realtime
mlb$ lxs!	expert and record-eleven
!
!	Utilities (conversion etc)
!
mlb$ lua!	utilities
!
!	RUST/XM services
!
mlb$ lsa!	RUST/XM services A..L	
mlb$ lsm!	RUST/XM services M..Z
!
done$
LIBR:
display "RUST.MLB"
!
@@sms:libver!			record version number
library/macro:512./prompt/object:smb:rust.mlb/allocate:400. smb:rust.mlb
smb:lrs.mla
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
copy smb:rust.mlb lib:rust.mlb
copy smb:rust.mlb lib:share.mlb
end$:
end$
mlb$ :=
