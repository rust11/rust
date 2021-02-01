file	lamod - latin font 
include rid:rider
include	rid:ladef

; cup 222a
; cap 2229

;	(i~	unary minus???
;	(-0	top left, top right, bottom left, bottom right
;	(-4	up triangle, down triangle, right, left
;	(-9	empty set
;	(i=	maplet (not implemented - but better than h)
;	(i?	if
;	(iA	for all
;	(iE	exists
;	(iM	lub
;	(iW	glb

data	la_tok - latin tokens

  type	laTtok
  is	Pmle : * char		; old MLE format
	Vlat : WORD		; latin ascii
	Vuni : WORD		; unicode code
	Vkbd : WORD		;
	Vtyp : WORD		; type - alphanum or operator
  end

  init	laAtok : [] laTtok
  is;	index	mle	lat	uni	kbd	type	; Char,Super,Name,Op
	kTOP:	"it",	'∞',	0x0,	't',	laCHA	; top/type
	kALP:	"ia",	'‡',	0x3b1,	'a',	laCHA	; alpha
;;;	kBET:	"iB",	'ﬂ',	0x3b2,	'B',	laCHA	; beta - boolean
	kDEL:	"id",	'',	0x3b3,	'd',	laCHA	; delta
	kGAM:	"ig",	'Á',	0x3b4,	'g',	laCHA	; gamma
	kLAM:	"il",	'º',	0x3bb,	'l',	laCHA	; lamda
	kSEM:	"i;",	'ò',	0x207f,	';',	laSUP	; super n (was i)
	kQUO:	"i\'",	'í',	0x0,	'\'',	laSUP	; prime (was n)
	kBOX:	"i`",	'ë',	0x2579,	'`',	laSUP	; super box
	kLFT:	"i%",	'Ê',	0x22d6,	'%',	laOPR	; left apply
	kTHN:	"i$",	'ß',	0x22d7,	'$',	laOPR	; then
	kSAT:	"iH",	'„',	0x22a8,	'H',	laOPR	; satisfies
	kINF:	"i8",	'ú',	0x221e,	'8',	laNAM	; infinity
	kEQV:	"i:",	'À',	0x2261,	':',	laOPR	; equivalent (3 line =)
	kLAR:	"i<",	'‰',	0x2190,	'<',	laOPR	; left arrow /90
	kRAR:	"i>",	'Æ',	0x2192,	'>',	laOPR	; right arrow /92
	kUAR:	"i^",	'‚',	0x2191,	'^',	laOPR	; up arrow
	kNth:	"iv",	'à',	0x2193,	'v',	laOPR	; Nth
	kELP:	"i.",	' ',	0x22ef,	'.',	laOPR	; ellipsis
	kALT:	"i+",	'Â',	0x2016,	'+',	laOPR	; alternate

	kNUM:	"iN",	'—',	0x4e,	'N',	laNAM	; Numeric
	kBOO:	"iB",	'å',	0x42,	'B',	laNAM	; Boolean
	kSTR:	"iS",	'ä',	0x53,	'S',	laNAM	; String
	kIMP:	"iI",	'Ó',	0x21d2,	'I',	laOPR	; Implies
	kTRU:	"iT",	'Ü',	0x22a8,	'T',	laNAM	; True
	kFAL:	"iF",	'É',	0x22ad,	'F',	laNAM	; False
	kIFF:	"ii",	'ø',	0x21D4,	'i',	laOPR	; if and only if
	kMAP:	"ih",	'§',	0x22a2,	'h',	laOPR	; maps to
	kBOT:	"ib",	'°',	0x22a5,	'b',	laNAM	; bottom
	kCOM:	"io",	'∑',	0x2218,	'o',	laOPR	; Compose
	kMUL:	"ix",	'◊',	0x0,	'x',	laOPR	; Multiply
	kIN:	"ie",	'Ä',	0x2208,	'e',	laOPR	; element (IsIn)
	kNIN:	"if",	'∆',	0x2209,	'f',	laOPR	; notIn
	kNE:	"i#",	'±',	0x2260,	'#',	laOPR	; Ne
	kLE:	"i{",	'´',	0x2264,	'{',	laOPR	; Le
	kGE:	"i}",	'ª',	0x2265,	'}',	laOPR	; Ge

	kDSL:	"i[",	'ù',	0x226a,	'[',	laOPR	; double square left
	kDSR:	"i]",	'û',	0x226b,	'[',	laOPR	; double square right
	kBUL:	"i@",	'÷',	0x25cf,	'@',	laOPR	; bullet - where
	kDIV:	"i/",	'˜',	0x0,	0,	laOPR	; Divide
	kAnd:	"i&",	'√',	0x2227,	'&',	laOPR	; And
	kOR:	"i|",	'‘',	0x2228,	'|',	laOPR	; Or
	kNEG:	"i-",	'ó',	0x2212,	'-',	laOPR	; Negate -- Super negate
	kNOT:	"i!",	'¨',	0x0,	'!',	laOPR	; Not
	kRNG:	"i\"",	'Ö',	0x2025,	'\"',	laOPR	; Range
	kNIL:	"i,",	'Å',	0x0,	',',	laNAM	; Nil / Null list
	kRST:	"iL",	'¶',	0x0,	'L',	laOPR	; rest of list
	kAPD:	"i*",	'á',	0x229e,	'*',	laOPR	; Append/Concat 25c7/9e
	kELI:	"i\\",	'â',	0x229f,	'\\',	laOPR	; Elide /16
	kHEA:	"i6",	'£',	0x25d0,	'6',	laOPR	; head
	kTAI:	"i7",	'•',	0x25d1,	'7',	laOPR	; tail
	kCON:	"i_",	'¢',	0x25a1,	'_',	laOPR	; Cons
	kLTU:	"i(",	'ã',	0x0,	'(',	laOPR	; tuple left
	kRTU:	"i)",	'õ',	0x0,	')',	laOPR	; tuple right
	kSP0:	"-*",	'∫',	0x0,	'0',	laSUP	; super 0
	kSP1:	"-1",	'π',	0x0,	'1',	laSUP	; super 1 (00b9)
	kSP2:	"-2",	'≤',	0x0,	'2',	laSUP	; super 2 (00b2)
	kSP3:	"-3",	'≥',	0x0,	'3',	laSUP	; super 3 (00b3
	kBEX:	"-s",	'ﬂ',	0x0,	's',	laNAM	; Beta
	kBET:	"-S",	'ﬂ',	0x0,	0,	laNAM	; Beta
	kMU:	"-m",	'µ',	0x0,	'm',	laNAM	; Mu
		0,	0,	0x0,	0
;;;	kLT:	"<",	'<',	0x0,	0,	laOPR	; Lt
;;;	kGT:	">",	'>',	0x0,	0,	laOPR	; Gt
;;;	kMOD:	"%",	'%',	0x0,	0,	laOPR	; Modulus
;;;	kLEN:	 "#",	0,	0x0,	0,	laOPR	; Length
  end

 	laAcur : [256] WORD = {0}	; curly i replacements
	laAtil : [256] WORD = {0}	; tilde replacements
	laAuni : [256] WORD = {0}	; unicode equivalents
	laAkbd : [256] WORD = {0}	;
	laAtyp : [256] WORD = {0}	;
	laVini : int = 0		; init done

  func	la_ini
  is	tok : * laTtok = laAtok
	lat : int = 0
	fine if laVini
	++laVini
	while tok->Pmle
	   lat = tok->Vlat & 0xff
	   if tok->Pmle[0] eq 'i'		; { i x replacements
	   .. laAcur[tok->Pmle[1]] = lat
	   if tok->Pmle[0] eq '-'		; ~ x   replacements
	   .. laAtil[tok->Pmle[1]] = lat
	   if tok->Vuni
	   .. laAuni[lat] = tok->Vuni		; unicode translation
	   if tok->Vkbd
	   .. laAkbd[tok->Vkbd&0xff] = tok->Vlat; keyboard translation
	   if tok->Vtyp && lat
	   .. laAtyp[lat] = tok->Vtyp
	   ++tok
 	end
  end

code	la_typ - latin type

  func	la_typ
	cha : int
	()  : int
  is	la_ini () if !laVini
	reply laAtyp[cha & 0xff]	; character type 
  end

code	la_rep - replace mle with latin code

  func	la_rep
	ipt : ** char
	opt : ** char
  is	src : * char = *ipt
	dst : * char = *opt
	cha : char

	la_ini () if !laVini
	if src[0] eq '~'
	   cha = laAtil[src[1]]
	   pass fail
	   *ipt += 2, *opt += 1
	   *dst++ = cha, *dst = 0
	   fine
	end

	fail if src[0] ne '{'
	fail if src[1] ne 'i'
	cha = laAcur[src[2]]
	pass fail
	*ipt += 3, *opt += 1
	*dst++ = cha, *dst = 0
	fine
  end
