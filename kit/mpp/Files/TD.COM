!
! THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED OR COPIED
! ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE.
!
!                     COPYRIGHT (c) 1982, 1986 BY
! 	    DIGITAL EQUIPMENT CORPORATION. ALL RIGHTS RESERVED.
!
! BUILD COMMAND FILE FOR TDX HANDLER
! SOURCE ON DK:, TDX.SYS ON SY:
SET ERROR NONE
UNLOAD TD
REMOVE TD
R MACRO
TDX=LB:TDRT,DK:XM,DK:XM.CND,LB:TD
^C
LINK/NOBITMAP/EXEC:SY:TDX.SYS TDX
DEL/NOQ TDX.OBJ
INSTALL TD
LOAD TD
                                    