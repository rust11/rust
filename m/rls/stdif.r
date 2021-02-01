file	stdif - differ -- compare limited strings
include rid:rider
include rid:stdef

code	st_dif - differ -- compare limited strings

  func	st_dif
	mod : * char
	tar : * char
	lim : size			; compare limit
  is	repeat				;
	   reply 0 if lim-- eq		; all done
	   quit if *mod ne *tar		; different strokes
	   reply 0 if *tar eq		; end of string
	   ++mod, ++tar			; next
	end				;
	reply (*mod gt *tar) ? 1 ?? -1	; difference
  end
