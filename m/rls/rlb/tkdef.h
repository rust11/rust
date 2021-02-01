/* header tkdef - token definitions */
#ifndef _RIDER_H_tkdef
#define _RIDER_H_tkdef 1
#include "m:\rid\mxdef.h"
#define tkEtyp enum tkEtyp_t
enum tkEtyp_t 
{ tkEND
  ,tkIDT
  ,tkNUM
  ,tkPUN
  ,tkSTR
   };
#define tkTctx struct tkTctx_t 
struct tkTctx_t
{ int Vflg ;
  char *Plin ;
  char *Pfst ;
  char *Plst ;
  char *Pnxt ;
  int Vsta ;
  int Vcmt ;
  void *(*Palc )();
  void (*Pdlc )();
  int (*Prep )();
  char *Pmsg ;
  char Aobj [mxLIN];
  int Vtyp ;
  char Atok [mxLIN];
  char Alin [mxLIN];
   };
#define tkINI_  BIT(0)
#define tkERR_  BIT(1)
#define tkMUT_  BIT(2)
#define tkCAS_  BIT(3)
#define tkSPC_  BIT(4)
#define tkUPR_  BIT(5)
tkTctx *tk_alc (int );
void tk_dlc (tkTctx *);
void tk_lin (tkTctx *,char *);
int tk_nxt (tkTctx *);
#define tk_typ(c)  ((c)->Vtyp)
#define tk_tok(c)  ((c)->Atok)
int tk_loo (tkTctx *,char *[]);
int tk_qua (tkTctx *,char *[]);
int tk_spc (tkTctx *,char *);
int tk_idt (int );
int tk_pun (int );
int tk_skp (tkTctx *);
tkTctx *tk_cli (tkTctx *,int ,char **);
#endif
