header	exdef - expressions
include	rid:rider

	exLstk  := 64		; stack length
	exBEG	:= 100		; beginning priority

;	Node categories

   enum	exEcat : {exNIX, exUOP, exBOP, exVAL, exNAM, exNOD, exTOK}

  type	exTatr
  is	Vcat : byte		; attribute category
	Vflg : byte		; attribute flags
	Vkwd : word		; attribute id
	Psuc : * exTatr		; next attribute
	Pptr : * void		; attribute pointer
	Vval : int		; attribute value
  end

  type	exTtok
  is	Vcat : BYTE		; exTOK
	Vact : BYTE		; priorty, polarity, arity, assoc.
	Vkwd : WORD		; keyword id
	Pstr : * char		; token string
  end

  type	exTopr			; token: operator/operand
  is	Vcat : BYTE 		; category
	Vflg : BYTE		; unused
	Vkwd : WORD		; keyword id
	Patr : * exTatr		; attribute list
	Vval : int		; operand constant value
	Pstr : * char		; operator string
  end

  type	exTnod			; expression tree node
  is	Vcat : BYTE 		; category
	Vflg : BYTE		; node flags 
	Vxxx : WORD 		; unused
	Plft : *exTnod		; left node
	Prgt : *exTnod		; right node
	Popr : *exTopr		; operator
  end
	exPAR_ := BIT(0)	; parenthesized

  type	exTelm			; stack element
  is	Popr : * void		; operator
	Vpri : int		; priority/association
	Pobj : * void		; object
  end

  type	exTctx : forward
  type	exFopr : (*exTctx, *int, **exTopr) int
  type	exFred : (*exTctx, *exTnod) int

  type	exTctx
  is	Aipt : [mxLIN+2] char	; expression string
	Astk : [exLstk] exTelm	; expression stack
	Pcha : * char		; string pointer
	Pstk : * exTelm		; stack pointer
	Ptre : * exTnod		; node pointer (tree root)
; general call back		;
	Popr : * exFopr		; operator/operand callback
	Pred : * exFred		; reduction callback
;	Perr : * exFfun		; error callback
  end

	ex_exp : (*exTctx, int) *exTnod
	ex_opr : (*exTctx, *int, **exTopr) int
	ex_pri : (*exTctx, *exTopr) int
	ex_nod : (int) *exTnod

	ex_tok : (*exTctx, *exTopr, int, *int) int
	ex_wlk : (*exTctx, *exTnod, int) *exTnod
	ex_tre : (*exTctx, *exTnod, int) int
	ex_evl : (*exTctx, *exTnod) int
	ex_val : (*exTopr, **char) void
	ex_str : (*exTopr, **char) void
	ex_get : (*exTctx) int
data	exTtok - tokens

	OPR(a,p) := (a|(p<<exPRI))
	KWD(o) := (((o)>>16)&0xff)
	ARI(o) := ((o)&exARI_)
	POL(o) := ((o)&exPOL_)
	PRI(o) := ((o)&exPRI_)
	PRA(o) := ((o)&exPRA_)

	exARI_ := BIT(0)	; arity
	exBOP_ := exARI_	; uop/bop
	exUOP_ := 0		;
	exPOL_ := BIT(1)	; scanner polarity
	exSUF_ := exPOL_	; prefix/suffix
	exPRE_ := 0		;
	exASS_ := BIT(2)	; association
	exRGT_ := exASS_	; right/left	
	exLFT_ := 0		;

	exPRI_ := 0370		; 32 priority levels
	exPRA_ := (exPRI_|exASS_); priority and association
	exPRI  := 3		; priority shift count

	exLPU := 0		; left  prefix unary    (unused)
	exLPB := 1		; left  prefix binary   (unused)
	exLSU := 2		; left  suffix unary    (unused)
	exLSB := 3		; left  suffix binary   most binary
	exRPU := 4		; right prefix unary    all
	exRPB := 5		; right prefix binary   (unused)
	exRSU := 6		; right suffix unary    ++ --
	exRSB := 7		; right suffix binary   ?= ; ,

end header
