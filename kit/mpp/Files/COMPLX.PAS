{MODULE COMPLX;}
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
  to the complex primitives and all of the necessary data structures to
  access the complex requests.

  Author  MN
*)

(*
  Edit history:

	BP	11-SEP-84	Fix stack setup for RECEIVE_ANY_ACK
	SHD/BP	 2-Nov-84	Fix count range
        BP	29-Apr-85	Give RECEIVE_ANY a default for RET_INFO

*)
{$LIST}

TYPE

COMPLEX_COUNT = 1..4;
COMPLEX_FUNC_VALUE = 0..5;


[EXTERNAL($GELAI)] FUNCTION GET_ELEMENT_ANY
                   (VAR SDB4 : RING_BUFFER_DESC := 0;
                    VAR SDB3 : RING_BUFFER_DESC := 0;
                    VAR SDB2 : RING_BUFFER_DESC := 0;
                    VAR SDB1 : RING_BUFFER_DESC;
                    COUNT : COMPLEX_COUNT := 0;
                    LENGTH : RING_BUFFER_DATA;
                    VAR DATA : UNIVERSAL;
                    VAR TIMEOUT : [READONLY] LONG_INTEGER := 0;
                    VAR STATUS : EXC_STATUS := 0) : COMPLEX_FUNC_VALUE; EXTERNAL;


[EXTERNAL($RCANI)] FUNCTION RECEIVE_ANY
                   (VAR SDB4 : QUEUE_SEMAPHORE_DESC := 0;
                    VAR SDB3 : QUEUE_SEMAPHORE_DESC := 0;
                    VAR SDB2 : QUEUE_SEMAPHORE_DESC := 0;
                    VAR SDB1 : QUEUE_SEMAPHORE_DESC;
                    COUNT : COMPLEX_COUNT := 0;
                    VAR REF_DATA : UNIVERSAL := 0;
                    REF_LENGTH : REF_DATA_LEN := 0;
                    VAR VAL_DATA : UNIVERSAL := 0;
                    VAL_LENGTH : VAL_DATA_LEN := 0;
                    VAR RET_INFO : INFO_BLOCK := 0;
                    VAR TIMEOUT : [READONLY] LONG_INTEGER := 0;
                    VAR STATUS : EXC_STATUS := 0) : COMPLEX_FUNC_VALUE; EXTERNAL;


[EXTERNAL($WAIAI)] FUNCTION WAIT_ANY
                   (VAR SDB4 : SEMAPHORE_DESC := 0;
                    VAR SDB3 : SEMAPHORE_DESC := 0;
                    VAR SDB2 : SEMAPHORE_DESC := 0;
                    VAR SDB1 : SEMAPHORE_DESC;
                    COUNT : COMPLEX_COUNT := 0;
                    VAR TIMEOUT : [READONLY] LONG_INTEGER := 0;
                    VAR STATUS : EXC_STATUS := 0) : COMPLEX_FUNC_VALUE; EXTERNAL;


[EXTERNAL($WAQAI)] FUNCTION GET_PACKET_ANY
                   (VAR SDB4 : QUEUE_SEMAPHORE_DESC := 0;
                    VAR SDB3 : QUEUE_SEMAPHORE_DESC := 0;
                    VAR SDB2 : QUEUE_SEMAPHORE_DESC := 0;
                    VAR SDB1 : QUEUE_SEMAPHORE_DESC;
                    COUNT : COMPLEX_COUNT := 0;
                    VAR PACKET_PTR : QUEUE_PTR;
                    VAR TIMEOUT : [READONLY] LONG_INTEGER := 0;
                    VAR STATUS : EXC_STATUS := 0) : COMPLEX_FUNC_VALUE; EXTERNAL;


[EXTERNAL($RAAKI)] FUNCTION RECEIVE_ANY_ACK
                   (VAR SDB4 : QUEUE_SEMAPHORE_DESC := 0;
                    VAR SDB3 : QUEUE_SEMAPHORE_DESC := 0;
                    VAR SDB2 : QUEUE_SEMAPHORE_DESC := 0;
                    VAR SDB1 : QUEUE_SEMAPHORE_DESC;
                    COUNT : COMPLEX_COUNT := 0;
                    VAR REF_DATA : UNIVERSAL := 0;
                    REF_LENGTH : REF_DATA_LEN := 0;
                    VAR REPLY_DESC : SEMAPHORE_DESC := 0;
                    $_BP_$ : INTEGER := 12;
                    VAR REC_LENGTH : REF_DATA_LEN;
                    VAR TIMEOUT : [READONLY] LONG_INTEGER := 0;
                    VAR STATUS : EXC_STATUS := 0) : COMPLEX_FUNC_VALUE; EXTERNAL;

{END.}
                                                                                                                                                                                                                                                                     