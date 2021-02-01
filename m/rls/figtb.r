file	figtb - get next byte
include rid:rider
include	rid:fidef

code	fi_gtb - Returns next byte from a file

  func	fi_gtb
	fil : * FILE
  is	cha : int
	fi_rea (fil, &cha, 1)
	reply cha
  end

code	fi_ptb - Put next byte to file

  func	fi_ptb
	fil : * FILE
	cha : int
  is	fi_wri (fil, &cha, 1)
	reply cha
  end

