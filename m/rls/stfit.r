file	st_fit - fit string into buffer
include rid:rider
include rid:stdef

code	st_fit - fit string into buffer

;	st_fit (src, dst, #dst)

  func	st_fit 
	src : * char		; string address
	dst : * char		; buffer address
	cnt : size		; buffer length
	()  : * char		
  is 	fail if !cnt		; no space for anything
	reply st_cln (src, dst, cnt-1)
  end
