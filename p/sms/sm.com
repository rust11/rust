!	SMS:SM.COM - Update SM MACRO library SMB:SM.MLB
!
!	@SMS:SM [ALL|LIST|LINK|SCAN]
!
!	SCAN checks each file for .MACRO/.ENDM etc errors
!
@ops:up sms smb sm.mlb 'P1' 'P2'
mlb$ := check$ ^1 sms:^1.mac smb:^1.mla strip$ ^1
strip$ := run sy:strip smb:^1.mla=sms:^1.mac
goto loop$ 
!
SCAN:
mlb$ := display "^1"|libr/mac tmp:a.a smb:^1.mla
!
loop$:
mlb$ smg!		general
mlb$ smd!		data directives
mlb$ smi!		instructions
mlb$ smp!		pdp
mlb$ smu!		utilities
!!!$ smv!		vax
!!
mlb$ sda!		ascii
mlb$ sdc!
mlb$ sdd!
mlb$ sde!
mlb$ sdf!
mlb$ sdf!
mlb$ sdi!
!!
mlb$ sxa!		library
mlb$ sxb!	
mlb$ sxc!	
mlb$ sxd!	
mlb$ sxe!	
mlb$ sxf!	
mlb$ sxi!	
mlb$ sxj!	
mlb$ sxl!	
mlb$ sxn!	
mlb$ sxo!	
mlb$ sxp!	
mlb$ sxr!	
mlb$ sxs!	
mlb$ sxt!	
mlb$ sxu!	
mlb$ sxw!	
!
done$
log$ SM.MLB
libr:
@@sms:smver!			record version number
library/macro:512./prompt/object:smb:sm.mlb lib:sm.mlb
smb:smg.mla
smb:smd.mla
smb:smi.mla
smb:smp.mla
smb:smu.mla
!smb:smv.mla
smb:sda.mla
smb:sdc.mla
smb:sdd.mla
smb:sde.mla
smb:sdf.mla
smb:sdi.mla
smb:sxa.mla
smb:sxb.mla
smb:sxc.mla
smb:sxd.mla
smb:sxe.mla
smb:sxf.mla
smb:sxi.mla
smb:sxj.mla
smb:sxl.mla
smb:sxn.mla
smb:sxo.mla
smb:sxp.mla
smb:sxr.mla
smb:sxs.mla
smb:sxt.mla
smb:sxu.mla
smb:sxw.mla
//
end:
end$:
strip$ :=
copy smb:sm.mlb lib:sm.mlb
