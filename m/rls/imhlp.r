file	imhlp - display help
include	rid:rider
include	rid:imdef

code	im_hlp - display one or two column help

  func	im_hlp
	hlp : ** char~			; help array
	col : int			;
  is	lft : ** char~ 			; 
	rgt : ** char~			;
	len : int = 0
					;
	if col le 1			;
	   PUT("%s\n",*hlp++ ) while *hlp
	.. exit				; is trivial

	lft = hlp 			;
	++len while *hlp++ 		; count them
	rgt = lft + (len /= 2)		; half each
	while len--			; got more
	   PUT("%-38s", *lft++)	; the left part
	   PUT("%-38s", *rgt++) if *rgt;
	   PUT("\n")
	end
  end
