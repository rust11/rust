{MODULE EXC;}
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
  3-DEC-81
  The examples have been removed from this file to make it smaller.  See MN
  for the examples.

  Author  MN
*)

(*
  Edit history:

  MN001   4-May-82   Fix QAR 075 in UPAX5
                     Remove the PCB definition and place each version
                     in a separate file.  Also remove PCB_POINTER.

  MN002   7-Jan-83   Add new exception codes for V1.3

  MN003  20-Jul-84   Add definition of STATUS parameter.

  RR001  18-SEP-84   Add %INCLUDE 'escode.pas'; delete types exceptions,
		     exc_set. Add type cxw_type. Re-define exc_codes to
		     be unsigned.

  SHD/BP 16-OCT-84   Added EXC_SIZE parameter

  BP	 09-NOV-84   Add WAIT_EXCEPTION

  BP	 24-JAN-85   ADD 0 DESC FOR DISCONNECT_EXCEPTION

  BP	 20-Mar-85   Remove error code comments

*)
{Include ES$NNN CONSTant declarations} (*RR001*)
{$LIST}

%INCLUDE 'LB:ESCODE.PAS' (*RR001*)

TYPE
  EXC_ACTION = ( DISMISS, ABORT, PASS );

  CONTEXT_SWITCH_OPTIONS = ( NOFPP, FPP, MMU );

  EXC_CODES = UNSIGNED; (*RR001*)

  CXW_TYPE = PACKED RECORD (*RR001*)
	CX_FPP,CX_MCX,CX_KT,CX_IAD,CX_SUP: BOOLEAN END; (*RR001*)

(* This routine is used to connect an exception process to an exception. *)

[EXTERNAL($CCNDI)] PROCEDURE CONNECT_EXCEPTION
                           ( VAR DESC : QUEUE_SEMAPHORE_DESC;
                             GROUP    : EXC_GROUP := 1;
                             EXC_TYPE : EXC_SET;
                             VAR STATUS : EXC_STATUS := 0 ); EXTERNAL; (* MN003 *)

(* This routine is used to disconnect an exception process from an exception. *)

[EXTERNAL($CCNDI)] PROCEDURE DISCONNECT_EXCEPTION
                           ( $_BP_$ : INTEGER := 0; (* BP *)
			     GROUP    : EXC_GROUP := 1;
                             EXC_TYPE : EXC_SET;
                             VAR STATUS : EXC_STATUS := 0 ); EXTERNAL; (* MN003 *)

(* This routine is used to get a pcb pointer via a queue semaphore. *)

[EXTERNAL($WAIQI)] PROCEDURE WAIT_EXCEPTION           (* BP *)
                           ( VAR PCB_PTR : UNIVERSAL;
                             VAR DESC       : QUEUE_SEMAPHORE_DESC := 0; (*MN007*)
                             VAR NAME       : [READONLY]NAME_STR := 0;
                             VAR STATUS     : EXC_STATUS := 0 ); EXTERNAL; (* MN006,MN007 *)

(* This routine is used to establish an exception procedure. *)

[EXTERNAL($ESTEX)] PROCEDURE ESTABLISH
                           ( PROCEDURE EXC_PROCEDURE (TYP : EXC_SET;
                             COD : EXC_CODES; EXC_INFO_SIZE : UNSIGNED;
			     VAR EXC_INFO : [READONLY] UNIVERSAL); 


                             EXC_TYPE : EXC_SET ); EXTERNAL;

(* This routine is used to revert an exception procedure. *)

[EXTERNAL($RVTEX)] PROCEDURE REVERT
                           ( EXC_TYPE : EXC_SET ); EXTERNAL;

(* This routine is used to report an exception. *)

[EXTERNAL($RPTEX)] PROCEDURE REPORT
                           ( VAR EXC_INFO : [READONLY] UNIVERSAL := 0;
			     EXC_INFO_SIZE : UNSIGNED := 0;
                             EXC_CODE     : EXC_CODES;
                             EXC_TYPE     : EXC_SET ); EXTERNAL;


{END.}
  