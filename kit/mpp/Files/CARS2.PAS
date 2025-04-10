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
  This file contains the CARS2 program as documented in the
  Introduction to MicroPower/Pascal manual.
*)


[SYSTEM(MICROPOWER), PRIORITY(1),
 DATA_SPACE(2000), STACK_SIZE(400)] PROGRAM CARS2;


PROCEDURE Clear_Screen;
BEGIN
  WRITE(''(27)'[2J');	
END;


[ PRIORITY(2), STACK_SIZE(400) ] PROCESS Car (line : INTEGER);
VAR
  Column : INTEGER;

PROCEDURE Move_car_right ;
BEGIN
  WRITE (''(27)'[',line:1,';',column:1,'H');
  IF column < 77
   THEN  
     BEGIN  
       WRITE (' #');  
       Column := Column + 1;  
     END
   ELSE
     BEGIN
       WRITE (' ');
       Column := 1;
       WRITE (''(27)'[', Line:1,';', Column:1,'H#');
     END;
END;


BEGIN	(* Process Car *)
  Column := 1;
  WHILE TRUE DO 
    Move_car_right;
END;



BEGIN
  Clear_screen;
  Car (Line := 10);	{ create one car on line 10 }
END.
                                                                                                                                                                                                                                                                                                                                       