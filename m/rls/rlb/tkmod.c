/* file -  tkmod - token processing */
#include "m:\rid\rider.h"
#include "m:\rid\cldef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\medef.h"
#include "m:\rid\tkdef.h"
#include "m:\rid\ctdef.h"
/* code -  tk_alc - allocate token context */
tkTctx *tk_alc(
int flg )
{ tkTctx *ctx ;
  ctx = me_acc ( sizeof(tkTctx));
  ctx->Vflg = flg;
  return ( ctx);
} 
/* code -  tk_dlc - deallocate token context */
void tk_dlc(
tkTctx *ctx )
{ me_dlc (ctx);
} 
/* code -  tk_lin - accept another line */
void tk_lin(
tkTctx *ctx ,
char *lin )
{ ctx->Plin = lin;
  ctx->Pfst = lin;
  ctx->Plst = lin;
  ctx->Pnxt = lin;
  ctx->Vsta = 0;
  tk_skp (ctx);
} 
/* code -  tk_cli - process image activation command line */
tkTctx *tk_cli(
tkTctx *ctx ,
int cnt ,
char *(*vec ))
{ char *lin ;
  if ( !ctx) {ctx = tk_alc (0) ;}
  lin = ctx->Alin;
  cl_ass (lin, cnt, vec);
  tk_lin (ctx, lin);
  return ( ctx);
} 
/* code -  tk_nxt - get next token */
tk_nxt(
tkTctx *ctx )
{ int cha ;
  char *tok ;
  char *ptr ;
  if( ctx == 0)return 0;
  if( ctx->Pnxt == 0)return 0;
  ctx->Atok[0] = 0;
  ctx->Vtyp = tkEND;
  tok = ctx->Atok;
  if( !tk_skp (ctx))return 0;
  ctx->Pfst = ctx->Pnxt;
  ctx->Plst = ctx->Pnxt;
  for(;;)  {
    cha = *ctx->Pnxt;
    if ( (cha == '\"') || (cha == '\'')) {
      ptr = st_bal (ctx->Pnxt);
      while ( ctx->Pnxt != ptr) {
        *tok++ = *ctx->Pnxt++; }
       ctx->Vtyp = tkSTR;break; }
    if ( tk_idt (*ctx->Pnxt)) {
      for(;;)  {
        *tok++ = cha;
        ++ctx->Pnxt;
        cha = *ctx->Pnxt;
      if( !tk_idt (*ctx->Pnxt))break; }
       ctx->Vtyp = tkIDT;break; }
    *tok++ = cha;
    ctx->Vtyp = tkPUN;
    ++ctx->Pnxt;
   break;} 
  *tok = 0;
  ctx->Plst = ctx->Pnxt;
  tk_skp (ctx);
  return ( ctx->Vtyp);
} 
/* code -  tk_idt - check identifier character */
tk_idt(
int cha )
{ cha = cha & 255;
  if( ct_aln (cha))return 1;
  if( cha == '$')return 1;
  if( cha == '_')return 1;
  return 0;
} 
tk_pun(
int cha )
{ return ( !tk_idt (cha));
} 
/* code -  tk_skp - skip spaces and comments */
tk_skp(
tkTctx *ctx )
{ int cha ;
  for(;;)  {
    if( (cha = *ctx->Pnxt) == 0)return 0;
    if ( cha == ctx->Vcmt) {
      ctx->Pnxt = st_end(ctx->Pnxt);
      return 0; }
    if ( (cha == ' ') || (cha == '\t')) {
       ++ctx->Pnxt;continue; }
    return 1;
  } 
} 
/* code -  tk_loo - lookup token in table */
tk_loo(
tkTctx *ctx ,
char *tab [])
{ int idx = 0;
  while ( *tab) {
    if (( ctx->Vtyp != tkEND)
    &&(cl_mat (*tab++, ctx->Atok))) {
      break; }
    ++idx;
  } 
  return ( idx);
} 
/* code -  tk_spc - get a file spec */
tk_spc(
tkTctx *ctx ,
char *spc )
{ char *ptr ;
  if( (ptr = (st_par ("pn", "A0|$_:.\\*%?[];", ctx->Pfst))) == NULL)return 0;
  ctx->Plst = ptr;
  ctx->Pnxt = ptr;
  tk_skp (ctx);
  st_cln (ctx->Pfst, ctx->Atok, ptr-ctx->Pfst);
  if ( spc) {st_cop (ctx->Atok, spc) ;}
  return 1;
} 
