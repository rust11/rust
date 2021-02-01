header	isdef - I/O stream management

  type	isTstm
  is	Vbot : int
	Vcur : int
	Vtop : int
	Vinc : int
	Vadd : int
	Pobj : ** void
  end

	is_alc : (int, int) * isTstm	; allocate i/o stream
	is_ini : (*isTstm) 		; init
	is_dlc : (*isTstm)		; deallocate
	is_add : (*isTstm, *void)	; add a file
	is_inc : (*isTstm, *void)	; include a file
	is_cur : (*isTstm) *void	; get current file
	is_stp : (*isTstm) 		; step to next file

end header
