file	gk_cfg - display config flags
include	rid:rider

  type	cfTdsc
  is	Vflg : WORD
	Pnam : * char
  end

  init	cfAcf1 : [] cfTdsc
  is	01,	"FB monitor"
	02,	"SL fetch"
	04,	"VT11 present"
	010,	"BATCH present"
	020,	"SL active"
	040,	"50 Hertz"
	0100,	"FPU present"
	0200,	"FG system"
	0400,	"VT11 link"
	01000,	"USR noswap"
	02000,	"QUEUE"
	04000,	"LSI cpu"
	010000,	"XM system"
	020000,	"Clock SR"
	040000,	"KW11P clock"
	0100000,"Clock present"
	0,	<>
  end

  init	cfAcf2 : [] cfTdsc
  is	01,	"Cache memory"
	02,	"Parity memory"
	04,	"Readable SWR"
	010,	"Writeable SWR"
	020,	"LD:"
	040,	"KMON swap"
	0100,	"Q-Bus cpu"
	0200,	"CIS present"
	0400,	"EIS present"
	01000,	"VS60 present"
	02000,	"DBGSY$"
	04000,	"KXJ11 cpu"
	010000,	"Global SCCA"
	020000,	"Pro cpu"
	040000,	"11/70 cpu"
	0100000,"11/60 cpu"
	0,	<>
  end
code	start

  type	cfTcfg
  is	Voff : int
	Pdsc : * cfTdsc
	Vsta : int		; current state
	Vbit : int		; loop bit
  end

  init	cfAcfg : [] cfTcfg
  is	0300, cfAcf1, 0, 0
	0370, cfAcf2, 0, 0
	0, <>, 0, 0
  end

  func	gk_cfg
  is	cfg : * cfTcfg
	fnd : int
	pad : int
	PUT("CONFIG			CONFG2\n")
	cfg  = cfAcfg
	while cfg->Voff ne
	   cfg->Vbit = 1
	   cfg->Vsta = rt_gvl (cfg->Voff)
	   ++cfg
	end
      repeat
	cfg  = cfAcfg
	fnd = 0
	pad = 0
	while cfg->Voff ne
	   ++fnd, pad = 0 if cf_ent (cfg, pad)
	   pad += 24      otherwise
	   ++cfg
	end
	quit if !fnd
 	PUT("\n")
     end
	fine
  end

  func	cf_ent
	cfg : * cfTcfg
	pad : int
  is	dsc : * cfTdsc = cfg->Pdsc

	while cfg->Vbit
	   quit if cfg->Vbit & cfg->Vsta
	   cfg->Vbit <<= 1
	end
	fail if !cfg->Vbit

	while dsc->Vflg
	   if !(cfg->Vbit & dsc->Vflg)
	   .. next ++dsc
	   PUT(" ") while pad--
	   PUT("%-8o%-16s", dsc->Vflg, dsc->Pnam)
	   cfg->Vbit <<= 1
	   fine
	end
	fail	; unidentified bit
  end

end file
