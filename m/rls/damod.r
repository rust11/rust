file	damod - disassembler
include	rid:rider
include	rid:dadef
include	rid:dbdef
include	rid:mxdef
include	rid:stdef
include	<stdio.h>
include	<stdarg.h>

	FET	 := da_fet (ctl)	; fetch IP byte
	MRM	 := da_mod (ctl)	; fetch mrm
	SIB	 := da_sca (ctl)	; fetch sib
	REG(a)	 := (((a)>>3)&7)	; extract register
	DEC(o)	 := da_dec (ctl, o)	; decode byte
	EMT(s)	 := da_fmt (ctl,s) 	; emit string
	EXP(s,o) := da_fmt (ctl, s, o)	; expand string


	daAseg : [] * char = {"ES","CS","SS","DS","FS","GS"}
	daAbyt : [] * char = {"AL","CL","DL","BL","AH","CH","DH","BH" }
	daAwrd : [] * char = {"AX","CX","DX","BX","SP","BP","SI","DI" }
	daAlng : [] * char = {"EAX","ECX","EDX","EBX","ESP","EBP","ESI","EDI" }

	da_dec : (*daTctl, *char) int own
	da_esc : (*daTctl, int, int) int own
	da_mrm : (*daTctl, int) int own
	da_sib : (*daTctl, int) int own
	da_nam : (*daTctl, int, int) int own
	da_imm : (*daTctl, int, int, int, int) int own
	da_rem : (*daTctl, int) int own
	da_mod : (*daTctl) int own
	da_sca : (*daTctl) int own
	da_fet : (*daTctl) int own
	da_fmt : (*daTctl, *char, ...) own
data	decode strings

;	add [eax],al is an unlikely instruction.
;
;	Tilde tokens in strings:
;	First char after '~':
;	 A - Direct address
;	 C - Reg of R/M picks control register
;	 D - Reg of R/M picks debug register
;	 E - R/M picks operand
;	 F - Flag register
;	 G - Reg of R/M selects a general register
;	 I - Immediate data
;	 J - Relative IP offset
;	 M - R/M picks memory
;	 O - No R/M, offset only
;	 R - Mod of R/M picks register only
;	 S - Reg of R/M picks segment register
;	 T - reg of R/M picks test register
;	 X - DS:ESI
;	 Y - ES:EDI
;	 2 - prefix of two-byte opcode
;	 e - put in 'e' if use32 (second char is part of reg name)
;	     put in 'w' for use16 or 'd' for use32 (second char is 'w')
;	 f - Floating point (second char is esc value)
;	 g - do R/M group 'n'
;	 p - prefix
;	 s - Size override (second char is a,o)
;	
;	Second char after '~' (type):
;	 a - Two words in memory (BOUND)
;	 b - Byte
;	 c - Byte or word
;	 d - DWord
;	 p - 32 or 48 bit pointer
;	 s - Six byte pseudo-descriptor
;	 v - Word or DWord
;	 w - Word
;	 1-8 - group number, esc value, etc
;
;	First Word ROM

  init	daArom : [] * char
  is	"ADD ~Eb,~Gb", "ADD ~Ev,~Gv",  "ADD ~Gb,~Eb", "ADD ~Gv,~Ev", ; 0
	"ADD AL,~Ib",  "ADD ~eAX,~Iv", "PUSH ES",     "POP ES",
	"OR ~Eb,~Gb",  "OR ~Ev,~Gv",   "OR ~Gb,~Eb",  "OR ~Gv,~Ev",
	"OR AL,~Ib",   "OR ~eAX,~Iv",  "PUSH CS",     "~2 ",

	"ADC ~Eb,~Gb", "ADC ~Ev,~Gv",  "ADC ~Gb,~Eb", "ADC ~Gv,~Ev", ; 1
	"ADC AL,~Ib",  "ADC ~eAX,~Iv", "PUSH SS",     "POP SS",
	"SBB ~Eb,~Gb", "SBB ~Ev,~Gv",  "SBB ~Gb,~Eb", "SBB ~Gv,~Ev",
	"SBB AL,~Ib",  "SBB ~eAX,~Iv", "PUSH DS",     "POP DS",

	"AND ~Eb,~Gb", "AND ~Ev,~Gv",  "AND ~Gb,~Eb", "AND ~Gv,~Ev", ; 2
	"AND AL,~Ib",  "AND ~eAX,~Iv", "~pE",         "DAA",
	"SUB ~Eb,~Gb", "SUB ~Ev,~Gv",  "SUB ~Gb,~Eb", "SUB ~Gv,~Ev",
	"SUB AL,~Ib",  "SUB ~eAX,~Iv", "~pC",         "DAS",

	"XOR ~Eb,~Gb", "XOR ~Ev,~Gv",  "XOR ~Gb,~Eb", "XOR ~Gv,~Ev", ; 3
	"XOR AL,~Ib",  "XOR ~eAX,~Iv", "~pS",         "AAA",
	"CMP ~Eb,~Gb", "CMP ~Ev,~Gv",  "CMP ~Gb,~Eb", "CMP ~Gv,~Ev",
	"CMP AL,~Ib",  "CMP ~eAX,~Iv", "~pD",         "AAS",

	"INC ~eAX",    "INC ~eCX",     "INC ~eDX",    "INC ~eBX", ; 4
	"INC ~eSP",    "INC ~eBP",     "INC ~eSI",    "INC ~eDI",
	"DEC ~eAX",    "DEC ~eCX",     "DEC ~eDX",    "DEC ~eBX",
	"DEC ~eSP",    "DEC ~eBP",     "DEC ~eSI",    "DEC ~eDI",

	"PUSH ~eAX",   "PUSH ~eCX",    "PUSH ~eDX",   "PUSH ~eBX", ; 5
	"PUSH ~eSP",   "PUSH ~eBP",    "PUSH ~eSI",   "PUSH ~eDI",
	"POP ~eAX",    "POP ~eCX",     "POP ~eDX",    "POP ~eBX",
	"POP ~eSP",    "POP ~eBP",     "POP ~eSI",    "POP ~eDI",

	"PUSHA",       "POPA",         "BOUND ~Gv,~Ma", "ARPL ~Ew,~Rw", ; 6
	"~pF",         "~pG",          "~so",           "~sa",
	"PUSH ~Iv",    "IMUL ~Gv=~Ev*~Iv", "PUSH ~Ib",  "IMUL ~Gv=~Ev*~Ib",
	"INSB ~Yb,DX", "INS~ew ~Yv,DX", "OUTSB DX,~Xb", "OUTS~ew DX,~Xv",

	"JO ~Jb",      "JNO ~Jb",       "JNC ~Jb",      "JC ~Jb", ; 7
	"JZ ~Jb",      "JNZ ~Jb",       "JBE ~Jb",      "JNBE ~Jb",
	"JS ~Jb",      "JNS ~Jb",       "JPE ~Jb",      "JPO ~Jb",
	"JL ~Jb",      "JGE ~Jb",       "JLE ~Jb",      "JG ~Jb",

	"~g1 ~Eb,~Ib",  "~g1 ~Ev,~Iv",  "MOV AL,~Ib",   "~g1 ~Ev,~Ib", ; 8
	"TEST ~Eb,~Gb", "TEST ~Ev,~Gv", "XCHG ~Eb,~Gb", "XCHG ~Ev,~Gv",
	"MOV ~Eb,~Gb",  "MOV ~Ev,~Gv",  "MOV ~Gb,~Eb",  "MOV ~Gv,~Ev",
	"MOV ~Ew,~Sw",  "LEA ~Gv,~M ",  "MOV ~Sw,~Ew",  "POP ~Ev",

	"NOP",            "XCHG ~eAX,~eCX", "XCHG ~eAX,~eDX", "XCHG ~eAX,~eBX",
	"XCHG ~eAX,~eSP", "XCHG ~eAX,~eBP", "XCHG ~eAX,~eSI", "XCHG ~eAX,~eDI",
	"CBW",            "CDW",            "CALL ~Ap",       "FWAIT",	; 9
	"PUSH ~eflags",   "POP ~eflags",    "SAHF",           "LAHF",

	"MOV AL,~Ov",     "MOV ~eAX,~Ov",     "MOV ~Ov,al",   "MOV ~Ov,~eAX",
	"MOVSB ~Xb,~Yb",  "MOVS~ew ~Xv,~Yv",  "CMPSB ~Xb,~Yb","CMPS~ew ~Xv,~Yv",
	"TEST AL,~Ib",    "TEST ~eAX,~Iv",    "STOSB ~Yb,AL","STOS~ew ~Yv,~eAX",
	"LODSB AL,~Xb",   "LODS~ew ~eAX,~Xv", "SCASB AL,~Xb","SCAS~ew ~eAX,~Xv",

	"MOV AL,~Ib",   "MOV CL,~Ib",   "MOV DL,~Ib",   "MOV BL,~Ib",	; b
	"MOV AH,~Ib",   "MOV CH,~Ib",   "MOV DH,~Ib",   "MOV BH,~Ib",
	"MOV ~eAX,~Iv", "MOV ~eCX,~Iv", "MOV ~eDX,~Iv", "MOV ~eBX,~Iv",
	"MOV ~eSP,~Iv", "MOV ~eBP,~Iv", "MOV ~eSI,~Iv", "MOV ~eDI,~Iv",

	"~g2 ~Eb,~Ib",   "~g2 ~Ev,~Ib",  "RET ~Iw",      "RET",		; c
	"LES ~Gv,~Mp",   "LDS ~Gv,~Mp",  "MOV ~Eb,~Ib",  "MOV ~Ev,~Iv",
	"ENTER ~Iw,~Ib", "LEAVE",        "RETF ~Iw",     "retf",
	"INT 3",         "INT ~Ib",      "INTO",         "IRET",

	"~g2 ~Eb,1", "~g2 ~Ev,1", "~g2 ~Eb,cl", "~g2 ~Ev,cl",		; d
	"AAM", "AAD", 0, "XLAT",
;	"ESC 0,~Ib", "ESC 1,~Ib", "ESC 2,~Ib", "ESC 3,~Ib",
;	"ESC 4,~Ib", "ESC 5,~Ib", "ESC 6,~Ib", "ESC 7,~Ib",
	"~f0", "~f1", "~f2", "~f3",
	"~f4", "~f5", "~f6", "~f7",

	"LOOPNE ~Jb", "LOOPE ~Jb", "LOOP ~Jb", "JCXZ ~Jb",		; e
	"IN AL,~Ib", "IN ~eAX,~Ib", "OUT ~Ib,AL", "OUT ~Ib,~eAX",
	"CALL ~Jv", "JMP ~Jv", "JMP ~Ap", "JMP ~Jb",
	"IN AL,DX", "IN ~eAX,DX", "OUT DX,AL", "OUT DX,~eAX",

	"LOCK ~p ", 0, "REPNE ~p ", "REP(e) ~p ",				; f
	"HLT", "CMC", "~g3", "~g0",
	"CLC", "STC", "CLI", "STI",
	"CLD", "STD", "~g4", "~g5"
  end

  init daAg00 : [] * char
  is	"~g6", "~g7", "LAR ~Gv,~Ew", "LSL ~Gv,~Ew", 0, 0, "CLTS", 0, ; 0
	0, 0, 0, 0, 0, 0, 0, 0
  end

  init daAg20 : [] * char
  is	"MOV ~Rd,~Cd", "MOV ~Rd,~Dd", "MOV ~Cd,~Rd", "MOV ~Dd,~Rd", ; 2
	"MOV ~Rd,~Td", 0, "MOV ~Td,~Rd", 0,
	0, 0, 0, 0, 0, 0, 0, 0
  end

  init daAg80 : [] * char
  is	"JO ~Jv", "JNO ~Jv", "JC ~Jv", "JNC ~Jv",
	"JZ ~Jv", "JNZ ~Jv", "JBE ~Jv", "JNBE ~Jv",
	"JS ~Jv", "JNS ~Jv", "JPE ~Jv", "JPO ~Jv",
	"JL ~Jv", "JGE ~Jv", "JLE ~Jv", "JG ~Jv",
	"SETO ~Eb", "SETNO ~Eb", "SETNC ~Eb", "SETC ~Eb",		; 9
	"SETZ ~Eb", "SETNZ ~Eb", "SETBE ~Eb", "SETNBE ~Eb",
	"SETS ~Eb", "SETNS ~Eb", "SETP ~Eb", "SETNP ~Eb",
	"SETL ~Eb", "SETGE ~Eb", "SETLE ~Eb", "SETG ~Eb",
	"PUSH FS",          "POP FS",          0,          "BT ~Ev,~Gv", ; a
	"SHLD ~Ev,~Gv,~Ib", "SHLD ~Ev,~Gv,cl", 0,           0,
	"PUSH GS",          "POP GS",          0,          "BTS ~Ev,~Gv",
	"SHRD ~Ev,~Gv,~Ib", "SHRD ~Ev,~Gv,cl", 0,          "IMUL ~Gv,~Ev",
	0, 0, "LSS ~Mp", "BTR ~Ev,~Gv",					 ; b
	"LFS ~Mp", "LGS ~Mp", "MOVZX ~Gv,~Eb", "MOVZX ~Gv,~Ew",
	0, 0, "~g8 ~Ev,~Ib", "BTC ~Ev,~Gv",
	"BSF ~Gv,~Ev", "BSR~Gv,~Ev", "MOVSX ~Gv,~Eb", "MOVSX ~Gv,~Ew",
  end

; Second byte of 2 byte OpCodes are Invalid if over 0xBF

  init daAgrp : [9][8] * char	; group 0 is group 3 for ~Ev set
  is	{ "TEST ~Ev,~Iv", "TEST ~Ev,~Iv,", "NOT ~Ev", "NEG ~Ev",
	  "MUL ~eAX,~Ev", "IMUL ~eAX,~Ev", "DIV ~eAX,~Ev", "IDIV ~eAX,~Ev" },
	{ "ADD", "OR", "ADC", "SBB", "AND", "SUB", "XOR", "CMP" },
	{ "ROL", "ROR", "RCL", "RCR", "SHL", "SHR", "SHL", "SAR" },
	{ "TEST ~Eb,~Ib", "TEST ~Eb,~Ib,", "NOT ~Eb", "NEG ~Eb",
	  "MUL AL,~Eb", "IMUL AL,~Eb", "DIV AL,~Eb", "IDIV AL,~Eb" },
	{ "INC ~Eb", "DEC ~Eb", 0, 0, 0, 0, 0, 0 },
	{ "INC ~Ev", "DEC ~Ev", "CALL ~Ev", "CALL ~Ep",
	  "JMP ~Ev", "JMP ~Ep", "PUSH ~Ev", 0 },
	{ "SLDT ~Ew", "STR ~Ew", "LLDT ~Ew", "LTR ~Ew",
	  "VERR ~Ew", "VERW ~Ew", 0, 0 },
	{ "SGDT ~Ms", "SIDT ~Ms", "LGDT ~Ms", "LIDT ~Ms",
	  "SMSW ~Ew", 0, "LMSW ~Ew", 0 },
	{ 0, 0, 0, 0, "BT", "BTS", "BTR", "BTC" }
  end
code	da_dis - disassemble instruction

  func	db_dis
	acc : * dbTacc
	buf : * char
	adr : * void
	()  : * void
  is	ctl : daTctl = {0}
	opc : int
	ctl.Pacc = acc
	ctl.Vpre = 0
	ctl.Qmrm = 0
	ctl.Qsib = 0
	ctl.Vops = 32
	ctl.V32b = 1
	ctl.Vbas = <long>adr
	ctl.Vadr = <long>adr
	ctl.Pbuf = buf
	*ctl.Pbuf = 0
	opc = da_fet (&ctl)
;	PUT("opc=[%s] ", daArom[opc])
	da_dec (&ctl, daArom[opc])
	reply <*void>ctl.Vadr
  end

code	da_dec - decode instruction

  func	da_dec
	ctl : * daTctl
	str : * char
  is	cha : int
	fail EMT("<null>") if !str
	while (cha = *str++) ne
	   if cha eq '~'
	      cha = *str++
;PUT("(~%c%c)", cha, *str)
	      da_esc (ctl, cha, *str++)
	   else
	   .. EXP("%c", cha)
	end
  end

code	da_fet - fetch a single byte

  func	da_fet
	ctl : * daTctl
  is	res : int
	ptr : * char = <*void>ctl->Vadr
	res = *ptr if !ctl->Pacc
	db_rea (ctl->Pacc, <*void>ctl->Vadr, &res, 1) otherwise
	++ctl->Vadr
	reply res & 255
  end

code	da_rem - get remaining bytes in instruction

  func	da_rem
	ctl : * daTctl
	cha : int
  is	case cha
	of 'b'  reply 1
	of 'w'  reply 2
	of 'd'  reply 4
	of 'v'	reply ctl->Vops / 8
	end case
	reply 0
  end
code	da_esc - handle escape field

  func	da_esc
	ctl : * daTctl
	cha : int
	typ : int
  is	byt : byte
	wrd : word
	lng : long
;PUT("pre=[%c] ", cha)
	case cha
	of 'A'  da_imm (ctl, typ, 4, 0, 32)	; direct address
	of 'C'  EXP("CR%d", REG(MRM))		; R/M control reg
	of 'D'  EXP("DR%d", MRM)		; R/M reg is debug reg
	of 'E'  da_mrm (ctl, typ)		; R/M operand
	of 'G'  da_nam(ctl, MRM&7, typ) if typ eq 'F'; R/M reg is gen reg
	        da_nam(ctl, REG(MRM), typ) otherwise
	of 'I'  da_imm (ctl, typ, 0,0,ctl->Vops); immediate data
	of 'J'	case da_rem (ctl,typ)		; relative IP (jumps)
		of 1  lng = <char signed>FET
		of 2  byt = FET, wrd = FET << 8
		      lng = wrd | byt
		of 4  lng = FET, lng |= FET << 8
		      lng |= FET<<16, lng |= FET<< 24
		end case
		lng = <signed>ctl->Vadr + lng
		EXP("%X", lng)
	of 'M'  da_mrm (ctl, typ)		; RM selects memory

	of 'O'	DEC("~p:[")			; Offset only
		da_imm (ctl, typ, 4, 0, 32)	;
		EMT("]")
	of 'R'	da_mrm (ctl, typ)		; Mod selects register

	of 'S'	EMT(daAseg[REG(MRM)])		; Reg of R/M picks seg
	of 'T'	EXP("TR%d",REG(MRM))		; Reg of R/M picks seg
	of 'X'  EMT("DS:[ESI]")			;
	of 'Y'  EMT("ES:[EDI]")			;
	of '2'	lng = FET			; 2 byte opcode prefix
		quit DEC(daAg00[lng]) if lng lt 10
		quit DEC(daAg20[lng-0x20]) if (lng gt 0x1F) && (lng lt 0x30)
		quit DEC(daAg80[lng-0x80]) if (lng gt 0x7F) && (lng lt 0xC0)
		EMT("???")
	of 'e'	quit EXP("%c", typ) if !ctl->V32b ; type is part of reg name
		EMT("D") if typ eq 'w'		; type "w" => 'D'
		EXP("E%c", typ) otherwise	; 'E', then type char
	of 'f'	EMT("?Floating?")		;
;sic]		da_flt (typ - '0')		; do floating op
	of 'g'	DEC(daAgrp[typ-'0'][REG(MRM)])	; r/m group 'n'
	of 'p'  ;PUT("typ=[%c] ", typ)
		case typ			; segment prefix
		of 'C'
		or 'D'
		or 'E'
		or 'F'
		or 'G'
		or 'S' ctl->Vpre = typ
		or ' ' DEC(daArom[FET])
		of ':' EXP("%cS:", ctl->Vpre)
		end case
	of 's'  quit if typ ne 'o'		; size override
		ctl->Vops = (32+16) - ctl->Vops	; quite clever
		ctl->V32b = ctl->Vops eq 32	;
		DEC(daArom[FET])		;
	end case
  end
code	da_mrm - emit mrm

  func	da_mrm
	ctl : * daTctl
	typ : int
  is	mod : int = (MRM >> 6) & 7
	reg : int = MRM & 7
	exit da_nam (ctl, reg, typ) if mod eq 3	; register

	if !mod && (reg eq 5)
	    da_dec(ctl, "~p:[")
	    da_imm(ctl, 'd', 4, 0, 32)
	    EMT("] ")
	.. fine
	da_dec(ctl, "~p:[") if reg ne 4
	case reg
	of 0 EMT("EAX")
	of 1 EMT("ECX")
	of 2 EMT("EDX")
	of 3 EMT("EBX")
	of 4 da_sib(ctl, mod)
	of 5 EMT("EBP")
	of 6 EMT("ESI")
	of 7 EMT("EDI")
 	end case
	
	case mod
	of 1  da_imm (ctl, 'b', 4, 0, 32);
        of 2  EMT("+")
	      da_imm (ctl, 'v', 4, 0, 32);
	end case
	EMT("]")
	fine
  end

code	da_mod - get mrm field

  func	da_mod
	ctl : * daTctl
  is	if !ctl->Qmrm
	   ++ctl->Vmrm
	.. ctl->Vmrm = da_fet (ctl)
	reply ctl->Vmrm
  end
code	da_sib - emit sib

  func	da_sib
	ctl : * daTctl
	mod : int
  is	sca : int = (SIB >> 6) & 7	; SSxxxxxx Scale
	idx : int = (SIB >> 3) & 7	; xxIIIxxx Index
	bas : int = SIB & 7		; xxxxxBBB Base

	case bas
	of 0 da_dec(ctl, "~p:[EAX")
	of 1 da_dec(ctl, "~p:[ECX")
	of 2 da_dec(ctl, "~p:[EDX")
	of 3 da_dec(ctl, "~p:[EBX")
	of 4 da_dec(ctl, "~p:[ESP")
	of 5 if !mod
	        da_dec(ctl, "~p:[")
	        da_imm(ctl, 'd', 4, 0, 32)
	     else
	     .. da_dec(ctl, "~p:[EBP")
	of 6 da_dec(ctl, "~p:[ESI")
	of 7 da_dec(ctl, "~p:[EDI")
	end case

	case idx
	of 0 EMT("+EAX")
	of 1 EMT("+ECX")
	of 2 EMT("+EDX")
	of 3 EMT("+EBX")
	of 4 fine
	of 5 EMT("+EBP")
	of 6 EMT("+ESI")
	of 7 EMT("+EDI")
	end case

	case sca
	of 0 nothing
	of 1 EMT("*2")
	of 2 EMT("*4")
	of 3 EMT("*8")
	end case
  end

code	da_sca - get sib field

  func	da_sca
	ctl : * daTctl
  is	if !ctl->Qsib
	   ++ctl->Qsib
	.. ctl->Vsib = da_fet (ctl)
	reply ctl->Vsib
  end
code	da_fmt - format output

  func	da_fmt
	ctl : * daTctl
	fmt : * char
	... : ...
  is	vsprintf (ctl->Pbuf, fmt, <va_list>&fmt + #fmt)
	ctl->Pbuf = st_end (ctl->Pbuf)
  end

code	da_val - format value

  func	da_val
	ctl : * daTctl
	buf : * void
	siz : int
  is	val : int = *<*int>buf
	val &= 0xff if siz eq 1
	val &= 0xffff if siz eq 2
	EXP("%X", val)
  end

code	da_nam - emit register name

  func	da_nam
	ctl : * daTctl
	reg : int
	typ : int
  is	if typ eq 'F'
	.. exit EXP("st%d", reg)
	if typ eq 'v' && ctl->V32b
	|| typ eq 'd'
	.. EMT("E")
	EXP("%s", (typ eq 'b') ? daAbyt[reg] ?? daAwrd[reg])
  end

code	da_imm - output immediate data

  func	da_imm
	ctl : * daTctl
	cha : int
	ext : int
	opt : int
	def : int
  is	buf : [10] BYTE
	seg : int = 0
	n   : int = 0
	i   : int
	case cha
	of 'b'	n = 1
	of 'w'	n = 2
	of 'd'  n = 4
	of 's'  n = 6
	of 'c'
	or 'v'  n = (ctl->Vops) ? 4 ?? 2
	of 'p'  n = (ctl->V32b) ? 6 ?? 4
		seg = 1
	end case
	i = -1
	buf[i] = da_fet (ctl) while ++i lt n
	i = n - 1
	buf[i] = (buf[i-1] & 0x80) ? 0xff ?? 0 while ++i lt ext
	da_val (ctl, buf+n-2, 2), n -= 2 if seg
	EMT("+") if ext && !opt
	da_val (ctl, buf, (ext) ? 4 ?? n)
  end
end file
	of 'J'	case da_rem (ctl,typ)		; relative IP (jumps)
		of 1  lng = <char signed>FET
		of 2  byt = FET, wrd = FET << 8
		      lng = wrd | byt
		of 4  lng = FET, lng |= FET << 8
		      lng |= FET<<16, lng |= FET<< 24
		end case
		lng = <signed>ctl->Vadr + lng
		EXP("%X", lng)
end file
code	sp_dmp - dump

	DMP (fmt, obj) := str += sprintf (str, fmt, (obj))

  func	sp_dmp
	env : * spTenv
  is	buf : [512] char		; the buffer
	lin : [134] char		; output line
	fil : * FILE			;
	ptr : * char			;
	str : * char			;
	top : * char			;
	blk : int = 0			;
	bls : int			;
	byt : int			;
	idx : int			;
	rem : int = 0			; remainder
	cnt : int			;
;	bls = (ctx->Pent->Vsiz + 511L) / 512L ; block size
	bls = 256			;
					;
	env->Pbuf = buf			; our buffer
	bas = env->Vnxt			;
	ptr = buf			;
	byt = 0				; byte in block
     while rem gt			;
	str = lin			; reset that
	top = ptr + 16			;
	cnt = (rem ge 16) ? 16 ?? rem	; segment length
	idx = 16			;
	PUT (" ", <>)			; start with a space
	while --idx ge			;
	   --top			;
	   DMP("   ", <>) if idx ge cnt	; out of data
	   DMP("%02X ", *top & 255) otherwise	;
	end				;
	DMP("%04x  ", byt)		;
	idx = 0				;
	while idx lt cnt		;
	   if ptr[idx] gt 32 && ptr[idx] le 127
	      *str++ = ptr[idx]		; store it
	   else				;
	   .. *str++ = '.'		;
	   ++idx			;
	end				;
	*str = 0			; terminate it
	PUT("%s\n", lin)		;
	byt += 16, ptr += 16, rem -= 16	;
     end				;
	++blk				; next block
   end					;
	PUT("\n")			;
 end



end file
#define xprintf printf
extern long printf(char *fmt, ...);		/* From Monitor.c */
   while (1) {
	if (next_segment()) {
	    if (*pSplatLex == ',') {
	       ++pSplatLex; display (); PUT("\n");}}	/* \\ force output */	
        else {
	   if (vFileOpen) display (); else PUT("%6d | ", vSplatPC);
	   get_command (); }

	/* repeat last command */
	if (aSplatLine[0] == ';') strcpy (aSplatLine, aSplatOldLine);

	next_token ();
	if (!*aSplatToken) {vSplatPC += vSplatSize; continue;}
	strcpy (aSplatOldLine, aSplatLine);
	++cmdctx;
	switch (match_token(commands)) {
	break; case cExit: exit(exitStatus);
	break; case cQuit: exit(1);
        break; case cHelp: do_help ();
	break; case cOpen: do_open();
	break; case cClose: do_close();
	break; case cShow: do_show();
	break; case cFind: do_find();
	break; case cDump: do_dump();
	break; case cAddr: do_address();
	break; case cDec: vSplatRadix = cSplatDECIMALBASE;
	break; case cHex: vSplatRadix = cSplatHEXBASE;
	break; case cSigned: vSplatSign = 1;
	break; case cUnsigned: vSplatSign = 0;
	break; case cByte: vSplatSize = cSplatBYTESIZE;
	break; case cWord: vSplatSize = cSplatWORDSIZE;
	break; case cLong: vSplatSize = cSplatLONGSIZE;

        break; default: do_special();
	}
   }
