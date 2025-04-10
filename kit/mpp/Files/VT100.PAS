    [System(MicroPower)] Module VT100;

    {
     This software is furnished under a license and may be used or copied
     only in accordance with the terms of such license.

     Copyright (c) 1984, 1986 by Digital Equipment Corporation.
     All rights reserved.
     }

type
    character_two = packed array [1..2] of char;
    character_three = packed array [1..3] of char;
    cursor_report = packed record
			       length : integer;
			       string : packed array [1..10] of char;
			   end;

const
    esc = 27; (* system dependent *)

    procedure escape_out;
      begin
	write (chr(esc))
      end;

    procedure prefix;
      begin
	escape_out;
	write ('[');
      end;

    procedure simple_one (term : char);
      begin
	escape_out;
	write (term);
      end;

    procedure simple_two (term : character_two);
      begin
	escape_out;
	write (term);
      end;

    procedure simple_three (term : character_three);
      begin
	escape_out;
	write (term);
      end;

    procedure report_cursor (var x : cursor_report);
    var
	done : boolean;
	y : char;
	i : integer;
      begin
	simple_three ('[6n');
	break(output);
	i := 0;
	  repeat
	    with x do
	      begin
		i := i + 1;
		read (y);
		string[i] := y;
		done := y = 'R';
	      end;
	  until done;
	x.length := i;
	x.string[i] := 'H';
      end;

    [global ($vt100)]
    procedure cursor (p : integer; term : char);
      begin
	prefix;
	write (p:1,term)
      end;

    [global ($vt101)]
    procedure up (p : integer);
      begin
	cursor (p,'A')
      end;

    [global ($vt102)]
    procedure down (p : integer);
      begin
	cursor (p,'B')
      end (* DOWN *);

    [global ($vt103)]
    procedure right (p : integer);
      begin
	cursor (p,'C')
      end;

    [global ($vt104)]
    procedure left (p : integer);
      begin
	cursor (p,'D');
      end;

    [global ($vt105)]
    procedure plot (r,c : integer);
      begin
	cursor (r,';');
	write (c:1,'H');
      end;

    [global ($vt106)]
    procedure index;
      begin
	simple_one ('D')
      end;

    [global ($vt107)]
    procedure nextline;
      begin
	simple_one ('E')
      end;

    [global ($vt108)]
    procedure reverseindex;
      begin
	simple_one ('M')
      end;

    [global ($vt109)]
    procedure save;
      begin
	simple_one ('7')
      end;

    [global ($vt110)]
    procedure restore;
      begin
	simple_one ('8')
      end;

    [global ($vt111)]
    procedure doublehightop;
      begin
	simple_two ('#3')
      end;

    [global ($vt112)]
    procedure doublehighbot;
      begin
	simple_two ('#4')
      end;

    [global ($vt113)]
    procedure singlewide;
      begin
	simple_two ('#5')
      end;

    [global ($vt114)]
    procedure doublewide;
      begin
	simple_two ('#6')
      end;

    [global ($vt115)]
    procedure alloff;
      begin
	simple_three ('[0m')
      end;

    [global ($vt116)]
    procedure boldon;
      begin
	simple_three ('[1m')
      end;

    [global ($vt117)]
    procedure underon;
      begin
	simple_three ('[4m')
      end;

    [global ($vt118)]
    procedure blinkon;
      begin
	simple_three ('[5m')
      end;

    [global ($vt119)]
    procedure reverseon;
      begin
	simple_three ('[7m')
      end;

    [global ($vt120)]
    procedure eraseright;
      begin
	simple_two ('[K')
      end;

    [global ($vt121)]
    procedure eraseleft;
      begin
	simple_three ('[1K')
      end;

    [global ($vt122)]
    procedure eraseline;
      begin
	simple_three ('[2K')
      end;

    [global ($vt123)]
    procedure erasedown;
      begin
	simple_two ('[J')
      end;

    [global ($vt124)]
    procedure eraseup;
      begin
	simple_three ('[1J')
      end;

    [global ($vt125)]
    procedure erasescreen;
      begin
	simple_three ('[2J')
      end;

    [global ($vt126)]
    procedure scroll (t,b : integer);
      begin
	cursor (t,';');
	write (b:1,'r')
      end;

    [global ($vt127)]
    procedure graphic;
      begin
	simple_two ('(0')
      end;

    [global ($vt128)]
    procedure ascii;
      begin
	simple_two ('(B')
      end;

    [global ($vt129)]
    procedure writebig(var text:[readonly]packed array[l..u:integer] of char);
    var
	i : integer;
	x : cursor_report;
      begin
	report_cursor (x);
	doublehightop;
	for i := l to u do write (text[i]);
	for i := 1 to x.length do write (x.string[i]);
	down(1);
	doublehighbot;
	for i := l to u do write (text[i]);
	up(1);
      end;

    [global ($vt130)]
    procedure writewide
	(var text:[readonly]packed array[l..u:integer] of char);
    var
	i:integer;
      begin
	doublewide;
	for i := l to u do write (text[i]);
      end;

end. 
                                                                                                                                                                                                                       