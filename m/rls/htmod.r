file	htmod - hash tree
include rid:rider
include rid:htdef
include rid:imdef
include rid:medef
include rid:stdef

	htCsho := TRUE			; want analysis code

;	A hash-tree combines the best of the hash table and the binary tree.
;	For each insert or locate operation a hash value is computed from
;	the name string. During the tree walk, hash values are compared.
;	String compares are only required for identical hash values, which
;	are infrequent.
;
;	A double-hash technique is used to achieve a good random distribution
;	of hash values, even for sorted input.
;
;	The problem of hash table overflows is avoided.
;	The problem of heavily unbalanced trees is avoided without 
;	introducing the overhead required for balanced binary trees.

  type	htTopr
  is	Pnam : * char			; name
	Proo : ** htTnod		; initial root
	Pnod : * htTnod			; result node
	Vhsh : int			; hash value
  end

	htCroo := 128		  	; number of roots (flattens 6 levels)
	htCsli := 4		  	; root slice factor

	htPfor : ** htTnod = NULL	; forest
	htPnam : * char = NULL		; current name string

	htVdup : int = 0		; duplicate count
	htVcla : int = 0		; clash count
	htVins : int = 0		; insert count
	htVdep : int = 0		; depth
	htVini : int = 0		; inited

	ht_new	: (*htTopr) *htTnod own	; make new node
	ht_hsh	: (*htTopr, *char) void own ; hash names

	_htFOR	:= "F-(htmod)-No room for forest"
	_htSTR	:= "F-(htmod)-String area full [%s]"
	_htNAM	:= "F-(htmod)-Name table full [%s]"

code	ht_ini - initialize structures

  func	ht_ini 				; init name tree
	()  : int			; fine/fail
  is	fine if htVini ne		; already done
;sic]	htVdup = 0			; no duplicates
;	htVcla = 0			; no clashs
;	htVins = 0			; no inserts
;	htVdep = 0			; no depth
	me_apc (&<*void>htPfor, htCroo * #<*htTnod>) ; allocate pointer & clear
	im_rep (_htFOR, <>) if fail	; no space -- does not return
	htVini = 1			; done
	fine				;
  end
code	ht_nam - get name pointer

  func	ht_nam
	nod : * htTnod fast
	()  : * char
  is	reply (!nod) ? <> ?? nod->Pnam	;
  end

code	ht_sym - get symbol pointer

  func	ht_sym 
	nod : * htTnod fast
	()  : * void
  is	reply (!nod) ? <> ?? nod->Psym	;
  end

code	ht_set - set symbol pointer

  proc	ht_set
	nod : * htTnod fast
	sym : * void fast
  is	exit if nod eq <>		; no node
	nod->Psym = sym			; setup pointer
  end
code	ht_new - allocate new node

  func	ht_new 
	opr : * htTopr
	()  : * htTnod own		; returns new node
  is	nod : * htTnod fast		; new node
	++htVins			; count insert
	nod = me_alc (sizeof (htTnod))	; make a new one
	im_rep (_htNAM, htPnam) if null	; failed -- abort
	nod->Vhsh = opr->Vhsh		;
	nod->Plft = <>			;
	nod->Prgt = <>			;
	nod->Psym = <>			;

	nod->Pnam = st_dup (opr->Pnam)	; get the string
	im_rep (_htSTR, opr->Pnam) if null ; failed -- abort
	reply nod			;
  end
code	ht_hsh - hash name

  proc	ht_hsh
	opr : * htTopr			; operation things
	nam : * Char			; search string
  is	roo : Int = 0			; root number
	tmp : Int = 0			; intermediate value
					;
	ht_ini () if htVini eq		; not setup yet
	opr->Pnam = nam			; save name pointer
	opr->Vhsh = 0			; no hash yet
	opr->Pnod = <>			; no result

;	1-char root hash, 2-char search hash

	while *nam			; for each character
	   roo = (roo << 1) ^ *nam	; roo = (roo*2) xor cha
	   tmp = *nam++ & 0377		; get low part of word hash
					;
	   if *nam			; got another character
	      roo = (roo << 1) ^ *nam	; rotate & xor root hash 
	      tmp |= *nam++ << 7	; or in high byte
	   else				; no more characters
	      tmp | (*opr->Pnam << 7)	; use first character instead
	   .. tmp = -that		; and negate it
	   opr->Vhsh ^= (opr->Vhsh+tmp)	; hsh = (hsh+wrd) xor hsh
	end

;	Setup root pointer

	roo >> htCsli	  		; select root slice
	that & (htCroo - 1)		; mask by number of roots
	opr->Proo = htPfor + that	; setup root pointer
  end
code	ht_ins - insert name in tree

;	Static variables are used since this routine is recursive

  	ht_sea : (*htTopr, *htTnod) * htTnod own	; forward
;	htPnod : * htTnod own = NULL	; located node
;	htProo : ** htTnod own = NULL	; current root
;	htVhsh : int own = 0		; current hash value

  func	ht_ins
	nam : * char fast		; name to insert
	()  : * htTnod			; node or abort
  is	opr : htTopr			;
	ht_hsh (&opr, nam)		; setup the name
	*opr.Proo = ht_sea (&opr, *opr.Proo) ; search for it
	reply opr.Pnod			; and send result back
  end

code	ht_sea - search tree

;	Static variables are used since this routine is recursive

  func	ht_sea
	opr : * htTopr fast		;
	nod : * htTnod fast		; node
	()  : * htTnod			;
  is	dir : int fast			; direction

	if nod eq <>			; aint no more
	   opr->Pnod = ht_new (opr)	; make a new node
	.. reply that			; and send it back
					;
	dir = opr->Vhsh - nod->Vhsh	; compute path
	if eq 				; hash value match
	   st_cmp (opr->Pnam, nod->Pnam); check exact
	   if eq 			; was exact
	      ++htVdup			; got duplicate
	      opr->Pnod = nod		; setup result
	   .. reply that		; found it
	.. ++htVcla			; got clash - go right
					;	
	if dir gt 			; 
	   nod->Plft = ht_sea (opr, nod->Plft); left 
	else				;
	.. nod->Prgt = ht_sea (opr, nod->Prgt); right
	reply nod			;
  end
code	ht_fnd - find name in tree

;	The find routine is relatively fast.
;	All it need do is hash the name and walk down the tree. String
;	compares occur only when hash codes match -- usually only one.

  func	ht_fnd
	nam : * char
	()  : * htTnod
  is	nod : * htTnod fast			; node
	dir : int fast				; direction
	opr : htTopr				;
	ht_hsh (&opr, nam)			; setup the name
	nod = *opr.Proo				; get first node
						;
	repeat					; big loop
	  reply <> if nod eq <>			; no more
	  ++htVdep				; count depth
						;
	  dir = opr.Vhsh - nod->Vhsh		; get direction
	  if eq 				; same hash
	     st_cmp (opr.Pnam,nod->Pnam)	; check string
	  .. reply nod if eq			; same string
						;
	  nod = nod->Plft   if dir gt		; check direction
	  nod = nod->Prgt   otherwise		;
	forever					;
  end
code	ht_wlk - walk thru tree

;	Walks through each node of each tree of forest.
;	No particular ordering is guaranteed.

	ht_stp : (*htTnod,*htTcbk) void own; traverse tree
  proc	ht_wlk				; depth first walk
  	fun : * htTcbk			; callback function
  is	roo : int fast = 0		; root index
	ht_ini ()			; force setup
	while roo lt htCroo		; got more
	.. ht_stp (htPfor [roo++], fun)	; do it
  end

code	ht_stp - next step in walk

  proc	ht_stp
	nod : * htTnod fast		; next node
	fun : * htTcbk			; function to call
  is	exit if nod eq <>		; are no more
	ht_stp (nod->Plft, fun)		; do left tree
	ht_stp (nod->Prgt, fun)		; do right tree
	(*fun)(nod)			; call the function
  end
