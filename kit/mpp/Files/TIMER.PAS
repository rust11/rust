{MODULE TIMER;}
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
  This is the that file that contains the declarations of the interfaces
  to the timer primitives and all of the necessary data structures to
  access the timer requests.

  Author  MN
*)

(*
  Edit history:

        BP      05-SEP-84       Removed error status for all modules
        SHD/CDO 03-OCT-84       Include date time subroutines
*)
{$LIST}

TYPE

  clock_time_use = (clock_value, sleep_interval);

  clock_time =
    RECORD
      CASE clock_time_use OF
	clock_value: (low, middle, high: UNSIGNED);
	sleep_interval: (interval: LONG_INTEGER; overflow: UNSIGNED);
    END;

  week_day = (Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday);

  system_date =
    RECORD
      year: INTEGER; { 1984..2099 }
      month: 1..12;
      day: 1..31;
      day_of_the_week: week_day;
    END;

  system_time =
    RECORD
      days: UNSIGNED;
      hours: 0..23;
      minutes: 0..59;
      seconds: 0..59;
      milliseconds: 0..999;
    END;

  system_date_time =
    RECORD
      year: INTEGER; { 1984..2099 }
      month: 1..12;
      day: 1..31;
      hours: 0..23;
      minutes: 0..59;
      seconds: 0..59;
      milliseconds: 0..999;
      day_of_the_week: week_day;
    END;



[EXTERNAL($GTIMI)] PROCEDURE GET_TIME(VAR SYS_TIME: CLOCK_TIME);
  EXTERNAL;


[EXTERNAL($SLEPI)] PROCEDURE SLEEP(VAR INTERVAL: [READONLY] LONG_INTEGER);
  EXTERNAL;


[EXTERNAL($STIMI)] PROCEDURE SET_TIME(VAR SYS_TIME: CLOCK_TIME);
  EXTERNAL;


[EXTERNAL($CSUB)] PROCEDURE subtract_clock_time
     (VAR difference: CLOCK_TIME;
      VAR start_time: CLOCK_TIME;
      VAR end_time: CLOCK_TIME);
  EXTERNAL;


[EXTERNAL($CADDT)] PROCEDURE add_clock_time
     (VAR sum: CLOCK_TIME;
      VAR start_time: CLOCK_TIME;
      VAR add_time: CLOCK_TIME);
  EXTERNAL;


[EXTERNAL($CMDT)] PROCEDURE combine_date
     (inp: system_date;
      VAR date: UNSIGNED);
  EXTERNAL;


[EXTERNAL($SPDT)] PROCEDURE split_date(date: UNSIGNED;
                                       VAR out: system_date);
  EXTERNAL;


[EXTERNAL($CMTM)] PROCEDURE combine_time
     (inp: system_time;
      VAR time: clock_time);
  EXTERNAL;


[EXTERNAL($SPTM)] PROCEDURE split_time(time: clock_time;
                                       VAR out: system_time);
  EXTERNAL;


[EXTERNAL($SETDT)] PROCEDURE set_system_date_time
     (sys_date_time: system_date_time);

  EXTERNAL;


[EXTERNAL($GETDT)] PROCEDURE get_system_date_time
     (VAR sys_date_time: system_date_time);

  EXTERNAL;

{END.}
                                                                                                                    