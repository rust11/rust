/* header exmod - EXPAT module definitions */
#ifndef _RIDER_H_exmod
#define _RIDER_H_exmod 1
#include "c:\f\m\rid\rider.h"
#include "c:\f\m\rid\dcdef.h"
#include "c:\f\m\rid\fidef.h"
#include "c:\f\m\rid\mxdef.h"
#include "c:\f\m\rid\tidef.h"
#include "c:\f\m\rid\vfdef.h"
typedef int cxTfun (vfTobj *,vfTent *);
int cx_dis (dcTdcl *,cxTfun *);
/* code -  cuTctl - EXPAT control block */
extern vfTobj Isrc ;
extern vfTobj Idst ;
#define cuTctl struct cuTctl_t 
struct cuTctl_t
{dcTdcl *Pdcl ;
  vfTobj *Psrc ;
  vfTobj *Pdst ;
  char Abef [mxSPC];
  char Adat [mxSPC];
  char Asin [mxSPC];
  tiTplx Ibef ;
  tiTplx Idat ;
  tiTplx Inew ;
  tiTplx Isin ;
  char Aexc [mxLIN];
  char Aopt [mxSPC];
  FILE *Hopt ;
  char Adir [mxSPC];
  int Vfct ;
  int Qasc ;
  int Qbrf ;
  int Qdat ;
  int Qexe ;
  int Qful ;
  int Qlst ;
  int Qlog ;
  int Qnew ;
  int Qoct ;
  int Qpau ;
  int Qque ;
  int Q7bt ;
  char Asch [mxLIN];
  int Qxdp ;
  int Qana ;
  int Qemt ;
  int Qdrs ;
  int Qpas ;
  int Qxmx ;
#if Win
  char Aexe [mxSPC];
#endif 
   };
extern cuTctl ctl ;
extern dcTitm cuAdcl [];
extern char *cuAhlp [];
dcTfun cv_cop ;
dcTfun cv_dir ;
dcTfun cv_typ ;
dc_ovl ();
dcTfun cm_cop ;
dcTfun cm_del ;
dcTfun cm_dir ;
dcTfun cm_ren ;
dcTfun cm_typ ;
dcTfun cm_xdp ;
int cu_asc (char );
cu_gdt ();
cu_cdt (vfTent *);
int cu_exe (vfTobj *,vfTent *);
cu_exc (vfTent *);
int cu_log (char *);
FILE *cu_opt (char *);
int cu_pau (FILE *,int *);
int cu_que (char *);
cu_res (char *,char *,char *);
cu_fmt (char *,char *);
int cu_sub (char *);
cu_prg ();
cu_fnf (ULONG );
ULONG cu_len (ULONG );
#endif
