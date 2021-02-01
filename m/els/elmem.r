file	elmem - memory
include	elb:elmod

code	el_fwd - fetch word

;	fetch/store word/byte routines

	SCHCON := (elVsch |= elCON_)

  func	el_fwd
	adr : elTadr
	()  : elTwrd
  is	val : elTwrd
	exit INVADR(0) if (adr & 1) && !elFlsi
	adr = VPR(adr)
	val = *PNW(adr & elVevn)	; 11/03 even addresses
	reply val if adr lt elVhwm	; nothing special
	reply val if adr ge elREG	; register area
 
	elVsch |= elCON_		; schedule controllers
	case NMX(adr)
	of elTKS  elVtks = 1
	of elTKB  elVtkb = 0, TKS &= ~(elRDY_)
	of elTPS  val |= elRDY_
	of elTPB
	of elPSW  INVADR(2) if elFlsi
		  val = PS otherwise
	of hdCSR
	of hdCNT
	of hdBLK
	of hdBUF
	of hdXX0
	of hdXX1
	of hdBAE
	of hdBAE+2
	of rlCSR 
	of rlBUF
	of rlBLK
	of rlCNT
	of rlEXT  INVADR(3) if !elFdlx

	of rkSTA  val |= rkRK5_
	of rkERR
	of rkCSR  val = val & ~(hdACT_)
		  val |= elRDY_
	of rkCNT
	of rkBUF
	of rkADR
	of rkDAT
	of rkDAT+2

;	of dyCSR
;	of dyBUF  dyVbuf = elFTW

	of elLTC  INVADR(3) if !elFltc

	of elMP0	; memory parity register set
	of elMP1
	of elMP2
	of elMP3
	of elMP4
	of elMP5
	of elMP6
	of elMP7

	of other  INVADR(3) if !el_mma (adr, 0, &val)
	end case
	reply val & elWRD_
  end

code	el_fbt - fetch byte

  func	el_fbt
	adr : elTadr
	()  : elTbyt
  is	val : elTbyt
	adr = VPR(adr)
	val = *PNB(adr)
	reply val if adr lt elVhwm	; nothing special
	reply val if adr ge elREG	; register area
	elVsch |= elCON_		; schedule controllers
	case NMX(adr)
	of elTKS  elVtks = 1
	of elTKB  elVtkb = 0, TKS &= (~elRDY_)
	of elTPS  val |= elRDY_
	of elTPB
	of elPSW  INVADR(6) if elFlsi
		  val = PS otherwise
	of hdCSR
	of hdCNT
	of hdBLK
	of hdBUF
	of hdXX0
	of hdXX1
	of hdBAE
	of hdBAE+2
	of rlCSR
	of rlBUF
	of rlBLK
	of rlCNT
	of rlEXT  INVADR(3) if !elFdlx

	of rkSTA   
	of rkERR
	of rkCSR
	of rkCSR+1
	of rkCNT
	of rkBUF
	of rkADR
	of rkDAT
	of rkDAT+2

;	of dyCSR
;	of dyBUF  dyVbuf = elFTB

	of elTKS+1
	of elTKB+1
	of elTPS+1
	of elTPB+1

	of elLTC  INVADR(3) if !elFltc

	of elMP0
	of elMP1
	of elMP2
	of elMP3
	of elMP4
	of elMP5
	of elMP6
	of elMP7

	of other   INVADR(7) if !el_mma (adr, 0, <*elTwrd>&val)
	end case
	reply val & elBYT_
  end

code	el_swd - store word

;	RDY := (*PNW(adr & elVevn) = ((old&0200)|(val&~0200)))

  proc	el_swd
	adr : elTadr
	val : elTwrd
  is	old : elTwrd
	exit INVADR(8) if (adr & 1) && !elFlsi
	adr = VPW(adr)
	exit if elVsch & elMMX_		; mmu error
	old = *PNW(adr & elVevn)
	*PNW(adr & elVevn) = val
	exit if adr lt elVhwm
	exit if adr ge elREG		; register area
	elVsch |= elCON_		; schedule controllers
	case NMX(adr)
	of elTKS   elVtks = 1, TKS = ((val&elENB_)|(old&elRDY_)) & 0300
		   el_sch (elKBD_) if (old eq 0200) && (val&elENB_)
	of elTKB
	of elTPS   TPS = ((val&(elENB_|1))|(old&elRDY_)) & 0301
		   el_sch (elTER) if TPS & elENB_
	of elTPB   TPS &= ~(elRDY_), elVtpp = 1 if elTPB & 0xff
	of elPSW   INVADR(10) if elFlsi
		   NEWPS(val & (~elT_)) otherwise
	of hdCSR
	of hdCNT
	of hdBLK
	of hdBUF
	of hdXX0
	of hdXX1
	of hdBAE
	of hdBAE+2
	of rlCSR
	of rlBUF
	of rlBLK
	of rlCNT
	of rlEXT  INVADR(3) if !elFdlx

	of rkSTA
	of rkERR
	of rkCSR  ;RDY
	of rkCNT
	of rkBUF
	of rkADR
	of rkDAT
	of rkDAT+2

;	of dyCSR
;	of dyBUF   dyVbuf = elSTW

	of elLTC  INVADR(3) if !elFltc

	of elMP0
	of elMP1
	of elMP2
	of elMP3
	of elMP4
	of elMP5
	of elMP6
	of elMP7

	of other   INVADR(11) if !el_mma (adr, 0 ,&val)
		   *PNW(adr & elVevn) = val
	end case
  end

code	el_sbt - store byte

  proc	el_sbt
	adr : elTadr
	val : elTbyt
  is	old : elTbyt
	adr = VPW(adr)
	exit if elVsch & elMMX_		; mmu error
	old = *PNB(adr)
	*PNB(adr) = val
	exit if adr lt elVhwm
	exit if adr ge elREG		; register area
	elVsch |= elCON_		; schedule controllers
	case NMX(adr)
	of elTKS   elVtks = 1, TKS = ((val&elENB_)|(old&elRDY_)) & 0300
		   el_sch (elKBD_) if (old eq 0200) && (val&elENB_)
	of elTKB
	of elTPS   TPS = ((val&(elENB_|1))|(old&elRDY_)) & 0301
		   el_sch (elTER) if TPS & elENB_
	of elTPB   TPS &= ~(elRDY_), elVtpp = 1 if elTPB & 0xff
	of elPSW   INVADR(13) if elFlsi
		   NEWPS((PS&0xff00) | (val&(0x00ff & ~elT_))) otherwise
	of hdCSR
	of hdCNT
	of hdBLK
	of hdBUF
	of hdXX0
	of hdXX1
	of hdBAE
	of hdBAE+2
	of rlCSR
	of rlBUF
	of rlBLK
	of rlCNT
	of rlEXT  INVADR(3) if !elFdlx

	of rkSTA
	of rkERR
	of rkCSR
	of rkCNT
	of rkBUF
	of rkADR
	of rkDAT
	of rkDAT+2

;	of dyCSR
;	of dyBUF   dyVbuf = elSTB

	of elTKS+1
	of elTKB+1
	of elTPS+1
	of elTPB+1

	of elLTC  INVADR(3) if !elFltc

	of elMP0
	of elMP1
	of elMP2
	of elMP3
	of elMP4
	of elMP5
	of elMP6
	of elMP7

	of other   INVADR(14) if !el_mma (adr, 0, <*elTwrd>&val)
;sic]		   *PNW(adr) = val	; see el_mma
	end case
  end
end file

-------------

file	elmem - memory

;	In general:
;
;	Reads are passive and can be handled generally
;	Writes are constrained and trigger action routines

  type	elTbus
  is	Vlow : elTwrd
	Vhgh : elTwrd
	Vand : elTwrd
	Vor  : elTwrd
	Vedg : elTwrd
	Pact : * elT
	Vflg : word
  end

	buCAS_ := BIT(0)	; case statement required
	buIHB_ := BIT(1)	; ignore high byte
	buMHB_ := BIT(2)	; merge high byte
	buRON_ := BIT(3)	;
	buLSI_ := BIT(4)	; not implemented on LSI

  init	elAbui : [4096] * elTbus
  is;	low	high	and	or	edge	act	flags
	0177560,0,	0100,	0200,	0300,	0,	CAS|IHB
	0177562,0,	0377,	0,	0,	0,	CAS|IHB
	0177564,0,	0100,	0200,	0300,	0,	0  |IHB
	0177566,0,	0377,	0,	0,	0,	CAS|IHB
	0,	0,	0,	0,	0,	0,	0
	0,	0,	0,	0,	0,	0,	0
  end

	elAbus : [4096] * elTbus = {0}

  func	el_rmb
	adr : elTadr
  is	val : int = el_rmw (adr & ~(1))
	reply val if ~(adr & 1)
	reply (val>>8) & 0377 
  end

  func	el_rmw
	adr : elT
  is	odd : int = adr & 1
	bus : * elTbus = elAbus[MBX(adr)]
	val : int = *MNB(adr)
	exit INVADR if !bus
	reply val if !bus->Vflg			; ordinary read
	reply 0 if bus->Vflg & el_		; always zero
	reply (*bus->Pact)(bus, adr) if bus->Pact
     if bus->Vflg & elCAS_			; want it cased
	case adr				;
	of
        end

  func	mm_rmg
	mem : * mmTmem
	adr : elTwrd
  is	case adr

  end

  func	mm_wmw
	adr : elT
	val : elTwrd
  is	mem : * elTmem = elAmem[adr-]
	exit INVADR if !mem

	val = (val & ~(mem->Vbic))|(mem->Vbis) 
	reply (*mem->Pact)(mem, adr) if mem->Pact

  