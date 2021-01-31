file	gkrmn - display rmon
include	rid:rider
include	gkb:gkmod

  type	rmTent
  is	Voff : int
	Pstr : * char
	Vcnt : int
  end

  type	rmTfun : (*rmTent)
	cu_ent : rmTfun

;	offset	title		bytes	;func	tabs
  init	rmAtab : [] rmTent
  is	0,	"rmon",		4;,	;0,	1
	04,	"csw",		2;,	;0,	2
	0244,	"sysch",	4;,	;0,	1
;	0252,	"i.serr",	2;,	;0,	2
;	0254,	"i.spls",	2;,	;0,	2
	0256,	"blkey",	2;,	;0,	2
	0260,	"chkey",	2;,	;0,	2
	0262,	"date",		2;,	;0,	2
	0264,	"dflg",		2;,	;0,	2
	0266,	"usrlc",	2;,	;0,	2
	0270,	"qcomp",	2;,	;0,	2
	0272,	"spusr",	2;,	;0,	2
	0274,	"syunit",	2;,	;rm_uni,	1
	0276,	"sysver",	1;,	;0,	2
	0277,	"sysupd",	1;,	;0,	2
	0300,	"config",	2;,	;0,	2
	0302,	"scroll",	2;,	;0,	2
	0304,	"ttks",		2;,	;0,	2
	0306,	"ttkb",		2;,	;0,	2
	0310,	"ttps",		2;,	;0,	2
	0312,	"ttpb",		2;,	;0,	2
	0314,	"maxblk",	2;,	;0,	2
	0316,	"e16lst",	2;,	;rm_e16,	1
	0320,	"time",		4;,	;0,	1
	0320,	"cntxt",	2;,	;0,	2
	0322,	"jobnum",	2;,	;0,	2
	0324,	"synch",	2;,	;0,	2
	0326,	"lowmap",	2;,	;0,	2
	0342,	"s$ynet",	1;,	;0,	2
	0342,	"p$hucf",	1;,	;0,	2
	0350,	"d$rpnm",	2;,	;0,	2
	0352,	"usrloc",	2;,	;0,	2
	0354,	"gtvect",	2;,	;0,	2
	0356,	"errcnt",	2;,	;0,	2
	0360,	"mtps",		2;,	;rm_mtp,	1
	0362,	"mfps",		2;,	;rm_mfp,	1
	0364,	"syindx",	2;,	;0,	2
	0366,	"statwd",	2;,	;0,	2
	0370,	"confg2",	2;,	;0,	2
	0372,	"sysgen",	2;,	;0,	2
	0374,	"usrare",	2;,	;0,	2
	0376,	"errlev",	1;,	;0,	2
	0377,	"ifmxns",	1;,	;0,	2
	0400,	"emtrtn",	2;,	;tblst,	1
	0402,	"fork",		2;,	;tblst,	1	
0,<>,0
	0404,	"pnptr",	2;,	;rm_pnp,	1
	0406,	"moname",	2;,	;pmonam,	1
	0412,	"suffix",	2;,	;suffix,	2
	0414,	"spool",	2;,	;0,	2
	0416,	"extind",	1;,	;0,	2
	0417,	"indsta",	1;,	;0,	2
	0420,	"memsz",	2;,	;0,	2
	0422,	"conlog",	2;,	;0,	2
	0424,	"tcfig",	2;,	;ptcfig,	1
	0426,	"inddv",	2;,	;dummy,	1
	0430,	"memptr",	2;,	;pname,	1
	0432,	"p1ext",	2;,	;0,	2
	0434,	"getcsr",	1;,	;0,	2
	0434,	"trplst",	1;,	;0,	2
	0436,	"getvec",	2;,	;0,	2
	0440,	"dwtype",	2;,	;0,	2
	0442,	"trpset",	2;,	;0,	2
	0444,	"$nuljb",	2;,	;0,	2
	0446,	"imploc",	2;,	;0,	2
	0450,	"progdf",	2;,	;0,	2
	0452,	"wildef",	1;,	;0,	2
	0454,	"$jobc",	1;,	;0,	2
	0456,	"$qhook",	2;,	;0,	2
	0460,	"$h2ub",	2;,	;0,	2
	0462,	"$h2ca",	2;,	;0,	2
	0464,	"$rtspc",	2;,	;0,	2
	0466,	"$cnfg3",	2;,	;0,	2
	0470,	"$tt2rm",	2;,	;0,	2
	0472,	"$rm2co",	2;,	;0,	2
	0474,	"$decnt",	2;,	;0,	2
	0476,	"$xttps",	2;,	;0,	2
	0500,	"$xttpb",	2;,	;0,	2
	0502,	"$slot2",	1;,	;0,	2
	0503,	"unused",	1;,	;0,	2
	0504,	"$spsiz",	2;,	;0,	2
	0,	<>,		1
	0,	<>,		1
  end
code	gk_rmn - display

	rm_ent : (* WORD, * diTrmn)
	rmWCT := 0506

 func	gk_rmn
	dcl : * dcTdcl
  is	rmn : * rmTent = rmAtab
	nxt : * rmTent = rmn	; next area
	bas : * rmTent		; current area
	tot : int = 0
	idx : int
	row : int
	col : int
	dep : int
	buf : * WORD = me_acc (rmWCT*2)	; make a buffer

	idx = 0
	while idx lt rmWCT
	   buf[idx] = rt_gvl (idx * 2)
	   ++idx
	end

    repeat
	bas = rmn = nxt
	tot = 0
	++tot, ++rmn while rmn->Pstr ne	; count total for group
	nxt = rmn + 1			; next group
	dep = tot / 2			; column depths
	row = 0
      repeat
	col = 0
	while col lt 2
	   idx = (dep * col) + row
	   rmn = bas + idx
	   rm_ent (buf, rmn)
	   ++col
	   quit if idx ge tot-1
	end
	PUT("\n")
	quit if idx ge tot-1
	++row
      end
	quit if nxt->Pstr eq		;no more groups
	co_prm ("?RMON-I-More? ", <>)
    end
	fine
  end
code	rm_ent - display entry

	rm_ent : (*WORD, int, int)

  func	rm_ent
	buf : * WORD
	ent : * rmTent
  is	off : int = ent->Voff
	cnt : int = ent->Vcnt
	val : int = 0
	snd : int = 0
	sys : * WORD = 054

	PUT("%-6o  ", *sys+off)
	PUT("%-6s  ", ent->Pstr)
	PUT("%-3o  ", off)
	val = rm_val (buf, off, ent->Vcnt)
	PUT("%-6o ", val)
	case off
	of 0000
	or 0304
	or 0310	++snd, val = rm_val (buf, off+2, 2)
	end case
	case snd
	of 0 PUT("       ")
	of 1 PUT("%-6o ", val)
	end case
 end

code	rm_val - get a value

  func	rm_val
	buf : * WORD
	off : int
	siz : int
  is	val : int = buf[off/2]
	if siz eq 1
	   val >> 8 if off & 1
	.. val &= ~(0377)
	reply val
  end
