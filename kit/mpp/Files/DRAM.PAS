{MODULE DRAM;}
{$NOLIST}

(*

                     COPYRIGHT (c) 1984, 1986 BY
             DIGITAL EQUIPMENT CORPORATION, MAYNARD
              MASSACHUSETTS.  ALL RIGHTS RESERVED.


 THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED AND  COPIED
 ONLY  IN  ACCORDANCE  WITH  THE  TERMS  OF  SUCH  LICENSE AND WITH THE
 INCLUSION OF THE ABOVE COPYRIGHT NOTICE.  THIS SOFTWARE OR  ANY  OTHER
 COPIES  THEREOF MAY NOT BE PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY
 OTHER PERSON.  NO TITLE TO AND OWNERSHIP OF  THE  SOFTWARE  IS  HEREBY
 TRANSFERRED.


 THE INFORMATION IN THIS SOFTWARE IS SUBJECT TO CHANGE  WITHOUT  NOTICE
 AND  SHOULD  NOT  BE  CONSTRUED  AS  A COMMITMENT BY DIGITAL EQUIPMENT
 CORPORATION.


 DIGITAL ASSUMES NO RESPONSIBILITY FOR THE USE OR  RELIABILITY  OF  ITS
 SOFTWARE ON EQUIPMENT THAT IS NOT SUPPLIED BY DIGITAL.

*)

(*
  This is the include file that contains the declarations of the interfaces
  to the DRAM primitives and all of the necessary data structures to
  access the DRAM requests.

  Author  MN
*)

(*
  Edit history:

	BP	06-SEP-84	Remove error status from 
				alrgi,dlrgi,rctxi,umapi

	RR001	19-SEPT-84	Change "PLAS" --> "DRAM"

	SHD/MN	01-Nov-84	Miscellaneous changes

	ERS	07-Mar-85	Make name var
	RLP	09-Jun-86	Add caching argument to map_window
*)
{$LIST}

TYPE

  REGISTER_RANGE = ARRAY [0..7] OF UNSIGNED;

  ADDRESS_TYPE = (COMMON, PHYSICAL);

  REGION_ID_BLOCK = RECORD
                      REGION_ADDRESS : UNIVERSAL;
                      REGION_SIZE : UNSIGNED;
                      REGION_MODE : ADDRESS_TYPE;
                      REGION_OFFSET : UNSIGNED;
                    END;

  WD$INS = (D_SPACE, I_SPACE);

  WD$RO = (READ_WRITE, READ_ONLY);

  WD$FIX = (FREE, FIXED);

  WD$DAC = (LEAVE,DISABLE);

  MAPPING = RECORD
              PARS : REGISTER_RANGE;
              PDRS : REGISTER_RANGE;
            END;

  ID_MAPPING = RECORD
                 I_PARS : REGISTER_RANGE;
                 I_PDRS : REGISTER_RANGE;
                 D_PARS : REGISTER_RANGE;
                 D_PDRS : REGISTER_RANGE;
               END;


[EXTERNAL($ACSRI)] PROCEDURE ACCESS_SHARED_REGION
                   (VAR RIB : REGION_ID_BLOCK;
                    VAR DESC : STRUCTURE_DESC := 0;
                    VAR NAME : [READONLY]NAME_STR := 0;
                    VAR STATUS : EXC_STATUS := 0); EXTERNAL;


[EXTERNAL($ALRGI)] FUNCTION ALLOCATE_REGION
                   (VAR RIB : REGION_ID_BLOCK;
                    REG_SIZE : UNSIGNED) : BOOLEAN; EXTERNAL;


[EXTERNAL($CRSRI)] PROCEDURE CREATE_SHARED_REGION
                   (VAR RIB : REGION_ID_BLOCK;
                    VAR DESC : STRUCTURE_DESC := 0;
                    VAR NAME : [READONLY]NAME_STR;
                    VAR STATUS : EXC_STATUS := 0); EXTERNAL;


[EXTERNAL($DLRGI)] PROCEDURE DEALLOCATE_REGION
                   (VAR RIB : REGION_ID_BLOCK); EXTERNAL;


[EXTERNAL($DLSTI)] PROCEDURE DELETE_SHARED_REGION
		   (VAR DESC : STRUCTURE_DESC := 0;
		    VAR NAME : [READONLY]NAME_STR := 0;
		    VAR	STATUS : EXC_STATUS := 0); EXTERNAL;
		    

[EXTERNAL($GMAPI)] PROCEDURE GET_MAPPING
                   (VAR INFO : UNIVERSAL;
                    VAR DESC : PROCESS_DESC := 0;
                    VAR NAME : [READONLY]NAME_STR := 0;
                    VAR STATUS : EXC_STATUS := 0); EXTERNAL;


[EXTERNAL($MAPWI)] PROCEDURE MAP_WINDOW
                   (ADDRESS_SPACE : WD$INS := D_SPACE;
                    ACCESS : WD$RO := READ_WRITE;
                    PAR_CHOICE : WD$FIX := FREE;
		    CACHING : WD$DAC := LEAVE;
                    VAR WINDOW_PTR : UNIVERSAL;
                    OFFSET : UNSIGNED := 0;
                    $_BP_$ : INTEGER := 0;
                    LENGTH : UNSIGNED;
                    VAR RIB : REGION_ID_BLOCK;
                    VAR STATUS : EXC_STATUS := 0); EXTERNAL;


[EXTERNAL($RCTXI)] PROCEDURE RESTORE_CONTEXT ; EXTERNAL;


[EXTERNAL($SCTXI)] PROCEDURE SAVE_CONTEXT
                   (VAR STATUS : EXC_STATUS := 0); EXTERNAL;


[EXTERNAL($UMAPI)] PROCEDURE UNMAP_WINDOW
                   (ADDRESS_SPACE : WD$INS := D_SPACE;
                    LENGTH : UNSIGNED;
                    VAR WINDOW_PTR : UNIVERSAL); EXTERNAL;


{END.}
                                                                                                                                                                                                                                                             