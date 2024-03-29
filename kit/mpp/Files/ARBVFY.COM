!
!                   Copyright (c) 1985, 1986 by
!             Digital Equipment Corporation, Maynard
!              Massachusetts.  All rights reserved.
!
! This software is furnished under a license and may be used and  copied
! only  in  accordance  with  the  terms  of  such  license and with the
! inclusion of the above copyright notice.  This software or  any  other
! copies  thereof may not be provided or otherwise made available to any
! other person.  No title to and ownership of  the  software  is  hereby
! transferred.
!
! The information in this software is subject to change  without  notice
! and  should  not  be  construed  as  a commitment by Digital Equipment
! Corporation.
!
! DIGITAL assumes no responsibility for the use or  reliability  of  its
! software on equipment that is not supplied by DIGITAL.
!
!
! MicroPower/Pascal V2.0 Build Command Procedure
! Application: ARBVFY  Generated : 22-Feb-85 10:18:30 by DIGITAL
!
! Command file name:	LB:ARBVFY.COM
! Kernel build:		Yes
! Application build:	Yes
! Optimize kernel:	No
! Debug support:	Yes
! Code type:		NHD
! Shared library:	None
! Unmapped Ram application
!
SET ERROR WARNING
!
! Build kernel and create memory image
!
R MACRO
TMP:CFDUNM=LB:CFDUNM.MAC,LB:COMU.SML/M
^C
RUN LB:MERGE
TMP:ARBKRN.KMO=TMP:CFDUNM/D,LB:PAXU.OBJ/D
^C
RUN LB:RELOC
TMP:ARBKRN,,DK:ARBKRN=TMP:ARBKRN.KMO
,,TMP:ARBKRN.DST=TMP:ARBKRN.KMO/D
^C
RUN LB:MIB
DK:ARBKRN,,DK:ARBKRN=TMP:ARBKRN,,TMP:ARBKRN.DST/K/S
^C
DEL/NOQUERY TMP:ARBKRN.DST
DEL/NOQUERY TMP:ARBKRN.(KMO,PIM)
DEL/NOQUERY TMP:CFDUNM.OBJ
!
! Build and install device drivers
!
R MACRO
TMP:TTPFX=LB:TTPFX.MAC,LB:COMU.SML/M
^C
RUN LB:MERGE
TMP:TTPFX=TMP:TTPFX,LB:DRVU.OBJ,DK:ARBKRN.STB
^C
RUN LB:RELOC
TMP:TTPFX=TMP:TTPFX,DK:ARBKRN
^C
RUN LB:MIB
DK:ARBKRN=TMP:TTPFX,DK:ARBKRN/S
^C
DEL/NOQUERY TMP:TTPFX.(MOB,PIM)
DEL/NOQUERY TMP:TTPFX.OBJ
!
R MACRO
TMP:KXPFX=LB:KXPFX.MAC,LB:COMU.SML/M
^C
RUN LB:MERGE
TMP:KXPFX=TMP:KXPFX,LB:DRVU.OBJ,DK:ARBKRN.STB
^C
RUN LB:RELOC
TMP:KXPFX=TMP:KXPFX,DK:ARBKRN
^C
RUN LB:MIB
DK:ARBKRN=TMP:KXPFX,DK:ARBKRN/S
^C
DEL/NOQUERY TMP:KXPFX.(MOB,PIM)
DEL/NOQUERY TMP:KXPFX.OBJ
!
! Create application memory image
!
COPY/PREDELETE DK:ARBKRN.MIM DK:ARBVFY.MIM
COPY/PREDELETE DK:ARBKRN.STB DK:ARBVFY.STB
COPY/PREDELETE DK:ARBKRN.DBG DK:ARBVFY.DBG
!
! Build and install User processes
!
R MPP
TMP:ARBVFY=LB:ARBVFY.PAS/D/I:NHD
R MPP
TMP:KXRWD=LB:KXRWD.PAS/D/I:NHD
RUN LB:MERGE
TMP:ARBVFY=TMP:ARBVFY.OBJ/D//
TMP:KXRWD.OBJ/D
LB:FILSYS.OBJ,LB:LIBNHD.OBJ,DK:ARBVFY.STB
//
^C
RUN LB:RELOC
TMP:ARBVFY,,TMP:ARBVFY.PST=TMP:ARBVFY,DK:ARBVFY/D
^C
RUN LB:MIB
DK:ARBVFY,,DK:ARBVFY=TMP:ARBVFY,DK:ARBVFY,TMP:ARBVFY.PST/S
^C
DEL/NOQUERY TMP:ARBVFY.PST
DEL/NOQUERY TMP:ARBVFY.(MOB,PIM)
DEL/NOQUERY TMP:KXRWD.OBJ
DEL/NOQUERY TMP:ARBVFY.OBJ
!
                                                                                                                                                                                                       