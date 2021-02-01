file	ht_anl - analyse tree
include rid:rider
include rid:htdef

;	summary	- totals
;	trees - tree totals
;	nodes - everything

data	ht_anl - per root data

	htCroo := 128		  	; number of roots
	htCsli := 4		  	; root slice factor
	htPfor : ** htTnod extern	; forest
	htPnam : * char	 extern		; current name string
	htVdup : int extern		; duplicate count
	htVcla : int extern		; clash count
	htVins : int extern		; insert count
	htVdep : int extern		; depth
	htVini : int extern		; inited

	htVnds : int = 0		; node count
	htVlfs : int = 0		; left paths
	htVrgs : int = 0		; right paths
	htVdps : int = 0		; depth count
	htVnls : int = 0		; null leave count
	ht_prt	: (*htTnod) int own	; print/walk node

code	ht_anl - analyse tree

  proc	ht_anl
  is	roo : Int = 0			; current root
	nds : Int = 0			; total nodes
	lfs : int = 0			; total left
	rgs : int = 0			; total right
	nls : int = 0			; total null
	dps : Int = 0			; total depth
	ht_ini ()			; force setup
	roo = -1			; first root
	while ++roo lt htCroo		; got more
	   htVlfs = 0			; zap per-root
	   htVrgs = 0			;
	   htVnds = 0			;
	   htVdps = 0			;
	   htVnls = 0			;
	   ht_prt (htPfor[roo])		; do that lot
	   next if htVnds eq		; nothing here
	   nds += htVnds		; accumulate totals
	   lfs += htVlfs		;
	   rgs += htVrgs		;
	   nls += htVnls		;
	   dps += htVdps		;
	   PUT("Root %3d: ",  roo)	;
	   PUT("%2d nodes, ", htVnds)
	   PUT("%2d right, ", htVrgs)
	   PUT("%2d left, ",  htVlfs)
	   PUT("%2d null, ",  htVnls)
	   PUT("Average depth %d\n",
	     htVdps/(htVnds ? htVnds ?? 1))
	end

	PUT("Totals:\n")
	PUT("%d inserted, ",   htVins)
	PUT("%d found, ",	   nds)
	PUT("%d duplicate, ",  htVdup)
	PUT("%d clashed\n",    htVcla)

	PUT("%d left, ",	   lfs)
	PUT("%d right, ",	   rgs)
	PUT("%d null, ",       nls)
	PUT("Average depth %d\n", dps/(nds ? nds ?? 1))
  end

code	ht_prt - print & walk node

  func	ht_prt
	nod : * htTnod fast		; node
	()  : int			;
  is	fnd : * htTnod fast		; node found
	if nod eq <>			; a leaf
	.. fail ++htVnls		; count it
	if ht_prt (nod->Plft)		; check left
	.. ++htVlfs			; count left
	if ht_prt (nod->Prgt)		; check right
	.. ++htVrgs			; count right
					;
	++htVnds			; got another node
	htVdep = 0			; no depth yet
	fnd = ht_fnd (nod->Pnam)	; search for the name
	if <>				; not found
	   PUT("Node [%s] not found\n", nod->Pnam)
	elif fnd ne nod			; found different
	.. PUT("Found [%s] instead of [%s]\n", fnd->Pnam, nod->Pnam)
	htVdps += htVdep		; total depths
	fine				;
  end
end file
file	ht_anl - analyse tree
include rid:rider
include rid:htdef

;	summary	- totals
;	trees - tree totals
;	nodes - everything

data	ht_anl - per root data

	htCroo := 128		  	; number of roots
	htCsli := 4		  	; root slice factor
	htVnds : int = 0	; node count
	htVlfs : int = 0	; left paths
	htVrgs : int = 0	; right paths
	htVdps : int = 0	; depth count
	htVnls : int = 0	; null leave count

	ht_prt	: (*htTnod) int own	

code	ht_anl - analyse tree

  proc	ht_anl
  is	roo : Int = 0			; current root
	nds : Int = 0			; total nodes
	lfs : int = 0			; total left
	rgs : int = 0			; total right
	nls : int = 0			; total null
	dps : Int = 0			; total depth
	roo = 0				; first root
	while roo lt htCroo		; got more
	   htVlfs = 0			; zap per-root
	   htVrgs = 0			;
	   htVnds = 0			;
	   htVdps = 0
	   htVnls = 0			;
	   ht_prt (htAroo[roo])		; do that lot
	   nds += htVnds		; accumulate totals
	   lfs += htVlfs		;
	   rgs += htVrgs		;
	   nls += htVnls		;
	   dps += htVdps		;
	   printf ("Root %d: ",  roo)	;
	   printf ("%d nodes, ", htVnds)
	   printf ("%d right, ", htVrgs)
	   printf ("%d left, ",  htVlfs)
	   printf ("%d null, ",  htVnls)
	   printf ("average depth %d\n", htVdps/htVnds)
	end

	printf ("Totals:\n")
	printf ("%d inserted ",    htVins)
	printf ("%d found",	   nds)
	printf ("%d duplicate, ",  htVdup)
	printf ("%d clashed\n",    htVcla)

	printf ("%d left, ",	   lfs)
	printf ("%d right, "	   rgs)
	printf ("%d null, "        nls)
	printf ("average depth %d\n", dps/nds)
  end

  func	ht_prt
	nod : * htTnod fast		; node
	()  : int			; fine/fail
  is	fnd : * htTnod fast		; node found

	if nod eq NULL			; a leaf
	   ++htVnls			; count it
	.. fail				; forget it

	if ht_prt (nod->Plft)		; check left
	.. ++htVlfs			; count left

	if ht_prt (nod->Prgt)		; check right
	.. ++htVrgs			; count right

	++htVnds			; got another node
	htVdep = 0			; no depth yet
	fnd = ht_fnd (nod->Pnam)	; search for the name
	if fnd eq NULL			; not found
	   printf ("Node %s not found\n", nod->Pnam)
	elif fnd ne nod			; found different
	.. printf ("Found %s instead of %s\n", fnd->Pnam, nod->Pnam)
	htVdps += htVdep		; total depths
	fine				;
  end
end file
