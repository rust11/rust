/* file -  bmmod - bitmaps */
#include "m:\rid\rider.h"
#include "m:\rid\medef.h"
#include "m:\rid\bmdef.h"
/* code -  bm_alc - allocate a bit map */
#define RND(x,y) (((x)+(y-1))&~((y-1)))
bmTbmp *bm_alc(
bmTbmp *bmp ,
int typ ,
int x ,
int y )
{ int tot = bm_tot (typ, x, y);
  if ( !bmp) {bmp = me_acc ( sizeof(bmTbmp)) ;}
  if ( bmp->Vtot != tot) {
    bmp->Vtot = 0;
    mg_dlc (bmp->Pdat);
    if( (bmp->Pdat = (mg_alg (0,tot,meALC_))) == 0)return ( 0 ); }
  bmp->Vwid = x;
  bmp->Vhgt = y;
  bmp->Vtot = tot;
  bmp->Vtyp = typ;
  return ( bmp);
} 
/* code -  bm_dlc - deallocate bitmap */
void bm_dlc(
bmTbmp *bmp )
{ mg_dlc (bmp->Pdat);
  me_dlc (bmp);
} 
/* code -  bm_cre - create a bitmap buffer from raw data */
bmTbmp *bm_cre(
BYTE *dat ,
int wid ,
int hgt )
{ bmTbmp *bmp ;
  if( (bmp = bm_alc (NULL, bmPAL, wid, hgt)) == 0)return ( 0 );
  me_mov (dat, bmp->Pdat, wid*hgt);
  return ( bmp);
} 
/* code -  bm_tot - calculate total bytes */
int bm_tot(
int typ ,
int x ,
int y )
{ int tot = 0;
  switch ( typ) {
  case bmMON:
    tot = (RND(x,32)/8) * y;
   break; case bmPAL:
    tot = RND(x, 4) * y;
   break; case bmRGB:
    tot = x * 4 * y;
     }
  return ( tot);
} 
/* code -  bm_fil - fill bitmap area */
bm_fil(
bmTbmp *bmp ,
int x ,
int y ,
int wid ,
int hgt ,
int hue )
{ int hor ;
  int ver ;
  int maj ;
  int min ;
  BYTE *nxt ;
  ULONG *lng ;
  BYTE *byt ;
  int cnt ;
  int msk = hue | (hue<<8);
  msk |= (msk<<16);
  byt = bm_adr (bmp, x, y, &hor, &ver);
  if( !hor)return 1;
  if ( wid < hor) {hor = wid ;}
  if ( hgt < ver) {ver = hgt ;}
  maj = hor / 4;
  min = hor - (maj * 4);
  while ( ver--) {
    lng = (ULONG *)byt, cnt = maj;
    while ( cnt--) {*lng++ = msk ;}
    byt = (BYTE *)lng, cnt = min;
    while ( cnt--) {*byt++ = msk ;}
    ++hgt;
  } 
} 
/* code -  bm_adr - compute bitmap address */
void *bm_adr(
bmTbmp *bmp ,
int col ,
int row ,
int *hor ,
int *ver )
{ BYTE *dat = bmp->Pdat;
  int wid = bmp->Vwid;
  int hgt = bmp->Vhgt;
  if( col >= wid)return 0;
  if( row >= hgt)return 0;
  dat += (row * bmp->Vwid) + col;
  if ( hor) {*hor = bmp->Vwid - col ;}
  if ( ver) {*ver = bmp->Vwid - col ;}
  return ( dat);
} 
