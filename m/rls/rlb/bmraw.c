/* file -  bmraw -- manage raw data window */
#include "m:\rid\wsdef.h"
#include "m:\rid\imdef.h"
#define bmTinf  BITMAPINFOHEADER
#define bmTraw struct bmTraw_t 
struct bmTraw_t
{ HDC Hidc ;
  HBITMAP Hmon ;
  bmTinf Sinf ;
  void *Pbuf ;
  int Vini ;
   };
bm_siz(
wsTevt *evt ,
bmTraw *raw )
{ bmTinf *inf = &raw->Sinf;
  int wid = LOWORD (evt->Vlng);
  int hgt = HIWORD (evt->Vlng);
  HBITMAP han ;
  int fst = 0;
  inf->biWidth = wid;
  inf->biHeight = hgt;
  if ( !raw->Vini) {
    ++fst;
    inf->biSize =  sizeof(bmTinf);
    inf->biPlanes = 1;
    inf->biBitCount = 8;
    inf->biCompression = BI_RGB;
    inf->biSizeImage = 0;
    inf->biClrUsed = 0;
    inf->biClrImportant = 0;
    raw->Hidc = CreateCompatibleDC (NULL);
    ++raw->Vini;
  } 
  if ( (han = CreateDIBSection (raw->Hidc, (BITMAPINFO *)inf,DIB_PAL_COLORS, &raw->Pbuf, NULL, 0)) == 0) {
     im_rep ("E-DIB Section creation failed", NULL);return 0; }
  inf->biSizeImage = (inf->biWidth * inf->biHeight);
  raw->Hmon = (HBITMAP )SelectObject (raw->Hidc, han);
  if ( !fst) {DeleteObject (han) ;}
  PatBlt(raw->Hidc, 0,0,wid, hgt, BLACKNESS);
  return 1;
} 
/* code -  bm_exi - exit raw bmp image */
bm_exi(
wsTevt *evt ,
bmTraw *raw )
{ HBITMAP han ;
  if ( raw->Vini) {
    raw->Vini = 0;
    han = (HBITMAP )SelectObject(raw->Hidc, raw->Hmon);
    DeleteObject (han);
    DeleteDC (raw->Hidc); }
} 
