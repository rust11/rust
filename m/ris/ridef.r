file	ridef - type definition
include rid:rider
include rib:eddef
include rib:ridef
include	rid:imdef
include rid:chdef
include rid:stdef
include rid:medef

;	name : ...
;	name : type			forward definition
;	name : unit			
;
;	type name : { ... }		enumeration
;	type name : * char		typedef char* name;
;	type name : () char		typedef () char name;
;	type name : forward		#define name struct name_t
;	unit name : forward		#define name union name_t
;	type name\ is\ \end		#define name struct name_t
;					struct name_t { };
;	unit name\ is\ \end
;
;	(typedef) is often missunderstood by compiler writers and cannot
;	be nested. Anyway, the type name is not visible until the definition
;	completes, so it cannot be used for forward references.
;
;	Thus, replace type names thruout with '(struct typename)'
;	Handle forward definitions in same way
;	Must be disabled during initial definition and redefinition
;	Thus, handle these during line output
;
;	The affix (_t) is chosen to catch collisions between type names,
;	since they share the same namespace.

;	ri_def	: (*char, char) void
	ri_def	: (*char, int) void
	ri_enc	: (char, *char) int

code	kw_typ - type definition

  proc	kw_typ
  is	ri_def ("struct", 'S')
  end

code	kw_uni - union definition

  proc	kw_uni
  is	ri_def ("union", 'U')
  end
code	ri_def - definition common

  proc	ri_def 
	kwd : * char~			; the keyword
	typ : int			; type letter
  is	nam : [64] char			; type name
	str : [64] char			; structure name
	ptr : * char~			; a pointer
	fwd : int = 0			;

;	name : ...	

	if typ eq 'S'			; got (type ...)
	&& ed_fnd (" : {")		; got enumeration
	   ri_enm ()			; inline enumeration
	.. exit				;

	if ed_rep (" : forward", "")	; a forward definition
	   ++fwd			; remember that
	elif ed_fnd (" : ")		; simple type
	   ri_typ (edPdot, edPdot)	; do it
	   ed_pre ("typedef")		; prefix it
	   ed_app (";")			; end it
	   exit				; fine

;	name \is \end

	elif not riVis			; must have is
	   im_rep ("W-Invalid type [%s]", edPdot) ; say so
	.. exit

	ptr = st_skp (edPdot)		; need that
	st_cop (ptr, nam)		; get the type name
	st_app (" ", that)		;
	st_app (kwd, that)		;
;	st_app (" ", that)		;
	st_cop (ptr, str)		; need structure name too
	st_app ("_t ", that)		;

	ri_dis ("#define ")		; define it
	ri_dis (nam)			;
	ri_dis (" ")			;
	ri_prt (str)			;
	++riVsup			; already written
	exit if fwd			; was forward definition

	ri_dis (kwd)			; struct
	ri_dis (" ")			;
	ri_dis (ptr)			; name
	ri_prt ("_t")			; name_t
  
	repeat				;
	   ri_get ()			; get the next

	   if riPcur->Veof		; got end of file
	      im_rep ("EOF in type [%s]", nam)
	   .. exit			; forget it

	   quit if ed_del (" end")	; this ends it - put it out
	   if ed_del (" type")		; enclosed type
	      kw_typ ()			;
	      next			;
	   elif ed_del (" unit")	;
	      kw_uni ()			;
	   .. next			;

;	   if ed_del (" | ")		; got enclosed unnamed type/unit
;	      ri_enc ('|', ptr)		; do enclosed unit
;	      next			;
;	   elif ed_del (" & ")		;
;	      ri_enc ('&', ptr)		;
;	   .. next

	   if *edPdot			; got more coming
	      if not ed_fnd (" : ")	; no type
	         im_rep ("Invalid type spec [%s]", nam)
	         quit			;
	      else			;
	         ri_typ (edPdot, edPdot);
	   .. .. ed_app (";")		;
	   if riVend eq			;
	   .. ri_put ()			; dump it
	until riVend			; this ends it
					;
	ed_app (" };")			; end it
	riPcur->Vend = 0		; remove end count
	ri_put ()			; write it
	--riVnst			; nest down
	++riVsup			; already written
  end
code	ri_enc - enclosed type/unit

;	Enclosed types/units are anonomous (never self-referential)
;
;	  type	...
;	  is	V... : ...
;		U... | U1  : ...
;		     | U2  : ...
;		W... : ...
;	  end
;
;	... := struct ..._t
;	struct ..._t {
;	 ... V...;
;	 union {
;	  ... U1;
;	  ... U2;
;	  } U...
;	 ... W...
;
;	|	enclosed unit
;	&	enclosed type
;	..	terminates enclosure if ambiguous (unit in unit)

  func	ri_enc
	pre : char~			; & or |
	rem : * char~			;
  is	tag : [64] char			; the tag name
					;
	if pre eq '&'			; struct
	   ri_dis ("struct {")		;
	else				; union
	.. ri_dis ("union {")		;
					;
	me_mov (edPdot, tag, rem-edPdot); copy the name
	*<*char>that = 0			;
	ed_del (tag)			; remove it
					;
	ri_beg ()			; nest in
	repeat				;
	   if pre eq '|'		;
	      ed_del (" |")		; skip prefix
	   else				;
	   .. ed_del (" &")		;
					;
	   if (rem = ed_fnd (" | ")) ne	; another enclosed
	      ri_enc ('|', rem)		;
	   elif (rem = ed_fnd (" & "))ne;
	      ri_enc ('&', rem)		;
	   else				;
	      ri_typ (edPdot, edPdot)	; convert to type spec
	      ed_app (";")		;
	      ri_idn (0)		; indent
	      ri_prt (riPcur->Atxt)	; display it
	   .. quit if riVend		; got end of this one
	   riPcur = riPnxt 		; get next line
	   quit if *riPcur->Pbod ne pre	; no more coming
	   ri_get ()			; get the next
	forever				;
	   ri_idn (0)			; indent
	   ri_dis ("} ")		;
	   ri_dis (tag)			;
	   ri_prt (";")			;
	   ri_end ()			;
   end					;
end file
;code	ri_ten - tentative name dictionary

;	Store tentative type names
;
;	A tentative name is replaced by its struct/union equivalent

; type	riTten
; is	Vtyp : int			; structure/union
;	Pnam : * char			; name string
;	Pten : * riTten			; next entry
; end

; func ri_ten
;  	act : int			; action
;	nam : * char			; name
;	()  : * char			; result name
; is	ent : * riTdic			;
;	prv : ** riTdic			;

;    case act
;    of	Dstr				; insert structure entry
;    of Duni				; insert union entry
;	ent = me_alc (riLdic)		; make an entry
;	ent->Vsta = act			; store the type
;	ent->Pnam = me_alc (st_len(nam));
;	st_cop (nam, ent->Pnam)		; copy it
;	ent->Pent = riPten		; the next entry
;	riPten = ent			; save it
;    of	Dfnd
;	ent = riPdic			; the next
;	while ent ne NULL		; got more
;	   if st_cmp (nam, ent->Pnam) eq ; found it
;	   .. exit ent->Vtyp		; return type
;	.. ent = ent->Pten		; the next
;	fail				; not found
;    of Dper				; make name permanent
;	prv = &riPdic			;
;	while *prv ne NULL		; got more
;	   ent = *prv			; get the next
;	   if st_cmp (nam, ent->Pnam)	;
