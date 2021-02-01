header	tkdef - token definitions
include	rid:mxdef

  enum	tkEtyp
  is	tkEND				; guaranteed zero
	tkIDT				; identifier
	tkNUM				; number
	tkPUN				; punctuation
	tkSTR				; some string
  end

  type	tkTctx
  is	Vflg : int			; control flags
	Plin : * char			; source line
	Pfst : * char			; first of token for backup
	Plst : * char			; last of token
	Pnxt : * char			; first of next token or eol
	Vsta : int			; parser state
;	Popr : ** char			; operator set (punctuation)
;	Pbal : * char			; balancing set (e.g. " ' ()
;	Vsep : int			; argument separator (space, comma)
	Vcmt : int			; comment character
	Palc : * () * void		; allocation routine
	Pdlc : * () void		; deallocation routine
	Prep : * () int			; error report routine
	Pmsg : * char			; most recent message
	Aobj : [mxLIN] char		; its object (a copy)
	Vtyp : int			; type of current token
	Atok : [mxLIN] char		; current token
	Alin : [mxLIN] char		; temporary line
  end

	tkINI_	:= BIT(0)		; is initialized
	tkERR_	:= BIT(1)		; some error detected
	tkMUT_	:= BIT(2)		; mute - report no errors
	tkCAS_	:= BIT(3)		; names are case sensitive
	tkSPC_	:= BIT(4)		; parse filespec
	tkUPR_	:= BIT(5)		; convert identifiers to uppercase

;	tk_ini	: (*dfTctx) int		; init token context
	tk_alc	: (int) *tkTctx		; allocate token context
	tk_dlc	: (*tkTctx) void	; deallocate token context
	tk_lin	: (*tkTctx, *char) void	; setup new line to parse
	tk_nxt	: (*tkTctx) int		; get next token
;	tk_typ	: (*tkTctx) int		; type of token
;	tk_tok	: (*tkTctx) * char	; name of token

	tk_typ (c) := ((c)->Vtyp)
	tk_tok (c) := ((c)->Atok)

	tk_loo	: (*tkTctx, []*char) int; match token with table
	tk_qua	: (*tkTctx, []*char) int; match qualifier with table
	tk_spc	: (*tkTctx, *char) int	; gather filespec

	tk_idt	: (int) int		; check identifier character
	tk_pun	: (int) int		; check punctuation character
	tk_skp	: (*tkTctx) int		; skip spaces

	tk_cli	: (*tkTctx, int, **char) *tkTctx
					; setup to process image command
					; MUST be image activation command

end header
