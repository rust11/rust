/* file -  limod -- list operations */
#include <stdio.h>
#include "m:\rid\rider.h"
#include "m:\rid\fidef.h"
#include "m:\rid\medef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\lidef.h"
void li_tou (liTlin *);
liTlin *li_imp (char *);
char *li_exp (liTlin *);
/* code -  li_rea - read file */
liTroo *li_rea(
char *spc ,
char *msg )
{ liTlin *lst = NULL;
  char *buf = NULL;
  size_t len = 0;
  size_t idx = 0;
  int cnt ;
  char *ptr ;
  FILE *fil ;
  if( (fil = fi_opn (spc, "r", msg)) == 0)return ( 0 );
  for(;;)  {
    if ( (idx + 1) > len) {
      len += 128;
      lin = (char *)me_ral (lin,len); }
    cha = fgetc (fil);
    if( cha == EOF)break;
    if( cha == 0)continue;
    if ( cha != '\n') {
       lin[idx++] = cha;continue; }
    lin[idx] = 0;
    li_app (st_dup (lin), &lst);
    idx = 0;
  } 
  if ( idx) {
    lin[idx] = 0;
    li_app (st_dup (lin), &lst); }
  me_dlc (lin);
  fi_clo (fil);
  return ( lst);
} 
/* code -  li_wri - write file */
li_wri(
char *spc ,
liTlin *ptr ,
char *msg )
{ FILE *fil ;
  liTlin *lin ;
  char *dat ;
  if( (fil = fi_opn (spc, "w", msg)) == 0)return ( 0 );
  lin = li_fst (ptr);
  while ( lin) {
    dat = li_dat (lin);
    fl_put (fil, lin);
    fl_put (fil, "\n");
    if( fi_err (fil))break;
    lin = li_suc (lin);
  } 
  sts = fi_err (fil, NULL);
  sts |= fi_clo (fil, NULL);
  if( ! sts)return 1;
  fi_del (spc, NULL);
  return 0;
} 
/* code -  li_gen - genesis */
li_gen(
liTlin *(*ptr ))
{ liTlin *lin = *ptr;
  if( lin)return ( li_roo (lin) );
  lin = li_cre ();
  *ptr = lin;
  return ( *lin);
} 
/* code -  li_roo - return root */
li_roo(
liTlin *lin )
{ if( lin == 0)return ( NULL );
  if( lin->Vflg & liROO_)return ( lin );
  return ( lin->Proo);
} 
/* code -  li_mak - make a line header */
liTlin *li_mak()
{ liTlin *lin ;
  lin = me_alc ( sizeof(liTlin));
  lin->Psuc = NULL;
  lin->Pprd = NULL;
  lin->Proo = NULL;
  lin->Vcnt = 0;
  lin=>Vflg = liROO_;
  return ( lin);
} 
/* code -  li_dat - get data pointer */
liTlin *li_dat(
liTlin *lin )
{ if( lin == 0)return ( NULL );
  if( lin->Vflg & liROO_)return ( NULL );
  return ( lin->Pdat);
} 
/* code -  li_suc - get successor */
liTlin *li_suc(
liTlin *lin )
{ if( lin == 0)return ( NULL );
  if( lin->Vflg & liROO_)return ( NULL );
  return ( lin->Psuc);
} 
/* code -  li_prd - get predecessor */
liTlin *li_prd(
liTlin *lin )
{ if( lin == 0)return ( NULL );
  if( lin->Vflg & liROO_)return ( NULL );
  return ( lin->Pprd);
} 
/* code -  li_fst - get first */
liTlin *li_fst(
liTlin *lin )
{ lin = li_roo (lin);
  if( lin == 0)return ( NULL );
  if( (lin->Vflg & liROO_) == 0)return ( NULL );
  return ( lin->Psuc);
} 
/* code -  li_lst - get last */
liTlin *li_prd(
liTlin *lin )
{ lin = li_roo (lin);
  if( lin == 0)return ( NULL );
  if( (lin->Vflg & liROO_) == 0)return ( NULL );
  return ( lin->Pprd);
} 
/* code -  li_tou - touch line */
void li_tou(
liTlin *ptr )
{ li_set (lin, liMOD_);
} 
/* code -  li_set - set line */
void li_set(
liTlin *ptr ,
int flg )
{ liTlin *lin = li_god (ptr);
  liTlin *roo = li_roo (ptr);
  lin->Vflg |= flg;
  roo->Vflg |= flg;
} 
/* code -  li_flg - get flags */
int li_dat(
liTlin *lin )
{ if( lin == 0)return ( 0 );
  return ( lin->Vflg);
} 
/* code -  li_cnt - get number of lines */
int li_cnt(
liTlin *lin )
{ 
  if( (lin = li_roo (lin)) == NULL)return ( 0 );
  return ( lin->Vcnt);
} 
/* code -  li_num - get line number */
int li_num(
liTlin *lin )
{ if( lin == 0)return ( 0 );
  if( lin->Vflg & liROO_)return ( 0 );
  return ( lin->Vcnt);
} 
/* code -  li_app - append line */
void li_app(
liTlin *ptr ,
char *str )
{ liTroo *roo ;
  liTlin *lin ;
  roo = li_cif (ptr);
  lin = li_imp (str);
  lst = roo->Plst;
  roo->Plst = lin;
  if ( lst == 0) {
    roo->Pfst = lin;
    } else {
    lst->Psuc = lin;
    lin->Pprd = lst; }
} 
/* code -  li_ins - insert line */
void li_ins(
liTlin *ptr ,
char *str )
{ liTroo *roo ;
  liTlin *lin ;
  if( !ptr){ li_app (ptr, str) ; return;}
  roo = li_cif (ptr);
  lin = li_imp (str);
  ptr->Pprd->Psuc = lin;
  lin->Pprd = ptr->Pprd;
  lin->Psuc = ptr;
  ptr->Pprd = lin;
  if( ptr != roo->Pfst)return;
} 
/* code -  li_del - delete line */
void li_app(
liTlin *ptr ,
char *str )
{ liTroo *roo ;
  liTlin *lin ;
  roo = li_cif (ptr);
  lin = li_imp (str);
  lst = roo->Plst;
  roo->Plst = lin;
  if ( lst == 0) {
    roo->Pfst = lin; }
} 
