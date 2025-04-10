{MODULE MUTEX;}
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
  This is the file that contains the declarations of the interfaces
  to the mutex procedures and all of the necessary data structures to
  access the mutex requests.

  Author  ERS
*)


(*
  Edit history:

	BP 	21-NOV-84	Add status argument for create,destroy

*)
{$LIST}

TYPE

  MUTEX = RECORD
            FLAG : INTEGER;
            SEM : SEMAPHORE_DESC;
          END;

[EXTERNAL($CRMUT)] PROCEDURE CREATE_MUTEX
                   (VAR MUTEX_VAR : MUTEX;
                    WAIT_ORDER : ORDERING := FIFO;
		    VAR STATUS : EXC_STATUS := 0); EXTERNAL;


[EXTERNAL($DSMUT)] PROCEDURE DESTROY_MUTEX
                   (VAR MUTEX_VAR : MUTEX;
		    VAR STATUS : EXC_STATUS := 0); EXTERNAL;


[EXTERNAL($LKMUT)] PROCEDURE LOCK_MUTEX
                   (VAR MUTEX_VAR : MUTEX); EXTERNAL;


[EXTERNAL($UNMUT)] PROCEDURE UNLOCK_MUTEX
                   (VAR MUTEX_VAR : MUTEX); EXTERNAL;

{END.}
                                                                                                                                                                                                                                