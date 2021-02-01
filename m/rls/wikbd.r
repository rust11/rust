file	wikbd - windows keyboard
include meb:eddef
include meb:edkbd
include	rid:kbdef
include	rid:ctdef
include	rid:chdef

	kb_trn : (*kbTcha) int own

code	kb_ini - init keyboard

  func	kb_ini
	()  : int
  is	kb_att ()
;;	kbVmod = kb101			;
	fine				;
  end					;

code	kb_avl - check character available
	
	kbVral	: int = 0
  func	kb_avl
	()  : int			; fine => key pending
  is	cha : kbTcha			;
	fine if kb_get (&cha, kbPEE_)	; got one waiting
	fail if !cha.Vflg & kbENH_	; not extended code
	fine if cha.Vflg & (kbALT_|kbCTL_)
	fail
  end

code	kb_any - any key

  proc	kb_any
  is repeat				;
	exit kb_key () if kb_avl ()	; take it
     end				;
  end

code	kb_brk - set break key

;	Break is disabled thruout the session

  proc	kb_brk
	opr : int			; 0=>off, 1=>on
  is	nothing				; ignored in Windows
  end

code	kb_emp

  proc	kb_emp
  is	kb_key () while kb_avl ()	; got more
  end
code	kb_key - get 16-bit keystroke

  func	kb_key
	()  : int
  is	cha : kbTcha
	key : int			; keystroke
	tab : * int			; tables
     repeat				; ignore some
	kb_get (&cha, kbWAI_)		; get a character
	key = cha.Vord			;
	if cha.Vflg & (kbVIR_|kbALT_|kbENH_)
	.. reply kb_trn (&cha)		;
	next if (cha.Vflg & kbVIR_)	; ordinary stuff
	key = '\n' if key eq '\r'	;
	key = 127 if key eq 8		; replace delete
;	key = if 27 key eq 27		; escape
	reply key			; simple for now
     forever
  end
code	ki replacements

  func	ki_ini
  is	fine
  end

  func	ki_exi
  is	fine
  end

  func	ki_mod
	par : int
  is	fine
  end

code	kb_trn - translate key
include	rid:vkdef

  init	kbAped : [] int
  is	vkPUP, kbCprv
	vkPDN, kbCnxt
	vkEND, kbCfnd
	vkHOM, kbCsel
	vkLFT, kbCclf
	vkUPA, kbCcup
	vkRGT, kbCcrt
	vkDWN, kbCcdn
	vkINS, kbCins
	vkDEL, kbCrem
	0, 0
  end

  func	kb_trn
	cha : * kbTcha
	()  : int 
  is	tab : * int
	flg : int = cha->Vflg
	ord : int = cha->Vord
	key : int = 0
	if flg & kbVIR_	
	   if flg & kbENH_
	   && (ord eq 17) || (ord eq 18)
	   .. reply kbCdon<<8
	   if (ord ge vkLTA) && (ord le vkLTZ)
	   .. reply kbC
	   tab = kbAped		; replacement keys
	   while *tab ne	; got another
	      if ord eq *tab++	; got it
	      .. reply *tab<<8	; thats it
	      ++tab		; skip replacement
	   end			;
	   reply 0
	elif flg & kbASC_
	   if flg & kbALT_
	   && ct_alp (ord)
	      key = (ch_low (ord) - 'a' + kbCatA) << 8
	   .. reply key
	end
	reply 0
  end
end file

	kbCatQ			;	16	Alt Q
	kbCatW			;	17	Alt W
	kbCatE			;	18	Alt E
	kbCatR			;	19	Alt R
	kbCatT			;	20	Alt T
	kbCatY			;	21	Alt Y
	kbCatU			;	22	Alt U
	kbCatI			;	23	Alt I
	kbCatO			;	24	Alt O
	kbCatP			;	25	Alt P
	0			;	26	
	0			;	27	
0 ;	kbCken	; e0/0d 224/13	;	28	kp enter
	0			;	29	
	kbCatA			;	30	Alt A
	kbCatS			;	31	Alt S
	kbCatD			;	32	Alt D
	kbCatF			;	33	Alt F
	kbCatG			;	34	Alt G
	kbCatH			;	35	Alt H
	kbCatJ			;	36	Alt J
	kbCatK			;	37	Alt K
	kbCatL			;	38	Alt L
	0			;	39	
	0			;	40	
	0			;	41	
	0			;	42	
	0			;	43	
	kbCatZ			;	44	Alt Z
	kbCatX			;	45	Alt X
	kbCatC			;	46	Alt C
	kbCatV			;	47	Alt V
	kbCatB			;	48	Alt B
	kbCatN			;	49	Alt N
	kbCatM			;	50	Alt M
	0			;	51	
	0			;	52	
0 ;	kbCpf1	; e0/2f	224/47	; /	53	kp /
	0			;	54	
0 ;	kbCpf2	; 37/2a	55/42	; *	55	
	0			;	56	
	0			;	57	
	0			;	58	
	kbCf15 ; kbCf1	help	;	59	F1
;	kbCf16 ; kbCf2	do	;	60	F2
	kbCf2			;	60	F2
	kbCf3			;	61	F3
	kbCf4			;	62	F4
	kbCf5			;	63	F5
	kbCf6			;	64	F6
	kbCf7			;	65	F7
	kbCf8			;	66	F8
	kbCf9			;	67	F9
	kbCf10	; pf1		;	68	F10
0 ;	kbCknl			;	69	num lock - supressed
	0			;	70
	kbCkp7			;	71	Home
	kbCkp8			;	72	Up arrow
	kbCkp9			;	73	PgUp
0 ;	kbCkmn	; 4a/2d 74/45	;	74	kp -
	kbCkp4			;	75	Left arrow
	kbCkp5			;	76	
	kbCkp6			;	77	Right arrow
0 ;	kbCkpl	; 4e/2b	78/43	;	78	
	kbCkp1			;	79	End
	kbCkp2			;	80	Down arrow
	kbCkp3			;	81	PgDn
	kbCkp0			;	82	Insert/Overstrike
	kbCkdt			;	83	Del
	0			;	84	Shift F1
	0			;	85	Shift F2
	0			;	86	Shift F3
	0			;	87	Shift F4
	0			;	88	Shift F5
	0			;	89	Shift F6
	0			;	90	Shift F7
	0			;	91	Shift F8
	0			;	92	Shift F9
	0			;	93	Shift F10
	0			;	94	Ctrl F1
	0			;	95	Ctrl F2
	0			;	96	Ctrl F3
	0			;	97	Ctrl F4
	0			;	98	Ctrl F5
	0			;	99	Ctrl F6
	0			;	100	Ctrl F7
	0			;	101	Ctrl F8
	0			;	102	Ctrl F9
	0			;	103	Ctrl F10
	0			;	104	Alt F1
	0			;	105	Alt F2
	0			;	106	Alt F3
	0			;	107	Alt F4
	0			;	108	Alt F5
	0			;	109	Alt F6
	0			;	110	Alt F7
	0			;	111	Alt F8
	0			;	112	Alt F9
	0			;	113	Alt F10
	0			;	114	Ctrl PrtSc
	0			;	115	Ctrl Left arrow
	0			;	116	Ctrl Right arrow
	0			;	117	Ctrl End
	0			;	118	Ctrl PgDn
	0			;	119	Ctrl Home
	0			;	120	Alt 1
	0			;	121	Alt 2
	0			;	122	Alt 3
	0			;	123	Alt 4
	0			;	124	Alt 5
	0			;	125	Alt 6
	0			;	126	Alt 7
	0			;	127	Alt 8
	0			;	128	Alt 9
	0			;	129	Alt 0
	0			;	130	Alt Hyphen (keypad)
	0			;	131	Alt =
	0			;	132	Ctrl PgUp
	kbCf11			;	133	F11
	kbCf12			;	134	F12
	0			;	135	Shift F11
	0			;	136	Shift F12
	0			;	137	Ctrl F11
	0			;	138	Ctrl F12
	0			;	139	Alt F11
	0			;	140	Alt F12
  end
