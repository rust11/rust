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
! Application: CARS3  Generated : 22-Jan-85 10:22:31 by DIGITAL
!
! Command file name:	DK:KRDUNM.COM
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
TMP:CFDUNM.KMO=TMP:CFDUNM/D,LB:PAXU.OBJ/D
^C
RUN LB:RELOC
TMP:CFDUNM,,DK:CFDUNM=TMP:CFDUNM.KMO
,,TMP:CFDUNM.DST=TMP:CFDUNM.KMO/D
^C
RUN LB:MIB
DK:CFDUNM,,DK:CFDUNM=TMP:CFDUNM,,TMP:CFDUNM.DST/K/S
^C
DEL/NOQUERY TMP:CFDUNM.DST
DEL/NOQUERY TMP:CFDUNM.(KMO,PIM)
DEL/NOQUERY TMP:CFDUNM.OBJ
!
! Build and install device drivers
!
R MACRO
TMP:TTPFX=LB:TTPFX.MAC,LB:COMU.SML/M
^C
RUN LB:MERGE
TMP:TTPFX=TMP:TTPFX,LB:DRVU.OBJ,DK:CFDUNM.STB
^C
RUN LB:RELOC
TMP:TTPFX=TMP:TTPFX,DK:CFDUNM
^C
RUN LB:MIB
DK:CFDUNM=TMP:TTPFX,DK:CFDUNM/S
^C
DEL/NOQUERY TMP:TTPFX.(MOB,PIM)
DEL/NOQUERY TMP:TTPFX.OBJ
!
! Create application memory image
!
COPY/PREDELETE DK:CFDUNM.MIM DK:CARS3.MIM
COPY/PREDELETE DK:CFDUNM.STB DK:CARS3.STB
COPY/PREDELETE DK:CFDUNM.DBG DK:CARS3.DBG
!
! Build and install User processes
!
R MPP
TMP:CARS3=LB:CARS3.PAS/D/I:NHD
RUN LB:MERGE
TMP:CARS3=TMP:CARS3.OBJ/D//
LB:FILSYS.OBJ,LB:LIBNHD.OBJ,DK:CARS3.STB
//
^C
RUN LB:RELOC
TMP:CARS3,,TMP:CARS3.PST=TMP:CARS3,DK:CARS3/D
^C
RUN LB:MIB
DK:CARS3,,DK:CARS3=TMP:CARS3,DK:CARS3,TMP:CARS3.PST/S
^C
DEL/NOQUERY TMP:CARS3.PST
DEL/NOQUERY TMP:CARS3.(MOB,PIM)
DEL/NOQUERY TMP:CARS3.OBJ
!
                                                                    