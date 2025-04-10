{MODULE FSINCL;}
{$NOLIST}

{
                   Copyright (c) 1984, 1986 by
             Digital Equipment Corporation, Maynard
              Massachusetts.  All rights reserved.

 This software is furnished under a license and may be used and  copied
 only  in  accordance  with  the  terms  of  such  license and with the
 inclusion of the above copyright notice.  This software or  any  other
 copies  thereof may not be provided or otherwise made available to any
 other person.  No title to and ownership of  the  software  is  hereby
 transferred.

 The information in this software is subject to change  without  notice
 and  should  not  be  construed  as  a commitment by Digital Equipment
 Corporation.


 DIGITAL assumes no responsibility for the use or  reliability  of  its
 software on equipment that is not supplied by DIGITAL.

}
{$LIST}
(*
 * This is the include file for the interface between PASCAL and
 * the file system 
 *)

type

  densities = (double,single);

(*
 *  init_directory ('device',directory size );
 *)

[external($initd)] procedure init_directory
		   (var strng : [readonly]packed array [l..u:integer] of char;
		    dirsiz : integer := 0;
		    var status : exc_status := 0 ); external;

(*
 *  squeeze_directory ('device', status );
 *)

[external ($squez)] procedure squeeze_directory
             (var strng : [readonly] packed array [l..u:integer] of char;
              var status : exc_status := 0 ); external;

(*
 *  delete_file ('filespec',status)
 *)

[external($delef)] procedure delete_file
		    (var strng : [readonly]packed array [l..u:integer] of char;
		     var status : exc_status := 0 ); external; 


(*
 *  rename_file ('old-filespec','new-filespec',status)
 *)

[external($renmf)] procedure rename_file
		  (var old_name:[readonly]packed array [l..u:integer] of char;
		   var new_name:[readonly]packed array [nl..nu:integer] of char;
		   var status : exc_status := 0 ); external; 
(*
 * protect_file ('filespec',status)
 *)

[external($protf)] procedure protect_file
		    (var strng : [readonly]packed array [l..u:integer] of char;
		     var status : exc_status := 0 ); external; 


(*
 * unprotect_file ('filespec',status)
 *)

[external($unprf)] procedure unprotect_file
		    (var strng : [readonly]packed array [l..u:integer] of char;
		     var status : exc_status := 0 ); external; 


(*
 * format_rx02 (Controller,Unit,Density);
 *)

[external($formt)] procedure format_rx02
			(controller : char := 'a';
		    	 unit : integer := 0;
			 density : densities := double);external;

{end.}
                                                                                                                                                                                                                                                                                                                                                                                                                              