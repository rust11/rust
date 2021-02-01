file	tmmod - temp files
include	rid:rider
include	rid:fidef
include	rid:mxdef
include	rid:rndef
include	rid:tmdef

code	tm_nam - create temporary name

  func	tm_nam
	spc : * char~
  is	rnd : int~
	cnt : int = 1000
      while cnt--
	rnd = rn_rnd ()
	rnd = ~rnd if rnd gt
	FMT(spc, "%o", rnd)
	next if fi_exs (spc, <>)
	fine
      end
	fail
  end

code	tm_opn - open temporary file

  func	tm_opn 
	siz : size
	()  : * FILE
  is	spc : [mxSPC] char
	fail if !tm_nam (spc)
	fi_def (spc, "tmp:.tmp", spc)
	reply fi_opn (spc, "wb", "")
  end

code	tm_pur - purge temporary file

  func	tm_pur
	fil : * FILE
  is	spc : * char = fi_spc (fil)
	fi_clo (fil, "")
	fi_del (spc, "")
  end
