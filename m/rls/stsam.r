file	stsam - strings same test
include	rid:rider
include	rid:stdef

code	st_sam - string equality test

  func	st_sam 
	mod : * char~			; model string
	tar : * char~			; target string
	()  : int			; fine => strings same
  is	while *mod++ eq *tar		; are same
	   fine if *tar++ eq		; perfect match
	end				;
	fail				;
  end
