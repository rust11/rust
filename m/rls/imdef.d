header	imdef - image definitions

  type	imTcbk : (void) void		; callback

	imPwar : * imTcbk+		; to user warning co-routine
	imPerr : * imTcbk+		; error	
	imPfat : * imTcbk+		; fatal
					;
	imPfac : * char+		; message facility

	im_ini : (*char) int+		; init image
	im_exi : (void) int+		; exit image
	im_war : (void) int+		; report warning
	im_err : (void) int+		; report error
	im_fat : (void) int+		; report fatal error
					;
  type	imTrep : (*char, *char) int
	im_rep : imTrep+		; report message

	im_hlp : (**char, int) int+	; display help
	imTWO_ := BIT(0)		; two column help
					;
If Win
	imPrep : * imTrep+		; report callback
	imPexi : * imTcbk+		; exit callback
	im_exe : (*char, *char, int)+	; execute program

Else ; Pdp

	im_clr : (void) void		; clear status
	im_suc : (void) void		; success status

  type	imTctx
  is	Pstk : * void			; sp
	Pcod : * void			; pc
  end

	im_sav : (*imTctx) int		; save context
	im_res : (*imTctx) void		; restore context
End

;	im_con : imTrep			; report message to console
;	im_sev : (*char) int+		; set severity
;	im_dec : (int, *char) *char	; convert decimal
;	im_hex : (int, *char) *char	; convert hexadecimal
;	im_arg : (int,*char,int,int,**char) int ; get image argument
;	im_prc : (*char, *char) *void	; image procedure address

end header
