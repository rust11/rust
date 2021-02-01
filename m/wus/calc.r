rad$c := 0
file	calc - simple calculator
include	rid:rider
include	rid:codef
include	rid:stdef
include	rid:medef
include	rid:imdef
include	rid:cldef
include	rid:ctdef
include	rid:mxdef
If Win
include	rid:codef
End

;	Also built by PDP-11 CUS:CALC.R
;
;	%build
;	rider wus:calc/object:cub:
;	@@uts:calinf
;	link utb:calinf,utb:calc/exe:utb:/map:utb:,lib:(crt,ridlib)/bot=3000/cross
;	%end

	exVER := 0	; verify?
	exWLK := 0	; walk (and display)

;	General expression parse/walk and evaluate routines.
;	The decoder translates an input stream via an expression stack.
;
;	The stack technique has some advantages.
;
;	o  It avoids the 16 nesting levels C needs
;	o  It permits an early bail-out
;	o  It is quite forgiving of messed up input:
;	   Operators and operands may come in any order
;	o  It defers most error messages to the reduction stage
;	o  Flexibility permits its use as declaration parser
;	o  Generic treatment of binary/unary operators.
;
;  The Scanner:
;	The key concept to think about is that an expression parser
;	never reorders operators and/or operands. Therefore a single
;	stack is sufficient to store the intermediate form.
;
;	The scanner recognises four things:
;
;	prefix operators
;	value  operand
;	suffix operators
;	binary operator
;
;	X := [p...]V[s...][B X]
;
;	Any number of prefixs, followed by exactly one operand
;	followed by any number of suffixes.
;	All this may then be followed by a binary operator, but
;	only if the binary operator is followed by an expression.
;	Clearly, the completed expression must terminate with a
;	Value or Suffix.
;
;  Scanner Mechanics:
;
;	At any given time the scanner is either in Prefix or Suffix mode.
;	In Prefix mode it collects prefixs until it detects a Value,
;	which switchs the mode to Suffix mode.
;	In Suffix mode it collects suffixs until it detects a Binary
;	operator, which switchs the mode back to Prefix mode.
;
;	In fact the scanner treats both modes identically. Operator priority
;	alone determines the action of the scanner.
;
;  Prefix/Suffix Callbacks:
;
;	The scanner calls xx_pre and xx_suf to break down the input
;	stream into operators and operands. The context pointers
;	can point to the same routine (in which case the "mod" parameter
;	would be used to determine the gender of the call).
;
;  "C" Expressions:
;  Prefix/Value:
;
;    Prefix:
;	Unary:	- + ! etc
;	Cast:	(char*)0	; Can't decide Cast/Expr lexically
;
;    Value
;	Value:  123 X etc 
;	Expr:	(...)		; "..." must be an expression
;	Error:	"0"		; defaults to zero/null
;
;  Suffix/Binary:
;
;    Suffix:
;	Unary:	-- ++ etc
;	Array:	[...]		; A[12]  limited type for ...
;	Call:	(...)		; F(x,y)  "," supressed in "..." 
;    Binary:
;	Binary:	+ - * / etc
;	Wierd:  ,		; may be supressed	
;	Error: "_"		; defaults to catenate
;
;  Statement Parsing
;
;	Note the following:
;
;	while exp	while @ exp
;	case exp	case @ exp
;	exp while	exp @ while
data	context

  type	exTval : long

	exLstk := 64
	exLhea := 128
	prBEG	:= 100
	prRGT_	:= 1

  type	exEkwd : int

	exERR := 0
	exSYM := 1
	exADD := 2
	exSUB := 3
	exMUL := 4
	exDIV := 5
	exPLU := 6
	exMIN := 7
	exICB := 8
	exDCB := 9
	exICA := 10
	exDCA := 11

  type	exEcat : int
	exNIX := 0
	exUOP := 1
	exBOP := 2
	exVAL := 3
	exNAM := 4
	exNOD := 5

  type	exTopr			; token: operator/operand
  is	Vcat : exEcat		; category
	Vval : exTval		; operand constant value
	Vkwd : int		; operator keyword
	Vpri : int		; operator priority
	Astr : [32] char	; string
  end

  type	exTnod			; expression tree node
  is	Vcat : exEcat		; category
	Plft : *exTnod		; left node
	Prgt : *exTnod		; right node
	Popr : *exTopr		; operator
  end

  type	exTelm			; stack element
  is	Popr : * void		; operator
	Vpri : int		; priority/association
	Pobj : * void		; object
  end

  type	exTctx : forward
  type	exFopr : (*exTctx, *int, **exTopr) int
  type	exFred : (*exTctx, *exTnod) int

  type	exTctx
  is	Aipt : [mxLIN+2] char	; expression string
	Astk : [exLstk] exTelm	; expression stack
	Pcha : * char		; string pointer
	Pstk : * exTelm		; stack pointer
	Ptre : * exTnod		; node pointer (tree root)
				;
	Popr : * exFopr		; operator/operand callback
	Pred : * exFred		; reduction callback
;	Perr : * exFfun		; error callback
	Verr : int 		; error count
	Vact : int		; active tree
	Vtre : int		; show tree
  end

	ex_exp	: (*exTctx, int) *exTnod
	ex_opr	: (*exTctx, *int, **exTopr) int
	ex_pri	: (*exTctx, *exTopr) int

	ex_wlk	: (*exTctx, *exTnod, int) *exTnod
	ex_evl	: (*exTctx, *exTnod) exTval
	ex_red	: (*char) int
	ex_cmd	: (*exTctx) int
code	main

	calc : (int, **char) int

If Win
  func	main
	cnt : int
	vec : **char
  is
	co_ctc (coENB)
	calc (cnt, vec)
  end
Else
  func	start
  is	calc (0, <>)
  end
End

  func	calc
	cnt : int
	vec : **char
  is	ctx : * exTctx~
	sin : int = 0
	res : exTval
	prm : [24] char

	im_ini ("CALC")
	ctx = me_acc (#exTctx)
	ctx->Pcha = ctx->Aipt
					;
If Win
	cl_ass (ctx->Pcha, cnt, vec)	; reassemble it
	sin = *ctx->Pcha		;
End
	repeat				;
	   ctx->Pstk = ctx->Astk + (exLstk-1)
	   if !ctx->Vact		; not active
	      st_cop ("CALC> ", prm)	;
	   else				;
	   .. FMT(prm, "%ld> ", res)	;

	   while ctx->Verr || !*ctx->Pcha;
	      ctx->Verr = 0		;
	      ctx->Pcha = ctx->Aipt	;
	      ctx->Vtre = 0
	   .. cl_cmd (prm, ctx->Pcha)	;
	   if exVER			; verify
	   .. PUT("In:  %s\n",ctx->Aipt); report
					;
	   ex_red (ctx->Pcha)		; remove all spaces
					;
	   next if !ex_cmd (ctx)	;

	   if ctx->Vact			; active
	   && !ct_dig (*ctx->Pcha)	; and not a new expression
	   && !(*ctx->Pcha eq '(')	;
	      FMT(prm, "%ld", res)	; prepend previous result
	   .. st_ins (prm, ctx->Pcha)	;

	   ctx->Ptre = ex_exp (ctx, 0)	; decode away
	   next if ctx->Verr		; some error
					;
	   if ctx->Vtre
	      ex_wlk (ctx, ctx->Ptre, 0); write the tree
	   .. PUT("\n")			;
	   res = ex_evl (ctx, ctx->Ptre);
					;
	   ctx->Vact = 1		;
If Win
	   quit if sin
Else
	   quit if cl_sin ()		; was single-line command
End
	forever				;
	PUT("%ld\n", res)		; show single result
	im_exi ()			;
  end

  func	ex_red
	src : * char~
  is	dst : * char~ = src
	while (*dst = ch_upr (*src++)) ne
	   ++dst if *dst ne ' '
	end
  end

  func	ex_cmd
	ctx : * exTctx~
  is	cha : int
	while ct_alp (*ctx->Pcha)
	   cha = *ctx->Pcha
	   case cha
	   of 'C'  ctx->Vact = 0
	   of 'D'  ctx->Vtre = 1
	   of 'E'
	   or 'X'  im_exi ()
	   of other
	      im_rep ("E-Invalid command [%s]", ctx->Pcha-1)
	      *ctx->Pcha = 0		;
	      fail
	   end case
	   st_del (ctx->Pcha, 1)
	end
	reply *ctx->Pcha
  end
code	ex_exp - decode binary expression

	SP  := stk

  func	ex_exp
	ctx : * exTctx~
	flg : int
	()  : * exTnod
  is	stk : * exTelm~ = ctx->Pstk	;
	opr : * exTopr = <>		; operator/operand
	red : * exTnod~			; reduction/result
	mod : int = 0			; 0=object/uop 1=postfix/bop
	cnt : int = 0			; stack depth
	pri : int = prBEG		; next priority

     repeat
	(--SP)->Pobj = <>		; no object yet
	SP->Popr = opr			; deal with previous op
	SP->Vpri = pri			; at previous priority
	pri = ex_opr (ctx, &mod, &opr)	; get another
	fail if ctx->Verr		;
	if !pri				; got object
	   SP->Pobj = opr		;
	   pri = ex_opr (ctx, &mod,&opr); now get operator
	.. fail if ctx->Verr		;
	++cnt				; count it
	while cnt ge 2			; need two to party
	&& pri le (SP->Vpri & ~prRGT_)	; pop if lower or (same & left)
	   red = me_acc (#exTnod)	; reduce the stack
	   red->Vcat = exNOD		;
	   red->Prgt = SP->Pobj		;       rgt
	   red->Popr = SP->Popr		;    opr
	   red->Plft = (++SP)->Pobj	; lft
	.. SP->Pobj = red, --cnt	; replace with reduction
     until !pri				; no more operators
	if !SP->Pobj || (cnt ne 1)	; nothing or incomplete
	.. im_rep ("W-Null expression", <>)
	reply (SP++)->Pobj		; pop back (ha ha ha)
  end
code	ex_opr - get operator/operand
	ex_str : (*exTopr, **char) void

  func	ex_opr
	ctx : * exTctx~
	mod : * int			; *0=>prefix, *1=>suffix
	res : ** exTopr			;
	()  : int			; priority
  is	opr : * exTopr~ = <>		;
	nod : * exTnod			;
	cha : * char = ctx->Pcha	;
	nxt : * char = cha + 1		;
	len : int = 1			;
	cat : exEcat			;
	kwd : exEkwd			;
	pri : int			;
					;
	++cha while *cha eq ' '		; skip spaces
 	ctx->Pcha = cha			;
	if !*cha || (*cha eq ')')	; end of expression
	|| (*cha eq ']')		;
	   *res = <>			; no more objects
	.. reply 0			; end of expression
					;
     if !*mod				; looking for prefix or operand
	if *cha eq '('			; nested expression
	   ++cha			;
	   ctx->Pcha = cha		;
	   nod = ex_exp (ctx, 0)	;
	   *res = <*void>nod		;
	   ++ctx->Pcha while *ctx->Pcha eq ' '
	   ++ctx->Pcha if *ctx->Pcha eq ')'
	   *mod = 1			; need suffix now
	.. reply 0			; object priority (unless cast)
					;
	opr = *res = me_acc (#exTopr)	; need new op
	if ct_dig (*cha)		; got a number
	   opr->Vcat = exVAL		;
If Win
	   SCN(cha, "%d", &opr->Vval)	; decode number
Else
	   SCN(cha, "%D", &opr->Vval)	; decode number
End
	   ++cha while ct_dig (*cha)	; skip digits
	   ctx->Pcha = cha		;
	   *mod = 1			; now looking for suffix or bop
	.. reply 0			; object priority

	if ct_alp (*cha)
	   opr->Vcat = exUOP
	   opr->Vkwd = exSYM
	   ex_str (opr, &cha)
	   ctx->Pcha = cha
	.. reply 0

	nxt = cha + 1			;
	case *cha			; get operator
	of '+'
	   case *nxt
	   of '+'    cat = exUOP, kwd = exICB, pri = 401, ++len
	   of other  cat = exUOP, kwd = exPLU, pri = 401
	   end case
	of '-'
	   case *nxt
	   of '-'    cat = exUOP, kwd = exDCB, pri = 401, ++len
	   of other  cat = exUOP, kwd = exMIN, pri = 401
	   end case
	of other
	      im_rep ("E-Invalid prefix/value [%s]", cha)
	      ctx->Verr = 1
exit
	      cat = exUOP, kwd = exERR, pri = 1
	      ex_str (opr, &cha)

;	      ++cha while ct_aln (cha[1])
	end case
     else
	opr = me_acc (#exTopr)		; need new op
	nxt = cha + 1
	case *cha			; get operator
	of '+'
	   case *nxt
	   of '+'    cat = exUOP, kwd = exICA, pri = 500, ++len
	   of other  cat = exBOP, kwd = exADD, pri = 100
	   end case
	of '-'
	   case *nxt
	   of '-'    cat = exUOP, kwd = exDCA, pri = 500, ++len
	   of other  cat = exBOP, kwd = exSUB, pri = 100
	   end case
	of '*'  cat = exBOP, kwd = exMUL, pri = 200
	of '/'  cat = exBOP, kwd = exDIV, pri = 200
	of other
	      im_rep ("E-Invalid suffix/bop [%s]", cha)
	      ++ctx->Verr
	      ctx->Pcha = ctx->Aipt
exit
	      cat = exBOP, kwd = exERR, pri = 1
	      ex_str (opr, &cha)
;	      ++cha while ct_aln (cha[1])
	end case
	*mod = 0 if cat eq exBOP
     end
	cha += len
	opr->Vcat = cat
	opr->Vkwd = kwd
	opr->Vpri = pri
	ctx->Pcha = cha
	*res = opr
	reply pri
  end

code	ex_str - extract string

  proc	ex_str
	opr : * exTopr
	ptr : ** char
  is	str : * char = opr->Astr
	cnt : int = 0
	while ct_aln (**ptr)
	   *str++ = **ptr if cnt++ lt 31
	   ++*ptr
	end
  end
code	ex_wlk - walk tree

  func	ex_wlk
	ctx : * exTctx~
	nod : * exTnod~
	idt : int
	()  : * exTnod
  is	opr : * exTopr~ = <*exTopr>nod
	fail if !nod

	case nod->Vcat
	of exNOD
		 PUT("(")
		 ex_wlk (ctx, nod->Plft, idt)
		 ex_wlk (ctx, <*void>nod->Popr, idt)
		 ex_wlk (ctx, nod->Prgt, idt)
		 PUT(")")
	of exUOP case opr->Vkwd
	 	 of exPLU  PUT("(+)")
	 	 of exMIN  PUT("(-)")
	 	 of exICB  PUT("(++)")
	 	 of exICA  PUT("(++)")
	 	 of exDCB  PUT("(--)")
	 	 of exDCA  PUT("(--)")
		 of exERR
		 or exSYM  PUT("([%s])", opr->Astr)
	 	 end case
	of exBOP case opr->Vkwd
		 of exADD  PUT(" + ")
	 	 of exSUB  PUT(" - ")
	 	 of exMUL  PUT(" * ")
	 	 of exDIV  PUT(" / ")
		 of exERR
		 or exSYM  PUT("[%s]", opr->Astr)
	 	 end case
	of exVAL PUT("(%ld)", opr->Vval)
	of exNAM PUT("%s", opr->Astr)
	of other PUT("Cat=%d ", nod->Vcat)
	end case
	fail
  end
code	ex_evl - evaluate tree

  func	ex_evl
	ctx : * exTctx
	nod : * exTnod
	()  : exTval
  is	opr : * exTopr
	lft : exTval~ = 0	; register mode fails compiler
	rgt : exTval~ = 0
	res : exTval~ = 0

	fail if !nod
	case nod->Vcat
	of exNOD
	   lft = ex_evl (ctx, nod->Plft)
	   opr = nod->Popr
	   rgt = ex_evl (ctx, nod->Prgt)
	   case opr->Vkwd
	   of exPLU  res = rgt
	   of exMIN  res = 0 - rgt
	   of exICB  res = ++rgt
	   of exDCB  res = --rgt
	   of exADD  res = lft + rgt
	   of exSUB  res = lft - rgt
	   of exMUL  res = lft * rgt
	   of exDIV  res = lft / rgt if (rgt ne 0)
		     res = 0 otherwise
	   of exICA  res = ++lft		; special for immediate usage
	   of exDCA  res = --lft
	   of exERR  res = 0
	   of exSYM  res = lft
	   end case
	   nod->Vcat = exVAL
	   (<*exTopr>nod)->Vval = res
	   if ctx->Vtre
	      ex_wlk (ctx, ctx->Ptre, 0)	; write the tree
	   .. PUT("\n")
	of exUOP ;PUT("Uop")
	of exBOP ;PUT("Bop")
	of exVAL res = (<*exTopr>nod)->Vval
	of exNAM res = 0
	of other nothing;PUT("Cat=%d ", nod->Vcat)
	end case
	reply res
  end
;	^xnnnn.	input number in specified radix
;
;	show	all|ascii|binary|decimal|hex|octal|rad50|...
;	show	keyboard
;	show	byte|word|long|quad
;	show	settings
;
;	<dec>123 * <oct>1010
;
;	%a	ascii
;	%b	binary input
;	%d	decimal
;	%h	hex
;	%o	octal
;	%r	rad50
;	%t 	date, time
;	%x	hex
;	???	various time formats
end file

data	expression array

  init	exAopr : [] ciTopr
;	name	cat	key	string	pri.	assoc.
  is	opCMA::	exBOP,	opCMA,	",",  	1 ,	exBLR

	opASS::	exBOP,	opASS,	"=",  	2 ,	exBRL
	anMOD::	exBOP,	anMOD,	"%=", 	2 ,	exBRL
	anBAN::	exBOP,	anBAN,	"&=", 	2 ,	exBRL
	anMUL::	exBOP,	anMUL,	"*=", 	2 ,	exBRL
	anADD::	exBOP,	anADD,	"+=", 	2 ,	exBRL
	anSUB::	exBOP,	anSUB,	"-=", 	2 ,	exBRL
	anDIV::	exBOP,	anDIV,	"/=", 	2 ,	exBRL
	anLFT::	exBOP,	anLFT,	"<<=",	2 ,	exBRL
	anRGT::	exBOP,	anRGT,	">>=",	2 ,	exBRL
	anXOR::	exBOP,	anXOR,	"^=", 	2 ,	exBRL
	anBOR::	exBOP,	anBOR,	"|=", 	2 ,	exBRL

	opQST::	exBOP,	opQST,	"?",  	3 ,	exTLR
	opCOL::	exBOP,	opCOL,	":",  	0 ,	exTLR
	opLOR::	exBOP,	opLOR,	"||", 	4 ,	exBLR
	opLAN::	exBOP,	opLAN,	"&&", 	5 ,	exBLR

	opBOR::	exBOP,	opBOR,	"|",  	6 ,	exBLR
	opXOR::	exBOP,	opXOR,	"^",  	7 ,	exBLR
	opBAN::	exBOP,	opBAN,	"&",  	8 ,	exBLR
	opNE::	exBOP,	opNE,	"!=", 	9 ,	exBLR
	opEQ::	exBOP,	opEQ,	"==", 	9 ,	exBLR
	opLE::	exBOP,	opLE,	"<=", 	10,	exBLR
	opLT::	exBOP,	opLT,	"<",  	10,	exBLR
	opGE::	exBOP,	opGE,	">=", 	10,	exBLR
	opGT::	exBOP,	opGT,	">",  	10,	exBLR
	opLEU::	exBOP,	opLEU,	"<=", 	10,	exBLR
	opLTU::	exBOP,	opLTU,	"<",  	10,	exBLR
	opGEU::	exBOP,	opGEU,	">=", 	10,	exBLR
	opGTU::	exBOP,	opGTU,	">",  	10,	exBLR
	opLFT::	exBOP,	opLFT,	"<<", 	11,	exBLR
	opRGT::	exBOP,	opRGT,	">>", 	11,	exBLR
	opADD::	exBOP,	opADD,	"+",  	12,	exBLR
	opSUB::	exBOP,	opSUB,	"-",  	12,	exBLR
	opDIV::	exBOP,	opDIV,	"/",  	13,	exBLR
	opMUL::	exBOP,	opMUL,	"*",  	13,	exBLR
	opMOD::	exBOP,	opMOD,	"%",  	13,	exBLR

	opNOT::	exUOP,	opNOT,	"!",  	14,	exURL
	opCMP::	exUOP,	opCMP,	"~",  	14,	exURL
	opSTA::	exUOP,	opSTA,	"*",	14,	exURL
	opPLU::	exUOP,	opPLU,	"+",	14,	exURL
	opMIN::	exUOP,	opMIN,	"-",	14,	exURL
	opINC::	exUOP,	opINC,	"++", 	14,	exURL
	opDEC::	exUOP,	opDEC,	"--", 	14,	exURL

	opICA::	exSOP,	opICA,	"++", 	15,	exURL
	opDCA::	exSOP,	opDCA,	"--", 	15,	exURL
	opPTR::	exSOP,	opPTR,	"->", 	15,	exBLR
	opDOT::	exSOP,	opDOT,	".",  	15,	exBLR

	opLPA::	exOPR,	opLPA,	"(",  	16,	exURL
	opLSB::	exOPR,	opLSB,	"[",  	16,	exURL
;	opRSB::	exOPR,	opRSB,	"]",  	0 ,	exURL

	opRPA::	exTOP,	opRPA,	")",  	0 ,	exURL
	opSEM::	exTOP,	opSEM,	";",  	0 ,	exURL
  end
;	Mouse version
;
;	Octal, Decimal, Hex
;	Ascii, Rad50, Date
;	Vector, Device
;	Ascii chart
;	Vector/device chart
;	disk geometry
;
;	a	b	c	d	e	f	hex digits
;	g	h	input	j	k	l
;	m	n	output	p	q	r
;	set	t	u	v	w	exit
;	show
;	y	z



	+------------------
;	|
;	+------------------
;	|
;	|  [C]   [CE]
;
