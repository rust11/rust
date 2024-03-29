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
  This file contains the CARS3 program as documented in the
  Introdction to MicroPower/Pascal manual. It is the program
  built by the installation verification procedures.
*)


[SYSTEM(MICROPOWER), PRIORITY(1),
 DATA_SPACE(2000), STACK_SIZE(400)] PROGRAM CARS3;

VAR
  S1, S2 : SEMAPHORE_DESC;  (* Semaphores for the "handshake" mechanism *)
  Ok     : BOOLEAN;         (* Indicates successful semaphore creation *)


[INITIALIZE] PROCEDURE Setup;
BEGIN
  Ok := CREATE_BINARY_SEMAPHORE ( DESC := S1, VALUE := 0 ) AND
        CREATE_BINARY_SEMAPHORE ( DESC := S2, VALUE := 0 );
END;


PROCEDURE Clear_screen;
BEGIN
  WRITE (''(27)'[2J');
END;


[STACK_SIZE(400)] PROCESS Car (Line : INTEGER;
                               VAR Start, Done : SEMAPHORE_DESC);
VAR
  Column : INTEGER;

  PROCEDURE Move_car_right;
  BEGIN
    WRITE (''(27)'[', Line:1, ';', Column:1, 'H');   
    IF Column < 77
     THEN
       BEGIN
         WRITE (' #');
         Column := Column + 1;
       END
     ELSE
       BEGIN
         WRITE (' ');   
         Column := 1;   
         WRITE (''(27)'[', Line:1, ';', Column:1, 'H#');   
       END;
  END;


BEGIN   (* Process car *)
  Column := 1;
  WHILE TRUE DO
    BEGIN
      WAIT (DESC := Start);
      Move_car_right;
      SIGNAL (DESC := Done);
    END;
END;   (* Process car *)


BEGIN
  IF Ok
   THEN
     BEGIN
       Clear_screen;
       (* create first car on line 10 *)
       Car (Line := 10, Start := S1, Done := S2,
            PRIORITY := 2, NAME := 'LANE10');
       (* create second car on line 12 *)
       Car (Line := 12, Start := S2, Done := S1,
            PRIORITY := 3, NAME := 'LANE12');
       SIGNAL (DESC := S1);
     END;
END.
                                                                                                                                                                                                                                                                                                                                                                                                                                                                     