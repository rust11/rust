/* header exmod - EXPAT module definitions */
#ifndef _RIDER_H_exmod
#define _RIDER_H_exmod 1
#include "rid:rider.h"
#include "rid:dcdef.h"
#include "rid:fidef.h"
#include "rid:mxdef.h"
#include "rid:tidef.h"
#include "rid:vfdef.h"
#if Win
#define cuSYS  vfWIN
#else 
#define cuSYS  vfRTA
#endif 
/* code -  cuTctl - EXPAT cusp control block */
#define cuTctl struct cuTctl_t 
struct cuTctl_t
{dcTdcl *Pdcl ;
  vfTobj *Psrc ;
  vfTobj *Pdst ;
  int Qasc ;
  int Qbrf ;
  int Qdat ;
  int Qexe ;
  int Qful ;
  int Qlst ;
  int Qlog ;
  int Qnew ;
  int Qoct ;
  int Qpag ;
  int Qnpg ;
  int Qrep ;
  int Qnrp ;
  int Qque ;
  int Qnqu ;
  int Q7bt ;
  int Qxdp ;
  char Aexc [mxLIN];
  char Asch [mxLIN];
  char Abef [mxSPC];
  char Adat [mxSPC];
  char Asin [mxSPC];
  tiTplx Ibef ;
  tiTplx Idat ;
  tiTplx Inew ;
  tiTplx Isin ;
  int Vflg ;
  int Vopt ;
  char Aopt [mxSPC];
  FILE *Hopt ;
  int Vcol ;
  int Vlin ;
  int Vcnt ;
  LONG Vtot ;
  char Adir [mxSPC];
  FILE *Hidx ;
  void *Pidx ;
  int Vidx ;
#if Win
  char Aexe [mxLIN];
#endif 
   };
#define cuACC_  BIT(0)
#define cuFNF_  BIT(1)
#define cuINI_  BIT(2)
#define cuNAT_  BIT(3)
#define cuOPT_  BIT(4)
#define cuLPT_  BIT(5)
#define cuPAG_  BIT(6)
#define cuQUE_  BIT(7)
#define cuSUB_  BIT(8)
extern cuTctl ctl ;
extern vfTobj Isrc ;
extern vfTobj Idst ;
extern dcTitm cuAdcl [];
extern char *cuAhlp [];
dcTfun cv_cop ;
dcTfun cv_del ;
dcTfun cu_dir ;
dcTfun cv_dir ;
dcTfun cv_ren ;
dcTfun cv_prt ;
dcTfun cv_tou ;
dcTfun cv_typ ;
dcTfun cv_xdp ;
typedef int cmTfun ();
int cu_dis ();
cmTfun cm_cop ;
cmTfun cm_del ;
cmTfun cu_exe ;
cmTfun cm_dir ;
cmTfun cm_ren ;
cmTfun cm_prt ;
cmTfun cm_tou ;
cmTfun cm_typ ;
cmTfun cm_xdp ;
int cu_asc ();
cu_gdt ();
cu_cdt ();
cu_exc ();
int cu_log ();
cu_opn ();
cu_clo ();
cu_pag ();
int cu_que ();
cu_dcl ();
cu_ovl ();
cu_f63 ();
cu_fmt ();
cu_fnf ();
LONG cu_len ();
cu_nat ();
cu_prg ();
cu_res ();
int cu_sub ();
#endif
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            