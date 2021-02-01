header	qudef - queue operations

  type	quTque
  is	Aque : [2] * quTque	; successor/predecessor
	Vpos : int		; queue position
  end

	quSUC := 0
	quPRE := 1

	PRE(que) := (que->Aque[quPRE])
	SUC(que) := (que->Aque[quSUC])

	qu_slf : (*quTque)
	qu_nul : (*quTque) : int
	qu_ins : (*quTque, *quTque)
	qu_rem : (*quTque) : *quTque

	qu_emp : (*quTque) : int
	qu_psh : (*quTque, *quTque)
	qu_app : (*quTque, *quTque)
	qu_pop : (*quTque) : *quTque
	qu_pos : (*quTque, *quTque)

end header
