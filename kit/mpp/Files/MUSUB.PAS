[system(micropower)] Module MU_routines;
{ MUSUB.PAS

  THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED OR COPIED
  ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE.
 
  COPYRIGHT (c) 1985, 1986 BY DIGITAL EQUIPMENT CORPORATION.
 		ALL RIGHTS RESERVED.

  Module to provide procedure definitions for the TK50 cartridge
  tape driver }

%INCLUDE 'LB:IOPKTS.PAS'

[Global($MUINI)]
 PROCEDURE init_tape_cntl(VAR mu_desc : STRUCTURE_DESC);

VAR
  io_request : io$req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := if$init;
	dep_mod := [];
	ind_mod := [];
    END;
  SEND(PRIORITY := 20,
       VAL_DATA := io_request,
       VAL_LENGTH := 34,
       DESC := mu_desc);
END;

[Global($MUMRK)]
 PROCEDURE write_tape_mark(VAR mu_desc : STRUCTURE_DESC;
		reply : STRUCTURE_DESC_PTR:=nil);

VAR
  io_request : io$req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := if$tape_mark;
	dep_mod := [];
	ind_mod := [];
	unit_num := 0;
	IF reply <> nil THEN reply_sem := reply^.id;
    END;
  SEND(PRIORITY := 20,
       VAL_DATA := io_request,
       VAL_LENGTH := 34,
       DESC := mu_desc);
END;

[Global($MURWD)]
 PROCEDURE rewind_tape(VAR mu_desc : STRUCTURE_DESC;
		reply : STRUCTURE_DESC_PTR:=nil);

VAR
  io_request : io$req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := if$rewind;
	dep_mod := [];
	ind_mod := [];
	modifier := 0;
	object_count := 0;
	mark_count := 0;
	unit_num := 0;
	IF reply <> nil THEN reply_sem := reply^.id;
    END;
  SEND(PRIORITY := 20,
       VAL_DATA := io_request,
       VAL_LENGTH := 34,
       DESC := mu_desc);
END;

[Global($MUPOS)]
 PROCEDURE reposition_tape(ocount : long_integer;
		mcount : long_integer;
		mod_oper : unsigned;
	    VAR mu_desc : STRUCTURE_DESC;
	        reply : STRUCTURE_DESC_PTR:=nil);

VAR
  io_request : io$req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := if$reposition;
	dep_mod := [];
	ind_mod := [];
	unit_num := 0;
	modifier := mod_oper;
	object_count := ocount;
	mark_count := mcount;
	IF reply <> nil THEN reply_sem := reply^.id;
    END;
  SEND(PRIORITY := 20,
       VAL_DATA := io_request,
       VAL_LENGTH := 34,
       DESC := mu_desc);
END;

[Global($MUWRT)]
 PROCEDURE write_tape(
	    VAR buffer : PACKED ARRAY[first..last: INTEGER] OF CHAR;
	    VAR mu_desc : STRUCTURE_DESC;
	        reply : STRUCTURE_DESC_PTR:=nil);
VAR
  io_request : io$req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := if$write_logical;
	dep_mod := [];
	ind_mod := [];
	unit_num := 0;
	IF reply <> nil THEN reply_sem := reply^.id;
    END;
  SEND(PRIORITY := 20,
       VAL_DATA := io_request,
       VAL_LENGTH := 22,
       DESC := mu_desc,
       REF_DATA := buffer,
       REF_LENGTH := last-first+1);
END;

[Global($MURDT)]
 PROCEDURE read_tape(
	    VAR buffer : PACKED ARRAY[first..last: INTEGER] OF CHAR;
	    VAR mu_desc : STRUCTURE_DESC;
	        reply : STRUCTURE_DESC_PTR:=nil);

VAR
  io_request : io$req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := if$read_logical;
	dep_mod := [];
	ind_mod := [];
	unit_num := 0;
	IF reply <> nil THEN reply_sem := reply^.id;
    END;
  SEND(PRIORITY := 20,
       VAL_DATA := io_request,
       VAL_LENGTH := 22,
       DESC := mu_desc,
       REF_DATA := buffer,
       REF_LENGTH := last-first+1);
END;

END.
                                                                                                                                                                                                             