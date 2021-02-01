/* file -  wsmod - windows server */
#include "m:\rid\wsdef.h"
#include "m:\rid\imdef.h"
#include "m:\rid\medef.h"
#include "m:\rid\mxdef.h"
#include "m:\rid\stdef.h"
#define Log  1
#include "m:\rid\dbdef.h"
#include <stdio.h>
wsTctx *wsPctx = NULL;
wsTcal *wsPwav = NULL;
wsTcal *wsPmou = NULL;
wsTcal *wsPdrp = NULL;
wsTcal *wsPloo = ws_loo;
wsTctx *wi_ctx (HWND );
BOOL wi_app (wsTctx *);
BOOL wi_ins (wsTctx *);
LRESULT CALLBACK wi_evt (HWND ,UINT ,WPARAM ,LPARAM );
int APIENTRY wi_mai (HANDLE ,HANDLE ,LPSTR ,int );
wsTcal ws_evt ;
wsTcal wc_mai ;
wsTcal wc_evt ;
/* code -  ws_ctx - get context */
wsTctx *ws_ctx()
{ return ( wsPctx);
} 
/* code -  wi_ctx - get context */
wsTctx *wi_ctx(
HWND wnd )
{ 
  return ( wsPctx);
} 
/* code -  ws_cod - get event code */
ws_cod(
wsTevt *evt )
{ return ( evt->Vwrd);
} 
/* code -  ws_exi - exit this image */
ws_exi(
wsTevt *evt )
{ 
  im_exi ();
  return 1;
} 
/* code -  ws_run - run a windows program */
int ws_run(
char *spc ,
int flg )
{ 
  return ( (WinExec (spc, SW_SHOW)) >= 32);
} 
/* code -  ws_chd - get/set child */
HWND ws_chd(
wsTevt *evt ,
HWND new )
{ wsTctx *ctx = evt->Pctx;
  HWND old = ctx->Hchd;
  if ( new) {ctx->Hchd = new ;}
  return ( old);
} 
/* code -  ws_tit - set window title */
ws_tit(
wsTevt *evt ,
char *tit )
{ char buf [256];
  FMT(buf, "%s %s", imPfac, tit);
  SetWindowText (evt->Hwnd, buf);
  return 1;
} 
/* code -  ws_fac - create facility */
wsTfac *ws_fac(
wsTevt *evt ,
char *nam )
{ wsTctx *ctx = evt->Pctx;
  wsTfac *(*prv )= &ctx->Pfac;
  wsTfac *cur ;
  while ( *prv) {
    cur = *prv;
    if ( st_sam (cur->Anam, nam)) {
      return ( cur); }
    prv = &cur->Psuc;
  } 
  cur = me_acc ( sizeof(wsTfac));
  *prv = cur;
  st_cln (nam, cur->Anam, 15);
  return ( cur);
} 
#define Log  1
/* code -  wi_mai - WinMain */
int APIENTRY WinMain(
HANDLE ins ,
HANDLE prv ,
LPSTR cmd ,
int sho )
{ wsTctx *ctx ;
  wsTevt evt = {0};
  int hgt ;
  int wid ;
  LOG ("ws_mai");
  ctx = me_acc ( sizeof(wsTctx));
  wsPctx = evt.Pctx = ctx;
  ctx->Hins = ins;
  ctx->Hprv = prv;
  ctx->Pcmd = cmd;
  ctx->Vsho = sho;
  ctx->Vclr = 1;
  gr_fnt (&evt, 0);
  hgt = ws_int (&evt, wsDTH);
  wid = ws_int (&evt, wsDTW);
  ctx->Vlft = wid/8;
  ctx->Vtop = hgt/8;
  ctx->Vwid = wid/6;
  ctx->Vhgt = hgt/6;
  LOG ("ws_mai -> wc_mai");
  wc_mai (&evt);
  LOG ("ws_mai -> wi_app");
  if( !prv && !wi_app (ctx))return 0;
  LOG ("ws_mai -> wi_ins");
  if( !wi_ins (ctx))return 0;
  evt.Hwnd = ctx->Hwnd;
  LOG ("ws_mai -> wc_bld");
  wc_bld (&evt, cmd);
  LOG ("ws_mai -> ws_upd");
  ws_upd (&evt);
  (*wsPloo) (&evt);
} 
/* code -  wi_app - init application */
#define CS1  CS_BYTEALIGNCLIENT
#define CS2  CS_HREDRAW | CS_VREDRAW
#define CS3  CS_DBLCLKS
BOOL wi_app(
wsTctx *ctx )
{ WNDCLASS cla ;
  char *nam = imPfac;
  if ( !nam) {nam = "noname" ;}
  LOGs("wi_app name=%s", nam);
  cla.style = CS1|CS2|CS3;
  cla.lpfnWndProc = wi_evt;
  cla.cbClsExtra = 0;
  cla.cbWndExtra = 4;
  cla.hInstance = ctx->Hins;
  cla.hCursor = LoadCursor (NULL, IDC_ARROW);
  cla.hbrBackground = GetStockObject (WHITE_BRUSH);
  cla.lpszMenuName = "";
  cla.lpszClassName = nam;
  if( RegisterClass (&cla))return 1;
   LOGe ("RegisterClass failed");return 0;
} 
/* code -  wi_ins - init instance */
#define WS1  WS_VSCROLL|WS_HSCROLL
#define WS2  WS_MINIMIZEBOX|WS_MAXIMIZEBOX|WS_THICKFRAME
#define WS3  WS_OVERLAPPED
#define WS4  WS_CAPTION|WS_SYSMENU
BOOL wi_ins(
wsTctx *ctx )
{ HWND wnd ;
  char *nam = imPfac;
  int lft ;
  int top ;
  int sho ;
  int sty = WS2 | WS3 | WS4;
  char *cla ;
  if ( !nam) {nam = "noname" ;}
  cla = nam;
  switch ( ctx->Vsty) {
  case wsBOX:
    sty = WS_POPUPWINDOW;
     }
  LOGs("wi_ins name=%s", nam);
  LOGv("wi_ins Han=%x", ctx->Hins);
  wnd = CreateWindow (cla, nam, sty,ctx->Vlft, ctx->Vtop, ctx->Vwid, ctx->Vhgt,NULL, NULL, ctx->Hins, NULL);
  if ( !wnd) {LOGe("wi_ins CreateWindow failed") ;}
  LOGv("wi_ins wnd=%x", wnd);
  if( !wnd)return 0;
  ctx->Hwnd = wnd;
  if ( ctx->Vmin) {sho = SW_MINIMIZE ;} else {
    sho = ctx->Vsho ; }
  ShowWindow (wnd, sho);
  UpdateWindow (wnd);
  return 1;
} 
/* code -  ws_loo - server driven message loop */
static int wi_dis (MSG *);
int ws_loo(
wsTevt *evt )
{ MSG msg ;
  while ( GetMessage (&msg, NULL, 0,0)) {
    wi_dis (&msg);
  } 
  return ( 0);
} 
/* code -  wi_dis - dispatch message */
wi_dis(
MSG *msg )
{ TranslateMessage (msg);
  DispatchMessage (msg);
  return 1;
} 
/* code -  ws_pee - peek at a message */
ws_pee(
wsTevt *evt ,
int wai )
{ MSG msg ;
  if ( !wai) {
    if( (PeekMessage (&msg, NULL, 0, 0, PM_REMOVE)) == 0)return ( 0 );
    } else {
    if( (GetMessage (&msg,NULL, 0, 0)) == 0){ wc_exi (evt) ; return 0;} }
  wi_dis (&msg);
  return 1;
} 
/* code -  wi_evt - windows event (WindowProc) */
LRESULT CALLBACK wi_evt(
HWND wnd ,
UINT msg ,
WPARAM wrd ,
LPARAM lng )
{ wsTctx *ctx = ws_ctx ();
  wsTfac *fac = ctx->Pfac;
  HWND chd = ctx->Hchd;
  POINT pnt ;
  wsTevt evt ;
  int res ;
  evt.Pctx = ctx;
  evt.Hwnd = wnd;
  evt.Vmsg = msg;
  evt.Vwrd = wrd;
  evt.Vlng = lng;
  if ( ctx) {
    if( wc_evt (&evt))return 0;
    if ( wsPwav) {
      if( (*wsPwav) (&evt))return 0; }
    if ( wsPmou && (*wsPmou)(&evt)) {
       wc_mou (&evt);return 0; }
  } 
  while ( fac) {
    if ( fac->Past) {
      if( ((*fac->Past)(&evt, fac)) != 0)return 0; }
    fac = fac->Psuc;
  } 
  switch ( msg) {
  case WM_MOVE:
    ctx->Vlft = LOWORD (lng);
    ctx->Vtop = HIWORD (lng);
   break; case WM_SIZE:
    ctx->Vwid = LOWORD (lng);
    ctx->Vhgt = HIWORD (lng);
     }
  switch ( msg) {
  case WM_KEYDOWN:
   break; case WM_COMMAND:
     wc_cmd (&evt);return 0;
   break; case WM_DROPFILES:
    LOGv("Dropfile %x", wsPdrp);
    if( *wsPdrp){ (*wsPdrp)(&evt) ; return 0;}
    LOG("Dropfile done");
   break; case WM_CREATE:
    LOG ("WM_CREATE -> wc_cre");
    wc_cre (&evt);
    LOG ("WM_CREATE done");
    return 0;
   break; case WM_PAINT:
    if( wc_pnt (&evt))return 0;
   break; case WM_CLOSE:
    wc_exi (&evt);
    ws_exi (&evt);
   break; case WM_QUIT:
  case WM_DESTROY:
     wc_exi (&evt);return 0;
   break; case WM_TIMER:
    if ( ctx->Ptim) {
      (*ctx->Ptim)(&evt); }
    return 0;
   break; case WM_SETFOCUS:
    if( !chd)break;
    SetFocus (chd);
    return 0;
   break; case WM_SIZE:
    if( ctx->Vmin)return 0;
    if( !chd)break;
    MoveWindow (chd, 0, 0, LOWORD(lng), HIWORD(lng), 1);
    return 0;
     }
  return ( DefWindowProc (wnd, msg, wrd, lng));
} 
/* code -  ws_upd - force update */
HBRUSH grHbru = 0;
HPEN grHpen = 0;
ws_upd(
wsTevt *evt )
{ wsTctx *ctx ;
  LOG ("ws_upd");
  if( !evt)return 0;
  ctx = wsPctx;
  InvalidateRect (ctx->Hwnd, NULL, ctx->Vclr);
  return 1;
} 
gr_syn(
wsTevt *evt )
{ wsTctx *ctx = evt->Pctx;
  MSG msg ;
  int res ;
  RedrawWindow (evt->Hwnd, NULL, NULL, RDW_ERASENOW);
  for(;;)  {
    if( (res = GetMessage (&msg,NULL,0,0)) == 0)break;
    if( msg.message == WM_PAINT)break;
    DefWindowProc (msg.hwnd, msg.message,msg.wParam, msg.lParam);
  } 
  return 1;
} 
int gr_beg(
wsTevt *evt )
{ wsTctx *ctx = wsPctx;
  HWND wnd = ctx->Hwnd;
  HDC dev ;
  TEXTMETRIC met ;
  LOG ("gr_beg");
  if ( evt->Vmsg != WM_PAINT) {
    gr_syn (evt); }
  ctx->Vpnt = 0;
  evt->Hdev = dev = (BeginPaint (wnd, &evt->Ipnt));
  SelectObject (dev, (GetStockObject (OEM_FIXED_FONT)));
  return 1;
} 
int gr_end(
wsTevt *evt )
{ LOG ("gr_end");
  if ( grHbru) {DeleteObject (grHbru) ;}
  if ( grHpen) {DeleteObject (grHpen) ;}
  grHbru = 0;
  grHpen = 0;
  EndPaint (evt->Hwnd, &evt->Ipnt);
  return 1;
} 
/* code -  gr_pol - draw polyline */
gr_pol(
wsTevt *evt ,
long *seg ,
int cnt )
{ HDC dev = evt->Hdev;
  Polyline (dev, (POINT *)seg, cnt);
  return 1;
} 
/* code -  gr_ppl - poly polyline */
gr_ppl(
wsTevt *evt ,
long *seg ,
ULONG *sec ,
int cnt )
{ HDC dev = evt->Hdev;
  while ( cnt--) {
    gr_pol (evt, seg, *sec);
    seg += *sec++ * 2;
  } 
  return 1;
} 
/* code -  gr_txt - text out */
gr_txt(
wsTevt *evt ,
int x ,
int y ,
char *str )
{ HDC dev = evt->Hdev;
  if ( (nat )(evt->Pctx) < 100) {
    ws_dec ("x: evt->Pctx", (int )evt->Pctx);
    } else {
    TextOut (dev, x, y, str, st_len (str));
  } 
  return 1;
} 
/* code -  gr_col - select colours */
gr_col(
wsTevt *evt ,
int pap ,
int ink )
{ HBRUSH han ;
  if ( pap != -1) {SetBkColor (evt->Hdev, PALETTEINDEX(pap)) ;}
  if( ink == -1)return 1;
  SetTextColor (evt->Hdev, PALETTEINDEX(ink));
  return 1;
} 
/* code -  gr_fnt - setup font metrics */
int gr_fnt(
wsTevt *evt ,
int fnt )
{ wsTctx *ctx = evt->Pctx;
  RECT rec = {0};
  HDC dev = CreateEnhMetaFile (NULL,NULL,&rec,NULL);
  HENHMETAFILE han ;
  TEXTMETRIC met ;
  db_clr ();
  SelectObject (dev, (GetStockObject (OEM_FIXED_FONT)));
  db_lst ("SelectObject");
  GetTextMetrics (dev, &met);
  db_lst ("GetTextMetrics");
  ctx->Vchh = met.tmHeight;
  ctx->Vchw = met.tmMaxCharWidth;
  han = CloseEnhMetaFile (dev);
  DeleteEnhMetaFile (han);
  return 1;
} 
/* code -  ws_msg - windows message */
#include "m:\rid\wsmsg.h"
#include "m:\rid\imdef.h"
ws_msg(
char *msg ,
char *obj )
{ char bod [128];
  int typ = wmbOC_;
  int res ;
  switch ( *msg) {
  case 'I':
    typ |= wmbINFO_;
   break; case 'F':
  case 'E':
    typ |= wmbERROR_;
   break; case 'W':
    typ |= wmbWARN_;
   break; case 'Q':
    typ = wmbQUERY_|wmbYNC_;
   break; default: 
    typ |= wmbWARN_;
     }
  if ( *msg && msg[1] == '-') {
    msg += 2; }
  FMT (bod, msg, obj);
  res = (MessageBox (0, bod, imPfac, typ));
  if (( res == IDCANCEL)
  &&(typ != (wmbQUERY_|wmbYNC_))) {
    im_exi (); }
  return ( res);
} 
/* code -  ws_pch - duplicate PUTCHAR function */
static char wsApch [84];
static int wsVpch = 2;
void ws_pch(
int cha )
{ char *buf = wsApch;
  int idx = wsVpch;
  if (( cha >= 32)
  &&(cha <= 127)) {
    buf[idx] = cha; }
  if (( cha == '\n')
  ||(idx > 82)) {
    buf[0] = 'I';
    buf[1] = '-';
    buf[idx] = 0;
    ws_msg (buf, "");
    idx = 2;
    } else {
    ++idx; }
  wsVpch = idx;
} 
/* code -  ws_dec - decimal message */
#include "m:\rid\opdef.h"
#include "m:\rid\stdef.h"
ws_dec(
char *msg ,
int val )
{ char buf [128];
  char *ptr = st_cop (msg, buf);
  *ptr++ = ' ';
  op_dec (val, ptr);
  MessageBox (0, buf, imPfac, wmbOK_|wmbINFO_);
  return 1;
} 
/* code -  ws_prt - printf replacement */
int wsVprt = 0;
int ws_prt(
const char *fmt ,
...)
{ char str [mxLIN*2];
  int res ;
  char *ptr = str;
  if( wsVprt)return 1;
  ++wsVprt;
  res = vsprintf(str, fmt, (va_list )&(fmt) +  sizeof(fmt));
  while ( *ptr) {ws_pch (*ptr++) ;}
  --wsVprt;
  return 1;
} 
/* code -  ws_str - string information */
char *ws_str(
wsTevt *evt ,
int cod )
{ wsTctx *ctx = wsPctx;
  switch ( cod) {
  case wsCMD:
    return ( ctx->Pcmd);
     }
  return 0;
} 
/* code -  ws_int - integer information */
int ws_int(
wsTevt *evt ,
int cod )
{ wsTctx *ctx = wsPctx;
  switch ( cod) {
  case wsDIH:
    return ( ctx->Vhgt);
   break; case wsDIW:
    return ( ctx->Vwid);
   break; case wsDSX:
    return ( ctx->Vlft);
   break; case wsDSY:
    return ( ctx->Vtop);
   break; case wsDTH:
    return ( GetSystemMetrics (SM_CYFULLSCREEN));
   break; case wsDTW:
    return ( GetSystemMetrics (SM_CXFULLSCREEN));
   break; case wsCLR:
    return ( ctx->Vclr);
   break; case wsMIN:
    return ( ctx->Vmin);
   break; case wsSTY:
    return ( ctx->Vsty);
   break; case wsCLA:
    return ( ctx->Vcla);
   break; case wsCHH:
    return ( ctx->Vchh);
   break; case wsCHW:
    return ( ctx->Vchw);
     }
  return 0;
} 
/* code -  ws_set - set things for client */
ws_set(
wsTevt *evt ,
int cod ,
int val )
{ wsTctx *ctx = wsPctx;
  switch ( cod) {
  case wsDIH:
    ctx->Vhgt = val;
   break; case wsDIW:
    ctx->Vwid = val;
   break; case wsDSX:
    ctx->Vlft = val;
   break; case wsDSY:
    ctx->Vtop = val;
   break; case wsCLR:
    ctx->Vclr = val;
   break; case wsPNT:
    if ( val) {UpdateWindow (ctx->Hwnd) ;}
   break; case wsMIN:
    ctx->Vmin = val;
   break; case wsSTY:
    ctx->Vsty = val;
   break; case wsCLA:
    ctx->Vcla = val;
     }
  return 1;
} 
/* code -  ws_mov - reset window area */
ws_mov(
wsTevt *evt )
{ wsTctx *ctx = evt->Pctx;
  HWND wnd = ws_chd (evt, 0);
  wnd = evt->Hwnd;
  SetWindowPos (wnd, 0,ctx->Vlft, ctx->Vtop,ctx->Vwid, ctx->Vhgt,SWP_NOZORDER|SWP_NOACTIVATE);
  return 1;
} 
/* code -  tm_sta - start timer */
tm_sta(
wsTevt *evt ,
long per ,
wsTcal *ast )
{ wsTctx *ctx = evt->Pctx;
  ctx->Ptim = ast;
  return ( (SetTimer (ctx->Hwnd, 1, per, NULL)));
} 
/* code -  tm_stp - stop timer */
tm_stp(
wsTevt *evt )
{ wsTctx *ctx = evt->Pctx;
  KillTimer (ctx->Hwnd, 1);
} 
