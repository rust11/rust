/* header dfdef - definition definitions */
#ifndef _RIDER_H_dfdef
#define _RIDER_H_dfdef 1
#include "m:\rid\mxdef.h"
#define _dfROL  "@ini@:roll.def"
#define _dfSHE  "ini:she.def"
#define _dfANO  "[]"
#define dfTdef struct dfTdef_t 
struct dfTdef_t
{ dfTdef *Psuc ;
  char *Pnam ;
  char *Pbod ;
   };
#define dfTctx struct dfTctx_t 
struct dfTctx_t
{ int Vflg ;
  dfTdef *Proo ;
  char *Pspc ;
  char *Popr ;
  char *Pbal ;
  int Vsep ;
  void *(*Palc )(size_t );
  void (*Pdlc )(void *);
  int (*Prep )(char *,char *);
  char *Pmsg ;
  char Aobj [mxLIN];
   };
#define dfINI_  BIT(0)
#define dfMOD_  BIT(1)
#define dfDYN_  BIT(2)
#define dfERR_  BIT(3)
#define dfMUT_  BIT(4)
#define dfMEM_  BIT(5)
#define dfSTA_  BIT(6)
#define dfEPH_  BIT(7)
#define dfREA_  BIT(7)
#define dfMRK_  BIT(8)
#define dfCOR_  BIT(9)
#define dfCAS_  BIT(10)
dfTctx *df_ctx (char *,int );
void df_dlc (dfTctx *);
int df_def (dfTctx *,char *);
dfTdef *df_loo (dfTctx *,char *);
dfTdef *df_nth (dfTctx *,int );
int df_rea (dfTctx *);
int df_wri (dfTctx *);
void df_lst (dfTctx *);
int df_ins (dfTctx *,char *,char *);
void df_del (dfTctx *,dfTdef *);
int df_exp (dfTctx *,dfTdef *,char *,char *,int ,int ,int );
void df_rep (dfTctx *,char *,char *);
#endif
