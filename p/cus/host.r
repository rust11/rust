file	host - issue host command
include rid:rider
include rid:cldef
include rid:mxdef

;	%build
;	rider cus:host/object:cub:host
;	link cub:host/exe:cub:/map:cub:,lib:crt/cross/bott=2000 
;	%end

  func	start
  is	cmd : [mxLIN] char
	sts : int
	im_ini ("HOST")
      repeat
	cl_cmd ("HOST> ", cmd)	; get command
	next if !cmd[0]		; no command
	exit if cl_mat (cmd, "EX*IT")
	st_ins ("c:\\rust\\she ", cmd)
	vr_hst (cmd)	; get command
      forever
  end

