file	txdef - text compare
include rid:rider
include rid:txdef

code	tx_cmp - compare text

  func	tx_cmp
	mod : * char
	tar : * char
	lim : int			; compare limit
  is	repeat				;
	   reply 0 if lim-- eq		; all done
	   quit if *mod ne *tar		; different strokes
	   reply 0 if *tar eq		; end of string
	   ++mod, ++tar			; next
	end				;
	reply (*mod gt *tar) ? 1 ?? -1	; difference
  end
