file	eldos - dos/batch extensions
include	elb:elmod
include	rid:dbdef
include	rid:stdef

  type	dsTemt
  is	Vcod : int
	Pnam : * char
 	P1   : * char
 	P2   : * char
 	P3   : * char
 	P4   : * char
  end

  init	dsAemt : [] dsTemt
  is	000, "waitr","lblck", "addr", "", ""
	001, "wait", "lblck", "", "", ""
	002, "write","lblck", "lbuff", "", ""
	003, "rlwr*", "", "", "", ""
	004, "read", "lblck", "lbuff", "", ""
	005, "rlrd*", "", "", "", ""
	006, "init", "lblck", "", "", ""
	007, "rlse", "lblck", "", "", ""
	010, "tran", "lblck", "tblck", "", ""
	011, "block","lblck", "bblck", "", ""
	012, "spec", "lblck", "sarg", "", ""
	013, "stat", "lblck", "", "", ""
	014, "look", "lblck", "fblck", "op", ""
	015, "alloc","lblck", "fblck", "n", ""
	016, "open", "lblck", "fblck", "", ""
	017, "close","lblck", "", "", ""
	020, "renam","lblck", "ofb", "nfb", ""
	021, "delet","lblck", "fblck", "", ""
	022, "appnd","lblck", "1fb", "2fb", ""
	023, "grbge*", "", "", "", ""
	024, "keep", "lblck", "fblck", "", ""
	025, "recrd","lblck", "fblck", "", ""
	030, "kbovl", "",  "", "", ""
	031, "kblistn", "",  "", "", ""
	032, "diagprt", "",  "", "", ""
	033, "kbcmd", "",  "", "", ""
	034, "bitmap", "",  "", "", ""
	035, "spare", "",  "", "", ""
	036, "spare", "",  "", "", ""
	037, "spare", "",  "", "", ""
	040, "msbovl", "",  "", "", ""
	041, "genutl", "",  "", "", ""
	042, "gencnv", "",  "", "", ""
	043, "fopen1", "",  "", "", ""
	044, "fopen2", "",  "", "", ""
	045, "fclose", "",  "", "", ""
	046, "fkook", "",  "", "", ""
	047, "falloc", "",  "", "", ""
	050, "fbtmap", "",  "", "", ""
	051, "calloc", "",  "", "", ""
	052, "fcheck", "",  "", "", ""
	053, "dellnk", "",  "", "", ""
	054, "delctg", "",  "", "", ""
	055, "appnd2", "",  "", "", ""
	056, "CSI1", "", "", "", ""
	057, "CSI2", "", "", "", ""
	060, "exit", "", "", "", ""
	061, "load1", "",  "", "", ""
	062, "load2", "",  "", "", ""
	063, "opntap", "",  "", "", ""
	064, "dump", "low", "high", "cde", ""
	065, "run", "", "", "", ""
	066, "cvtdt", "", "", "", ""
	067, "flush", "", "", "", ""

;	Internal

	030, "iot", "code", "", "", ""		; redirect IOT trap
						; code=0  halt cpu
	000, "", "", "", "", ""
  end

  proc	ds_emt
 	adr : elTwrd
	emt : elTwrd
  is	ptr : * dsTemt = dsAemt
;	PUT("%o	%o	emt	%o	", adr&0177777, emt, emt&0377)
	PUT("%o%s\t", adr&0xffff, el_mod (PS))
	emt &= 0377
	while ptr->Pnam
	   quit if ptr->Vcod eq emt
	   ++ptr
	end
	PUT("%-7s ", ptr->Pnam)
	el_new ()
  end
