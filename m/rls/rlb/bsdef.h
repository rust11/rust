/* header bsdef - Bitmap sections */
#ifndef _RIDER_H_bsdef
#define _RIDER_H_bsdef 1
#if wsSVR
#define bsTinf  BITMAPINFOHEADER
#define bsTsec struct bsTsec_t 
struct bsTsec_t
{ int Vhgt ;
  int Vwid ;
  void *Pbuf ;
  int Vext ;
  int Vini ;
  int Vwng ;
  int Vori ;
  bsTinf Sinf ;
  RGBQUAD Argb [256];
  HDC Hidc ;
  HBITMAP Hpre ;
  HPALETTE Hpal ;
  LOGPALETTE *Ppal ;
   };
#else 
#define bsTsec  void
#endif 
bsTsec *bs_alc (wsTevt *,bsTsec *,int ,int );
void bs_dlc (wsTevt *,bsTsec *);
bs_blt (wsTevt *,bsTsec *);
void *bs_scn (bsTsec *,int );
bs_dim (bsTsec *,int *,int *);
bs_beg (wsTevt *,bsTsec *);
bs_end (wsTevt *,bsTsec *);
#endif
