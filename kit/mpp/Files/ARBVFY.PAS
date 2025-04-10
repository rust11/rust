[ SYSTEM(MICROPOWER), PRIORITY(100),
  DATA_SPACE(1000), STACK_SIZE (300)] PROGRAM arbvfy;
{
 THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED OR COPIED
 ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE.

 COPYRIGHT (c) 1982, 1986 BY DIGITAL EQUIPMENT CORPORATION.
		ALL RIGHTS RESERVED.
}
{$NOLIST}
%include 'LB:IOPKTS.PAS'
%include 'LB:EXC.PAS'
%include 'LB:KXINC.PAS'
{$LIST}
const
  LEFTPOS = 0.0;		{ Left margin of screen in playing space }
  LEFT = LEFTPOS;		{ Left limit of playing space }
  RIGHT = 50.0;			{ Right limit of playing space
				  I would think the right thing would
				  be to say `RIGHT = LEFT+50.0;' but
				  everyone knows that the way PASCAL does
				  things is the only `RIGHT' way to do things,
				  so obviously there is something very wrong
				  in wanting to do that..... }
  ESCAPECODE = 27;		{ Value of the ESC character }
  TOP = 0.0;			{ Top limit of playing space }
  BOTTOM = 100.0;		{ Bottom limit of playing space }
  SCREENWIDTH = 79;		{ Width of the screen }
  SCREENLENGTH = 23;		{ Length of the screen }

type
  col = 0..79;
  row = 0..23;

  vector = record
    x,y : real;			{ X and Y components }
  end;

  screen_pos = record
    c : col;
    r : row;
  end;

  ball = record
    op : vector;		{ Old position }
    p : vector;			{ Position }
    v : vector;			{ Velocity }
    sp : screen_pos;		{ Position in screen units }
    osp : screen_pos;		{ Old position in screen units }
  end;

  message = record
    case m_type : char of		{ Message type }
      "b": (b:ball);
  end;

var
  esc : char;
  b : ball;

procedure cls;
begin
  write(esc,'[2J')
end;

procedure topos(sp:screen_pos);
var
  xc,yc : integer;
begin
  xc := sp.c+1;
  yc := sp.r+1;
  write(esc,'[');
  if (yc < 10) then write(yc:1)
    else write(yc:2);
  write(';');
  if (xc < 10) then write(xc:1)
    else write(xc:2);
  write('H');
end;

procedure fly(var b:ball);
begin
  b.op := b.p;
  b.p.x := b.p.x + b.v.x;
  b.p.y := b.p.y + b.v.y;
end;

procedure scale(var v:vector; var sp:screen_pos);
begin
  sp.c := round((v.x - LEFTPOS)/(RIGHT-LEFT) * SCREENWIDTH);
  sp.r := round(v.y/(BOTTOM-TOP) * SCREENLENGTH);
end;

procedure show(var b:ball);
begin
  b.osp := b.sp;
  scale(b.p,b.sp);
  if ((b.sp.r <> b.osp.r) or (b.sp.c <> b.osp.c)) then begin
    topos(b.osp);
    write(' ');
    topos(b.sp);
    write('o');
  end;
end;

procedure bounce(var c:real; lim:real; var v:real);
begin
  c := lim + (lim - c);
  v := -v;
end;

procedure trans(var m:message);
var
  garbage : unsigned;
  garbage2 : unsigned;
begin
  repeat
    garbage := KX_write_data(m,size(m),garbage2);
    garbage := KX_read_data(m,size(m),garbage2);
  until (garbage = ES$NOR);
end;

procedure pass_over(var b:ball);
var
  m : message;
begin
  topos(b.sp);
  write(' ');
  m.m_type := "b";
  m.b := b;
  trans(m);
  b := m.b;
end;

procedure move(var b:ball);
begin
  fly(b);
  if (b.p.x < LEFT) then bounce(b.p.x,LEFT,b.v.x);
  if (b.p.x > RIGHT) then pass_over(b);
  if (b.p.y < TOP) then bounce(b.p.y,TOP,b.v.y);
  if (b.p.y > BOTTOM) then bounce(b.p.y,BOTTOM,b.v.y);
  show(b);
end;

begin
  esc := chr(ESCAPECODE);
  b.p.x := LEFT;
  b.p.y := TOP;
  b.v.x := 1.666666;
  b.v.y := 2.0;

  cls;
  while true do begin
    move(b);
  end;

end.
                                                                                                                                                                              