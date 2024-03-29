{MODULE LOGNAM;}
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
  to the logical name primitives and all of the necessary data structures to
  access the logical name requests.

  Author  MN
*)

(*
  Edit history:

   30-Oct-84/SHD	Correct length and add override default.
   07-Mar-85/ERS	Update to make VAR
*)
{$LIST}

TYPE

  LOGICAL_NAME_LEN = 1..256;


[EXTERNAL($CRLNI)] PROCEDURE CREATE_LOGICAL_NAME
                   (OVERRIDE : BOOLEAN := FALSE;
                    LENGTH : LOGICAL_NAME_LEN;
                    VAR STRING : [READONLY] UNIVERSAL;
                    VAR DESC : STRUCTURE_DESC := 0;
                    VAR NAME : [READONLY]NAME_STR;
                    VAR STATUS : EXC_STATUS := 0); EXTERNAL;


[EXTERNAL($TRLNI)] PROCEDURE TRANSLATE_LOGICAL_NAME
                   (VAR LENGTH : LOGICAL_NAME_LEN;
                    VAR STRING : UNIVERSAL;
                    VAR DESC : STRUCTURE_DESC := 0;
                    VAR NAME : [READONLY]NAME_STR := 0;
                    VAR STATUS : EXC_STATUS := 0); EXTERNAL;


[EXTERNAL($DLLNI)] PROCEDURE DELETE_LOGICAL_NAME
                   (VAR DESC : STRUCTURE_DESC := 0;
                    VAR NAME : [READONLY]NAME_STR := 0;
                    VAR STATUS : EXC_STATUS := 0); EXTERNAL;

{END.}
                                                                                                                                                                                                                                                                                                                                                             