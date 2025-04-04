MODULE DATTIM;

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
  This is the module that contains the Date Time subroutines referenced
  by timer.pas. These subroutines perform various conversion functions
  between the internal, kernel time format and date/time records.

  Author  SHD/CDO
*)

(*
  Edit history:

*)

 %INCLUDE 'LB:TIMER.PAS'

  TYPE

    monthtab_typ = PACKED ARRAY [1..12] OF INTEGER;


  [EXTERNAL($CADD)] PROCEDURE $$SHD_ADD(VAR sum: CLOCK_TIME;
                                        VAR start_time: CLOCK_TIME;
                                        add_time: UNSIGNED);
    EXTERNAL;


  [EXTERNAL($CDIV)] PROCEDURE $$SHD_DIV(VAR remainder: UNSIGNED;
                                        VAR quotient: CLOCK_TIME;
                                        dividend: CLOCK_TIME;
                                        divisor: UNSIGNED);
    EXTERNAL;


  [EXTERNAL($CMUL)] PROCEDURE $$SHD_MUL(VAR product: CLOCK_TIME;
                                        multiplicand: CLOCK_TIME;
                                        multiplier: UNSIGNED);
    EXTERNAL;


{+

Procedure to combine a system date record into an unsigned number.

-}


  [GLOBAL($CMDT)] PROCEDURE combine_date {(inp: system_date; VAR date:
                                          UNSIGNED)} ;

    VAR
      year_dif, l, k: UNSIGNED;
      monthtab: monthtab_typ;


    BEGIN
      monthtab := monthtab_typ(31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
      year_dif := inp.year - 1984;
      k := 0;
      FOR l := 1 TO (inp.month - 1) DO
        k := k + monthtab[l];
      IF ((inp.year MOD 4) <> 0) AND (inp.month > 2)
        THEN
          k := k - 1;
      date := (year_dif * 365) + k + (inp.day - 1) + ((year_dif + 3) DIV 4);
    END;

{+

Procedure to translate an unsigned value into a 
system_date record.

-}


  [GLOBAL($SPDT)] PROCEDURE split_date {(date: UNSIGNED; VAR out:
                                        system_date)} ;

    VAR
      quad_year, quad_off, i: UNSIGNED;
      monthtab: monthtab_typ;


    BEGIN
      monthtab := monthtab_typ(31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
                  ;
      i := date + (3 * 365); {Days since 1/1/1981}
      quad_year := i DIV 1461; {Number of 4 year groups elapsed}
      i := i MOD 1461; {Days into this 4 year group}
      quad_off := i DIV 365; {Years into this 4 year group}
      IF quad_off = 4
        THEN
          quad_off := 3; {Dec 31, leap year problem}
      i := i - (quad_off * 365); {Don't use out.day mod 365}
      out.year := 1981 + quad_year * 4 + quad_off;
      i := i + 1; {day 0 is Jan 1}
      IF ((out.year MOD 4) <> 0) AND (i > 31 + 28)
        THEN
          i := i + 1; {Adjust if past Feb 28 in a non-leap year}
      out.month := 1;
      WHILE (i > monthtab[out.month]) DO
        BEGIN
          i := i - monthtab[out.month];
          out.month := out.month + 1;
        END;
      out.day := i;
      out.day_of_the_week := (date MOD 7)::week_day;
    END;


{+

Procedure to combine a system_time record into a triple precision
clock_time.

-}


  [GLOBAL($CMTM)] PROCEDURE combine_time {(inp: system_time; VAR time:
                                          clock_time)} ;


    BEGIN
      time.high := 0;
      time.middle := 0;
      time.low := inp.days;
      $$shd_mul(time, time, 24);
      $$shd_add(time, time, inp.hours);
      $$shd_mul(time, time, 60);
      $$shd_add(time, time, inp.minutes);
      $$shd_mul(time, time, 60);
      $$shd_add(time, time, inp.seconds);
      $$shd_mul(time, time, 1000);
      $$shd_add(time, time, inp.milliseconds);
    END;

{+

Procedure to split a triple precision clock_time into a system_time
record.

-}


  [GLOBAL($SPTM)] PROCEDURE split_time {(time: clock_time; VAR out:
                                        system_time)} ;

    VAR
      temp: UNSIGNED;


    BEGIN
      $$shd_div(temp, time, time, 1000);
      out.milliseconds := temp;
      $$shd_div(temp, time, time, 60);
      out.seconds := temp;
      $$shd_div(temp, time, time, 60);
      out.minutes := temp;
      $$shd_div(temp, time, time, 24);
      out.hours := temp;
      out.days := time.low;
    END;

{+

Procedure to set system date and time

-}


  [GLOBAL($SETDT)] PROCEDURE set_system_date_time
   {(sys_date_time: system_date_time)} ;

    VAR
      clock: clock_time;
      date: system_date;
      time: system_time;
      days: UNSIGNED;


    BEGIN
      date.year := sys_date_time.year;
      date.month := sys_date_time.month;
      date.day := sys_date_time.day;
      combine_date(date, days);
      time.days := days;
      time.hours := sys_date_time.hours;
      time.minutes := sys_date_time.minutes;
      time.seconds := sys_date_time.seconds;
      time.milliseconds := sys_date_time.milliseconds;
      combine_time(time, clock);
      set_time(clock);
    END;


{+

Procedure to get system date and time

-}


  [GLOBAL($GETDT)] PROCEDURE get_system_date_time
   {(VAR sys_date_time: system_date_time)} ;

    VAR
      clock: clock_time;
      date: system_date;
      time: system_time;
      days: UNSIGNED;


    BEGIN
      get_time(clock);
      split_time(clock, time);
      days := time.days;
      sys_date_time.hours := time.hours;
      sys_date_time.minutes := time.minutes;
      sys_date_time.seconds := time.seconds;
      sys_date_time.milliseconds := time.milliseconds;
      split_date(days, date);
      sys_date_time.year := date.year;
      sys_date_time.month := date.month;
      sys_date_time.day := date.day;
      sys_date_time.day_of_the_week := date.day_of_the_week;
    END;
END.
                 