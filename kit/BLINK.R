file	blink
include	rid:rider
include	rid:tidef

;	%build
;	rider sks:blink/object:skb:
;	link skb:blink/exe:skb:,lib:crt
;	set program/iopage skb:blink
;	%end

	SWR 	:= 0177570	; switch register address

  func	start
  is	swr : * word = SWR	; swr -> switch register 
	pat : int = 1		; the pattern
				;
	repeat			;
	   *swr = pat		; display the pattern
	   pat <<= 1		; rotate left
	   pat = 1 if !pat	; rotate carry
	   ti_wai (50L)		; wait n milliseconds (n : long)
	forever			;
  end
  