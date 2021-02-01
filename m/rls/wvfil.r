file	wvfil - wave file operations
include	rid:rider
include	rid:imdef
include	rid:fidef
include	rid:medef
include	rid:stdef
include	rid:mxdef
include	<windows.h>
include <stdio.h>
WVDEF_LOCAL := 1
include	rid:wvdef
include	rid:wsdef
	wv_opn	: (*char, *char, *char) *FILE own

code	wv_clo - close and deallocate buffer

  func	wv_clo
	wav : * wvTwav
  is	fine wv_dlc (wav)
  end
code	wv_loa - load wave file

	wv_imp : (*char, *char, *char)
	wv_red : (*wvTwav) int

  func	wv_loa
	spc : * char				; spec
	sto : * char				; storage spec
	msg : * char				; error message
	()  : *wvTwav				;
  is	imp : [mxSPC] char			;
	atr : [128] char			;
	wav : * wvTwav = <>			;
	hdr : * wvThdr				;
	len : size = 0L				;
	tot : size
	cnt : size				;
	fil : * FILE = <>			;
	buf : * char = <>			;
	cod : int = 0				;
	gbl : HGLOBAL				;
						;
      repeat					; fail block
	quit if !wv_imp (spc, imp, sto)		; import mp3 etc
	quit if (len = fi_siz (imp)) eq		; no such file or what?
	quit if (fil = wv_opn (imp, ".wav", "rb")) eq; no access
	quit if (wav = wv_alc (<>, len)) eq	; allocate raw space
	quit if !fi_rea (fil, wav->Phdr, len)	; read the file
	quit if !fi_clo (fil, "")		;
	if st_cmp (spc, imp)			; we converted?
	.. fi_del (imp, <>)			; delete temp file
	quit if !wv_red (wav)			; get rid of redundant stuff
						;
	hdr = wav->Phdr				;
						;
	wav->Vchn = hdr->Vchn			; channel count
	wav->Vwid = hdr->Vwid / 8		; byte width, not bit width
	wav->Vrat = hdr->Vrat			; data rate
	wav->Vpnt = wav->Vchn * wav->Vwid	; point size in bytes
	wav->Vavg = wav->Vrat * wav->Vpnt	; average bytes second
						;
	tot = hdr->Vdsz				; data size
	if tot gt (len - #wvThdr)		; sanity check			
	.. tot = len - #wvThdr			; limit it

	if tot && wav->Vpnt
	   cnt = tot / wav->Vpnt		; get count
	else
	.. cnt = 0				;

	wav->Vcnt = cnt				;
	wav->Vtot = cnt * wav->Vpnt		;
	wav->Vsiz = cnt				;
	reply wav				;
      never					;
	wv_dlc (wav) if wav			; deallocate buffer
	fi_clo (fil, "") if fil			; close file
	reply <>				; failed
  end
code	wv_sto -- store file

  func	wv_sto 
	wav : * wvTwav
	spc : * char				;
	msg : * char				; error message
  is	fil : * FILE				;
	buf : * char				;
	siz : size				;
	fail if !wav				; no wave 
	wv_nor (wav)				; normalize wave first
	buf = <*char>wav->Phdr			; start of data
	siz = wav->Vtot + #wvThdr		; total size

;	if !(flg & wvALL_) && wav->Vsiz		;
;	    buf += wav->Vbeg			;
;	..  siz = wav->Vsiz			;

	if (fil = wv_opn (spc, ".wav", "wb")) eq; write a file
	|| fi_wri (fil, buf, siz) eq		;
	   fi_rep (spc, msg, "")		; say what happened
	   fi_clo (fil, "")			;
	.. fail					;
	fi_clo (fil, "")			; close it
	wv_opt (wav, spc)			; write attributes
	fine					;
  end
code	wv_ipt - input attributes

;	unused

  func	wv_ipt
	wav : * wvTwav
	spc : * char
  is	txt : [512] char
	fil : * FILE
	lst : **wvTatr = &(wav->Patr)	; first attribute
	atr : * wvTatr			;
	beg : size			;
	siz : int			;
	typ : int			;
	flg : int			;
	fil = wv_opn (spc, ".wat", "rb")
	fail if !fil			;
	repeat
	   fscanf (fil, "%lx,%lx,%lx,%lx",
		  &beg, &siz, &typ, &flg)
	   quit if fail			; all over
	   fi_get (fil, txt, 126)	; get the rest of it
	   quit if typ eq wvEOF		; end of file
	   atr = me_acc (#wvTatr)	; make an attribute
	   atr->Vbeg = beg		;
	   atr->Vsiz = siz		;
	   atr->Vtyp = typ		;
	   atr->Vflg = flg		;
	   if flg & wvTXT_		; got text 
	      fi_get (fil, txt, 500)	;
	      quit if fail		;
	   .. atr->Pdat = st_dup (txt)	; get the text
	   *lst = atr			;
	   lst = &(atr->Psuc)		;
	forever				;
	fi_clo (fil, "")
	fine
  end
code	wv_opt - output attributes

  func	wv_opt
	wav : * wvTwav
	spc : * char
  is	fil : * FILE
	atr : * wvTatr = wav->Patr
	if !atr				; no attributes
;	   if fi_exs (spc, <>)		; has attributes
;	   .. fi_del (spc, "")		;
	.. fine				;
	fil = wv_opn (spc, ".wat", "wb")
	while atr			;
	   fprintf (fil, "%lx,%lx,%lx,%lx",
		   atr->Vbeg, atr->Vsiz,
		   atr->Vtyp, atr->Vflg)
	   if atr->Vflg & wvTXT_	
	   .. fi_put (fil, atr->Pdat)	; writeth
	   fi_put (fil, "\n")
	   atr = atr->Psuc
	end
	fi_clo (fil, "")
	fine
  end
code	wv_opn - open a wave file

  func	wv_opn
	spc : * char
	typ : * char
	mod : * char
	()  : * FILE
  is	nam : [mxSPC] char
	st_cop (spc, nam)
	if st_sam (typ, ".wat")		; open wave attribute file
	   st_rep (".wav", ".wat", nam)	;
	elif st_sam (typ, ".wav")	; open wave data file
	.. st_rep (".wat", ".wav", nam)	;
	reply fi_opn (nam, mod, "")	;
  end
code	wv_red - reduce wave file

	pragma	pack(2)		;
  type	wvTchk
  is	Alab : [4] char		;
	Vsiz : LONG		;
  end

  type	wvTrif
  is	Alab : [4] char		;
	Vsiz : LONG		;
	Awav : [4] char
	Ichk : wvTchk		; first chunk
  end

;	Wave files can have all sorts of data blocks
;	Get rid of anything we don't use
;
;	All we want is:
;
;	RIFF
;	fmt ...
;	data ...


  func	wv_red
	wav : * wvTwav
  is	rif : * wvTrif = <*void>wav->Phdr
	chk : * wvTchk = &rif->Ichk
	rem : size = rif->Vsiz - 4	; "WAVE
	len : size
	src : * char = <*void>chk
	dst : * char = src
	dat : int 
      while rem gt
	chk = <*void>src
	len = chk->Vsiz + #wvTchk		;
	fail if (rem -= len) lt			; oops--overrun
	dat = me_cmp (chk->Alab, "data", 4)
	if me_cmp (chk->Alab, "fmt ", 4) || dat
	   me_cop (chk, dst, len)
	   dst += len
	.. fine if dat
	src += len
      end
	fine
  end
code	wv_imp - import mp3 etc

;	Use FFMPEG.EXE to convert files for input

	wvFFM := "c:\\cusps\\ffmpeg\\bin\\ffmpeg.exe"
	wvTMI := "f:\\tmp\\soundsin.tmp"
	wvTMO := "f:\\tmp\\soundsout.wav"

  func	wv_imp
	spc : * char
	imp : * char
	sto : * char
  is	inp : [mxSPC] char
	opt : [mxSPC] char
	rem : [(mxSPC*2)+8] char
	typ : * char
	sts : int
;PUT("[%s]\n", spc)

	st_cop (spc, imp)
	fine if st_fnd (".wav", spc)

	if sto
	   st_cop (spc, sto)
	   typ = st_fnd (".", sto)
	   st_cop (".wav", typ) if typ
	end

	st_cop (spc, inp)
	st_cop (spc, opt)
	if st_fnd (" ", spc)		; got spaces?
	   fi_del (wvTMI, <>)		; delete previous temp
	   fi_del (wvTMO, <>)		; delete previous temp
	   fi_cop (spc, wvTMI, "", 0)	; copy to temp file
	   pass fail			;
	   st_cop (wvTMI, inp)		; use temp file for input
	   st_cop (wvTMO, opt)		; use temp file for output
	.. st_cop (wvTMO, imp)		; and then import that

	typ = st_fnd (".", imp)		; must have file type
	pass fail			;
a
	st_cop (".wav", typ)
	st_cop ("-loglevel quiet -i \"", rem)
	st_app (inp, rem)
	st_app ("\" \"", rem)
	st_app (opt, rem)
	st_app ("\"", rem)
PUT("[%s]\n", rem)
b
	sts = im_exe (wvFFM, rem, 0)	; execute the program
c
	fail if sts lt
d
	fine
  end
