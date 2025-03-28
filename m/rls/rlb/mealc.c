/* file -  mealc - memory allocation */
#include <stdlib.h>
#include "m:\rid\rider.h"
#include "m:\rid\imdef.h"
#include "m:\rid\medef.h"
/* code -  me_apc - memory allocate via pointer & clear */
int me_apc(
void *(*ptr ),
size_t siz )
{ 
  return ( (*ptr = (me_alg (*ptr, siz, meCLR_))) != NULL);
} 
/* code -  me_alp - memory allocate via pointer */
int me_alp(
void *(*ptr ),
size_t siz )
{ 
  return ( (*ptr = (me_alg (*ptr, siz, 0))) != NULL);
} 
/* code -  me_dlp - deallocate memory via pointer */
void me_dlp(
void *(*ptr ))
{ if( ptr == NULL || *ptr == NULL)return;
  free (*ptr);
  *ptr = NULL;
} 
/* code -  me_alc - memory allocate */
void *me_alc(
size_t siz )
{ 
  return ( (me_alg (NULL, siz, 0)));
} 
/* code -  me_acc - memory allocate & clear */
void *me_acc(
size_t siz )
{ 
  return ( (me_alg (NULL, siz, meCLR_)));
} 
/* code -  me_ral - reallocate memory */
void *me_ral(
void *bas ,
size_t siz )
{ return ( me_alg (bas, siz, 0));
} 
/* code -  me_alg - allocate generic */
void *me_alg(
void *bas ,
size_t siz ,
int mod )
{ if ( bas == NULL) {
    if( !siz)return 0;
    bas = malloc (siz);
    } else {
    if( !siz){ free (bas) ; return 0;}
    bas = realloc (bas, siz); }
  if ( bas == NULL) {
    if( mod & meALC_)return ( NULL );
    im_rep ("F-Memory exhausted", NULL); }
  if ( mod & meCLR_) {me_clr (bas, siz) ;}
  return ( bas);
} 
/* code -  me_dlc - deallocate memory */
void me_dlc(
void *bas )
{ if( bas == NULL)return;
  free (bas);
} 
/* code -  me_dup - duplicate object */
void *me_dup(
void *src ,
size_t siz )
{ void *dst = me_alc (siz);
  me_cop (src, dst, siz);
  return ( dst);
} 
/* code -  me_ulk - unlock object */
void *me_ulk(
void *bas )
{ return ( bas);
} 
/* code -  me_lck - lock object */
void *me_lck(
void *bas )
{ return ( bas);
} 
#if Win
#include <windows.h>
#define mgSIG  0xf0f0f0f0
#define mgTblk struct mgTblk_t 
struct mgTblk_t
{ long Vsig ;
  HGLOBAL Hhan ;
  mgTblk *Ploc ;
  mgTblk *Pglb ;
   };
static mgTblk *mg_loc (void *);
/* code -  mg_alc - global memory allocate */
void *mg_alc(
size_t siz )
{ 
  return ( (mg_alg (NULL, siz, 0)));
} 
/* code -  mg_acc - global memory allocate & clear */
void *mg_acc(
size_t siz )
{ 
  return ( (mg_alg (NULL, siz, meCLR_)));
} 
/* code -  mg_ral - global reallocate memory */
void *mg_ral(
void *bas ,
size_t siz )
{ return ( mg_alg (bas, siz, 0));
} 
/* code -  mg_dup - duplicate object */
void *mg_dup(
void *src ,
size_t siz )
{ void *dst = mg_alc (siz);
  me_cop (src, dst, siz);
  return ( dst);
} 
/* code -  mg_alg - global allocate generic */
void *mg_alg(
void *bas ,
size_t siz ,
int mod )
{ mgTblk *loc = NULL;
  char *dat ;
  HGLOBAL han = 0;
  HGLOBAL *ptr ;
  nat atr = GMEM_MOVEABLE|GMEM_SHARE;
  if ( mod & meCLR_) {atr |= GMEM_ZEROINIT ;}
  for(;;)  {
    if ( bas == NULL) {
      if( (loc = me_alg (NULL,  sizeof(mgTblk), meALC_|meCLR_)) == 0)break;
      if( (han = GlobalAlloc (atr, siz +  sizeof(mgTblk))) == 0)break;
      } else {
      if( (loc = mg_loc (bas)) == 0)break;
      mg_flt (loc);
      han = loc->Hhan;
      if( (han = GlobalReAlloc (han, atr, siz)) == 0)break; }
    loc->Vsig = mgSIG;
    loc->Hhan = han;
    loc->Ploc = loc;
    if( (dat = mg_lck (loc + 1)) == 0)break;
    return ( dat);
   break;} 
  me_dlc (loc);
  if( mod & meALC_)return ( NULL );
  im_rep ("F-Global memory exhausted",NULL);
  return 0;
} 
/* code -  mg_dlc - global deallocate memory */
int mg_dlc(
void *bas )
{ mgTblk *loc ;
  if( (loc = mg_loc (bas)) == 0)return 1;
  mg_flt (bas);
  me_dlc (loc->Ploc);
  return ( GlobalFree (loc->Hhan) == NULL);
} 
/* code -  mg_ulk - unlock global block */
void *mg_ulk(
void *bas )
{ mgTblk *loc = mg_loc (bas);
  if( !loc)return 0;
  if ( (GlobalUnlock (loc->Hhan)) == 0) {loc->Pglb = NULL ;}
  return ( loc + 1);
} 
/* code -  mg_lck - lock global block */
void *mg_lck(
void *bas )
{ mgTblk *loc = mg_loc (bas);
  mgTblk *glb ;
  if( !loc)return 0;
  if( (glb = GlobalLock (loc->Hhan)) == 0)return ( 0 );
  glb->Vsig = mgSIG;
  glb->Ploc = loc;
  loc->Pglb = glb;
  return ( glb + 1);
} 
/* code -  mg_fix - fix in memory */
void *mg_fix(
void *bas )
{ mgTblk *loc = mg_loc (bas);
  mgTblk *glb ;
  if( !loc)return 0;
  if( loc->Pglb)return ( loc->Pglb );
  return ( mg_lck (bas));
} 
/* code -  mg_flt - float object */
void *mg_flt(
void *bas )
{ mgTblk *loc = mg_loc (bas);
  int cnt = 100;
  if( !loc)return 0;
  while ( cnt--) {
    mg_ulk (bas);
    if( !loc->Pglb)break;
  } 
  return ( loc + 1);
} 
/* code -  mg_loc - get local block */
static mgTblk *mg_loc(
void *bas )
{ mgTblk *blk ;
  if( !bas)return 0;
  blk = ((mgTblk *)bas) - 1;
  if ( blk->Vsig != mgSIG) {
    im_rep ("I-Invalid global memory block", NULL);
    return 0; }
  return ( blk->Ploc);
} 
#endif 
