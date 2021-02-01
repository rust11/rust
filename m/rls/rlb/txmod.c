/* file -  txmod - windows text objects */
#include "m:\rid\wsdef.h"
#include "m:\rid\txdef.h"
#include "m:\rid\medef.h"
#include "m:\rid\fidef.h"
#define Log  0
#include "m:\rid\dbdef.h"
/* code -  tx_cre - create text window */
#define ES1  WS_CHILD | WS_VISIBLE | WS_VSCROLL
#define ES2  ES_LEFT | ES_MULTILINE | WS_BORDER
#define ES3  ES_NOHIDESEL | ES_AUTOVSCROLL
#define EDITID  1
txTtxt *tx_cre(
wsTevt *evt )
{ txTtxt *txt ;
  wsTctx *ctx = evt->Pctx;
  HANDLE ins = ((LPCREATESTRUCT )evt->Vlng)->hInstance;
  HWND wnd ;
  LOGFONT log ;
  LOG ("Create edit window");
  wnd = CreateWindow ("edit", NULL,ES1|ES2|ES3, 0, 0, 0, 0,evt->Hwnd, (HMENU )EDITID, ins, NULL);
  if ( !wnd) {LOGe("Edit window create failed") ;}
  if( !wnd)return 0;
  txt = me_acc ( sizeof(txTtxt));
  txt->Hwnd = wnd;
  LOGv("wnd=%x", wnd);
  ws_chd (evt, wnd);
  SendMessage (wnd, EM_LIMITTEXT, 64000, 0L);
  GetObject ((GetStockObject (SYSTEM_FONT)),  sizeof(LOGFONT), (LPSTR )&log);
  tx_fnt (evt, txt, &log);
  return ( txt);
} 
/* code -  tx_des - destroy text window */
tx_des(
wsTevt *evt ,
txTtxt *txt )
{ DestroyWindow (txt->Hwnd);
  me_dlc (txt);
  return 1;
} 
/* code -  tx_loa - load file */
int tx_loa(
wsTevt *evt ,
txTtxt *txt ,
char *spc ,
int mod )
{ char *dat ;
  size_t len ;
  int res = 0;
  LOG("tx_loa");
  fi_loa (spc, &(void *)dat, &len, NULL, NULL);
  if( !dat)return 0;
  if ( len < 64000) {
    LOG ("fi_loa - set window text");
    LOGv("buf=%x", dat);
    LOGv("len=%d", len);
    dat[len-1] = 0;
    res = SetWindowText (txt->Hwnd, dat); }
  LOG ("fi_loa - deallocate");
  mg_dlc (dat);
  LOGv("tx_loa done %d", res);
  return ( res);
} 
/* code -  tx_clo - close file */
tx_clo(
wsTevt *evt ,
txTtxt *txt )
{ SetWindowText (txt->Hwnd, "\0");
  tx_fun (evt, txt, txALL);
  tx_fun (evt, txt, txDEL);
  return 1;
} 
/* code -  tx_sto - store file */
tx_sto(
wsTevt *evt ,
txTtxt *txt ,
char *spc ,
int mod )
{ size_t len ;
  char *buf ;
  int res ;
  LOG ("tx_sto");
  LOGv("txt=%x", txt);
  LOGv("wnd=%x", txt->Hwnd);
  len = GetWindowTextLength (txt->Hwnd);
  LOGv("len=%d", len);
  buf = mg_alc (len);
  LOGv("buf=%x", buf);
  if( !buf)return 0;
  res = GetWindowText (txt->Hwnd, buf, len);
  if ( res != len) {
    LOGv ("GetWindowText %d", res); }
  if ( res != 0) {
    res = fi_sto (spc, buf, len, 0, ""); }
  LOG ("tx_sto -- dealloc");
  mg_dlc (buf);
  LOGv("tx_sto res=%d", res);
  return ( res);
} 
/* code -  tx_fun - simple functions */
tx_fun(
wsTevt *evt ,
txTtxt *txt ,
int fun )
{ int cod ;
  long lng ;
  if( !txt)return 1;
  switch ( fun) {
  case txUND:
    cod = WM_UNDO;
   break; case txCUT:
    cod = WM_CUT;
   break; case txCOP:
    cod = WM_COPY;
   break; case txPAS:
    cod = WM_PASTE;
   break; case txDEL:
    cod = WM_CLEAR;
   break; case txALL:
    cod = EM_SETSEL;
    lng = ~(0);
     }
  return ( (SendMessage (txt->Hwnd, cod, 0, lng)));
} 
/* code -  tx_fnt - get/set font */
wsTfnt *tx_fnt(
wsTevt *evt ,
txTtxt *txt ,
wsTfnt *fnt )
{ wsTctx *ctx = evt->Pctx;
  LOGFONT *log = (LOGFONT *)fnt;
  HFONT new ;
  if( !fnt)return ( &txt->Sfnt );
  new = CreateFontIndirect (log);
  SendMessage (ctx->Hchd, WM_SETFONT, (ULONG )new, 0L);
  if ( txt->Hfnt) {DeleteObject (txt->Hfnt) ;}
  txt->Hfnt = new;
  me_cop (log, &txt->Sfnt,  sizeof(LOGFONT));
  return ( &txt->Sfnt);
} 
/* code -  tx_opt - output string */
tx_opt(
wsTevt *evt ,
txTtxt *txt ,
char *buf ,
int len )
{ if ( len == -1) {len = st_len (buf) ;}
  while ( len--) {
    SendMessage (txt->Hwnd, WM_CHAR, *buf++, 0);
  } 
  return 1;
} 
