file	clmor - ask for more
include rid:rider
include rid:cldef
include rid:mxdef
include rid:stdef

  func	cl_mor
	cnt : * int~
  is	cmd : [mxLIN] char~
	if cnt
	   fine if *cnt eq -1
	   fine if ++(*cnt) lt 24
	.. *cnt = 0
	cl_cmd ("More? ", cmd)
	case *cmd
	of 'N'
	or 'n'
	   fail
	of 'A'
	or 'a'
	   *cnt = -1
	end case
	fine
  end
