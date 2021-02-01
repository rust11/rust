file	thdef - thread definitions

  type	thTthr : forward
  type	thTfun : (*thTthr) int

  type	thTthr
  is	Vidt : LONG
	Vhnd : LONG
	Vevt : LONG
	Pfun : *thTfun		; user thread main
	Ppar : *void		; user data
  end

	th_cre : (*thTfun, *void) *thTthr
	th_wai : (*thTthr) int
	th_sig : (*thTthr, int)
