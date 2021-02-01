/* file -  bsmod - bitmap sections */
#include "m:\rid\wsdef.h"
#include "m:\rid\bsdef.h"
#include "m:\rid\medef.h"
#include "m:\rid\imdef.h"
#include "m:\rid\stdef.h"
int bs_pal (wsTevt *,bsTsec *);
/* code -  bs_sho - show device */
bs_sho(
bsTsec *sec ,
HDC dev ,
char *tit )
{ char buf [512];
  int x ;
  int y ;
  st_cop ("I-", buf);
  st_app (tit, buf);
  st_app (": ", buf);
  x = GetDeviceCaps (dev, HORZRES);
  y = GetDeviceCaps (dev, VERTRES);
  FMT(st_end(buf), "Width=%d, Height=%d\n", x, y);
  x = GetDeviceCaps (dev, SIZEPALETTE);
  FMT(st_end(buf), "Palette=%d\n", x);
  im_rep(buf, NULL);
} 
/* code -  bs_dim - get buffer dimensions */
bs_dim(
bsTsec *sec ,
int *wid ,
int *hgt )
{ if( !sec)return 0;
  *wid = sec->Vwid;
  *hgt = sec->Vhgt;
  return 1;
} 
/* code -  bs_scn - get start of scanline */
void *bs_scn(
bsTsec *sec ,
int scn )
{ if( !sec)return ( NULL );
  if( scn >= sec->Vhgt)return ( NULL );
  return ( (BYTE *)sec->Pbuf + (scn * sec->Vext));
} 
/* code -  bs_beg - begin/end paint */
HDC DDC ;
bs_beg(
wsTevt *evt ,
bsTsec *sec )
{ wsTctx *ctx = evt->Pctx;
  HWND wnd = ctx->Hwnd;
  HDC ddc ;
  ctx->Vpnt = 0;
  ddc = BeginPaint(wnd,&evt->Ipnt);
  DDC = ddc;
  if ( sec->Hpal) {SelectPalette (ddc, sec->Hpal, 0) ;}
  RealizePalette (ddc);
  evt->Hdev = sec->Hidc;
  TextOut (sec->Hidc, 10, 10, "hello", 5);
  return 1;
} 
bs_end(
wsTevt *evt ,
bsTsec *sec )
{ EndPaint (evt->Hwnd, &evt->Ipnt);
  return 1;
} 
/* code -  bs_blt - blit the section */
bs_blt(
wsTevt *evt ,
bsTsec *sec )
{ HDC ddc ;
  if( !sec)return 0;
  if ( (BitBlt(DDC, 10,10,10, 10,sec->Hidc, 10, 10, SRCCOPY)) == 0) {PUT("Blt %X\n", GetLastError()) ;}
  return 1;
} 
/* code -  bs_alc - allocate/reallocate current bitmap section */
bsTsec *bs_alc(
wsTevt *evt ,
bsTsec *sec ,
int wid ,
int hgt )
{ bsTinf *inf ;
  HBITMAP han ;
  int fst = 0;
  if ( !sec) {sec = me_acc ( sizeof(bsTsec)) ;}
  inf = &sec->Sinf;
  sec->Vwid = inf->biWidth = wid;
  sec->Vhgt = inf->biHeight = hgt;
  sec->Vext = ((wid+3)/4)*4;
  if ( !sec->Vini) {
    inf->biSize =  sizeof(bsTinf), inf->biPlanes = 1;
    inf->biBitCount = 8, inf->biCompression = BI_RGB;
    bs_pal (evt, sec);
    sec->Hidc = CreateCompatibleDC (NULL);
    if ( !sec->Hidc) {im_rep ("E-Bitmap DC create failed", NULL) ;}
    ++sec->Vini, ++fst;
  } 
  if ( sec->Vwng) {
    } else {
    han=CreateDIBSection(sec->Hidc,(BITMAPINFO *)inf,DIB_RGB_COLORS, &sec->Pbuf, NULL, 1);
  } 
  if( !han){ im_rep ("E-Bitmap Section creation failed", NULL) ; return 0;}
  inf->biSizeImage = inf->biWidth * inf->biHeight;
  if ( (han = (HBITMAP )SelectObject (sec->Hidc, han)) == 0) {im_rep ("E-Bitmap Select failed", NULL) ;}
  if ( fst) {sec->Hpre = han ;} else {
    DeleteObject (han) ; }
  PatBlt(sec->Hidc, 0,0,wid, hgt, BLACKNESS);
  return ( sec);
} 
/* code -  bs_dlc - deallocate bitmap section */
void bs_dlc(
wsTevt *evt ,
bsTsec *sec )
{ HBITMAP han ;
  if( !sec || !sec->Vini)return;
  sec->Vini = 0;
  han = (HBITMAP )SelectObject(sec->Hidc, sec->Hpre);
  DeleteObject (han);
  DeleteDC (sec->Hidc);
  me_dlc (sec->Ppal);
  if ( sec->Hpal) {DeleteObject (sec->Hpal) ;}
  me_dlc (sec);
} 
/* code -  bs_pal - create palette */
wsTfas bs_evt ;
bs_pal(
wsTevt *evt ,
bsTsec *sec )
{ LOGPALETTE *pal ;
  PALETTEENTRY *ent ;
  RGBQUAD *rgb ;
  HBITMAP bmp ;
  wsTfac *fac ;
  int cnt ;
  HDC scr ;
  if( !sec)return 0;
  if ( (pal = sec->Ppal) == 0) {
    sec->Ppal = pal = me_acc ( sizeof(LOGPALETTE) + ( sizeof(PALETTEENTRY) * 255));
    pal->palVersion = 0x300;
    pal->palNumEntries=256; }
  ent = pal->palPalEntry;
  rgb = sec->Argb;
  scr = GetDC (HWND_DESKTOP);
  GetSystemPaletteEntries (scr,0,256,ent);
  ReleaseDC (0, scr);
  for (cnt = (0); cnt<=(255); ++cnt) {
    if ( (cnt >= 10) || (cnt < 246)) {
      rgb[cnt].rgbRed = ent[cnt].peRed;
      rgb[cnt].rgbBlue = ent[cnt].peBlue;
      rgb[cnt].rgbGreen = ent[cnt].peGreen;
      rgb[cnt].rgbReserved = 0;
      ent[cnt].peFlags = PC_NOCOLLAPSE;
      } else {
      ent[cnt].peFlags = 0; }
  } 
  if ( (sec->Hpal = CreatePalette (pal)) == 0) {PUT("CreatePalette\n") ;}
  fac = ws_fac (evt, "BS_PALETTE");
  fac->Pusr = sec;
  fac->Past = bs_evt;
} 
/* code -  bs_evt - Windows event handling */
bs_evt(
wsTevt *evt ,
wsTfac *fac )
{ bsTsec *sec = fac->Pusr;
  HDC hdc ;
  if( !sec)return 0;
  if( !sec->Vini)return 0;
  switch ( evt->Vmsg) {
  case WM_PALETTECHANGED:
    PUT("Palette event\n");
    if( evt->Hwnd == (HWND )evt->Vwrd)return 0;
  case WM_QUERYNEWPALETTE:
    PUT("Palette event\n");
    if ( (hdc = GetDC (evt->Hwnd)) == 0) {PUT("1\n") ;}
    if ( sec->Hpal) {
      if ( (SelectPalette (hdc, sec->Hpal, 0)) == 0) {PUT("2\n") ;}
    } 
    if ( (RealizePalette (hdc)) == GDI_ERROR) {PUT("3 %X\n", GetLastError ()) ;}
    if ( (ReleaseDC (evt->Hwnd, hdc)) == 0) {PUT("4\n") ;}
    return 1;
     }
  return 0;
} 
