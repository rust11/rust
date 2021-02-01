/* file -  dfexp - expand definition */
#include "m:\rid\rider.h"
#include "m:\rid\dfdef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\chdef.h"
#include "m:\rid\ctdef.h"
#include "m:\rid\fidef.h"
/* code -  messages */
#define E_Ovr  "E-Definition buffer overflow [%s]"
#define E_Mis  "E-Not enough arguments [%s]"
#define E_Xcs  "E-Too many arguments [%s]"
#define E_Syn  "E-Invalid definition operator in [%s]"
static int df_arg (dfTctx *,int ,char *,char **);
/* code -  df_arg - isolates nth argument */
int df_arg(
dfTctx *ctx ,
int nth ,
char *str ,
char *(*res ))
{ char *bal ;
  int sep = ctx->Vsep;
  if( nth < 0)return 0;
  for(;;)  {
    while ( ct_spc (*str)) {++str ;}
    if( *str == 0)return 0;
    *res = str;
    while ( *str != 0) {
      bal = ctx->Pbal;
      while ( *bal != 0) {
        if ( *str == *bal++) {
           str = st_bal (str);break; } }
      if( *str == sep || !*str)break;
      ++str;
    } 
    if( nth-- == 0)break;
    if ( *str != 0) {++str ;}
  } 
  return ( str-*res);
} 
/* code -  df_exp - expand definition */
#define dfARG  0
#define dfREQ  1
#define dfFRM  2
#define dfALL  3
#define dfDEF  4
#define dfTRN  5
int df_exp(
dfTctx *ctx ,
dfTdef *def ,
char *rem ,
char *dst ,
int max ,
int pre ,
int syn )
{ char *bod = def->Pbod;
  char *arg ;
  char *msg ;
  int exp = 0;
  int top = 0;
  int len = 2;
  int cha ;
  int cas ;
  int idx ;
  int cnt ;
  char *bas = dst;
  for(;;)  {
    *dst = 0;
    if ( *bod == 0) {
      if( exp || *rem == 0)return 1;
      *dst++ = ' ', ++len, cha = 'a';
      } else {
      if( ++len >= max){ msg=E_Ovr ; break;}
      if( *bod != pre){ *dst++ = *bod++ ; continue;}
      if( *++bod == pre){ *dst++ = *bod++ ; continue;}
      if( (cha = *bod++&255) == 0){ *dst=0 ; return 1;}
      --len; }
    ++exp;
    if ( cha == 'x') {
      if( df_arg (ctx,top,rem,&arg) == 0)continue;
       msg=E_Xcs;break; }
    switch ( cha) {
    case 'd':
      cas = dfDEF;
     break; case 'e':
      continue;
     break; case ' ':
    case 'n':
       *dst++ = '\n';continue;
     break; case 'a':
      cas = dfALL;
     break; case 'f':
      cas = dfFRM;
     break; case 'r':
      cas = dfREQ;
     break; case 't':
      cas = dfTRN;
     break; default: 
      cas = dfARG;
       }
    if ( cas != dfALL) {
      if ( cas != dfARG) {cha = *bod++ & 255 ;}
      if( cha == 0){ msg=E_Syn ; break;}
      if ( ct_dig (cha)) {
        idx = cha - '0';
      } else if ( ct_upr (cha)) {
        idx = (cha - 'a') + 10;
        } else {
         msg=E_Syn;break; }
      if ( idx > top) {top = idx ;}
      cnt = df_arg (ctx, idx-1, rem, &arg); }
    switch ( cas) {
    case dfALL:
      arg = rem, cnt = st_len (rem);
     break; case dfFRM:
      if ( cnt != 0) {cnt = st_len (arg) ;}
     break; case dfTRN:
      fi_loc (arg, arg);
     break; case dfDEF:
      if( cnt == 0)break;
      idx = 1;
      while ( *bod != 0) {
        if( *bod++ != pre)continue;
        if( (cha=*bod++) == 0)break;
        if ( cha == 'd') {++idx ;}
        if ( cha == 'e') {--idx ;}
        if( idx == 0)break;
      } 
       }
    if( cnt ==  0&& cas == dfREQ){ msg=E_Mis ; break;}
    if( (len += cnt) >= max){ msg=E_Ovr ; break;}
    while ( cnt--) {*dst++ = *arg++ ;}
  } 
  df_rep (ctx, msg, def->Pnam);
  return 0;
} 
