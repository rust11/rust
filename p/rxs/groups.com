!	GROUPS.COM
!
!	Prototype group assignment command file
!
!	groups:
!
!		development	100
!		documentation	110
!		office		120
!		support		130
!
!	members:
!
!		ian		1
!		ewald		2
!		christine	6
!		sabine		10
!
!	
assign/system vx log!				project log files
assign/system vx skr!				scratch directory
assign/system vx pro!				project directory
!
! setup development group assignments
!
set uic [100,1]! 				select development UIC
assign/group vx sps!				SHAREplus sources
assign/group vx spb!				SHAREplus binaries
assign/group vx spx!				SHAREplus executables
assign/group vx spd!				SHAREplus documentation
assign/group vx spk!				SHAREplus distribution
assign/group vx dcs!				DCL sources
assign/group vx dcb!				DCL binaries
assign/group vx dcx!				DCL executable
!
! setup documentation group assignments
!
set uic [110,1]!				select UIC
assign/group vx spd!				SHAREplus documentation
assign/group vx vrd!				VRT documentation
assign/group vx vad!				VAMP documentation
assign/group vx shd!				SHARE-eleven documentation
assign/group vx std!				STAR-eleven documentation
!
! setup office group assignments
!
set uic [120,1]!				select UIC
assign/group vx	add!				address files
assign/group vx off!				office runtime system
assign/group vx dat!				office database
assign/group vx dok!				office docs
!
! setup support group assignments
!
set uic [130,1]!				select UIC
assign/group vx	sup!				support database
assign/group vx tst!				binary customer reports
assign/group vx spk!				SHAREplus distribution
assign/group vx exk!				star/share/vrt distribution
assign/group vx vak!				VAMP distribution
!
set uic [1,4]!					reset system UIC
                                                                                                                                                                                                                                                                                                                                                          