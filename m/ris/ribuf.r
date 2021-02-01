file	ribuf - buffered i/o
include	rid:rider
include rid:chdef
include rid:ctdef
include	rid:imdef
include	rid:iodef
include	rid:medef
include rid:stdef
include	rib:eddef
include rib:ridef

	riFmac : int = 0

;	For each line we have:
;
;	null	preceding null line count
;	dots	.. count
;	||/&&	cond flag
;	unbal	unbalanced (()

data	locals

	ri_ipt	: (void) void own
	ri_kwk	: (void) void own
	ri_red	: (*char) int own
	ri_dbg	: (*riTlin, *char) int

	riAcnd : [] * char is		; conditional line prefixs
	   "&&", "||"			;
	.. "!&", "!|", NULL		; negated 
					;
	riAext : [] * char is		; extension line prefixs
	   "&&", "||"			;
	.. "!&", "!|", NULL		; negated 
					;
	riArep : [] * char is		; replacement list
	   " ??",	":"		; fudge to avoid ' : ' later
	   "not",	"!"		;
	   "<>",	"NULL"		; null
;???	   "null",	"NULL"		;
	   "own",	"static"	;
	   "size",	"size_t"	;
;?V4-	   "#include",	"include"	; obselete

	   "byte",	"sbyte"		; when we use it, it's special
;	   "BYTE",	"UBYTE"		;
;	   "word",	"sword"		;
;	   "WORD",	"UWORD"		;
If Win
	   "LONG",	"ULONG"		; Windows special
;	   "FAR",	"TOFAR"		; Windows special
End
					;
	   "fast",	"register"	;
	   "Int",	"int register"	;
	   "Char",	"char register"	;
;	   "INT",	"int unsigned"	;
;	   "CHAR",	"char unsigned"	;
;	   "LONG",	"long unsigned"	;
;	   "byte",	"char signed"	;
;	   "BYTE",	"char unsigned"	;
;	   "word",	riAswd		; implementation dependent
;	   "WORD",	riAuwd		;
	   "reply null", "reply NULL"	; difficult to handle otherwise
	.. NULL,	 NULL		;

	riAifs : [] * char is		; if list
	   "if fail", "if that eq 0"	;
	   "if fine", "if that ne 0"	;
	   "if null", "if that eq NULL";
	   "if NULL", "if that eq NULL";
	   "if real", "if that ne NULL";
	   "if eof",  "if that eq EOF"	;
	   "if EOF",  "if that eq EOF"	;
	   "if eq",   "if that eq"	;
	   "if ne",   "if that ne"	;
	   "if gt",   "if that gt"	;
	   "if ge",   "if that ge"	;
	   "if lt",   "if that lt"	;
	   "if le",   "if that le"	;
	   "if <>",   "if that eq NULL";
	.. NULL,	NULL		;
					;
	riAunt : [] * char is		; until list
	   "until fail", "until that eq 0"
	   "until fine", "until that ne 0"
	   "until null", "until that eq NULL"
	   "until NULL", "until that eq NULL"
	   "until real", "until that ne NULL"
	   "until eof",  "until that eq EOF"
	   "until EOF",  "until that eq EOF"
	   "until eq",   "until that eq"
	   "until ne",   "until that ne"
	   "until gt",   "until that gt"
	   "until ge",   "until that ge"
	   "until lt",   "until that lt"
	   "until le",   "until that le"
	   "until <>",   "until that eq NULL"
	.. NULL,	NULL		;
					;
	riApas : [] * char is		; pass list
	   "pass fail", "reply 0 if that == 0"
	   "pass fine", "reply 1 if that != 0"
	   "pass null", "reply NULL if that == NULL"
	   "pass NULL", "reply NULL if that == NULL"
	   "pass <>",   "reply NULL if that == NULL"
	   "pass eof",  "reply EOF if that == EOF"
	   "pass EOF",  "reply EOF if that == EOF"
	.. NULL,	NULL		;
					;
	riAzer : [] * char is		; zero replacement list
	   "eq", "==", "ne", "!="	; (implicit zero added)
	   "gt", ">",  "ge", ">="	;
	   "lt", "<",  "le", "<="	;
	.. NULL, NULL			;

code	ri_beg - increment nesting level

  proc	ri_beg
  is	++riPcur->Vbeg
  end

code	ri_end - decrement nesting level

  proc	ri_end 
  is	++riPcur->Vend
  end
code	ri_get - get next line
	
;	Conditionals are handled here to take them out of the way
;	of type/unit/init control sequences.

	kw_asc : (void) void

  func	ri_get 
	()  : int			; fine/fail
  is	lin : * riTlin fast		; the line
	nxt : * riTlin fast		; next line
	msg : [128] char
	mac : int = 0			; macro conditional
					;
	if riPcur eq NULL 		; first time
	   riPcur = me_alc (riLlin)	; allocate the line
	   riPnxt = me_alc (riLlin)	; and the next one
	.. ri_ipt ()			; get the first
					;
     repeat				;
	lin = riPnxt			; swap pointers
	nxt = riPcur			;
	riPnxt = nxt			;
	riPcur = lin			;
	fail if lin->Veof		; at end of file
	ri_ipt ()			; get the next
	ed_set (lin->Atxt, lin->Pbod)	; setup current

	next if ed_del (" .if")		; skip MACRO conditional

If Pdp
;	end_of_file

	if ed_del (" end_of_file")	; got end of file
	   lin->Vnul = 0		; no blank lines for this
	   ++lin->Veof			; signal end of file
	.. exit				;

;	skip from ".title" to "end macro"

	if mac
	   next if !ed_del (" end macro")
	.. riFmac = mac = 0

	if ed_del (" .title ")
	.. next riFmac = mac = 1
End

	ri_dbg (lin, edPdot)		; check debug stuff

;	if ed_scn (" #")		; compatible with old version
;	   if ed_scn (" #ifdef")
;	   || ed_scn (" #ifndef")
;	   || ed_scn (" #if")
;	      ++riVpre
;	   elif ed_scn (" #endif")
;	.. .. --riVpre

	if ed_del (" If")		; got conditional line
	   pp_if ()			;
	elif ed_del (" Elif")		;
	   pp_elf ()			;
	elif ed_del (" Else")		;
	   pp_els ()			;
	elif ed_del (" End")		;
	   pp_end ()			;
	elif ed_del (" ascii")
	   kw_asc ()
	else				;
	.. quit				;
	ri_put ()			; write that out
     forever				;

;	Check for continuation/extension

	while lin->Vcon			; current has continuation
	   || nxt->Vext			; next is extension
	   ed_set (lin->Atxt, lin->Pbod); setup current
					;
	   st_len (lin->Asrc) 		; current length
	   st_len (nxt->Asrc) + that	; plus next length
	   quit if that ge 200	;???	; too high
					;
	   ed_app (nxt->Pbod)		; append next to this line		
	   st_app (nxt->Asrc, lin->Asrc); and the source too
	   lin->Vbal += nxt->Vbal	; fixup balance
	   lin->Vwas += nxt->Vwas	; get was
	   lin->Vend += nxt->Vend	; get following end count
	   lin->Vcon = nxt->Vcon	; get next continuation
	   ri_ipt ()			; get the next
	.. quit if nxt->Veof		; was not there  
					;
	ed_set (lin->Atxt,lin->Pbod)	; setup current
	riVend = lin->Vend		; dot count
	riVcnd = nxt->Vcnd		; check next line for conditional
	riVis = nxt->Vis		; is count
	riVwas = nxt->Vwas		; get the was (that) flag
					;
	if quFver			; want verify
	.. printf ("%s\n", lin->Atxt)	; verify it
					;
	if lin->Vbal ne			; unbalanced
	   if riVcnd			; got && coming
	      nxt->Vbal += lin->Vbal	; handle it later
	   elif lin->Vbal gt		; too few
	      FMT (msg, "(%s)[%s]", riAseg, lin->Pbod)
	      im_rep ("W-Missing [)] in %s", msg)
	   else
	      FMT (msg, "(%s)[%s]", riAseg, lin->Pbod)
	.. .. im_rep ("W-Extra [)] in %s", msg)
					;
	if ed_del (" of")		; got of ...
	   ri_orf (1)			; handle that

	elif ed_del (" or")		; got or ...
	.. ri_orf (0)			;

	if ed_fnd (" ?= ")		; got conditional fixup
	.. pp_fix ()			; handle fixup

;printf ("was=%d, is=%d, dot=%d, %s\n", riVwas, riVis, riVend, lin->Pbod)
;printf ("%s\n", lin->Pbod)
	fine				; we won
  end
code	ri_ipt - input edited line

;	returns blank line count
;	handles xxx := yyy locally

  proc	ri_ipt
  is	lin : * riTlin fast = riPnxt	; line block
	txt : * Char = &lin->Atxt[0]	; text pointer
	opr : ** Char			; operator lookup table
	tmp : * char			;

	exit if !ri_raw ()		; get another raw line
	exit if riFmac			; in macro file

;	... <*char>exp ...
;	Convert any casts first to avoid (<,>) ambiguity with conditionals 
;	Must convert casts before sizeof (so that <> converts to ())

	if not ed_scn ("include")	; avoid (include <...>)
	&& not ed_scn ("#include")	; 
	.. ri_cst (txt)			; convert casts (in rityp.r)

;	name := string		constants, macros
;	name #= string		hex constants

	if (tmp = ed_rep (":=", " ")) 	ne <>   ; x := y => #define x y
	|| (tmp = ed_rep ("#=", " 0x")) ne <>	; xxx #= yyy => xxx 0xyyy
	   spin while st_rem (" ", tmp) ; delete following spaces
	   ed_rep (" (", "(")		; x (y) => x(y)
	   ri_siz ()			; handle (#type) before (#define)
	   ed_pre ("#define ")		; #define xxx [0x]yyy
	   ed_set (txt, txt)		; and use whole line
	else				;
	.. ri_siz ()			; replace #t with sizeof(t)
;V4	ri_kon ()			; replace @p with *p const
;V4	ri_bit ()			; replace `n with (1<<(n))

;	.. is ..

	if not ed_scn (" ...")		; not an ellipse
	   ++lin->Vend while ed_del (" .."); count/delete dots
	   ++lin->Vis  while ed_del (" is"); count/delete is's
	.. ++lin->Vend while ed_del (" .."); count/delete dots

	ed_mor ()			; remove blanks

;	||, &&, !|, !& - conditional line (Vcnd)	

	opr = riAcnd			; look for conditions
	while (txt = *opr++) ne <>	; got more
	   next if ed_skp (txt) eq	; skip &&, || etc
	   lin->Vcnd = -1 if *txt eq '!'; got negated conditional
	   lin->Vcnd =  1 otherwise	; found one
	   quit				;
	end				;

;	Vext - extension line - starts with &&, ||, ==, etc
;???	==, etc are translated below, not useful anyway

	ed_mor ()			; remove blanks
	opr = riAext			; init pointer
	while *opr ne <>		; got more
	   if ed_scn (*opr++)		; check leading operator
	.. .. quit ++lin->Vext		; found one - an extension line
					;
	ri_kwk ()			; replace keywords in context
					;
;	if quFdos eq			; not in dos
;	   spin while ed_rep ("far", ""); drop fars
;	   spin while ed_rep ("near", ""); drop nears
;	end

;	pass statements

	if ed_fnd ("pass") 		; got an if
	   opr = riApas			; pass fine etc
	   while *opr ne <>		; got more
	      ed_rep (opr[0], opr[1])	; handle replacements
	      quit if ne		; found one
	.. .. opr += 2			; next one

;	Replace ifs

	if ed_fnd ("if") 		; got an if
	   opr = riAifs			; if fine => if that ne FAIL
	   while *opr ne <>		; got more
	      ed_rep (opr[0], opr[1])	; handle replacements
	      quit if ne <>		; found one
	.. .. opr += 2			; next one

;	Replace until (but not embedded form: ++src until *src eq)

	if ed_scn ("until") 		; got an until statement
	   opr = riAunt			; if fine => if that ne FAIL
	   while *opr ne <>		; got more
	      ed_rep (opr[0], opr[1])	; handle replacements
	      quit if ne <>		; found one
	.. .. opr += 2			; next one

;	that

	if ed_fnd ("that")		; look for that was
	.. ++lin->Vwas			; remember it

;	, \

	txt = ed_lst ()			; point at last
	if riVini eq			; not initializing data
	&& *txt eq ',' || *txt eq '('	; and got comma or ( at end
	   ++lin->Vcon   		; got continuation
	elif *txt eq '\\'		; got explicit continuation
	   ++lin->Vcon			; say so
	.. *txt = 0			; remove it

;	) , && || nl
;	(... eq)   ... eq,   ... eq(nl)
;	Zero-replacement - replace and add implicit zero

	opr = riAzer			; do replacements
	while *opr ne <>		; got more
	   txt = ed_rep (opr[0], opr[1]); handle replacements
	   if txt ne NULL		; got it
	      txt = st_skp (txt)	; skip spaces
	      if *txt eq ')'		; (
	      || *txt eq ','		; ,
	      || *txt eq '|' && txt[1] eq '|'	; ||
	      || *txt eq '&' && txt[1] eq '&'	; &&
	      || *txt eq '!' && txt[1] eq '|'	; !|
	      || *txt eq '!' && txt[1] eq '&'	; !&
		 st_mov (txt, txt+2)	; make space
		 me_mov (" 0", txt, 2)	; insert zero test
	      elif *txt eq		; at end of line
	      .. ed_app (" 0")		; supply implicit 0
	   .. next			; try again
	.. opr += 2			; skip two entries
					;
;PUT("[%s]\n", edPdot)
	lin->Pbod = edPdot		; remember body
  end
code	ri_raw - get raw input line

  func	ri_raw
  is	lin : * riTlin fast = riPnxt	; line block
	txt : * Char = &lin->Atxt[0]	; text pointer
	lin->Vnul = -1			; assume no blank lines
	lin->Veof = 0			; not end of file
	lin->Vis = 0			; no is
	lin->Vbeg = 0			; begin count
	lin->Vend = 0			; no dots
	lin->Vcnd = 0			; no conditional
	lin->Vcon = 0			; not a continuation
	lin->Vext = 0			; not an extension line
	lin->Vwas = 0			; no was
	lin->Vbal = 0			; equal balance

;	Input text until EOF or non-blank line (after reduction)

     repeat
	++lin->Vnul			; count null lines
	if io_get (txt) eq		; end of file
	   ++lin->Veof			; end of file
	.. fail				; done
	st_cop (txt, lin->Asrc)		; keep a copy
	lin->Vbal = ri_red (txt)	; reduce line
     until *(st_skp (txt)) ne 		; non-blank line
					;
	ed_set (txt, txt)		; setup to edit
	ed_del ("\f")			; delete leading form feeds
	fine				;
  end
code	ri_kwk - replace keywords in context

;	Do not replace xxx.keyword or xxx->keyword
;	But do replace xxx..keyword
;
;	Handles situations where xxx->size does not mean xxx->size_t

  proc	ri_kwk
  is	opr : ** char
	dot : * char
	ptr : * char

	opr = riArep			; do replacements
	dot = edPdot			;
     while *opr ne <>			; got more
      repeat				; replace all occurences
	ptr = ed_fnd (opr[0])		; find the next occurence
	quit if null			; no more of this one
	if ptr-edPdot ge 2		; space for it
	   if (ptr[-1] eq '.'		; .keyword
	       && ptr[-2] ne '.')	; but not ..keyword
	   || st_scn ("->", ptr-2)	; ->keyword
	.. .. next edPdot = ptr+1	; skip this occurrence
	ed_exc (opr[1], ptr, st_len (opr[0])) ; replace it
	edPdot = ptr+1			; advance
      forever				;
	edPdot = dot			;
	opr += 2 			; next (multiple accepted)
     end				;
  end
code	ri_red - reduce line

;	compress whitespace
;	count ( & )
;	; is accepted as comment
;	check () balance

  func	ri_red
	txt : * char			; line to reduce
  is	lin : * char = txt		; a copy 
	dst : * char = txt		; in-place result
	cha : int			; a character
	bal : int = 0			; parenthesis balance
					;
	lin = st_skp (lin)		; skip leading spaces
					;
  while (*lin)				; get the lot
	*lin = _space if *lin eq _tab	; convert tabs to spaces
					;
	case *lin			; handle leading stuff
	of _space  if ct_spc (lin[1])	; got another
		   .. next ++lin	; skip this one
					;
	of _paren  ++bal		; ( - up balance
	of paren_  --bal		; ) - down balance
					;
	of _semi   next *lin = 0	; ; - terminate on comment
					;
	of _slash  if lin[1] eq _slash	; / - maybe //
		   .. next *lin = 0	;     terminate
					;
	of _quotes			; "
	or _apost			; '
	   *dst++ = cha = *lin++	; get & copy quote character
	   while *lin			; got more
	      *dst++ = *lin++		; copy next
	      quit if that eq cha	; end of it
	      if lin[-1] eq _back	; got \ escape
	      && *lin			; got something to skip
	      .. *dst++ = *lin++	; keep it
	   end				; quote loop
	   next				; next from top
	end_case			; 
	*dst++ = *lin++			; keep any that falls thru
      end				; more
					;
	if *txt				; hasnt reduced to null line
	&& dst[-1] eq _space		; has terminating space
	.. --dst			; get rid of it
	*dst = 0			; terminate it
	reply bal			; send back balance
  end
code	ri_dbg - debug support

;	A single lowercase letter in the left column triggers debug.
;	a-w	display the string name-a, where name is function name.
;	y	turns on debug trace
;	z	turns it off

  func	ri_dbg
	lin : * riTlin
  	nxt : * char
  is	buf : [256] char
	fine if lin->Asrc[0] ne *nxt	; some spaces at start
	if *nxt ge 'a'			; want some debugging
	&& *nxt le 'z'			;
	&& nxt[1] le ' '		;
	   case *nxt			;
	   of 'y' riVdbg = 1		; trace on
	   of 'z' riVdbg = 0		; trace off
	   of other			;
	      FMT(buf, "puts (\"#%s", riAseg)
	      FMT(st_end (buf), ".%c\");\n", *nxt)
;	      FMT(buf, "printf (\"#%s", riAseg)
;	      FMT(st_end (buf), ".%c\\n\");\n", *nxt)
	      *nxt = ' '
	      ri_dis (buf)
	.. end case
	fine
  end
