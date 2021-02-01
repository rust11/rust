/* header wsdef - server module definitions */
#ifndef _RIDER_H_wsdef
#define _RIDER_H_wsdef 1
#include <windows.h>
#define wsSVR  1
#define wsTevt struct wsTevt_t 
#define wsTfac struct wsTfac_t 
typedef int wsTcal (wsTevt *);
#define wsTctx struct wsTctx_t 
struct wsTctx_t
{ HANDLE Hins ;
  HANDLE Hprv ;
  LPSTR Pcmd ;
  int Vsho ;
  HWND Hwnd ;
  int Vhgt ;
  int Vwid ;
  void *Pmen ;
  LPSTR Xcla ;
  LPSTR Xwnd ;
  LPSTR Xmen ;
  LPSTR Xico ;
  int Vpnt ;
  HCURSOR Harr ;
  HCURSOR Hhou ;
  size_t Vlft ;
  size_t Vtop ;
  wsTcal *Ptim ;
  HWND Hchd ;
  int Vclr ;
  wsTfac *Pfac ;
  int Vmin ;
  int Vsty ;
  int Vcla ;
  int Vchh ;
  int Vchw ;
  void *Pkbd ;
   };
#define wsTevt struct wsTevt_t 
struct wsTevt_t
{ HWND Hwnd ;
  UINT Vmsg ;
  UINT Vwrd ;
  ULONG Vlng ;
  HDC Hdev ;
  PAINTSTRUCT Ipnt ;
  wsTctx *Pctx ;
  HWND Hchd ;
   };
typedef int wsTfas (wsTevt *,wsTfac *);
#define wsTfac struct wsTfac_t 
struct wsTfac_t
{ wsTfac *Psuc ;
  char Anam [16];
  int Vflg ;
  wsTfas *Past ;
  void *Pusr ;
  int Vusr ;
   };
wsTctx *ws_ctx (void );
typedef int wsTcal (wsTevt *);
wsTcal *wsPmou ;
wsTcal *wsPwav ;
wsTcal *wsPdrp ;
HWND ws_chd (wsTevt *,HWND );
typedef LOGFONT wsTfnt ;
wsTfac *ws_fac (wsTevt *,char *);
#include "m:\rid\wgdef.h"
#endif
