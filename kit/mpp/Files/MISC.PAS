{MODULE Misc;}
{$NOLIST}
{
   This software is furnished under a license and may be used or copied
   only in accordance with the terms of such license.

   Copyright (c) 1984, 1986 by Digital Equipment Corporation.
   All rights reserved.



  This is the file that contains the declarations of the interfaces
  to some miscellaneous primitives and some miscellaneous data structures.

  Author  MN

  Edit history:

	BP 	20-SEP-84	Added add POWER_FAIL and SET_STOP_FLAG
				declarations
	SHD	13-Dec-84	Added CMR-21 bit to config word
	ERS	13-Mar-85	Made VAR of name in get_config
	ERS	13-Mar-85	Added KXT_LOAD procedure
	SHD	 3-Jan-86	Add FPA option to config word
	MN	 3-MAR-86	Add Check_free_space procedure
	RSR	23-APR-86	Add KXJ_LOAD
	RLP     23-Apr-86	Add KXJ_ENABLE_SHARED and KXJ_DISABLE_SHARED
}
{$LIST}

TYPE

  Hardware_config = PACKED RECORD
                      fpp : [pos(0)] boolean;
                      fis : [pos(1)] boolean;
                      f11 : [pos(2)] boolean;
                      j11 : [pos(3)] boolean;
                      t11 : [pos(4)] boolean;
                      iop : [pos(5)] boolean;
                      q22 : [pos(6)] boolean;
                      mmu : [pos(7)] boolean;
		      cmr : [pos(8)] boolean;
		      fpa : [pos(9)] boolean;
                      rom_ram : [pos(15)] boolean;
                    END;


[EXTERNAL($CVALI)] PROCEDURE GET_CONFIG
                   (VAR CLOCK_FREQ : INTEGER;
		    VAR CONFIG : HARDWARE_CONFIG;
		    $_BP_$ : INTEGER := 0;
		    VAR $_MN_$ : [READONLY]NAME_STR := 0;
		    VAR STATUS : EXC_STATUS := 0); EXTERNAL;


[EXTERNAL($SSFAI)] PROCEDURE DEFINE_STOP_FLAG
                   (VAR FLAG : BOOLEAN := 0); EXTERNAL;


[EXTERNAL($PWFLI)] FUNCTION POWER_FAIL : BOOLEAN; EXTERNAL;
		

[EXTERNAL($KXTLO)] PROCEDURE KXT_LOAD
                   (KXT_ADDR : UNSIGNED;
		    VAR MIMF : [READONLY]PACKED ARRAY[L..U:INTEGER] OF CHAR;
		    VAR STATUS : EXC_STATUS := 0); EXTERNAL;


[EXTERNAL($HPCHK)] PROCEDURE CHECK_FREE_SPACE
                   (VAR TOTAL : UNSIGNED;
                    VAR LARGEST : UNSIGNED); EXTERNAL;

[EXTERNAL($KXJLO)]
PROCEDURE KXJ_LOAD (KXJ_ADDR : UNSIGNED;
		    VAR MIMF : [READONLY]PACKED ARRAY[L..U:INTEGER] OF CHAR;
		    VAR STATUS : EXC_STATUS := 0); EXTERNAL;

[EXTERNAL($KXJES)]
PROCEDURE KXJ_ENABLE_SHARED(START : LONG_INTEGER;
		    SIZE : LONG_INTEGER;
		    VAR STATUS : EXC_STATUS := 0); EXTERNAL;

[EXTERNAL($KXJDS)]
 PROCEDURE KXJ_DISABLE_SHARED(VAR STATUS : EXC_STATUS := 0); EXTERNAL;
{END.}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                              