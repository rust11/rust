header	hldef - help support

	hlWID	:= 72

  type	hlThlp
  is	Pspc : * char
	Ptxt : * char
	Pnxt : * char
	Pprv : * char
	Vlin : int
	Vcol : int 
	Vidt : int
	Alin : [mxLIN] char
  end

	hl_ini : (*hlThlp, *char, *char) *hlThlp
	hl_dlc : (*hlThlp) int
	hl_cmd : (*hlThlp, *char) int
	hl_hlp : (*hlThlp, *char) int
	hl_con : (*hlThlp) int
	hl_brf : (*hlThlp) 

end header
