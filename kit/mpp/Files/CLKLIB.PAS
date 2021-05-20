{MODULE CLKLIB;}

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
  Version 1 clock interface subroutines.
  This file is provided for version 1.5 compatibility. It provides
  an interface to the version 2 kernel clock service that is compatible
  with procedures provided for version 1 in CLKLIB.PAS. An application
  using this include file must be built with the modules DATTIM.PAS and
  VT100.PAS.

  Author  LP
*)

(*
  Edit history:

        SHD/JMS 8-Oct-84	Version 2 compatibility updates


  This file defines clock functions/procedures and constants, types
  and variables employed with the clock procedures.
  INCLUDE this file at the outer block of your application system.
  The application system should initialize this clock "package" by call-
  ing Initclock which will create the necessary semaphores and setup
  date and time by calling Set_time_date. Lines marked with a  {D} are
  optional--they cause the following actions: VT100 is set, a scrolling
  region is established for lines 5..24, a get current-time call is made
  and the current time and date are displayed at line 1, column 40.

*)


{$NOLIST}

 %INCLUDE 'LB:TIMER.PAS'
 %INCLUDE 'LB:VT1INC.PAS'
 %INCLUDE 'LB:MISC.PAS'

{$LIST}

  TYPE
   
    month = (january, february, march, april, may, june, july, august,
             september, october, november, december);

    date_time =
      PACKED RECORD
        second, minute, hour, day, mon, year: byte_range;
      END;

    msg_sig_sem =
      PACKED RECORD
        function_code, sequence_num: INTEGER;
        reply_sem: structure_id;
        time_intval: LONG_INTEGER;
      END;

    month_abrev = PACKED ARRAY [1..3] OF char;
    month_list = PACKED ARRAY [1..36] OF char;

  VAR

    current_time: date_time; 		{Record of 6 8-bit values: }
					{ Second,Minute,Hour,Day,}
					{ Month,Year(since 1980) }
    sys_time: REAL; 			{Seconds since midnight}

    ticks_per_second: INTEGER; 		{ Initialized by INITCLOCK procedure }
    uniq_seq_num: INTEGER;

    month_text: PACKED ARRAY [0..11] OF month_abrev;


  FUNCTION next_seq_num: integer;

  { A unique sequence number is returned for each call.  The sequence number
   cycles modulo 2**16. }


    BEGIN
      uniq_seq_num := uniq_seq_num + 1;
      next_seq_num := uniq_seq_num
    END;



  [PRIORITY(100), STACK_SIZE(126)] PROCESS clocker
       (sem: semaphore_desc;
        msecs_interval: LONG_INTEGER);


    BEGIN
      WHILE TRUE DO
        BEGIN
          sleep(msecs_interval);
          SIGNAL(sem);
        END;
    END;


  PROCEDURE Signal_periodic(VAR REQUEST: msg_sig_sem;
                            VAR SEMPHR: semaphore_desc;
                            INTERVAL: INTEGER);

{Signals a specified binary or counting  semaphore (SEMPHR) at 
 the given INTERVAL. }

    VAR
      config: hardware_config;
      t: LONG_INTEGER;


    BEGIN
      get_config(ticks_per_second, config); { Get clock frequency }
      CASE ticks_per_second OF 		    { Convert ticks to milliseconds }

        50:
          t := interval * 20;
        60:
          BEGIN
            t := (interval DIV 3) * 50; 
            CASE (interval MOD 3) OF
              1:
                t := t + 17;
              2:
                t := t + 34;
              END;
          END;
        100:
          t := interval * 10;
        800:
          BEGIN
            t := (interval DIV 4) * 5;
            CASE (interval MOD 4) OF
              1, 2:
                t := t + 1;
              3:
                t := t + 2;
              END;
          END;
        END;
      clocker(semphr, t); { start process to signal semaphore }
    END; {Signal_periodic}



  PROCEDURE get_time_date(VAR x: date_time;
                          VAR t: real);

    VAR

      date_rec: system_date_time;


    BEGIN
      get_system_date_time(date_rec);
      x.second := date_rec.seconds;
      x.minute := date_rec.minutes;
      x.hour := date_rec.hours;
      x.day := date_rec.day - 1;
      x.mon := date_rec.month-1;
      x.year := date_rec.year - 1980;

      t := x.hour * 3600.0 + x.minute * 60.0 + x.second +
           date_rec.milliseconds DIV 1000;

    END { get_time_date } ;


  PROCEDURE display_time_date(x: date_time);

    CONST

      line = 1; { Line that the time and date are displayed.}
      column = 40; { Column that the time and date begin in. }

    VAR

      dy, yr: integer;


    BEGIN
      yr := x.year + 1980;
      dy := x.day + 1;
      {D} save;
      {D} plot(line, column);
      WRITE('DATE: ', dy: 2, '-', month_text[x.mon], '-', yr: 4, '  ',
              'TIME: ');
      IF x.hour < 10 THEN WRITE('0');
      WRITE(x.hour:1,':');
      IF x.minute < 10 THEN WRITE('0');
      WRITE(x.minute:1,':');
      IF x.second < 10 THEN WRITE('0');
      WRITELN(x.second:1);
      {D} restore;
    END { display_time_date } ;



  PROCEDURE set_time_date;

    VAR

      mm, dd, yy, mxday, hh, mi, ss: INTEGER;
      good_time, good_date: BOOLEAN;
      x: system_date_time;
      xmonth: month;


    BEGIN
      good_date := false;
      good_time := false;
      WRITELN('Enter today''s date and time.');
      WHILE NOT good_date DO
        BEGIN
          WRITE('Today''s date [mm dd yyyy]: ');
          READ(mm, dd, yy);
          WRITELN;
          IF (mm > 0) AND (mm < 13) AND (dd > 0) AND (yy > 1983)
            THEN
              BEGIN
                xmonth := january;
                WHILE mm <> ord(xmonth) + 1 DO
                  xmonth := succ(xmonth);
                CASE xmonth OF
                  january, march, may, july, august, october, december:
                    mxday := 31;
                  april, june, september, november:
                    mxday := 30;
                  february:
                    IF (yy MOD 4 = 0) AND (yy MOD 100 <> 0)
                      THEN
                        mxday := 29
                      ELSE
                        mxday := 28
                  END { CASE } ;
                IF dd <= mxday
                  THEN
                    good_date := true
                  ELSE
                    writeln('Invalid date specified.');
              END
            ELSE
              writeln('Invalid date specified.');
          IF good_date
            THEN
              WHILE NOT good_time DO
                BEGIN
                  WRITE('The time using a 24 hour clock [hh mm ss]');
                  READ(hh, mi, ss);
                  WRITELN;
                  IF (hh >= 0) AND (hh < 24) AND (mi >= 0) AND (mi < 60) AND
                       (ss >= 0) AND (ss < 60)
                    THEN
                      good_time := true
                    ELSE
                      writeln('Error specifying the time of day.');
                END;
        END;
      WITH x DO
        BEGIN
          seconds := ss;
          minutes := mi;
          hours := hh;
          day := dd;
          month := mm;
          year := yy;
          milliseconds := 0;
        END;
      set_system_date_time(x);
    END { set_time_date } ;



  PROCEDURE Initclock;

    VAR
      config: hardware_config;


    BEGIN
      get_config(ticks_per_second, config); { Initialize clock frequency }
      uniq_seq_num := 0; { Initialize unique sequence number. }

      { Initialize the array, month_text. }

      month_text::month_list := 'JanFebMarAprMayJunJulAugSepOctNovDec';
      set_time_date;
      {D} get_time_date(current_time, SYS_TIME);
      {D} display_time_date(current_time);
    END; {Procedure Initclock}

{END.}
                                                                                 