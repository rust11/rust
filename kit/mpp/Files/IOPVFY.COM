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
! Application: IOPVFY  Generated : 22-Feb-85 10:29:40 by DIGITAL
!
! Command file name:	LB:IOPVFY.COM
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
TMP:CFDKTC=LB:CFDKTC.MAC,LB:COMU.SML/M
^C
RUN LB:MERGE
TMP:IOPKRN.KMO=TMP:CFDKTC/D,LB:PAXU.OBJ/D
^C
RUN LB:RELOC
TMP:IOPKRN,,DK:IOPKRN=TMP:IOPKRN.KMO
,,TMP:IOPKRN.DST=TMP:IOPKRN.KMO/D
^C
RUN LB:MIB
DK:IOPKRN,,DK:IOPKRN=TMP:IOPKRN,,TMP:IOPKRN.DST/K/S
^C
DEL/NOQUERY TMP:IOPKRN.DST
DEL/NOQUERY TMP:IOPKRN.(KMO,PIM)
DEL/NOQUERY TMP:CFDKTC.OBJ
!
! Build and install device drivers
!
R MACRO
TMP:TTPFXK=LB:TTPFXK.MAC,LB:COMU.SML/M
^C
RUN LB:MERGE
TMP:TTPFXK=TMP:TTPFXK,LB:DRVU.OBJ,DK:IOPKRN.STB
^C
RUN LB:RELOC
TMP:TTPFXK=TMP:TTPFXK,DK:IOPKRN
^C
RUN LB:MIB
DK:IOPKRN=TMP:TTPFXK,DK:IOPKRN/S
^C
DEL/NOQUERY TMP:TTPFXK.(MOB,PIM)
DEL/NOQUERY TMP:TTPFXK.OBJ
!
R MACRO
TMP:KKPFX=LB:KKPFX.MAC,LB:COMU.SML/M
^C
RUN LB:MERGE
TMP:KKPFX=TMP:KKPFX,LB:DRVU.OBJ,DK:IOPKRN.STB
^C
RUN LB:RELOC
TMP:KKPFX=TMP:KKPFX,DK:IOPKRN
^C
RUN LB:MIB
DK:IOPKRN=TMP:KKPFX,DK:IOPKRN/S
^C
DEL/NOQUERY TMP:KKPFX.(MOB,PIM)
DEL/NOQUERY TMP:KKPFX.OBJ
!
! Create application memory image
!
COPY/PREDELETE DK:IOPKRN.MIM DK:IOPVFY.MIM
COPY/PREDELETE DK:IOPKRN.STB DK:IOPVFY.STB
COPY/PREDELETE DK:IOPKRN.DBG DK:IOPVFY.DBG
!
! Build and install User processes
!
R MPP
TMP:IOPVFY=LB:IOPVFY/D/I:NHD
R MPP
TMP:KKRWD=LB:KKRWD.PAS/D/I:NHD
RUN LB:MERGE
TMP:IOPVFY=TMP:IOPVFY.OBJ/D//
TMP:KKRWD.OBJ/D
LB:FILSYS.OBJ,LB:LIBNHD.OBJ,DK:IOPVFY.STB
//
^C
RUN LB:RELOC
TMP:IOPVFY,,TMP:IOPVFY.PST=TMP:IOPVFY,DK:IOPVFY/D
^C
RUN LB:MIB
DK:IOPVFY,,DK:IOPVFY=TMP:IOPVFY,DK:IOPVFY,TMP:IOPVFY.PST/S
^C
DEL/NOQUERY TMP:IOPVFY.PST
DEL/NOQUERY TMP:IOPVFY.(MOB,PIM)
DEL/NOQUERY TMP:KKRWD.OBJ
DEL/NOQUERY TMP:IOPVFY.OBJ
!
                                                                                                                                                                                                  