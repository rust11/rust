{ MUINC.PAS

  THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED OR COPIED
  ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE.
 
  COPYRIGHT (c) 1985, 1986 BY DIGITAL EQUIPMENT CORPORATION.
 		ALL RIGHTS RESERVED.

  Include file to provide procedure definitions for the TK50 cartridge
  tape driver }

[External($MUINI)]
 PROCEDURE init_tape_cntl(VAR mu_desc : STRUCTURE_DESC);EXTERNAL;

[External($MUMRK)]
 PROCEDURE write_tape_mark(VAR mu_desc : STRUCTURE_DESC;
		VAR reply : STRUCTURE_DESC:=0);EXTERNAL;

[External($MURWD)]
 PROCEDURE rewind_tape(VAR mu_desc : STRUCTURE_DESC;
		VAR reply : STRUCTURE_DESC:=0);EXTERNAL;

[External($MUPOS)]
 PROCEDURE reposition_tape( ocount : long_integer;
		mcount : long_integer;
		mod_oper : unsigned;
	    VAR mu_desc : STRUCTURE_DESC;
	    VAR reply : STRUCTURE_DESC:=0);EXTERNAL;

[External($MUWRT)]
 PROCEDURE write_tape(
	    VAR buffer : PACKED ARRAY[first..last: INTEGER] OF CHAR;
	    VAR mu_desc : STRUCTURE_DESC;
	    VAR reply : STRUCTURE_DESC:=0);EXTERNAL;

[External($MURDT)]
 PROCEDURE read_tape(
	    VAR buffer : PACKED ARRAY[first..last: INTEGER] OF CHAR;
	    VAR mu_desc : STRUCTURE_DESC;
	    VAR reply : STRUCTURE_DESC:=0);EXTERNAL;

{ End of MUINC.PAS }
                                                                                                                                                                                                                                                                           