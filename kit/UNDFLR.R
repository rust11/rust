file	undflr
include	rid:rider

;	%build
;	rider wus:undflr/obj:tmp:
;	link tmp:undflr/exe:tmp:/map:tmp:,lib:crx/bot:2000
;	%end

	b(x) := (byt[x]&0xff)

  func	start
  is	val : double = 1.0
	byt : * BYTE = <*void>&val
	stp : int = 0

	PUT("#double=%d, #int=%d\n", #double, #long)

	while stp lt 10
	   PUT("value = 1/(2**%d)", stp)
	   PUT(" = %-12g ", val)
If Win
	   PUT("hex=%02x%02x %02x%02x %02x%02x %02x%02x\n",
	      b(7),b(6),b(5),b(4),
	      b(3),b(2),b(1),b(0))
Else
	   PUT("hex=%02x%02x %02x%02x %02x%02x %02x%02x\n",
	      b(1),b(0),b(3),b(2),
	      b(5),b(4),b(7),b(6))
End
	   val /= 2, ++stp
	end
  end
