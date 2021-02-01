file	dgmod - dialog functions
include	rid:wsdef
include	rid:dgdef
include	rid:medef
include	rid:stdef
include	rid:mxdef
include	rid:imdef
include rid:cldef
include <commdlg.h>
include <shellapi.h>

code	dg_opn - open file name dialog

	_dgOPN := "All files(*.*)|*.*|"
	dg_flt	: (*char, *char, *char) int own

;	filter	"comment|spc|comment|spc|"

  func	dg_opn
	dir : * char			; these are impure strings
	flt : * char			; and all are 256 chars
	spc : * char			; result spec
	flg : int			; 0=open, 1=save_as
	()  : int			;
  is	ofn : OPENFILENAME		; open filename block
	flb : [1024] char		; to edit the filter
	err : DWORD			; error code
	buf : [256] char		; error buffer
	res : int			;
	dg_flt (flt, flb, _dgOPN)	; convert filter
					;
	me_clr (&ofn, #OPENFILENAME)	;
	ofn.lStructSize = #OPENFILENAME ;
;;;	ofn.hwndOwner = wi_hnd ()	; the window handle
	ofn.lpstrFilter = flb		;
	ofn.nFilterIndex = 1		;
	ofn.lpstrFile = spc		;
	ofn.nMaxFile = mxSPC		;
;	ofn.lpstrFileTitle = tit	;
;	ofn.nMaxFileTitle = mxSPC	;
	ofn.lpstrInitialDir = dir	;
	ofn.Flags = OFN_PATHMUSTEXIST|OFN_FILEMUSTEXIST|OFN_OVERWRITEPROMPT
	res = GetOpenFileName (&ofn) if !flg
	res = GetSaveFileName (&ofn) otherwise
	if !res				; oops
	   err = CommDlgExtendedError (); get the error code
	   fail if !err			; just a cancel???
	   FMT (buf, "%lu", err)	; 
	   im_rep ("I-Error %s", buf)	;
	   fail				;
	end				;
	fine
  end

code	dg_flt - parse file filter string

;	"....|.....|"	replace each "|" with zero

  func	dg_flt
	flt : * char			; prototype
	dup : * char			; result
	def : * char			; default
  is	lst : int	

	flt = def if flt eq <>		; default filter
	st_cop (flt, dup)		; copy to edit buffer
	flt = dup			;
	lst = *st_lst (flt)		; the separator
	while *flt ne			; got more
	   *flt = '\0' if *flt eq lst	;
	   ++flt			;
	end				;
	fine
  end
code	dg_fnt - font dialogue

	CF1 := CF_INITTOLOGFONTSTRUCT
	CF2 := CF_SCREENFONTS | CF_EFFECTS

  func	dg_fnt
	evt : * wsTevt
	fnt : * wsTfnt
  is	ctx : * wsTctx = evt->Pctx
	wnd : HWND = evt->Hwnd
	chf : CHOOSEFONT = {0}
	log : * LOGFONT = <*LOGFONT>fnt	;

	chf.lStructSize = sizeof (CHOOSEFONT)
	chf.hwndOwner   = wnd		;
	chf.lpLogFont   = log		;
	chf.Flags       = CF1 | CF2	;
	reply ChooseFont (&chf)		;
  end
code	dg_beg - begin asynchronous dialogue

;	dgPdrp	: * dgTdlg = <>
	dg_drp	: wsTast

  func	dg_beg 
	evt : * wsTevt
	typ : int
	cod : int
	()  : * dgTdlg
  is	dlg : * dgTdlg = me_acc (#dgTdlg)
	fac : * wsTfac = ws_fac (evt, "drop")
	dlg->Vtyp = typ
	dlg->Vcod = cod
	case typ
	of dgDRG
	   DragAcceptFiles (evt->Hwnd, 1)
	   fac->Past = dg_drp
	   fac->Pusr = dlg
;	   wsPdrp = &dg_drp
;	   dgPdrp = dlg
	of other
	   me_dlc (dlg)
	   fail
	end case
	reply dlg
  end

code	dg_end - end asynchronous dialogue

  func	dg_end 
	evt : * wsTevt
	dlg : * dgTdlg
  is	fac : * wsTfac = ws_fac (<>, "drop")
	case dlg->Vtyp
	of dgDRG
	   DragAcceptFiles (evt->Hwnd, 0)
	   fac->Past = <>
;	   wsPdrp = <>
	of other
	   fail
	end case
;	me_dlc (dlg)
	fine
  end

code	dg_drp - drop handling

  func	dg_drp
	evt : * wsTevt
	fac : * wsTfac
  is	dlg : * dgTdlg = fac->Pusr ;dgPdrp
	fail if evt->Vmsg ne WM_DROPFILES
	dlg->Vval = evt->Vwrd
	evt->Vwrd = dlg->Vcod
	SendMessage (evt->Hwnd, WM_COMMAND, dlg->Vcod, 0L)
;	wc_cmd (evt)
	fine
  end

code	dg_drg - drag handling

  func	dg_drg
	evt : * wsTevt
	dlg : * dgTdlg
	nth : int
	str : * char 
  is	han : HDROP = <HDROP>dlg->Vval
	fail if !han
	DragQueryFile (han, nth, str, 256)
	fine if ne ~(0)
	DragFinish (han)
	dlg->Vval = 0
	fail
  end
code	dg_fnd - find/replace dialogue

  type	dgTfnd
  is	Vflg : int
	Amod : [256] char
	Arep : [256] char
	Sdlg : FINDREPLACE
	Vmsg : int
  end

	dg_fra : wsTast

  func	dg_fnd
	evt : * wsTevt
	mod : * char
	rep : * char
	flg : int
  is	fac : * wsTfac = ws_fac (evt, "FIND")
	fnd : * dgTfnd
	dlg : * FINDREPLACE
	if !fac->Pusr
	.. fac->Pusr = me_acc (#dgTfnd)
	fnd = fac->Pusr

	if !fnd->Vmsg
	   RegisterWindowMessage (FINDMSGSTRING)
	   fnd->Vmsg = that
	.. fac->Past = dg_fra

	fnd->Vflg = flg
	dlg = &fnd->Sdlg

	dlg->lStructSize     = #FINDREPLACE
	dlg->hwndOwner       = evt->Hwnd
;	dlg->Instance        = <>
	dlg->Flags            = 0 ;FR1
	dlg->lpstrFindWhat    = fnd->Amod
	dlg->lpstrReplaceWith = fnd->Arep
	dlg->wFindWhatLen     = 256
;	dlg->wReplaceWithLen  = 256
;	dlg->lCustData        = 0
;	dlg->lpfnHook         = <>
;	dlg->lpTemplateName   = <>
	reply FindText (dlg) ne
  end
	
code	dg_fra - find ast

  func	dg_fra
	evt : * wsTevt
	fac : * wsTfac
  is	fnd : * dgTfnd = fac->Pusr
	dlg : * FINDREPLACE
	flg : int
	act : int = 0
	ctl : int = 0
	fail if evt->Vmsg ne fnd->Vmsg
	dlg = <*void>evt->Vlng
	flg = dlg->Flags
	act = dgTER if flg & FR_DIALOGTERM
	act = dgREP if flg & FR_REPLACE
	act = dgALL if flg & FR_REPLACEALL
	act = dgNXT if flg & FR_FINDNEXT
	wc_fnd (evt, act, ctl, fnd->Amod, fnd->Arep)
	im_rep ("Q-String not found", "") if fail
	fine				;
  end
end file
#define MAX_STRING_LEN   256

static char szFindText [MAX_STRING_LEN] ;
static char szReplText [MAX_STRING_LEN] ;

HWND PopFindFindDlg (HWND hwnd)
     {
     static FINDREPLACE fr ;       // must be static for modeless dialog!!!

     fr.lStructSize      = sizeof (FINDREPLACE) ;
     fr.hwndOwner        = hwnd ;
     fr.hInstance        = NULL ;
     fr.Flags            = FR_HIDEUPDOWN | FR_HIDEMATCHCASE | FR_HIDEWHOLEWORD ;
     fr.lpstrFindWhat    = szFindText ;
     fr.lpstrReplaceWith = NULL ;
     fr.wFindWhatLen     = sizeof (szFindText) ;
     fr.wReplaceWithLen  = 0 ;
     fr.lCustData        = 0 ;
     fr.lpfnHook         = NULL ;
     fr.lpTemplateName   = NULL ;

     return FindText (&fr) ;
     }

HWND PopFindReplaceDlg (HWND hwnd)
     {
     static FINDREPLACE fr ;       // must be static for modeless dialog!!!

     fr.lStructSize      = sizeof (FINDREPLACE) ;
     fr.hwndOwner        = hwnd ;
     fr.hInstance        = NULL ;
     fr.Flags            = FR_HIDEUPDOWN | FR_HIDEMATCHCASE | FR_HIDEWHOLEWORD ;
     fr.lpstrFindWhat    = szFindText ;
     fr.lpstrReplaceWith = szReplText ;
     fr.wFindWhatLen     = sizeof (szFindText) ;
     fr.wReplaceWithLen  = sizeof (szReplText) ;
     fr.lCustData        = 0 ;
     fr.lpfnHook         = NULL ;
     fr.lpTemplateName   = NULL ;

     return ReplaceText (&fr) ;
     }

BOOL PopFindFindText (HWND hwndEdit, int *piSearchOffset, LPFINDREPLACE lpfr)
     {
     int         iPos ;
     LOCALHANDLE hLocal ;
     LPSTR       lpstrDoc, lpstrPos ;

               // Get a pointer to the edit document

     hLocal   = (HWND) SendMessage (hwndEdit, EM_GETHANDLE, 0, 0L) ;
     lpstrDoc = (LPSTR) LocalLock (hLocal) ;

               // Search the document for the find string

     lpstrPos = _fstrstr (lpstrDoc + *piSearchOffset, lpfr->lpstrFindWhat) ;
     LocalUnlock (hLocal) ;

               // Return an error code if the string cannot be found

     if (lpstrPos == NULL)
          return FALSE ;

               // Find the position in the document and the new start offset

     iPos = lpstrPos - lpstrDoc ;
     *piSearchOffset = iPos + _fstrlen (lpfr->lpstrFindWhat) ;

               // Select the found text

     SendMessage (hwndEdit, EM_SETSEL, 0,
                  MAKELONG (iPos, *piSearchOffset)) ;

     return TRUE ;
     }

BOOL PopFindNextText (HWND hwndEdit, int *piSearchOffset)
     {
     FINDREPLACE fr ;

     fr.lpstrFindWhat = szFindText ;

     return PopFindFindText (hwndEdit, piSearchOffset, &fr) ;
     }

BOOL PopFindReplaceText (HWND hwndEdit, int *piSearchOffset, LPFINDREPLACE lpfr)
     {
               // Find the text

     if (!PopFindFindText (hwndEdit, piSearchOffset, lpfr))
          return FALSE ;

               // Replace it

     SendMessage (hwndEdit, EM_REPLACESEL, 0, (long) lpfr->lpstrReplaceWith) ;

     return TRUE ;
     }

BOOL PopFindValidFind (void)
     {
     return *szFindText != '\0' ;
     }
