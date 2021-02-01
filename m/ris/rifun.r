file	rifun - function declarations
include rid:rider
include rib:eddef
include rib:ridef
include	rid:imdef
include	rid:ctdef
include	rid:medef
include rid:chdef
include rid:stdef

;	  func	name own
;		for : type
;		...
;		()  : result type
;	  is	body
;
;		type name (for1, for...)
;		ftype for;
;		{

data	locals

If !Win
	ri_aut : () void
End

	riLstr := 64			; formal length

  type	riTfun 				; function block
  is	Anam : [riLstr] char		; function name
	Alst : [riLstr] char		; formal list
	Atyp : [riLstr] char		; function type
	Afml : [riLstr*24] char		; formal parameters
  end

  	riIfun : riTfun = {0}		; function block
	ri_fun	: (*char) void
	kw_fun	: riTkwd
	kw_pro	: riTkwd

  type	riTfns
  is	Psuc : * riTfns
	Pnam : * char
  end
	riPfns : * riTfns = <>		;

code	kw_fun - function preface

  proc	kw_fun				; func name
  is	ut_seg ("func", <>)		; remember it
	ri_fun ("")
  end

code	kw_pro - procedure preface

  proc	kw_pro
  is	ut_seg ("proc", <>)		; setup segment
	ri_fun ("void")
  end
code	ri_fun - process function header

;  func	name
;	p1  : t1
;	p2  : t2
;	p3  : ...
;	()  : t3
;  is
;  end

  proc	ri_fun 
	typ : * char			; "void" or ""
  is	fun : * riTfun fast = &riIfun	;
	fns : * riTfns~			; function names
	dot : * char~			; editor dot
	ptr : * char~			; general
	fml : * char = fun->Afml	; formal pointer
	loc : int = 0			; own function
	cnt : int = 0			; number of formals
	dup : int = 0			; duplicate name
					;
	++riVcod			; in code
	if ed_fnd ("()")		; common error
	   im_rep ("W-Removed [()] from func/proc statement [%s]", riAseg)
	.. ed_rep ("()", " ")		; elide it
					;
	++loc if ed_rep (" static", "")	; got own function
					;
	ed_skp (" ")			; skip spaces
	st_cop (typ, fun->Atyp)		; get default type
	st_cop ("(", fun->Alst)		; start formal list
					;
	if (riVnst)			; nesting wrong
	   im_rep ("W-Nested function [%s]", riAseg)
	.. riVnst = 0			; clear it
					;
	st_cop (edPdot, fun->Anam)	; get the name of it

; 	Check duplicate function name

	fns = riPfns			;
	while fns ne <>			; got more
	   st_sam (fun->Anam, fns->Pnam); compare it
	   quit ++dup if that		; got dup
	   fns = fns->Psuc		;
	end				;
	if dup				; is a duplicate
	   if riVpre			; in a conditional
	      im_rep ("I-Duplicate function name [%s]", fun->Anam)
	   else				; not in conditional
	   .. im_rep ("E-Duplicate function name [%s]", fun->Anam)
	else
	   fns = me_acc (#riTfns)	; a new one
	   fns->Psuc = riPfns		; link it in
	   riPfns = fns			;
	.. fns->Pnam = st_dup (fun->Anam); save the name
					;
    while not (riVis|riVend) 		; more coming
	if ri_get () eq			; oops
	   im_rep ("E-End of file in func/proc header [%s]", riAseg)
	.. quit				;
					;
	if ed_del (" end")		; end of it
	.. quit ++riVend		; remember it
	quit if ed_fnd (" : ") eq <>	; need a declaration
					;
	if ed_del (" ()")		; got function type
	   ri_typ (edPdot, edPdot)	; convert it   
	   st_cop (edPdot, fun->Atyp)	; remember it
	.. quit ;next			;
					;
	ed_del (" ")			; skip spaces
	dot = edPdot			; get pointer
					;
	if ed_fnd ("...")		; ... anywhere is enough
	   st_app ("...,", fun->Alst)	; save it
	   if quFpro			; new style
	      st_cop ("...", fml)	; terminate it
	   .. fml += riLstr, ++cnt	; next formal
	.. next				; do the next

	quit if not ct_alp (*dot)	; need alpha

;	Copy parameter into prototype list

	if !quFpro			; old style prototypes
	   ptr = st_end (fun->Alst)	; get the address
	   while ct_aln (*dot) 		; got more
	   .. *ptr++ = *dot++		; move one
	   *ptr++ = _comma		; add comma
	.. *ptr = 0			; terminate it

;	Convert and store type

	ri_typ (edPdot, edPdot)		; got it
	st_cop (edPdot, fml)		; store it
	st_app (";", fml) if !quFpro	; terminate it
	fml += riLstr, ++cnt		; next formal
   end
  
	if not (riVis|riVend) 		; incorrect header termination
	.. im_rep ("E-Invalid func/proc header [%s]", riAseg)

;	Got declaration/definition
;
;	Output text

	*fml = 0			; finish up formals
					;
	if !quFpro			; old style
	   ptr = st_end (fun->Alst)	; end of formal list
	   --ptr if ptr[-1] eq _comma	; finished at comma, dump it
	   *ptr++ = paren_			; terminate it
	.. *ptr = 0			;
					;
	riVsup = 1			; supress output (including Vend)
	ed_tru ()			; clear the line
	ed_app ("static ") if loc	; static function
	ed_app (fun->Atyp)		; the function type
	ed_app (fun->Anam)		; the function name
					;
	if not riVis			; just a declaration
	   im_rep ("E-Func/proc missing (is) [%s]", riAseg)
	   ed_app (" ();")		; add C78 stuff
	   ri_prt (edPdot)		; typ nam ();
	.. exit				;
					;
	if quFpro			;
	   ed_app ("(")			; open the parameters up
	   ed_app (")") if !cnt		; are none
	else				;
	.. ed_app (fun->Alst)		; definition - add formal list  
	ri_prt (edPdot)			; type nam (f1, ...)
 					;
	fml = fun->Afml			; process formals
	while *fml 			; got more
	   if quFpro			; new style
	      st_app (",", fml) if fml[riLstr]
	   .. st_app (")", fml) otherwise
	   ri_prt (fml)			; type fx;
	.. fml += riLstr 		; 

If !Win
	ri_aut () if !quFpro		; do auto initializers
End
  end
If Pdp
code	ri_aut - handle auto initializers

;	PDP-11 C compilers don't handle auto initialize.
;	This routine solves the problem:
;
;	func ...
;	is	name1 : type1 = val1
;		name2 : type2 = val2
;		...
;
;	produces:
;
;	func ...
;	is
;		name1 : type1
;		name2 : type2
;		...
;		name1 = val1
;		name2 = val2

  func	ri_cln
	str : * char~
  is	++str while ct_aln (*str)	; skip alphas
	reply st_scn (" : ", str) ne	;sic] for wsc
  end

  proc	ri_aut 
  is	fun : * riTfun fast = &riIfun	;
	fml : * char~ = fun->Afml	; formal pointer
	cnt : int = 0			; auto-assign count
	dot : * char~			; editor dot
	ptr : * char~			; general
	ini : * char			;
	exit if !ri_cln (riPnxt->Pbod)	;
;PUT("[%s]\n", riPnxt->Pbod)
	st_cop (edPdot, riAseg)		; save for errors
    while not riVend 			; more coming
	quit if !ri_cln (riPnxt->Pbod)
	quit if not ri_get ()		; eof
					;
	ed_del (" ")			; skip spaces
	dot = edPdot			; get pointer
;	quit if !ed_fnd (" : ")		; no more autos
	quit if not ct_alp (*dot)	; need alpha

;	copy parameter into prototype list

;	ini = ed_fnd (" = ")		; got an initializer?
	ini = ed_fnd ("=")		; got an initializer?
	if ini				; got initializer
	   ++cnt			; count it
	   ptr = fml			;
	   fml += riLstr		; next formal
	   while ct_aln (*dot) 		; got more
	   .. *ptr++ = *dot++		; move one
	   ptr = st_cop (ini, ptr)	; name = ini
	   *ptr++ = _semi		; add semicolon
	   *ptr = 0			; terminate it
	.. *ini = 0			; elide initializer

;	convert and store type

	ri_typ (edPdot, edPdot)		; int x
	ed_app (";")			;      ;
	ri_put ()			; emit
   end
  
;	output any auto-initializers

	fml = fun->Afml			; process autos
	while cnt--			; more
	   ri_idn (0)			; indent
	   ri_prt (fml)			; write x = y;
	   fml += riLstr 		; next auto
	end				;
;	++riVsup			; don't repeat PUT
  end
End
end file
code	ri_stp - store type

;	stores a type
;	checks type if already stored

  type	riTtyp
  is	Psuc : * riTtyp
	Atyp : [2] char
  end

  type	fun : (a,b,c) d

;	"t#label#int#*char#*riTfun"
	
