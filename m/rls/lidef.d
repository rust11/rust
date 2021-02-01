header	lidef - line operations
	
;	High-level text line handling facility.
;
;	Psuc/Ppre/Proo are all null for an unattached line.
;
;	The root may be recovered from any node.
;	Data is stored with a leading zero, permitting us to recover
;	the header of from a text pointer.
;
;	The root is just another linkage element.
;	It links to the first (Psuc) and last (Ppre) elements.
;	Appending to NULL automatically creates the root.
;	Deleting the last line also deletes the root (unless liMAN_ is set).

	liTroo := liTlin
  type	liTlin			; node:		root:		null:
  is	Psuc : * liTlin		; successor	first		first
	Ppre : * liTlin		; predecessor	last		last
	Proo : * liTroo		; root		null		root
	Vcnt : int		; line number	line count	first line
	Vflg : int		; line flags	liROO_ etc
;	Patr : * void		; attributes	user defined area
	Adat : [4] char		; extensible data area
  end

	liROO_ := BIT(0)	; this is the root
	liMOD_ := BIT(1)	; line has been modified
	liMAN_	:= BIT(2)	; manual -- do not autodelete root
	liNUM_ := BIT(15)	; root: line numbering update pending
				; node: line not yet numbered

	li_ini : (void) *liTroo				; init
	li_exi : (*liTroo) int				; exit
	li_cre : (void) *liTroo				; create a root
;	li_dlc : (*liTlin) void				; deallocate line

	li_rea : (*char, *char) *liTroo			; read a file
	li_wri : (*liTroo, *char, *char) int		; write a file
							
	li_roo : (*liTlin) *liTroo			; get root pointer
	li_suc : (*liTlin) *liTlin			; get successor
							; root:  first
							; last:  null
	li_prd : (*liTlin) *liTlin			; get predecessor
							; root:  last
							; first: null
	li_fst : (*liTlin) *liTlin			; first
	li_lst : (*liTlin) *liTlin			; last
	li_nth : (*liTlin, int) *liTlin			; nth line
	li_cnt : (*liTlin) int				; line count

	li_dat : (*liTlin) *char			; get data pointer
	li_num : (*liTlin) int				; get line number
	li_flg : (*liTlin) int				; get line flags
	li_set : (*liTlin, int) void			; set line flags
	li_tou : (*liTlin) void				; set modified flag

	li_imp : (*char) *liTlin			; import *char->*liTlin
	li_exp : (*liTlin) *char			; export *liTlin->*char
;	li_hdr : (*char) *liTlin			; recovers line header

;	li_inc : (*liTlin, *liTlin) int			; right includes left
;	li_cmp : (*liTlin, *liTlin) int			; compare lines
							;
;	li_pre : (*liTlin, *char) 			; prepend
	li_ins : (*liTlin, *liTlin, *char) *liTlin	; insert (before)
	li_app : (*liTlin, *char) *liTlin		; append
	li_del : (*liTlin) *liTlin			; delete line or tree
							;
;	li_dup : (*liTlin) *liTlin			; duplicate line or tree
;	li_rep : (*liTlin, *liTlin) int			; replace line

;	li_opn : (*liTlin) *liTstm			; null for new list
;	li_get : (*liTstm) char				; get next from stream
;	li_put : (*liTstm, char)			; put next to stream
;	li_clo : (*liTstm) *liTroo			; 
end header
