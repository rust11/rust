/* file -  lnmod - logical name routines */
#include "m:\rid\rider.h"
#include "m:\rid\dfdef.h"
#include "m:\rid\mxdef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\lndef.h"
dfTctx *ln_ctx (void );
extern dfTctx *lnPctx ;
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
