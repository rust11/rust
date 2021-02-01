;	MACROM.MAC/.PAL
;	MACLIB.MAC/.PAL/.P11
;	DRVCOM
file	elxdp -- xxdp extensions
include	elb:elmod
include	rid:dbdef
include	rid:stdef

; XXDP tests
; xxdp23
; vkaac0.bic  11/03 basic instructions
; vkabb0.bic  11/03 EIS & terminal interrupts
; vkacc1.bic  11/03 FIS & CIS (DIBOL INSTRUCTION SET)
; vkadc1.bic  11/03 Traps Test
; vkaeb3.bic  11/03 DLV11 TEST
; vkah1.bic
;
; xxdp25
; zkcaa0 - unibus

	xxIGN := 0
	xxSHO := 1
	xxONC := 2

	xxVsho : int = xxSHO
	xxVign : int = xxIGN
	xxVonc : int = xxONC

	xxVprv : int = 0

;	37. SM services

	xx_spc : (elTadr, *char) *char
	IGN(s,x) := (msk = xxVign)
	DSP(s,x) := (cap = s)
	SPC(s) := (spc = xx_spc (s, asc))

  proc	xx_emt
	adr : elTwrd
	emt : elTwrd
  is	cap : * char = ""
	msk : int = 1
	asc : [14] char
	spc : * char = <>
	cas : int = OP & 0377

	case cas
	of 000 DSP("GCmdSt", "GetLin")
	of 001 DSP("GToken", "ParFld")
	of 002 IGN("PLine",  "TypMon")
	of 003 IGN("TypMsg", "TypStr")
	of 004 IGN("PutChr", "PutChk")
	of 005 IGN("CKybd",  "GetAvl")
	of 006 IGN("GetChr", "GetChk")
	of 007 IGN("CrLf",   "NewLin")

	of 010 IGN("Tabs",   "PutTab")
	of 011 DSP("GetNum", "ParOct")
	of 012 DSP("Open",   "OpnFil"), SPC(R0)
	of 013 DSP("Close",  "CloFil")		; a NOP
	of 014 DSP("Load",   "LoaLDA"), SPC(R0)
	of 015 IGN("GetWrd", "ReaWrd")
	of 016 IGN("GetByt", "ReaByt")
	of 017 IGN("OneChr", "PutCha")

	of 020 DSP("NxtBlk", "ReaNxt")
	of 021 DSP("BkRead", "ReaBlk")
	of 022 DSP("SetErr", "SetAbt")
	of 023 DSP("Error",  "JmpAbt")	; defined as "Abort" in TRAP list
	of 024 IGN("CmpNam", "CmpSpc")
	of 025 IGN("UpkNam", "R50Asc")
	of 026 DSP("KSwitch","SetLin")
	of 027 DSP("Date",   "GetDat")

	of 030 DSP("IToA",   "OctAsc")
	of 031 DSP("Default","DevNam")
	of 032 DSP("RToken", "SetFld")
	of 033 DSP("LinePtr","RedTer")
	of 034 DSP("NoPrtr", "RstTer")
	of 035 DSP("Autoloa","LoaSup")
	of 036 DSP("GetDec", "ParDec") 
	of 037 DSP("Fill",   "PutPad")

	of 040 DSP("PutScp", "BatMod")
	of 041 DSP("CChain", "TerMod")		; TerMod wrong???
	of 042 DSP("Comm",   "GetCSR")
	of 043 DSP("RDrive", "GetDrv")	
	of 044 DSP("FrcTyp", "TypSpc")

;	End of XXDP+ services

	of 045 DSP("ChkCC",  "")
	of 046 DSP("Emt46",  "")
	of 047 DSP("Emt47",  "")

	of 050 DSP("Lkup",   "")		; lookup?
	of 051 DSP("WrtODv", "")
	of 052 DSP("ClsFil", "")
	of 053 DSP("ReadBin","")
	of 054 DSP("ReadAsc","")
	of 055 DSP("WriteA", "")
	of 056 DSP("LdProg", "")
	of other
	       DSP("???",    "")
	end case

	case msk
	of xxIGN  exit
	of xxONC  exit if xxVprv eq cas
	end case
	xxVprv = cas

	el_sol ()			; force start-of-line
	PUT("%o	emt=%-4o ", PC&0177777, OP&0377)
	PUT("%-7s", cap)
	PUT(" r0=%-6o", R0)
	PUT(" r1=%-6o", R1)
	PUT(" r5=%-6o", R5)
	PUT(" spc=[%s]", spc) if spc
	el_new ()
  end

  func	xx_spc
	adr : elTadr
	spc : * char
	()  : * char
  is	ptr : * char = spc
	cnt : int = 10
	cha : int
	blk : int = 0

	while cnt--
	   cha = el_fbt (adr++)
	   next if !blk && !cha
	   *ptr++ = cha, ++blk
	end
	*ptr = 0
	reply spc
  end
code	xx_trp - xxdp traps

  proc	xx_trp
	adr : elTwrd
	emt : elTwrd
  is	cap : * char = ""
	msk : int = 1
	asc : [14] char
	spc : * char = <>
	cas : int = OP & 0377

	case cas
	of 000 cap = "???"
	of 001 cap = "TypRad"	; type rad50?
	of 002 cap = "Bcdcv"	; decimal ascii output, r1=#digits
	of 003 cap = "DatUpk"	; unpack date
	of 004 cap = "BytFil"	; byte fill: src=r1,dst=@r0,cnt=r2
	of 005 cap = "ClrBMp"	; clear bitmap: Use BytFil to clear bmap
	of 006 cap = "BkRead"	; block read: RdDat 256 words
	of 007 cap = "RdDat"	; read data

	of 010 cap = "WrtDat"	; write data
	of 011 cap = "BlkWrt"	; block write
	of 012 cap = "WrtLc"	; write lc?
	of 013 cap = "ClrBuf"	; clear buffer
	of 014 cap = "PakNam"	; pack name (to rad50)
	of 015 cap = "TypNam"	; type name
	of 016 cap = "MBufAd"	; M buffer address
	of 017 cap = "ChkSum"	; 256-word checksum returned in @r0
				; tracks directory additions/deletions
				; during wildcard operations
	of 020 cap = "BMove"	; buffer move: src=@r1,dst=@r2,cnt=r3
	of 021 cap = "Trap21"	; was probably abort
;	emt 23 abort
	of 022 cap = "DtDel"	; DT delete (dectape?)
	of 023 cap = "Boot"	; boot device
	of 024 cap = "ClrMap"	; clear map
	of 025 cap = "AlocBk"	; allocate block
	of 026 cap = "Alloc"	; allocate
	of 027 cap = "ReadMp"	; read map

	of 030 cap = "ClsMap"	; close map
	of 031 cap = "WrtMap"	; write map
	of 032 cap = "Trap32"	;
	of 033 cap = "StufDs"	; stuff DS
	of 034 cap = "Close"	; close
	of 035 cap = "DalSbk"	; deallocate Sbk
	of 036 cap = "DalLnk" 	; Deallocate Lnk
	of 037 cap = "DalCtg"	; Deallocate Contiguous

	of 040 cap = "StMaps"	; st maps
	end case

	case msk
	of xxIGN  exit
	of xxONC  exit if xxVprv eq cas
	end case
	xxVprv = cas

	el_sol ()			; force start-of-line

;	PUT("%o	%o	trap	%3o", PC&0177777, OP, OP&0377)
	PUT("%o	trap=%-3o ", PC&0177777, OP&0377)
	PUT("%-7s", cap)
	PUT(" r0=%-6o", R0)
	PUT(" r1=%-6o", R1)
	PUT(" r5=%-6o", R5)
	PUT(" spc=[%s]", spc) if spc
	el_new ()
  end
code	xx_loo - detect loop

;	collect information on last few EMTs or TRAPs
;	detect cycles

