file	ctmod - character type tests
include	rid:rider
include	rid:ctdef

data	ctAtab - ascii character table

  init  ctAtab : [] BYTE	;	char	    dec oct
  is	(ctCTL_),		;	null	=    0  ;0
	(ctCTL_),		;	ctrla.	=    1.	;1	
	(ctCTL_),		;	ctrlb.	=    2.	;2
	(ctCTL_),		;	ctrlc.	=    3.	;3
	(ctCTL_),		;	ctrld.	=    4.	;4
	(ctCTL_),		;	ctrle.	=    5.	;5
	(ctCTL_),		;	ctrlf.	=    6.	;6
	(ctCTL_),		;	bell.	=    7.	;7
	(ctCTL_|ctSPC_),	;	bs.	=    8.	;10
	(ctCTL_|ctSPC_),	;	tab.	=    9.	;11 or ht.
	(ctCTL_|ctSPC_),	;	lf.	=   10.	;12
	(ctCTL_|ctSPC_),	;	vt.	=   11. ;13
	(ctCTL_|ctSPC_),	;	ff.	=   12.	;14
	(ctCTL_|ctSPC_),	;	cr.	=   13.	;15
	(ctCTL_),		;	si.	=   14.	;16
	(ctCTL_),		;	so.	=   15.	;17
	(ctCTL_),		;	ctrlp.	=   16.	;20
	(ctCTL_),		;	ctrlq.	=   17.	;21
	(ctCTL_),		;	ctrlr.	=   18.	;22
	(ctCTL_),		;	ctrls.	=   19.	;23
	(ctCTL_),		;	ctrlt.	=   20.	;24
	(ctCTL_),		;	ctrlu.	=   21.	;25
	(ctCTL_),		;	ctrlv.	=   22.	;26
	(ctCTL_),		;	ctrlw.	=   23.	;27
	(ctCTL_),		;	ctrlx.	=   24.	;30
	(ctCTL_),		;	ctrly.	=   25.	;31
	(ctCTL_),		;	ctrlz.	=   26.	;32
	(ctCTL_),		;	esc.	=   27.	;33	ctrl/[
	(ctCTL_),		;	ctbsl.	=   28.	;34	ctrl/\
	(ctCTL_),		;	ctrsb.	=   29.	;35	ctrl/]
	(ctCTL_),		;	cthat.	=   30.	;36	ctrl/^
	(ctCTL_),		;	ctund.	=   31.	;37	ctrl/_
	(ctPRN_|ctSPC_),	;	space.	=   32.	;40	;space
	(ctPRN_|ctPUN_),	;	xclam.	=   33.	;41	;!
	(ctPRN_|ctPUN_),	;	dquot.	=   34. ;42	;"
	(ctPRN_|ctPUN_),	;	hash.	=   35.	;43	;#
	(ctPRN_|ctPUN_|ctIDN_),	;	dolar.	=   36.	;44	;$
	(ctPRN_|ctPUN_),	;	perct.	=   37.	;45	;%
	(ctPRN_|ctPUN_),	;	ampsd.	=   38.	;46	;&
	(ctPRN_|ctPUN_),	;	quote.	=   39.	;47	;' or squot.
	(ctPRN_|ctPUN_),	;	lparn.	=   40.	;50	;(
	(ctPRN_|ctPUN_),	;	rparn.	=   41.	;51	;)
	(ctPRN_|ctPUN_),	;	astrx.	=   42.	;52	;*
	(ctPRN_|ctPUN_),	;	plus.	=   43.	;53	;+
	(ctPRN_|ctPUN_),	;	comma.	=   44.	;54	;,
	(ctPRN_|ctPUN_),	;	minus.	=   45.	;55	;-
	(ctPRN_|ctPUN_),	;	dot.	=   46.	;56	;.
	(ctPRN_|ctPUN_),	;	slash.	=   47.	;57	;/
	(ctPRN_|ctDIG_|ctHEX_),	;	dig0.	=   48.	;60	;0
	(ctPRN_|ctDIG_|ctHEX_),	;
	(ctPRN_|ctDIG_|ctHEX_),	;
	(ctPRN_|ctDIG_|ctHEX_),	;
	(ctPRN_|ctDIG_|ctHEX_),	;
	(ctPRN_|ctDIG_|ctHEX_),	;
	(ctPRN_|ctDIG_|ctHEX_),	;
	(ctPRN_|ctDIG_|ctHEX_),	;
	(ctPRN_|ctDIG_|ctHEX_),	;
	(ctPRN_|ctDIG_|ctHEX_),	;	dig9.	=   57.	;71	;9
	(ctPRN_|ctPUN_),	;	colon.	=   58.	;72	;:
	(ctPRN_|ctPUN_),	;	semi.	=   59.	;73	;;
	(ctPRN_|ctPUN_),	;	langl.	=   60.	;74	;<
	(ctPRN_|ctPUN_),	;	equal.	=   61.	;75	;=
	(ctPRN_|ctPUN_),	;	rangl.	=   62.	;76	;>
	(ctPRN_|ctPUN_),	;	qmark.	=   63.	;77	;?
	(ctPRN_|ctPUN_),	;	atsgn.	=   64.	;100	;@
	(ctPRN_|ctUPR_|ctHEX_), ;	upra.	=   65.	;101	;a	capa.
	(ctPRN_|ctUPR_|ctHEX_),	;	b
	(ctPRN_|ctUPR_|ctHEX_),	;	c
	(ctPRN_|ctUPR_|ctHEX_),	;	d
	(ctPRN_|ctUPR_|ctHEX_),	;	e
	(ctPRN_|ctUPR_|ctHEX_),	;	f
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;
	(ctPRN_|ctUPR_),	;	uprz.	=   90.	;132	;z	capz.
	(ctPRN_|ctPUN_),	;	lsqua.	=   91.	;133	;[ 	lbrac.
	(ctPRN_|ctPUN_),	;	bslas.	=   92.	;134	;\
	(ctPRN_|ctPUN_),	;	rsqua.	=   93.	;135	;]	rbrac.
	(ctPRN_|ctPUN_),	;	hat.	=   94.	;136	;^
	(ctPRN_|ctPUN_|ctIDN_),	;	under.	=   95.	;137	;_
	(ctPRN_|ctPUN_),	;	tick.	=   96.	;140	;`
	(ctPRN_|ctLOW_|ctHEX_),	;	lowa.	=   97.	;141	;a
	(ctPRN_|ctLOW_|ctHEX_),	;	b
	(ctPRN_|ctLOW_|ctHEX_),	;	c
	(ctPRN_|ctLOW_|ctHEX_),	;	d
	(ctPRN_|ctLOW_|ctHEX_),	;	e
	(ctPRN_|ctLOW_|ctHEX_),	;	f
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;
	(ctPRN_|ctLOW_),	;	lowz.	=  122.	;172	;z
	(ctPRN_|ctPUN_),	;	lsqig.	=  123.	;173	;{
	(ctPRN_|ctPUN_),	;	vbar.	=  124.	;174	;|
	(ctPRN_|ctPUN_),	;	rsqig.	=  125.	;175	;}
	(ctPRN_|ctPUN_),	;	tilda.	=  126.	;176	;~
	(ctCTL_)		;	del.	=  127.	;177	;del
  end
