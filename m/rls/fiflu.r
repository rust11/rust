file	fiflu - flush file
include	<stdio.h>
include rid:rider
include	rid:fidef

  func	fi_flu
	fil : * FILE
  is	fflush (fil)
	reply (that ne EOF)
  end

