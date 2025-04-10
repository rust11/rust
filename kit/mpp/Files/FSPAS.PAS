[System(MicroPower), Data_space(3000), Stack_size(400)] PROGRAM FSD001;

{
 THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED OR COPIED
 ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE.

 COPYRIGHT (c) 1982, 1986 BY DIGITAL EQUIPMENT CORPORATION.
 ALL RIGHTS RESERVED.
}

{
 This program requires the following system drivers:
      TT driver ( terminal driver )
      DU driver ( may be replaced by any disk class device )
      ACP process ( RT-11 Ancillary Control Process )
}

const
    permfile = %O'2000';
    end_of_segment = %O'4000';
    protected_permfile = %O'102000';

type
    entry  = record
		 status,
		 name1,
		 name2,
		 exten,
		 length,
		 active,
		 date    : integer;
	     end;

    string = packed array [1..3] of char;
    dseg = array [0..511] of integer;

var
    f  : text;
    dirfile  : file of dseg;  
    index, entries, next_seg : integer;
    end_of_seg : boolean;
    i  : integer;
    this_entry : entry;
    extra_words : integer;

    procedure print_date ( dateword : integer );

    var
	i : integer;
	m, d, y : integer;
	months : packed array [1..36] of char;

      begin
	months := 'JanFebMarAprMayJunJulAugSepOctNovDec';
	if dateword <> 0
	  then
	    begin
	      y := (dateword mod 32) + 72;
	      dateword := dateword div 32;
	      d := dateword mod 32;
	      m := dateword div 32;
	      write ('    ', d:2, '-');
	      for i := (m * 3) - 2 to (m * 3) do write (months[i]);
	      write ('-', y:2);
	    end
	  else write ('    ??-???-??');
      end;
    function ascii_value (rad50 : unsigned): string;

	{ Converts Rad50 letters and numbers to ASCII.  }
	{ Rad50 ".","$", and "UNUSED" are not supported }

    const
	radix = 40;  { Radix 50 in Octal }

    var
	position,
	power  : integer;
	quotient,
	remainder : unsigned;



	function raise (rad : integer ; pow : integer) : integer;

	    { Raise Radix 'Rad' to Power 'Pow' }

	var
	    i,j : integer;

	  begin
	    j := 1;
	    if pow > 0
	      then for i := 1 to pow do
	      j := j * rad;
	    raise := j;
	  end;



	{ Start of ASCII_Value }
      begin
	power := 2;
	for position := 1 to 3 do
	  begin
	    quotient := (rad50 div (raise (radix,power)));
	    remainder := (rad50 - (quotient * raise (radix,power)));
	    if quotient = 0
	      then ascii_value[position] := ' '
	      else
		if quotient < 27
		  then ascii_value [position] := chr (quotient + 64)
		  else ascii_value [position] := chr (quotient + 18);

	    power := power - 1;
	    rad50 := remainder;
	  end;
      end;
    function new_entry(start: integer): entry;

      begin
	new_entry.status   :=   dirfile^[start];
	New_Entry.name1    :=   dirfile^[start+1];
	New_Entry.name2    :=   dirfile^[start+2];
	New_Entry.exten    :=   dirfile^[start+3];
	New_Entry.length   :=   dirfile^[start+4];
	New_Entry.active   :=   dirfile^[start+5];
	New_Entry.date    :=   dirfile^[start+6];

      end;



    procedure dir_print (entry_to_print:entry);

      begin
	with entry_to_print do
	  begin
	    writeln;
	    write (ascii_value(name1));
	    write (ascii_value(name2));
	    write ('.');
	    write (ascii_value(exten));
	    write ('   ');
	    write (length);
	    if status = protected_permfile
	      then write ('P')
	      else write (' ');
	    write ('   ');
	    print_date (date);
	  end;
      end;

  begin { main block }
    writeln ('FSD001 start...');
    writeln ('Directory of DUA0:');
    writeln;
    open (dirfile, 'DUA0:', buffersize := 512,
	  history := old, access_method := direct,
	  overlapped := disable, autobreak := false);
    reset (dirfile);
    find (dirfile,4); { get first directory segment (block 6) }

    extra_words := dirfile^[3] DIV 2;
    next_seg := 1; { start at first segment }

      repeat
	find (dirfile,next_seg+3); { get directory segment }
	end_of_seg := FALSE;
	index := 5;      { Skip segment header words 0..4 }
	next_seg := dirfile^[1];

	while not end_of_seg do
	  begin
	    this_entry := new_entry (index);
	    if this_entry.status = end_of_segment
	      then end_of_seg := true
	      else
		if (this_entry.status = permfile) or
		  (this_entry.status = protected_permfile)
		  then dir_print (this_entry);
	    index := index + 7 + extra_words;
	  end;

      until next_seg = 0;

    close ( dirfile );
    writeln;
    writeln ('FSD001 completed...');
  end.
                                                                                       