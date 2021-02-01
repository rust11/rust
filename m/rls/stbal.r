;***;	STBAL - worms its way through "", '' etc
file	stbal - balance substring
include rid:rider
include rid:stdef
include rid:chdef

code	st_bal - balance substring

;	(...)	balances (), handles nests (())
;	"..."	balances quoted strings
;	'...'	balances quoted literals
;	\x	skips escape sequences (single characters)

  func	st_bal
	str : * char~ 			; start of segment
	()  : * char			; past segment, or at end
  is	ter : char~ = *str++		; get balance char
	if ter eq _paren		; have (
	.. ter = paren_			; that ends it
					;
	while *str			; got more
	   if *str eq ter		; got terminator
	   .. reply ++str		; skip and return
					;
	   if ter eq paren_		; want parens
	      if *str eq _quotes	; "		
	      || *str eq _apost		; '
	      || *str eq _paren		; (
	         str = st_bal (str)	; balance that
	      .. next			; try again
	   else 			; ' or "
	      if *str eq _back		; got \ escape
	      && not *++str 		; skip, test end of line
	   .. .. quit			; forget it
	   ++str			; skip character
	end				;
	reply str			; send it back
  end 
