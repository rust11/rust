file	meset - set memory
include	rid:rider
include	rid:medef
If Win
include rid:wimod
Else
include	<string.h>
End

  func	me_set
	dst : * void
	cnt : size
	val : int
 	()  : * void
  is
If Win
	FillMemory (dst, cnt, val)
Else
	memset (dst, val, cnt)
End
 	reply <*char>dst + cnt
  end
