file	mosh - text macro processor
include	rid:rider
include rid:chdef
include rid:codef
include rid:fidef
include	rid:imdef
include rid:stdef
include rid:mhdef

;	See the syntax description at the end of this file.
;
;	%build
;	rider kus:mosh/object:cub:
;	link cub:mosh/exe:cub:/map:cub:/cross/bot:3000,lib:crt
;	%end

	_mhTER := "TT"		
	_mhDEF := "ini:mosh.ini"

	mh_qua : (*mhTpit, *char)
	mh_scr : (*mhTpit, *char, int)

  init	mhAhlp : [] * char
  is	"MOSH: RUST text macro processor V2.0"
	" "
	"o mosh infile,,... outfile"
	""
	"infile  = infile[.m]"
	"outfile = outfile[.txt]"
	""
	<>
  end
code	mosh main

;	mosh infile,... outfile
;
;	Present infiles in reverse order to mosh engine

  func	main
	cnt : int				; argument count
	vec : ** char~				; argument vector
  is	pit : * mhTpit~				; our mosh
	lin : [mxLIN+2] char
	spc : [mxSPC] char
	src : * char
	dst : * char
	idx : int
	lin[0] = 0

	im_ini ("MOSH")				; init image stuff
	co_ctc (coENB)				;
						;
	exit im_hlp (mhAhlp, 1) if cnt le 2	; naught to be done
						;
	pit = mh_alc (<>)			; get a mosh pit
	++vec, --cnt, idx = 0			; skip vec[0]

	st_cop (vec[idx++], lin+1)		; copy the line
	src = st_end (lin+1)			; scan backwards
      while src[-1]
	--src while src[-1]  && (src[-1] ne ',');
	st_cop (src, spc)			;
	fail if !mh_qua (pit, spc)		; do qualifiers
	fi_def (spc, ".m", spc)			;
	fail if !mh_ipt (pit, spc)		;
	*--src = 0 if (src[-1] eq ',')
      end					;

	if cnt ge 2
	   st_cop (vec[idx], spc)		;
	   fail if !mh_qua (pit, spc)		; do qualifiers
	   fi_def (spc, ".mx", spc)		;
	.. fail if !mh_opt (pit, spc)		;
						;
	mh_par (pit)				; parse input
	mh_dlc (pit)				; close
	im_exi ()				;
  end

code	mh_qua - get qualifiers

  func	mh_qua
	pit : * mhTpit~
	arg : * char~
	()  : int			; fine/fail
  is	obj : [2] char			;
	qua : int			;
	exit if arg eq <>		; is none
      while *arg ne			; more of
	next ++arg if *arg ne '/'	; not an option
	*arg++ = 0			; terminate parameter
					;
	qua = *arg++			; get character, or null
	qua = ch_upr (qua)		; go upper class
	case qua			;
	of '?'				;
	or 'H'  fail im_hlp (mhAhlp, 1)	; wants help
 	of 'M'  ++pit->Fmet		; wants metas shown
 	of 'V'  ++pit->Fver		; wants verify
	of other			;
	   obj[1] = qua, obj[2] = 0	; setup message
	   fail im_rep ("E-Invalid qualifier [/%s]", obj);
	end case			;
      end				;
	fine				;
  end
end file

;	MHS:*.M	
;	WDOT	WikiDot
;	WSPACE	WikiSpaces
;	CREOLE	WikiCreole
;	RTF	RTF
;	HTML	HTML
; ???	PDF	PDF
;	RTHELP	Rust help
;
;	SLF	@@StreamLF
;	SCR	@@StreamCR
;	SCL	@@StreamCRLF
;	SLC	@@StreamLFCR
;	CTB	@@CountedByte
;	CTW	@@CountedWord
;
;	Directory strategy
;
;		%%M:		Mosh directoruy
;	TXT	%%M:\TXT\	Plain text
;	HTM	%%M:\HTM\	HTML
;	RTF	%%M:\RTF\	RTF 
;	HLP	%%M:\HLP\	RUST HELP
;	WSP	%%M:\SPACES\	Wikispaces 
;	WDT	%%M:\DOT\	Wikidot 
;	WCR	%%M:\CREOLE\	Wikidot 
;
;	mosh document xxT
;
;	translates to:
;
;	mosh dir:doc.M  dir:\HTM\DOC.HTM
;
;	htmo.m		HTM output 
@; CreoleOut (see wwww.wikicreole.org)
@;
@Head1 := ~=~= ^a
@Head2 := ~=~=~= ^a
@Line := ~-~-~-~-

@o := * ^a
@_o := ** ^a
@n := # ^a
@_n := ## ^a

(@NL := `\`\)
(@I := ~/~/)(@Ix := ~/~/);

== Title	== Sub-title	=== Sub-sub
   Title	   Head		    Item
\\ newline
* bullet item	** sub-bullet
# number	## sub-numbered

---- HL
//italic//	**bold**	__underline__
^^super^^	,,sub,,		??--strike--
##fixed##	{{{plain}}}
[[link]]	[[URL|link]]	{{image|title}}
<<plug-in>>

|=	|=	|=	|NL	Table header
|	|	|	|	Table row
|	|	|	|	Table row

@Table
@||
@|
@Row
@TableX
