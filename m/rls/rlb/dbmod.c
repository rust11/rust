/* file -  dbmod - debugging */
#include "m:\rid\rider.h"
#include "m:\rid\mxdef.h"
#include "m:\rid\fidef.h"
#include "m:\rid\imdef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\dbdef.h"
#include <errno.h>
#if Win
ULONG GetLastError (void );
void SetLastError (ULONG );
#endif 
#define dbUNK  0
#define dbOFF  1
#define dbTER  2
#define dbFIL  3
int dbVfir = 1;
int dbVlog = dbUNK;
FILE *dbHlog = NULL;
/* code -  db_sav - save context */
void db_sav(
dbTctx *ctx )
{ ctx->Vrts = errno;
#if Win
  ctx->Vsys = GetLastError ();
#else 
  ctx->Vsys = 0;
#endif 
} 
void db_res(
dbTctx *ctx )
{ errno = ctx->Vrts;
#if Win
  SetLastError (ctx->Vsys);
#endif 
} 
/* code -  db_val - log int object */
db_val(
char *msg ,
int val )
{ char txt [128];
  if ( st_fnd ("%", msg)) {
    FMT (txt, msg, val);
    } else {
    FMT (txt, "%s %d", msg, val); }
  db_msg (txt);
  return 1;
} 
/* code -  db_str - log string */
db_str(
char *msg ,
char *obj )
{ char txt [128];
  if ( st_fnd ("%", msg)) {
    FMT (txt, msg, obj);
    } else {
    FMT (txt, "%s %s", msg, obj); }
  db_msg (txt);
  return 1;
} 
/* code -  db_err - log error */
db_err(
char *msg )
{ char spc [mxSPC];
  dbTctx ctx ;
  char txt [128];
  char *err ;
  db_sav (&ctx);
  FMT (txt, "%s errno=%d system=%d", msg, ctx.Vrts, ctx.Vsys);
#if Win
  FMT (st_end (txt), "=%s", dbw_err (ctx.Vsys));
#endif 
  db_msg (txt);
  return 1;
} 
/* code -  db_msg - log message */
db_msg(
char *msg )
{ char txt [128];
  FMT (txt, "%%%s-D-%s\n", imPfac, msg);
  db_wri (txt);
  return 1;
} 
/* code -  db_wri - write to debug log */
db_wri(
char *txt )
{ char spc [mxSPC];
  dbTctx ctx ;
  char *err ;
  int trn ;
  db_sav (&ctx);
  if ( dbVlog == dbUNK) {
    trn = ln_trn (_dbLOG, spc, 0);
    if ( trn) {st_low (spc) ;}
    if (( !trn)
    ||(st_sam (spc, "off"))) {
      dbVlog = dbOFF;
    } else if ( st_sam (spc, "tt")) {
      dbVlog = dbTER;
      } else {
      if ( (dbHlog = fi_opn (spc, dbVfir ? "w": "a+","")) != 0) {dbVlog = dbFIL ;} else {
        dbVlog = dbOFF ; }
      dbVfir = 0; } }
  switch ( dbVlog) {
  case dbUNK:
    dbVlog = dbOFF;
   break; case dbTER:
    im_rep ("I-%s", txt);
   break; case dbFIL:
    fprintf (dbHlog, "%s", txt);
    fflush (dbHlog);
    fclose (dbHlog);
    dbVlog = dbUNK;
   break; case dbOFF:
    ;
     }
  return 1;
} 
#if Win
/* code -  db_lst - decode last error message */
db_clr()
{ 
  return 1;
} 
db_lst(
char *idt )
{ char buf [256];
  char *msg ;
  int err = GetLastError ();
  if( !err)return 1;
  msg = dbw_err (err);
  st_cop ("I-", buf);
  if ( idt) {
    st_app (idt, buf);
    st_app (" ", buf); }
  st_app ("%s", buf);
  im_rep (buf, msg);
  return 0;
} 
#endif 
