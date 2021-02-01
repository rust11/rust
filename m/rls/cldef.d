header	cldef - command language definitions
;nclude	sci:stdio
If !&Crt
include	<stdio.h>
End

;	cl_lin	cli
;	cl_cmd	cli		no prompt
;		cli @file tt:	with prompt
;	cl_prm	          tt:
;	co_prm		  tt:	terminal editor on Windows
;
;	cl_sin() : 1 => single line command

  type	clTdis
  is	Pkwd : * char		; keyword name
	Pfun : * (*void) void	; function
  end

  type	clTkwd
  is	Pmod : * char		; model string with wildcards
	Vflg : int		; unused at present
	Vusr : int		; caller value
	Pusr : * void		; caller pointer
  end
	clNEG_ := BIT(0)

	cl_dis	: (*void, *char, *clTdis, *char) int	; dispatch command
	cl_loo	: (*char, []*char, *int) int		; lookup keyword
	cl_kwd  : (*clTkwd, *char) int			; match keyword
	cl_mat	: (*char, *char) int			; match keyword
	cl_cmd	: (*char, *char) int			; prompt for command
	cl_prm	: (*FILE, *char, *char, int) int	; prompt for command
	cl_lin	: (*char) int				; get command line

	cl_ass	: (*char, int, **char) int		; assemble vector
	cl_mrg	: (*char, int, **char) int		; merge vector
	cl_vec	: (*char, *int, ***char) int		; vectorise line
	cl_nth (n,s,d) := cl_arg (n,s,d,0,<>)		; default form
	cl_arg	: (int, *char, *char, int, *char) int	; get nth argument
;	cl_qua  : (*char, *char, *char)			; get text of...
;	cl_par	: (int, *char, *char)			; get nth parameter

	cl_red 	: (*char) int			; reduce command line
	cl_scn	: (*char, *char) int		; scan/reduce leading string

	cl_mor	: (*int) int				; ask for more
	cl_foc  : (*void) *void				; get focus back


If Wnt							; clwin
	cl_tty	: (*FILE) *FILE				; check tty handle
	cl_dir	: (*char) int				; get command directory
End

end header
