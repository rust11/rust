    [System(MicroPower)] Module initdirectory;

    {
     Edit Level 0

     Copyright (c) 1985, 1986
     by DIGITAL EQUIPMENT CORPORATION, 
     Maynard, Massachusetts.
     All Rights Reserved.


     This software is furnished under a license and may be used and  copied
     only  in  accordance  with  the  terms  of  such  license and with the
     inclusion of the above copyright notice.  This software or  any  other
     copies  thereof may not be provided or otherwise made available to any
     other person.  No title to and ownership of  the  software  is  hereby
     transferred.


     The information in this software is subject to change  without  notice
     and  should  not  be  construed  as  a commitment by DIGITAL EQUIPMENT
     CORPORATION.


     DIGITAL assumes no responsibility for the use or  reliability  of  its
     software on equipment that is not supplied by DIGITAL.




     Module name: INTDIR.PAS

     System: MicroPower/Pascal

     Author: ERS  Creation date: 19-Jun-84

     Modified:

     Functional Description:

     This module defines the INIT_DIRECTORY Procedure.

     }
    %include 'LB:exc.pas'
    [global ($initd)] procedure init_directory
	(var strng : [readonly] packed array [l..u:integer] of char;
	     dirsiz : integer := 0;
	 var status : exc_status := 0);

    label
	99;

    const
	rec_offset = 1; { PASCAL sees file as record 1 to N instead of 0..n-1 }
	dir_offset = 6; { Starting block of RT-11 directories }

	{ Directory status bits }
	tentfile = %O'400';
	emptyfile = %O'1000';
	permfile = %O'2000';
	endsegment = %O'4000';
	protpermfile = %O'102000';

    type
	segtype = (int_typ, rec_typ);
	home_data = array[0..22] of integer;

	dbuf = packed record 
		  case segtype of
		       int_typ : ( buff : array [0..255] of unsigned; );
		       rec_typ : ( bad_block : array [0..64] of unsigned;
				  reserved : array[65..232] of unsigned;
				  home_info : home_data; );
	      end;

    var
	i : integer;
	f : file of dbuf;
	numsegs : integer;
	size : unsigned;
	error_status : exc_status;
	(*
	 * Abort this procedure, filling in the return status
	 *)
	procedure error_exit (error_status : exc_status);
	type
	  pain_full = ^ exc_status;
	var
	  i : integer;
	  begin
	    i::pain_full := address (status);
	    if i <> 0
	      then status := error_status
	      else 
		if error_status.exc_code <> ES$NOR
		  then report (exc_type := error_status.exc_type,
			       exc_code := error_status.exc_code,
			       exc_info := 0, exc_info_size := 0);
	    goto 99;
	  end;
      begin
	f :: integer := 0; { don't allow uninitialized variable bug }
	open (f, strng, filesize := i, buffersize := 512, history := old,
	      access_method := update, overlapped := disable,
	      autoempty := false, status := error_status);

	size := i :: unsigned; { for some reason, filesize is an integer }
	if error_status.exc_code <> ES$NOR
	  then error_exit (error_status);
	reset (f);

	if (dirsiz = 0) or (dirsiz > 31)
	  then { default directory size }
	    begin
	      numsegs := 1;
	      if size > 512
		then numsegs := 4;
	      if size > (2 * 1024)
		then numsegs := 16;
	      if size > (12 * 1024)
		then numsegs := 31; 
	    end
	  else numsegs := dirsiz;

	for i := 0 to 255 do f^.buff[i] := 0;  { Clear block 0 }
	{ Flag non-bootable for firmware/HALT if booted. }
	put (f); { output block 0 }
	{
	 Home Block Definition  (Logical Block 1 on disk)
	 ( all numbers are in octal bytes )
	   0..201 - bad block replacement table
	 700..701 - reserved, MBZ (must be zero)
	 702..703 - reserved, MBZ
	 722..723 - Pack cluster size
	 724..725 - Block number of first directory segment
	 726..727 - System Version
	 730..743 - Volume Identification (Default 'RT11A' and 7 spaces)
	 744..757 - Owner name (Default 12. spaces)
	 760..773 - System Identification (Default 'DECRT11A' and 4 spaces)
	 776..777 - Checksum (sum of all bytes into a word, negated)
	 }

        i := f^.buff[0];  { force read of 1st block }
	for i := 65 to 232 do f^.reserved[i] := 0;
	f^.home_info := HOME_DATA
			 (1, dir_offset,
			   %O'107123' { RAD50 'V05'  System Version },
			   %O'52122'  { 'RT11A' & 7 spaces  volid },
			   %O'30461',
			   %O'020101',
			   3 OF %O'20040',
			   6 OF %O'20040' { Owner },
			   %O'42504' { ASCII "DECRT11A    " System Id * },
			   %O'51103',
			   %O'30524',
			   %O'40461',
			   %O'20040',
			   %O'20040',
			   0  { undefined word..reserved },
			   0 { sum of all bytes added to a word, then negated }  );

	put(f);    { output the home block }
	find (f, dir_offset+rec_offset); { seek to first segment }

        i := f^.buff[0];  { force read of block }
	{ fill in first directory segment }

	f^.buff[0] := numsegs; { number of segments in directory }
	f^.buff[1] := 0;  { No next segment }
	f^.buff[2] := 1;  { High seg in use is segment 1 }
	f^.buff[3] := 0;  { extra bytes per directory entry }
	f^.buff[4] := dir_offset + (numsegs*2); { block number of 1st file }

	{ fill in first directory entry }

	f^.buff[5] := emptyfile; { status word = empty entry }
	f^.buff[6] := %O'325'; { name = ' EMPTYFIL' }
	f^.buff[7] := %O'63471';
	f^.buff[8] := %O'23364';
	f^.buff[9] := size - (numsegs*2 + dir_offset); { size of this empty }
	f^.buff[10] := 0;  { Channel number }
	f^.buff[11] := 0;   { Creation date }

	f^.buff[12] := endsegment;   { end segment for next entry }

	put(f);  { output first directory segment }
	close(f);

	error_exit (error_status);
99:
      end;

end. 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                