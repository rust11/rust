file	exdel - expat delete/print/type commands
include rid:rider	; rider
include rid:fidef	; files
include rid:stdef	; strings
include	rid:vfdef	; virtual files
include	exb:exmod	; expat

code	delete command

  func	cm_del
	src : * vfTobj
	ent : * vfTent~
  is	spc : [mxSPC] char
	cu_res (src->Aspc,ent->Anam,spc) ; get resultant spc
	fi_del (spc, "")	; delete the file
	fine
  end


code	print command

  func	cm_prt
	src : * vfTobj
	ent : * vfTent~
  is	cha : char

	while (cha = vf_get (src)) ne EOF
	   next if !cu_asc (cha)	; not an ascii character
 	   PUT("%c", cha) if cha ne	; get a byte/put a byte
	   next if (cha&255) ne '\n'	;
	   quit if !cu_pag()		; /page
	end
	fine
  end

code	type command

;	Type always uses /ASCII (which might be a problem)

  func	cm_typ
	src : * vfTobj
	ent : * vfTent~
  is	cha : char

	while (cha = vf_get (src)) ne EOF
	   next if !cu_asc (cha)	; not an ascii character
 	   PUT("%c", cha) if cha ne	; get a byte/put a byte
	   next if (cha&255) ne '\n'	;
	   quit if !cu_pag()		; /page
	end
	fine
  end
                                                                                                                                                                                                                                                                                                                                                                                                                                                      