{MODULE PCBM;}
{$NOLIST}

(*

                COPYRIGHT (c) 1982, 1986 BY
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
  This is the include file that contains the declaration of a mapped
  PCB.

  Author  MN
*)

(*
  Edit history:

  MN001   4-May-82   Fix QAR 075 in UPAX5 (Create this file)

  MN002	 19-May-82   Add ESF to PCB definition

  MN003  17-Dec-82   Change the area with PARs and PDRs to an array

  RR001  18-SEP-84  Update to v2.0 PCB structure.

  BP001  29-JAN-85  Changed STATUS_TYPE to STATE_CODE_MODIFIER_TYPE

  BP	 20-Mar-85  Removed error code comments

  BP	 06-May-85  Put PCBM.PAS in sync with kernel (DATDFM.MAC)

*)
{$LIST}

TYPE
  I_AND_D = (IAD_NOT_USED, IAD_USED); (*RR001*)

  PAR_PDR_ARRAY = ARRAY [0..7] OF UNSIGNED; (*RR001*)

  PROCESS_MEMORY_MAP = RECORD (*RR001*)
	CASE I_AND_D OF (*RR001*)
	 IAD_NOT_USED : (PARS, PDRS : PAR_PDR_ARRAY); (*RR001*)
	 IAD_USED     : (IPARS, IPDRS, DPARS, DPDRS : PAR_PDR_ARRAY) (*RR001*)
	 END; (*RR001*)

  CONTEXT_BLOCK = RECORD (*RR001*)
	 PTR : ^CONTEXT_BLOCK; (*RR001*)
	 MAP_INFO : PROCESS_MEMORY_MAP; (*RR001*)
	 END; (*RR001*)

  PCB_POINTER = ^PCB;

  PCB = PACKED RECORD
	  FLK : PCB_POINTER;
	  BLK : PCB_POINTER;
	  PRI : [BYTE] BYTE_RANGE;
	  STA : [BYTE] PROCESS_STATE;
	  TYP : [BYTE] PROCESS_TYPE;
	  STS : [BYTE] STATE_CODE_MODIFIER_TYPE;  (* BP *)
	  PNT : PCB_POINTER;
	  EXC : UNIVERSAL;
	  MSK : UNSIGNED;
	  SFA : UNSIGNED; (*RR001*)
	  SPT : STRUCTURE_DESC_PTR; (*RR001*)
	  ALK : PCB_POINTER;
	  SPC : INTEGER;
	  RLK : PCB_POINTER;
	  CXW : [BYTE] CXW_TYPE; (*RR001*)
	  GRP : [BYTE] EXC_GROUP;
	  TER : UNIVERSAL;
	  MCX : UNIVERSAL;
          GOS : UNSIGNED;
          GUS : UNSIGNED;
          EPC : UNSIGNED;
          EPS : UNSIGNED;
	  ESC : UNSIGNED; (*RR001*)
	  TML : UNSIGNED; (*RR001*)
	  TMH : UNSIGNED; (*RR001*)
	  CSD : ARRAY [0..3] OF RECORD (*RR001*)
		FLK : PCB_POINTER; (*RR001*)
		SPT : STRUCTURE_DESC_PTR; (*RR001*)
		PCB : PCB_POINTER; (*RR001*)
		END; (*RR001*)
	  KSP : UNSIGNED;
	  KSV : PACKED RECORD
                  R4, R3, R0, PAR2, PAR3 : UNSIGNED;
		END;
	  USV : PACKED RECORD
                  R0, R1, R2, R3, R4, R5, PC, PS, SP, MCX : UNSIGNED;
		END;
	  MAP : ^PROCESS_MEMORY_MAP; (*RR001*)
	  EXP : UNSIGNED; (*RR001*)
	  TPS : UNSIGNED; (*RR001*)
	  USP : UNSIGNED; (*RR001*)
	  CBP : ^CONTEXT_BLOCK; (*RR001*)
	  STK : PACKED ARRAY [1..38] OF UNSIGNED;
          FSV : PACKED RECORD
		 CASE CONTEXT_SWITCH_OPTIONS OF
		  FPP : ( STAT : UNSIGNED;
                          F0, F1, F2, F3, F4, F5 : QUAD_WORD );
		END;
        END;

(* This routine is used to respond to an exception. *)

[EXTERNAL($DEXCI)] PROCEDURE RELEASE_EXCEPTION
                           ( ACTION  : EXC_ACTION;
                             PCB_PTR : PCB_POINTER ); EXTERNAL;

{END.}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       