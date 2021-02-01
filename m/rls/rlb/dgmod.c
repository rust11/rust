/* file -  dgmod - dialog functions */
#include "m:\rid\wsdef.h"
#include "m:\rid\dgdef.h"
#include "m:\rid\medef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\mxdef.h"
#include "m:\rid\imdef.h"
#define Log  1
#include "m:\rid\dbdef.h"
#include <commdlg.h>
/* code -  dg_opn - open file name dialog */
static int dg_flt (char *,char *,char *);
#define _dgOPN  "All files(*.*)|*.*|"
int dg_opn(
char *dir ,
char *flt ,
char *spc ,
int flg )
{ OPENFILENAME ofn ;
  char flb [1024];
  DWORD err ;
  char buf [256];
  int res ;
  dg_flt (flt, flb, _dgOPN);
  me_clr (&ofn,  sizeof(OPENFILENAME));
  ofn.lStructSize =  sizeof(OPENFILENAME);
  ofn.lpstrFilter = flb;
  ofn.nFilterIndex = 1;
  ofn.lpstrFile = spc;
  ofn.nMaxFile = mxSPC;
  ofn.lpstrInitialDir = dir;
  ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;
  if ( !flg) {res = GetOpenFileName (&ofn) ;} else {
    res = GetSaveFileName (&ofn) ; }
  if ( !res) {
    err = CommDlgExtendedError ();
    if( !err)return 0;
    FMT (buf, "%lu", err);
    im_rep ("I-Error %s", buf);
    return 0;
  } 
  return 1;
} 
/* code -  dg_flt - parse file filter string */
dg_flt(
char *flt ,
char *dup ,
char *def )
{ int lst ;
  if ( flt == NULL) {flt = def ;}
  st_cop (flt, dup);
  flt = dup;
  lst = *st_lst (flt);
  while ( *flt != 0) {
    if ( *flt == lst) {*flt = '\0' ;}
    ++flt;
  } 
  return 1;
} 
/* code -  dg_fnt - font dialogue */
#define CF1  CF_INITTOLOGFONTSTRUCT
#define CF2  CF_SCREENFONTS | CF_EFFECTS
dg_fnt(
wsTevt *evt ,
wsTfnt *fnt )
{ wsTctx *ctx = evt->Pctx;
  HWND wnd = evt->Hwnd;
  CHOOSEFONT chf = {0};
  LOGFONT *log = (LOGFONT *)fnt;
  chf.lStructSize = sizeof (CHOOSEFONT);
  chf.hwndOwner = wnd;
  chf.lpLogFont = log;
  chf.Flags = CF1 | CF2;
  return ( ChooseFont (&chf));
} 
/* code -  dg_beg - begin asynchronous dialogue */
dgTdlg *dgPdrp = NULL;
wsTcal dg_drp ;
dgTdlg *dg_beg(
wsTevt *evt ,
int typ ,
int cod )
{ dgTdlg *dlg = me_acc ( sizeof(dgTdlg));
  dlg->Vtyp = typ;
  dlg->Vcod = cod;
  switch ( typ) {
  case dgDRG:
    DragAcceptFiles (evt->Hwnd, 1);
    wsPdrp = &dg_drp;
    dgPdrp = dlg;
   break; default: 
    LOGv("dg_beg-Unknown type %d", typ);
    me_dlc (dlg);
    return 0;
     }
  return ( dlg);
} 
/* code -  dg_end - end asynchronous dialogue */
dg_end(
wsTevt *evt ,
dgTdlg *dlg )
{ switch ( dlg->Vtyp) {
  case dgDRG:
    DragAcceptFiles (evt->Hwnd, 0);
    wsPdrp = NULL;
   break; default: 
    return 0;
     }
  me_dlc (dlg);
  return 1;
} 
/* code -  dg_drp - drop handling */
dg_drp(
wsTevt *evt )
{ dgTdlg *dlg = dgPdrp;
  LOG("dg_drp 1");
  dlg->Vval = evt->Vwrd;
  evt->Vwrd = dlg->Vcod;
  LOG("dg_drp 2");
  SendMessage (evt->Hwnd, WM_COMMAND, dlg->Vcod, 0L);
  LOG("dg_drp 3");
  return 1;
} 
/* code -  dg_drg - drag handling */
dg_drg(
wsTevt *evt ,
dgTdlg *dlg ,
int nth ,
char *str )
{ HDROP han = (HDROP )dlg->Vval;
  if( !han)return 0;
  if( (DragQueryFile (han, nth, str, 256)) != ~(0))return 1;
  DragFinish (han);
  dlg->Vval = 0;
  return 0;
} 
/* code -  dg_fnd - find/replace dialogue */
#define dgTfnd struct dgTfnd_t 
struct dgTfnd_t
{ int Vflg ;
  char Amod [256];
  char Arep [256];
  FINDREPLACE Sdlg ;
  int Vmsg ;
   };
dgTfnd dgSfnd = {0};
wsTfas dg_fra ;
dg_fnd(
wsTevt *evt ,
char *mod ,
char *rep ,
int flg )
{ wsTfac *fac ;
  dgTfnd *fnd ;
  FINDREPLACE *dlg ;
  fac = ws_fac (evt, "FIND");
  fnd = fac->Pusr = me_acc ( sizeof(dgTfnd));
  if ( !fnd->Vmsg) {
    fnd->Vmsg = (RegisterWindowMessage (FINDMSGSTRING));
    fac->Past = dg_fra; }
  fnd->Vflg = flg;
  dlg = &fnd->Sdlg;
  dlg->lStructSize =  sizeof(FINDREPLACE);
  dlg->hwndOwner = evt->Hwnd;
  dlg->Flags = 0;
  dlg->lpstrFindWhat = fnd->Amod;
  dlg->lpstrReplaceWith = fnd->Arep;
  dlg->wFindWhatLen = 256;
  return ( FindText (dlg) != 0);
} 
/* code -  dg_fra - find ast */
dg_fra(
wsTevt *evt ,
wsTfac *fac )
{ dgTfnd *fnd = fac->Pusr;
  FINDREPLACE *dlg ;
  int flg ;
  int act = 0;
  int ctl = 0;
  if( evt->Vmsg != fnd->Vmsg)return 0;
  dlg = (void *)evt->Vlng;
  flg = dlg->Flags;
  if ( flg & FR_DIALOGTERM) {act = dgTER ;}
  if ( flg & FR_REPLACE) {act = dgREP ;}
  if ( flg & FR_REPLACEALL) {act = dgALL ;}
  if ( flg & FR_FINDNEXT) {act = dgNXT ;}
  if ( (wc_fnd (evt, act, ctl, fnd->Amod, fnd->Arep)) == 0) {im_rep ("Q-String not found", "") ;}
  return 1;
} 
