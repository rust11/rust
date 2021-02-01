;???;	DFENG - in progress
file	dfeng - definition engine
include	rid:rider
include	rid:imdef
include	rid:stdef
include	rid:medef
include	rid:mxdef
include	rid:iodef
include	rid:osdef
include	rid:dfdef
include	rid:chdef
include	rid:cldef
include	rid:ctdef
include	rid:fidef
include	rid:codef

	shVexp	: int = 0		; expansion in progress
	shPexp	: * char = <>		; expansion buffer

code	

code	df_eng - the middleware engine

  func	df_eng
	cmd : * char			; the command
	rem : * char			; its remainder
	()  : int			; found/not found
  is	buf : [mxLIN*2] char		; expansion buffer
	exp : * char = shPexp		; shell expansions
	ctx : * dfTctx = ut_def ()	; synch with definitions
	def : * dfTdef			;
	rep : * char			;
					;
	def = df_loo (ctx, cmd)		; look it up
	fail if null			;
	df_exp (ctx, def, rem, buf, mxLIN, '^', 0)
	if gt				; success
	   st_len(buf) + st_len(exp)	; get total length  
	   if that gt shEXP-4		; too many expansions
	      sh_abt ()			; abort things
	      ut_rep (E_TooManExp, cmd)	;
	   .. fine			;
	   st_ins ("\n",exp) if shVexp	; insert a separator
	   *exp=0, ++shVexp  otherwise	; first expansion
	   st_ins (buf, exp)		; insert this one
	.. shVexp = 1			; remember it
	ut_rep ("L-Definition [%s]",cmd); debug it
	fine				; we did it
  end

