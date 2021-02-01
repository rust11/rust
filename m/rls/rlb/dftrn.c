/* file -  dftrn - translate definition */
#include "m:\rid\rider.h"
#include "c:\rid\dfdef.h"
#include "c:\rid\stdef.h"
#define E_Loo  "E-Definition loops [%s]"
int df_trn (dfTctx ,char *,char *,char *,char *);
int df_trn(
dfTctx *ctx ,
char *lin ,
char *res ,
char *exp ,
char *max )
{ char nam [mxIDT];
  int ugh = 0;
  dfTdef *def = NULL;
  dfTdef *nxt ;
  st_cop (lin, exp);
  for(;;)  {
    if( (def = df_loo (ctx, lin, &rem)) == NULL)break;
    if ( --loo <= 0) {
       df_rep (ctx, E_loo,df_exp (ctx, def, lin, max, opr, syn);break; }
    if( that == 0)return ( 0 );
#define ugh  printf("ugh\n")
main()
{ dfTctx *ctx ;
  char lin [128];
  char nam [128];
  char exp [128];
  char *ent ;
  dfTdef *def ;
  im_ini ("TEST");
  ctx = df_ctx ("\\skr\\a.def", 0);
  for(;;)  {
    lin[0] = 0;
    printf ("+ ");
    fgets (lin, 128, stdin);
    if( *lin == 0)continue;
    st_trm (lin);
    if ( st_fnd (" := ", lin)) {
      df_def (ctx, lin);
    } else if ( st_sam ("show", lin)) {
      df_lst (ctx);
      } else {
      if( (def = df_loo (ctx, nam)) == NULL)continue;
      printf ("%s := %s\n", nam, def->Pbod);
      df_exp (ctx, def, lin, exp, 128, '#', 0);
      printf ("=> [%s]\n", exp);
    } 
  } 
} 
