file	rxmod - rad50 routines
include rid:rider
include rid:rxdef

;	This module is based on cts:rxdef.d
;	The older RT_UNP etc will be phased out

code	rx_pck - pack rad50 words

  func	rx_pck
	str : * char
	res : * elTwrd
	all : int
	()  : * char
  is	cnt : int = 3
	cha : int
	wrd : elTwrd = 0
	dig : int
     while cnt--
	cha = *str
	dig = 0
	if cha eq '$'
	   dig = 27, ++str if all
	elif cha eq '%'
	   dig = 28, ++str if all
	elif cha eq '*'
	   dig = 29, ++str if all
	elif cha eq '_'
	   dig = 0, ++str if all
	elif ct_dig (cha)
	   dig = cha - 022, ++str
	elif ct_alp (cha)
	.. dig = ch_upr (cha) - 0100, ++str
	wrd = wrd * 40 + dig
     end
	*res = wrd
	reply str
  end

code	rx_unp - unpack rad50

  init	rxAunp : [41] char
  is	" ABCDEFGHIJKLMNOPQRSTUVWXYZ$%*0123456789"
  end

  func	rx_unp
	wrd : WORD		; pointer to rad50 input
	asc : * char		; pointer to ascii output
	()  : * char
  is	div : int = 40*40
	rem : int
	while div && wrd
	   rem = wrd / div
	   wrd -= rem * div
	   *asc++ = rxAunp[rem]
	   div /= 40
	end
	*asc++ = 0
	reply asc
  end
code	rx_par - parse'n'pack filespec

  func	rx_par
	spc : * char
	nam : * elTwrd
	mod : int
	cnt : int
	()  : * char
  is	wrd : elTwrd
	nth : int
	me_clr (nam, cnt*2)
					;
	spc = rt_pck (spc, &wrd, mod)	;
	if cnt eq 4			; want full spec
	   if *spc eq ':'		; device
	      *nam++ = wrd, ++spc	;
	      spc = rt_pck (spc, &wrd, mod);
	   else
	.. .. *nam++ = 0		;
	*nam++ = wrd			;
	if ne				; got a filename
	   spc = rt_pck (spc,nam++,mod)	; fill in the filename
	   if *spc eq '.'		; got a filetype
	   && spc[1]			;
	   .. spc = rt_pck (++spc, nam,mod); fill in the filename
	else				;
	.. *nam++ = *nam++ = 0		;

	reply spc
  end
end file

