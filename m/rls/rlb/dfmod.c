/* file -  dfmod - user definitions */
#include <stdio.h>
#include "m:\rid\rider.h"
#include "m:\rid\imdef.h"
#include "m:\rid\dfdef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\medef.h"
#include "m:\rid\chdef.h"
#include "m:\rid\fidef.h"
#include "m:\rid\cldef.h"
/* code -  locals */
void df_str (dfTctx *,dfTdef *,char *);
int df_par (dfTctx *,char *);
int df_amb (char *,char *);
int df_cmp (char *,char *);
dfTdef *df_mak (dfTctx *,char *,char *);
void df_rep (dfTctx *,char *,char *);
#define _dfSPC  "noname.def"
#define E_Inv  "E-Invalid definition [%s]"
#define W_Opn  "W-Error opening definition file [%s]"
#define E_Rea  "E-Error reading definition file [%s]"
#define E_Cre  "E-Error creating definition file [%s]"
#define E_Wri  "E-Error writing definition file [%s]"
#define E_Cor  "E-Corrupted definition file [%s]"
#define E_Amb  "E-Abbreviated symbol is ambiguous [%s]"
/* code -  df_ctx - build definition context */
dfTctx *df_ctx(
char *spc ,
int flg )
{ dfTctx *ctx ;
  ctx = me_acc ( sizeof(dfTctx));
  ctx->Pspc = spc;
  ctx->Vflg = flg;
  ctx->Pbal = "";
  ctx->Vsep = ' ';
  ctx->Vflg |= dfINI_;
  ctx->Proo = NULL;
  if ( ctx->Popr == NULL) {ctx->Popr = ":=" ;}
  ctx->Palc = &me_acc;
  ctx->Pdlc = &me_dlc;
  ctx->Prep = &im_rep;
  if ( ctx->Pspc != 0) {df_rea (ctx) ;}
  return ( ctx);
} 
/* code -  df_dlc - deallocate the lot */
void df_dlc(
dfTctx *ctx )
{ dfTdef *def ;
  dfTdef *nxt ;
  if( ctx == 0)return;
  def = ctx->Proo;
  while ( def) {
    nxt = def->Psuc;
    df_del (ctx, def);
    def = nxt;
  } 
  me_dlc (ctx);
} 
/* code -  df_mak - make a new one */
dfTdef *df_mak(
dfTctx *ctx ,
char *nam ,
char *bod )
{ dfTdef *def ;
  def = me_acc ( sizeof(dfTdef));
  def->Pnam = st_dup (nam);
  def->Pbod = st_dup (bod);
  ctx->Vflg |= dfMOD_;
  return ( def);
} 
/* code -  df_del - delete one */
void df_del(
dfTctx *ctx ,
dfTdef *def )
{ me_dlc (def->Pnam);
  me_dlc (def->Pbod);
  me_dlc (def);
  ctx->Vflg |= dfMOD_;
} 
/* code -  df_def - parse definition */
int df_def(
dfTctx *ctx ,
char *lin )
{ 
  if( (df_par (ctx, lin)) == 0)return ( 0 );
  if ( ctx->Vflg & dfMOD_) {
    return ( df_wri (ctx)); }
  return 1;
} 
/* code -  df_loo - lookup definition */
dfTdef *df_loo(
dfTctx *ctx ,
char *str )
{ dfTdef *def ;
  char nam [mxLIN];
  st_cop (str, nam);
  st_trm (nam);
  def = ctx->Proo;
  if ( (ctx->Vflg & dfCAS_) != 0) {
    while ( def != NULL) {
      if( (st_sam (nam, def->Pnam)) != 0)return ( def );
      def = def->Psuc;
    } 
    } else {
    st_low (nam);
    while ( def != NULL) {
      if( (cl_mat (nam, def->Pnam)) > 0)return ( def );
      def = def->Psuc;
    }  }
  return ( NULL);
} 
/* code -  df_nth - n'th definition */
dfTdef *df_nth(
dfTctx *ctx ,
int nth )
{ dfTdef *def ;
  def = ctx->Proo;
  while ( def != NULL) {
    if( nth-- == 0)return ( def );
    def = def->Psuc;
  } 
  return ( NULL);
} 
/* code -  df_lst - list definitions */
void df_lst(
dfTctx *ctx )
{ char lin [mxLIN];
  dfTdef *def = ctx->Proo;
  while ( def != NULL) {
    df_str (ctx, def, lin);
    fputs (lin, stderr);
    def = def->Psuc;
  } 
} 
/* code -  df_str - definition to string */
void df_str(
dfTctx *ctx ,
dfTdef *def ,
char *lin )
{ st_cop (def->Pnam, lin);
  st_app (" ", lin);
  st_app (ctx->Popr, lin);
  st_app (" ", lin);
  st_app (def->Pbod, lin);
  st_app ("\n", lin);
} 
/* code -  df_rea - read definition file */
int df_rea(
dfTctx *ctx )
{ FILE *fil ;
  char lin [mxLIN];
  char *spc = ctx->Pspc;
  int fst = 1;
  if( ctx->Vflg & dfMEM_)return 1;
  if ( (fil = fi_opn (spc, "r", NULL)) == NULL) {
    if( ctx->Vflg & dfEPH_)return 1;
     df_rep (ctx, W_Opn, spc);return 0; }
  ctx->Vflg |= dfREA_;
  ctx->Vflg &= ~(dfMRK_);
  for(;;)  {
    if( (fi_get (fil, lin, mxLIN)) == EOF)break;
    if( *lin == 0)continue;
    if( *lin == ';')continue;
    if ( st_fnd (ctx->Popr, lin) == NULL) {
       df_rep (ctx, E_Cor, spc);break; }
    df_par (ctx, lin);
  } 
  if ( (fi_clo (fil, NULL)) == 0) {df_rep (ctx, E_Rea, spc) ;}
  ctx->Vflg &= ~(dfREA_);
  if( (ctx->Vflg & dfMRK_) == 0)return 1;
   df_rep (ctx, ctx->Pmsg, ctx->Aobj);return 0;
} 
/* code -  df_wri - write definitions */
int df_wri(
dfTctx *ctx )
{ FILE *fil ;
  char lin [mxLIN];
  char *spc = ctx->Pspc;
  dfTdef *def = ctx->Proo;
  if( ctx->Vflg & (dfMEM_|dfSTA_))return 1;
  if ( (fil = fi_opn (spc, "w", NULL)) == NULL) {
     df_rep (ctx, E_Cre, spc);return 0; }
  while ( def != NULL) {
    df_str (ctx, def, lin);
    fi_put (fil, lin);
    def = def->Psuc;
  } 
  if( fi_clo (fil, NULL))return 1;
   df_rep (ctx, E_Wri, spc);return 0;
} 
/* code -  df_par - parse & insert */
int df_par(
dfTctx *ctx ,
char *str )
{ char nam [mxLIN];
  char *bod ;
  st_cop (str, nam);
  if ( (bod = st_fnd (ctx->Popr, nam)) == NULL) {
     df_rep (ctx, E_Inv, nam);return 0; }
  *bod = 0;
  bod += 2;
  return ( (df_ins (ctx, nam, bod)));
} 
/* code -  df_ins - insert definition */
int df_ins(
dfTctx *ctx ,
char *nam ,
char *bod )
{ dfTdef *def ;
  dfTdef *(*pre );
  dfTdef *ent ;
  if ( (ctx->Vflg & dfCAS_) == 0) {
    st_low (nam); }
  st_trm (nam);
  st_trm (bod);
  def = ctx->Proo;
  while ( def != NULL) {
    if ( df_amb (nam, def->Pnam)) {
      df_rep (ctx, E_Amb, nam);
      return 0; }
    def = def->Psuc;
  } 
  pre = &ctx->Proo;
  for(;;)  {
    if( (def = *pre) == NULL)break;
    if( df_cmp (def->Pnam, nam) >= 0)break;
    pre = &def->Psuc;
  } 
  if (( def != NULL)
  &&(df_cmp (def->Pnam, nam) == 0)) {
    if (( st_sam (def->Pnam, nam))
    &&(st_sam (def->Pbod, bod))) {
      return 1; }
    *pre = def->Psuc;
    df_del (ctx, def);
    if( *bod == 0)return 1; }
  ent = df_mak (ctx, nam, bod);
  ent->Psuc = *pre;
  *pre = ent;
  return 1;
} 
/* code -  df_amb - check ambiguous */
int df_amb(
char *lft ,
char *rgt )
{ if( df_cmp (lft, rgt) == 0)return 0;
  if (( st_mem ('*', lft) == 0)
  &&(st_mem ('*', rgt) == 0)) {
    return 0; }
  for(;;)  {
    if( *lft == '*' || *lft == 0)return 1;
    if( *rgt == '*' || *rgt == 0)return 1;
    if( *lft != *rgt)return 0;
    ++lft, ++rgt;
  } 
} 
/* code -  df_cmp - compare without stars */
int df_cmp(
char *lft ,
char *rgt )
{ for(;;)  {
    if ( *lft == '*') {++lft ;}
    if ( *rgt == '*') {++rgt ;}
    if( *lft != *rgt)break;
    if( *lft == 0)break;
    ++lft, ++rgt;
  } 
  return ( (unsigned char )*lft - (unsigned char )*rgt);
} 
/* code -  df_rep - report errors */
void df_rep(
dfTctx *ctx ,
char *msg ,
char *obj )
{ ctx->Pmsg = msg;
  st_cop (obj, ctx->Aobj);
  ctx->Vflg |= dfERR_|dfMRK_;
  if( ctx->Vflg & (dfMUT_|dfREA_))return;
  (*ctx->Prep)(msg, obj);
} 
