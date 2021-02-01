header	iminf - image information
include	rid:rider
include	rid:imdef
include	rid:mxdef

  type	imTinf
  is	Psuc : * imTinf
	Pinf : * char
	Linf : size
	Ares : [mxLIN] char
	Aidt : [mxLIN] char
	Adsc : [mxLIN] char
	Aspc : [mxLIN] char
	Aver : [mxLIN] char
	Aprd : [mxLIN] char
	Aprv : [mxLIN] char
	Acmp : [mxLIN] char
  end

	imFNF := 0
	imFMT := 1
	im_opn : (*imTinf, *char, *int) int
	im_dsc : (*imTinf, *char, *int) int
	im_que : (*imTinf, *char, *char) int
	im_clo : (*imTinf)

end header
