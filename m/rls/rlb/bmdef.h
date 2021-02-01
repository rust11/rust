/* header bmdef - bitmaps */
#ifndef _RIDER_H_bmdef
#define _RIDER_H_bmdef 1
#include "m:\rid\wcdef.h"
#define bmMON  1
#define bmPAL  2
#define bmRGB  3
#define bmTbmp struct bmTbmp_t 
struct bmTbmp_t
{ int Vtyp ;
  size_t Vwid ;
  size_t Vhgt ;
  size_t Vtot ;
  void *Pdat ;
  void *Hhan ;
   };
bmTbmp *bm_alc (bmTbmp *,int ,int ,int );
void bm_dlc (bmTbmp *);
int bm_tot (int ,int ,int );
bm_fil (bmTbmp *,int ,int ,int ,int ,int );
void *bm_adr (bmTbmp *,int ,int ,int *,int *);
bmTbmp *bm_cre (BYTE *,int ,int );
int bm_pnt (wsTevt *,bmTbmp *,int ,int );
int bm_imp (void *,bmTbmp *);
bm_gly (int ,bmTbmp *);
bmTbmp *bm_loa (char *,char *);
int bm_sto (bmTbmp *,char *,char *);
#endif
