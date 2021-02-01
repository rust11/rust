/* header usmod */
#ifndef _RIDER_H_usmod
#define _RIDER_H_usmod 1
#include <stdio.h>
#if Win
#include <stdlib.h>
#endif 
#include "f:\m\rid\rider.h"
#include "f:\m\rid\chdef.h"
#include "f:\m\rid\ctdef.h"
#include "f:\m\rid\stdef.h"
#include "f:\m\rid\medef.h"
#include "f:\m\rid\imdef.h"
#include "f:\m\rid\mxdef.h"
#include "f:\m\rid\drdef.h"
#include "f:\m\rid\fidef.h"
#include "f:\m\rid\mxdef.h"
#include "f:\m\rid\cldef.h"
#include "f:\m\rid\tidef.h"
#include "f:\m\rid\iminf.h"
#if Dos
#include "f:\m\rid\dslib.h"
#else 
#define ki_ini()  
#define ki_exi()  
#define ki_ctc()  (0)
#endif 
#define NL  cu_new()
/* code -  qualifiers */
extern int quFall ;
extern int quFany ;
extern int quFbig ;
extern int quFbin ;
extern int quFbyt ;
extern int quFbar ;
extern int quFdat ;
extern int quFdbg ;
extern int quFdec ;
extern int quFdir ;
extern int quFdou ;
extern int quFdtb ;
extern int quFdwn ;
extern int quFeps ;
extern int quFfor ;
extern int quFfre ;
extern int quFfst ;
extern int quFful ;
extern int quFhex ;
extern int quFimg ;
extern int quFlng ;
extern int quFlog ;
extern int quFnew ;
extern int quFold ;
extern int quFpau ;
extern int quFpee ;
extern int quFque ;
extern int quFnqr ;
extern int quFqui ;
extern int quFrep ;
extern int quFnrp ;
extern int quFoct ;
extern int quFrev ;
extern int quFsma ;
extern int quFtim ;
extern int quFtit ;
extern int quFtrm ;
extern int quFtot ;
extern int quFuse ;
extern int quFvrb ;
extern int quFwid ;
extern int quFwrd ;
extern int quVfro ;
extern int quVlft ;
extern int quVtop ;
extern int quVlin ;
extern int quFlst ;
extern int quFvie ;
extern int quFsiz ;
extern int quFacc ;
extern int quFcop ;
extern int quFmov ;
extern int quFren ;
extern int quVatr ;
extern int quVcat ;
extern int quVsat ;
extern int quVcol ;
extern int quVsrt ;
#define E_MisCmd  "E-Command missing"
#define E_InvCmd  "E-Invalid command [%s]"
#define E_InvQua  "E-Invalid qualifier [%s]"
#define E_MisVal  "E-Missing qualifier value [%s]"
#define E_InvVal  "E-Invalid qualifier value [%s]"
#define E_RngVal  "E-Value out of range [%s]"
#define E_InvCnt  "E-Wrong number of parameters [%s]"
#define E_InvWld  "E-Invalid wildcards [%s]"
#define _cuQUE  ": Yes, No, All, Quit? "
#define cuTctx struct cuTctx_t 
typedef int cuTrou (cuTctx *);
#define cuTctx struct cuTctx_t 
struct cuTctx_t
{ char *Pcmd ;
  char *P1 ;
  char *P2 ;
  char *P3 ;
  int Varg ;
  drTdir *Pdir ;
  drTent *Pent ;
  char *Ppth ;
  char *Pnam ;
  char *Pspc ;
  char *Ptar ;
  FILE *Psrc ;
  FILE *Pdst ;
  cuTrou *Pfun ;
  int Vsrt ;
  int Vatr ;
  long Vsiz ;
  long Vtot ;
  int Vcnt ;
  int Vmat ;
  int Vmis ;
  int Vsam ;
  int Vdif ;
  long Vcha ;
  long Vwrd ;
  long Vlin ;
  long Vpag ;
  tiTval Itim ;
  tiTval Idat ;
  char *Pobf ;
  char *Popt ;
  int Vqui ;
  int Vtar ;
  char *Phdr ;
  char *Pobj ;
  char *Pjoi ;
  imTinf Iimg ;
   };
extern cuTctx *cuPsrc ;
extern cuTctx *cuPdst ;
cuTctx *cu_ctx (void );
int cu_cmd (cuTctx *,int ,char **);
static char *(*cu_arg (cuTctx *,char **,char *));
void cu_tit (cuTctx *);
int cu_opr (cuTctx *);
int cu_que (cuTctx *,char *);
int cu_ask (cuTctx *,char *,char *);
void cu_siz (long ,char *);
char *cu_dts (tiTval *,char *);
char *cu_tms (tiTval *,char *);
void cu_new (void );
void cu_rew (cuTctx *);
void cu_flu (cuTctx *);
void cu_typ (char *);
void cu_opt (char *,char *);
#define OPT(c,o)  cu_opt(c, o)
#define APP(c)  cu_opt(c, NULL)
void cu_abt (void );
void cu_err (char *,char *);
FILE *cu_src (cuTctx *);
FILE *cu_dst (cuTctx *);
int cu_clo (cuTctx *,FILE **,char *);
FILE *cu_tar (cuTctx *);
FILE *cu_opn (char *,char *,char *,char *);
int cu_cln (cuTctx *);
int cu_rpl (cuTctx *);
void cu_wld (cuTctx *,int );
void cu_tot (cuTctx *);
void cu_scn (cuTctx *);
void cu_don (drTdir *);
int cu_avl (char *);
char *cu_spc (char *,char *,char *);
int cu_kop (FILE *,FILE *,long );
int us_scn (cuTctx *);
drTent *us_nxt (cuTctx *);
cuTrou su_cmp ;
cuTrou su_edt ;
cuTrou su_cre ;
cuTrou su_tra ;
cuTrou su_sea ;
cuTrou su_zap ;
cuTrou pu_zap ;
cuTrou kw_atr ;
cuTrou kw_cmp ;
cuTrou kw_var ;
cuTrou kw_edt ;
cuTrou kw_dif ;
cuTrou kw_chg ;
cuTrou kw_cnt ;
cuTrou kw_cre ;
cuTrou kw_del ;
cuTrou kw_dmp ;
cuTrou kw_hlp ;
cuTrou kw_lst ;
cuTrou kw_mak ;
cuTrou kw_prn ;
cuTrou kw_rem ;
cuTrou kw_sho ;
cuTrou kw_tou ;
cuTrou kw_tra ;
cuTrou kw_typ ;
cuTrou kw_see ;
cuTrou kw_sea ;
cuTrou kw_srt ;
cuTrou kw_tru ;
cuTrou kw_zap ;
#endif
