header	bidef - variable size block i/o 

  type	biTfil
  is	Phan : * void
	Vlen : size		; bytes per block
  end

	bi_opn : (*char, size, *char) *biTfil
	bi_rea : (*biTfil, *void, size, size, *void) size
	bi_clo : (*biTfil)

end header
