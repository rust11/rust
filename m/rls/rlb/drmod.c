/* file -  drmod - directory access */
#include "m:\rid\medef.h"
#include "m:\rid\mxdef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\tidef.h"
#include <stdio.h>
#include <stdlib.h>
#include "m:\rid\drdef.h"
static drTent *dr_acc (drTdir *,drTent *);
static void dr_pth (char *,char *);
static int dr_srt (drTdir *);
/* code -  dr_scn - scan directory */
drTdir *dr_scn(
char *raw ,
int atr ,
int srt )
{ char *pth = me_acc (mxSPC);
  drTdir *dir = me_acc ( sizeof(drTdir));
  drTent *ent = me_acc ( sizeof(drTent));
  drTent *prv = NULL;
  dir->Ppth = pth;
  dir->Vatr = atr;
  dir->Vsrt = srt;
  dr_pth (raw, pth);
  if ( !dr_acc (dir, ent)) {
    me_dlc (ent);
    } else {
    dir->Proo = ent;
    while ( ent != NULL) {
      if ( prv) {prv->Psuc = ent ;}
      prv = ent, ++dir->Vcnt;
      ent = dr_enu (dir, NULL, 0, 1);
    } 
    dr_don (dir);
    if ( srt) {dr_srt (dir) ;} }
  return ( dir);
} 
/* code -  dr_nxt - get next entry */
drTent *dr_nxt(
drTdir *dir )
{ drTent *ent = dir->Pnxt;
  if ( ent == NULL) {ent = dir->Proo ;} else {
    ent = ent->Psuc ; }
  if( ent == NULL)return ( NULL );
  return ( (dir->Pnxt = ent));
} 
/* code -  dr_dlc - deallocate directory */
void dr_dlc(
drTdir *dir )
{ drTent *nxt ;
  drTent *cur ;
  if( dir == NULL)return;
  nxt = dir->Proo;
  while ( nxt != NULL) {
    cur = nxt, nxt = cur->Psuc;
    me_dlc (cur->Pnam);
    me_dlc (cur->Palt);
    me_dlc (cur);
  } 
  me_dlc (dir->Ppth);
  me_dlc (dir->Pext);
  me_dlc (dir);
} 
/* code -  dr_srt - sort entries */
static int dr_cmp ();
static int drVsrt = 0;
static int drVrev = 0;
static int dr_srt(
drTdir *dir )
{ drTent *(*tab );
  drTent *(*ent );
  drTent *fil ;
  int cnt = dir->Vcnt;
  size_t wid =  sizeof(drTent *);
  int chk = 0;
  if( cnt <= 0)return 1;
  if( cnt > 15000)return 0;
  if( (tab = malloc (wid * cnt)) == NULL)return 0;
  ent = tab;
  fil = dir->Proo;
  while ( fil != NULL) {
    if ( ++chk <= cnt) {
      *ent++ = fil; }
    fil = fil->Psuc;
  } 
  drVsrt = dir->Vsrt & drSRT_;
  drVrev = dir->Vsrt & drREV_;
  qsort (tab, cnt, wid, &dr_cmp);
  ent = tab;
  dir->Proo = fil = *ent++;
  while ( --cnt) {
    fil->Psuc = *ent;
    fil = *ent++;
  } 
  fil->Psuc = NULL;
  me_dlc (tab);
  return 1;
} 
/* code -  dr_cmp - compare two members */
int dr_cmp(
drTent *(*src ),
drTent *(*dst ))
{ drTent *lft = *src;
  drTent *rgt = *dst;
  char *ltp ;
  char *rtp ;
  int cmp ;
  for(;;)  {
    if( (cmp = (rgt->Vatr & drDIR_) - (lft->Vatr & drDIR_)) != 0)break;
    if ( drVsrt == drSIZ) {
      cmp = lft->Vsiz - rgt->Vsiz;
    } else if ( drVsrt == drTIM) {
      cmp = ti_cmp (&lft->Itim, &rgt->Itim); }
    if ( cmp == 0) {
      if ( drVsrt == drTYP) {
        if ( (ltp = st_fnd (".", lft->Pnam)) == NULL) {ltp = "" ;}
        if ( (rtp = st_fnd (".", rgt->Pnam)) == NULL) {rtp = "" ;}
        cmp = st_cmp (ltp, rtp);
        if( cmp != 0)break; }
      cmp = st_cmp (lft->Pnam, rgt->Pnam); }
   break;} 
  return ( (drVrev) ? -cmp: cmp);
} 
/* code -  dr_acc - access first file */
static drTent *dr_acc(
drTdir *dir ,
drTent *ent )
{ char *pth = dir->Ppth;
  int atr = dir->Vatr | drFST_;
  drTent *nxt ;
  char *ptr ;
  int wld = 0;
  if ( (ptr = st_fnd (":", pth)) != 0) {
    if ( st_cmp (":\\", ptr) == 0) {
      st_app ("*.*", pth); } }
  if (( (ptr = st_fnd ("\\.",pth)) != 0)
  ||((ptr = st_fnd (":.", pth)) != 0)) {
    st_ins ("*", ptr+1); }
  if ( *(ptr = st_lst (pth)) == '.') {
    st_app ("*", pth);
  } else if ( *ptr == ':') {
    st_app ("\\*.*", pth);
  } else if ( *ptr == '\\') {
    st_app ("*.*", pth); }
  if ( st_mem ('*', pth)) {++wld ;}
  if ( st_mem ('?', pth)) {++wld ;}
  if ( wld && !st_mem ('.', pth)) {
    st_app (".*",pth); }
  if ( (nxt = dr_enu (dir, ent, atr|drDIR_, 0)) == NULL) {
    if ( !st_mem ('.', pth)) {
      st_app (".*", pth);
      nxt = dr_enu (dir, ent, atr, 0); }
    } else {
    if ( (nxt->Vatr & drDIR_) && !wld) {
      st_app ("\\*.*", pth);
      nxt = dr_enu (dir, ent, atr, 0); } }
  if( nxt == 0)return ( NULL );
  if (( nxt->Vatr & drDIR_)
  &&((atr & drDIR_) == 0)) {
    nxt = dr_enu (dir, ent, atr, 1); }
  return ( nxt);
} 
/* code -  dr_pth - work out path */
void dr_pth(
char *spc ,
char *pth )
{ char buf [mxSPC];
  char *src = buf;
  char *drv = pth;
  *src = 0;
  fi_loc (spc, src);
  st_low (src);
  *pth = 0;
  if ( *st_lst (src) == ':') {
    st_cop (src, pth);
    st_app ("\\", pth);
    return;
  } else if ( !st_fnd (":", src)) {
    if ( *src == '\\') {
      dr_sho (pth, drDRV);
      pth = st_end (pth);
      } else {
      dr_sho (pth, drPTH);
      if ( *st_lst (pth) != '\\') {
        st_app ("\\", pth); }
      pth = st_end (pth); }
    } else {
    while ( *src != ':') {*pth++ = *src++ ;}
    *pth++ = *src++;
    if ( *src != '\\') {*pth++ = '\\' ;} }
  st_cop (src, pth);
} 
/* code -  dr_spc - form full file spec */
char *dr_spc(
char *pth ,
char *nam ,
char *spc )
{ char *lst ;
  st_cop (pth, spc);
  st_low (spc);
  *st_par ("pe","\\", spc) = 0;
  if ( nam != NULL) {
    return ( st_app (nam, spc)); }
  lst = st_lst (spc);
  if (( *lst == '\\')
  &&(lst != spc)
  &&(lst[-1] != ':')
  &&(lst[-1] != '\\')) {
    *lst = 0; }
  return ( lst);
} 
/* code -  dr_mat - match directory file */
dr_mat(
drTdir *dir ,
char *nam )
{ char buf [256];
  char *mod = st_par ("pb", ":\\", dir->Ppth);
  st_cop (nam, buf);
  if ( st_idx ('.', buf) < 0) {st_app (".", buf) ;}
  return ( st_wld (mod, buf));
} 
/* code -  dr_roo - determines if spec is root directory */
dr_roo(
char *spc )
{ char pth [mxSPC];
  dr_spc (spc, NULL, pth);
  if( st_sam (pth, "\\"))return 1;
  if( st_sam (pth+1, ":\\"))return 1;
  return 0;
} 
