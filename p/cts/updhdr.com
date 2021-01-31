!	CTS:UPDHDR.COM - Build and update CRT library headers
!
!	$cts - compiles RT-11-specific headers in CTS:
!	$rls - compiles shared headers stored in RLS:
!
@ops:up cts ctb NONE 'P1' 'P2'
cts$ := check$ ^1 cts:^1.d rid:^1.h rider/header=rid:^1.h cts:^1.d
rls$ := check$ ^1 rls:^1.d rid:^1.h rider/header=rid:^1.h rls:^1.d
!
!!!$ crt!	CRT front-end (crt.mac)
mlb$ crtmac!	CRT MACRO library
cts$ rider!	Rider front-end
!
rls$ btmap!	bit array get/put
cts$ emdef!	RT-11 emts
cts$ fbdef!	CRT file block
cts$ osdef!	Operating system codes
rls$ rddef!	RT-11 directory toolkit
rls$ rndef!	RSX definitions
rls$ rsmod!	RSX definitions
rls$ rssts!	RSX definitions
rls$ rtbad!	RT-11 bad blocks
cts$ rtboo!	RT-11 bootstrap
cts$ rtchn!	RT-11 channels
cts$ rtcla!	RT-11 file class
cts$ rtcsi!	RT-11 CSI
cts$ rtdev!	RT-11 devices
cts$ rtdir!	RT11A
cts$ rtdrv!	RT-11 drivers
cts$ rtfat!	RT-11 file attributes
cts$ rtmon!	RT-11 RMON header
rls$ rtmod!	RT-11 general definitions
cts$ rttim!	Rust time format
rls$ rxdef!	Rad50 conversion
cts$ btdef
rls$ chdef
rls$ cldef
rls$ ctdef
rls$ codef
rls$ dcdef
rls$ dfdef
rls$ dpdef
cts$ dprst
rls$ eldef
cts$ fidef
cts$ fsdef
rls$ hodef
rls$ hldef
rls$ htdef
rls$ imdef
rls$ iodef
rls$ lndef
cts$ medef
rls$ mhdef
cts$ mxdef
cts$ obdef
rls$ rvpdp
rls$ qudef
cts$ qddef
rls$ sbdef
rls$ skdef
cts$ stdef
rls$ tidef
cts$ timat
rls$ tmdef
rls$ xxdef
done$
end$:
end$
cts$ :=
rls$ :=
