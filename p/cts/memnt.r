file	memnt - dynamic memory maintenance 
include	rid:rider

	m$ebas : * WORD+
	m$elim : * WORD+

  proc	me_mnt
  is	bas : * WORD = m$ebas
	cur : * WORD = bas
	lim : WORD = <WORD>m$elim
	c   : WORD
	n   : WORD
	l   : WORD
	f   : WORD
	PUT("m$ebas=%o->%o\n", &m$ebas, m$ebas)
	PUT("m$elim=%o->%o\n", &m$elim, m$elim)
     repeat
	c = <WORD>cur
	n = <WORD>*cur
	f = n & 1
	n &= ~(1)
	l = n - c

	PUT("%o->%o l=%o f=%o ", c, n, l, f)
;	PUT("%o->%o l=%o f=%o ", c, n, l, f)
;	PUT("%o->%o ", c, n)
;	PUT("len=%o free=%o ", l, f)
	quit PUT("Wrap\n") if n le c
	quit PUT("Over\n") if n gt lim
	exit PUT("End\n") if n eq lim
	PUT("\n")
	cur = <*char>n
     forever
	cc_exi (0)
  end
code	me_val - validate memory

  proc	me_val
  is	bas : * WORD = m$ebas
	cur : * WORD = bas
	lim : WORD = <WORD>m$elim
	c   : WORD
	n   : WORD
	l   : WORD
	f   : WORD
     repeat
	c = <WORD>cur
	n = <WORD>*cur
	f = n & 1
	n &= ~(1)
	l = n - c

	quit PUT("Wrap\n") if n le c
	quit PUT("Over\n") if n gt lim
	exit if n eq lim
	cur = <*char>n
     forever
	rt_bpt ()
	cc_exi (0)
  end
