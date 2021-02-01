/* header tidef - time routines */
#ifndef _RIDER_H_tidef
#define _RIDER_H_tidef 1
#define tiTplx struct tiTplx_t 
struct tiTplx_t
{ WORD Vmil ;
  WORD Vsec ;
  WORD Vmin ;
  WORD Vhou ;
  WORD Vday ;
  WORD Vmon ;
  WORD Vyea ;
  WORD Vdow ;
  WORD Vdoy ;
  WORD Vdst ;
   };
#if Wnt
#define tiTval struct tiTval_t 
struct tiTval_t
{ ULONG Vlot ;
  long Vhot ;
   };
#else 
typedef ULONG tiTval ;
#endif 
typedef long tiTcpu ;
int ti_cpu (tiTcpu *);
int ti_clk (tiTval *);
int ti_sub (tiTval *,tiTval *,tiTval *);
int ti_cmp (tiTval *,tiTval *);
int ti_plx (tiTval *,tiTplx *);
int ti_val (tiTplx *,tiTval *);
int ti_day (tiTplx *,char *);
int ti_dat (tiTplx *,char *);
int ti_tim (tiTplx *,char *);
int ti_mil (tiTcpu *,char *);
ti_msk (tiTval *,tiTval *,int );
#define tiMIL_  BIT(0)
#define tiSEC_  BIT(1)
#define tiMIN_  BIT(2)
#define tiHOU_  BIT(3)
#define tiDAY_  BIT(4)
#define tiMON_  BIT(5)
#define tiYEA_  BIT(6)
#define tiDST_  BIT(7)
#define tiTIM_ (tiMIL_|tiSEC_|tiMIN_|tiHOU_|tiDST_)
#define tiDAT_ (tiDAY_|tiMON_|tiYEA_)
/* code -  system specific routines */
#if Dos
#define tiTdos struct tiTdos_t 
struct tiTdos_t
{ int Vtim ;
  int Vdat ;
   };
#define tiTnat  tiTdos
#define ti_imp  ti_fds
#define ti_exp  ti_tds
int ti_fds (tiTdos *,tiTval *);
int ti_tds (tiTval *,tiTdos *);
#endif 
#if Wnt
#define tiTwnt struct tiTwnt_t 
struct tiTwnt_t
{ ULONG Vlot ;
  ULONG Vhot ;
   };
#define tiTnat  tiTwnt
#define ti_imp  ti_fnt
#define ti_exp  ti_tnt
int ti_fnt (tiTwnt *,tiTval *);
int ti_tnt (tiTval *,tiTwnt *);
int ti_sys (tiTval *);
#endif 
#endif
