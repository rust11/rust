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
! Application: CARS3  Generated : 22-Jan-85 10:17:40 by DIGITAL
!
! Command file name:	DK:KRDFPL.COM
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
TMP:CFDFPL=LB:CFDFPL.MAC,LB:COMU.SML/M
^C
RUN LB:MERGE
TMP:CFDFPL.KMO=TMP:CFDFPL/D,LB:PAXU.OBJ/D
^C
RUN LB:RELOC
TMP:CFDFPL,,DK:CFDFPL=TMP:CFDFPL.KMO
,,TMP:CFDFPL.DST=TMP:CFDFPL.KMO/D
^C
RUN LB:MIB
DK:CFDFPL,,DK:CFDFPL=TMP:CFDFPL,,TMP:CFDFPL.DST/K/S
^C
DEL/NOQUERY TMP:CFDFPL.DST
DEL/NOQUERY TMP:CFDFPL.(KMO,PIM)
DEL/NOQUERY TMP:CFDFPL.OBJ
!
! Build and install device drivers
!
R MACRO
TMP:TTPFXF=LB:TTPFXF.MAC,LB:COMU.SML/M
^C
RUN LB:MERGE
TMP:TTPFXF=TMP:TTPFXF,LB:DRVU.OBJ,DK:CFDFPL.STB
^C
RUN LB:RELOC
TMP:TTPFXF=TMP:TTPFXF,DK:CFDFPL
^C
RUN LB:MIB
DK:CFDFPL=TMP:TTPFXF,DK:CFDFPL/S
^C
DEL/NOQUERY TMP:TTPFXF.(MOB,PIM)
DEL/NOQUERY TMP:TTPFXF.OBJ
!
! Create application memory image
!
COPY/PREDELETE DK:CFDFPL.MIM DK:CARS3.MIM
COPY/PREDELETE DK:CFDFPL.STB DK:CARS3.STB
COPY/PREDELETE DK:CFDFPL.DBG DK:CARS3.DBG
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
                                                           