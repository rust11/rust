/* file -  lnmod - logical name routines */
#include <stdlib.h>
#include "m:\rid\rider.h"
#include "m:\rid\mxdef.h"
#include "m:\rid\dfdef.h"
#include "m:\rid\evdef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\lndef.h"
dfTctx *lnPctx = NULL;
int lnVchg = 0;
int lnVerr = 0;
dfTctx *ln_ctx()
{ if( lnVerr > lnLIM)return ( NULL );
  if ( !lnPctx) {
    lnPctx = df_ctx (_lnFIL, dfEPH_); }
  if ( lnPctx == 0) {++lnVerr ;}
  return ( lnPctx);
} 
int ln_ini()
{ return ( ln_ctx () != 0);
} 
/* code -  ln_loo - simple lookup */
char *ln_loo(
char *log )
{ dfTctx *ctx ;
  dfTdef *def ;
  if( (ctx = ln_ctx ()) == NULL)return ( NULL );
  def = ctx->Proo;
  while ( def) {
    if( st_sam (log, def->Pnam))break;
    def = def->Psuc;
  } 
  if( !def)return ( NULL );
  return ( def->Pbod);
} 
/* code -  ln_trn - full translation */
int ln_trn(
char *log ,
char *res ,
int mod )
{ char nam [mxIDT];
  char *lft ;
  char *fnd = NULL;
  int loo = 16;
  st_cln (log, nam, mxIDT-1);
  st_cln (nam, res, mxIDT-1);
  st_low (nam);
  lft = nam;
  if ( st_sam (nam, _lnLOG)) {
    if( (ev_get (_lnENV, res, mxIDT)) != 0)return ( 1 );
    st_cop (_lnDEF, res);
    return 1; }
  while ( loo--) {
    if( (lft = ln_loo (lft)) == NULL)break;
    fnd = lft;
  } 
  if( fnd == 0)return 0;
  st_cop (fnd, res);
  return 1;
} 
/* code -  ln_rev - reverse translation */
int ln_rev(
char *eqv ,
char *res ,
int nth )
{ dfTctx *ctx ;
  dfTdef *def ;
  char nam [mxIDT];
  char *fnd = NULL;
  if( (ctx = ln_ctx ()) == 0)return 0;
  st_cln (eqv, nam, mxIDT-1);
  st_low (nam);
  def = ctx->Proo;
  while ( def) {
    if ( st_sam (eqv, def->Pbod)) {
      fnd = def->Pnam;
      if( !--nth)break; }
    def = def->Psuc;
  } 
  if( nth)return 0;
  st_cop (fnd, res);
  return 1;
} 
/* code -  ln_exi - exit define/undefine sequence */
void ln_exi()
{ if ( lnVchg) {ln_upd () ;}
  if ( lnPctx) {df_dlc (lnPctx) ;}
  lnPctx = NULL;
} 
/* code -  ln_upd - update logical name table */
int ln_upd()
{ if( ! lnPctx)return;
  if( (df_wri (lnPctx)) == 0){ ++lnVerr ; return 0;}
  lnVchg = 0;
  return 1;
} 
/* code -  ln_def - define logical name */
int ln_def(
char *log ,
char *equ ,
int mod )
{ char lft [mxIDT];
  char rgt [mxIDT];
  dfTctx *ctx = ln_ctx ();
  if( ctx == 0)return 0;
  st_cln (log, lft, mxIDT-1);
  st_cln (equ, rgt, mxIDT-1);
  st_low (lft);
  st_low (rgt);
  df_ins (ctx, log, equ);
  return ( ln_upd ());
} 
/* code -  ln_und - undefine logical name */
int ln_und(
char *log ,
int mod )
{ char lft [mxIDT];
  dfTctx *ctx = ln_ctx ();
  dfTdef *def ;
  char *nam ;
  int wri = 0;
  if( !ctx)return 0;
  st_cln (log, lft, mxIDT-1);
  st_low (lft);
  def = df_loo (ctx, lft);
  if( !def)return 0;
  df_del (ctx, def);
  return ( ln_upd ());
} 
