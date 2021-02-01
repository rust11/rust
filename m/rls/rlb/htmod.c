/* file -  htmod - hash tree */
#include "m:\rid\rider.h"
#include "m:\rid\htdef.h"
#include "m:\rid\imdef.h"
#include "m:\rid\medef.h"
#include "m:\rid\stdef.h"
#define htCsho  TRUE
#define htTopr struct htTopr_t 
struct htTopr_t
{ char *Pnam ;
  htTnod *(*Proo );
  htTnod *Pnod ;
  int Vhsh ;
   };
#define htCroo  128
#define htCsli  4
htTnod *(*htPfor )= NULL;
char *htPnam = NULL;
int htVdup = 0;
int htVcla = 0;
int htVins = 0;
int htVdep = 0;
int htVini = 0;
static htTnod *ht_new (htTopr *);
static void ht_hsh (htTopr *,char *);
#define _htFOR  "F-(htmod)-No room for forest"
#define _htSTR  "F-(htmod)-String area full [%s]"
#define _htNAM  "F-(htmod)-Name table full [%s]"
/* code -  ht_ini - initialize structures */
int ht_ini()
{ if( htVini != 0)return 1;
  if ( (me_apc (&(void *)htPfor, htCroo *  sizeof(htTnod *))) == 0) {im_rep (_htFOR, NULL) ;}
  htVini = 1;
  return 1;
} 
/* code -  ht_nam - get name pointer */
char *ht_nam(
register htTnod *nod )
{ return ( (!nod) ? NULL: nod->Pnam);
} 
/* code -  ht_sym - get symbol pointer */
void *ht_sym(
register htTnod *nod )
{ return ( (!nod) ? NULL: nod->Psym);
} 
/* code -  ht_set - set symbol pointer */
void ht_set(
register htTnod *nod ,
register void *sym )
{ if( nod == NULL)return;
  nod->Psym = sym;
} 
/* code -  ht_new - allocate new node */
static htTnod *ht_new(
htTopr *opr )
{ register htTnod *nod ;
  ++htVins;
  if ( (nod = me_alc (sizeof (htTnod))) == NULL) {im_rep (_htNAM, htPnam) ;}
  nod->Vhsh = opr->Vhsh;
  nod->Plft = NULL;
  nod->Prgt = NULL;
  nod->Psym = NULL;
  if ( (nod->Pnam = st_dup (opr->Pnam)) == NULL) {im_rep (_htSTR, opr->Pnam) ;}
  return ( nod);
} 
/* code -  ht_hsh - hash name */
void ht_hsh(
htTopr *opr ,
register char *nam )
{ register int roo = 0;
  register int tmp = 0;
  if ( htVini == 0) {ht_ini () ;}
  opr->Pnam = nam;
  opr->Vhsh = 0;
  opr->Pnod = NULL;
  while ( *nam) {
    roo = (roo << 1) ^ *nam;
    tmp = *nam++ & 0377;
    if ( *nam) {
      roo = (roo << 1) ^ *nam;
      tmp |= *nam++ << 7;
      } else {
      tmp = -(tmp | (*opr->Pnam << 7)); }
    opr->Vhsh ^= (opr->Vhsh+tmp);
  } 
  opr->Proo = htPfor + ((roo >> htCsli) & (htCroo - 1));
} 
/* code -  ht_ins - insert name in tree */
static htTnod *ht_sea (htTopr *,htTnod *);
htTnod *ht_ins(
register char *nam )
{ htTopr opr ;
  ht_hsh (&opr, nam);
  *opr.Proo = ht_sea (&opr, *opr.Proo);
  return ( opr.Pnod);
} 
/* code -  ht_sea - search tree */
htTnod *ht_sea(
register htTopr *opr ,
register htTnod *nod )
{ register int dir ;
  if ( nod == NULL) {
    return ( (opr->Pnod = ht_new (opr))); }
  if ( (dir = opr->Vhsh - nod->Vhsh) == 0) {
    if ( (st_cmp (opr->Pnam, nod->Pnam)) == 0) {
      ++htVdup;
      return ( (opr->Pnod = nod)); }
    ++htVcla; }
  if ( dir > 0) {
    nod->Plft = ht_sea (opr, nod->Plft);
    } else {
    nod->Prgt = ht_sea (opr, nod->Prgt); }
  return ( nod);
} 
/* code -  ht_fnd - find name in tree */
htTnod *ht_fnd(
char *nam )
{ register htTnod *nod ;
  register int dir ;
  htTopr opr ;
  ht_hsh (&opr, nam);
  nod = *opr.Proo;
  for(;;)  {
    if( nod == NULL)return ( NULL );
    ++htVdep;
    if ( (dir = opr.Vhsh - nod->Vhsh) == 0) {
      if( (st_cmp (opr.Pnam,nod->Pnam)) == 0)return ( nod ); }
    if ( dir > 0) {nod = nod->Plft ;} else {
      nod = nod->Prgt ; }
  } 
} 
/* code -  ht_wlk - walk thru tree */
static void ht_stp (htTnod *,htTcbk *);
void ht_wlk(
htTcbk *fun )
{ register int roo = 0;
  ht_ini ();
  while ( roo < htCroo) {
    ht_stp (htPfor [roo++], fun); }
} 
/* code -  ht_stp - next step in walk */
void ht_stp(
register htTnod *nod ,
htTcbk *fun )
{ if( nod == NULL)return;
  ht_stp (nod->Plft, fun);
  ht_stp (nod->Prgt, fun);
  (*fun)(nod);
} 
