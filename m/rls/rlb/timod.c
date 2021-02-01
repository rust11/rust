/* file -  timod - time utilities */
#include "m:\rid\rider.h"
#include "m:\rid\tidef.h"
#include <time.h>
#if Wnt
#include <windows.h>
#endif 
#define tiTccc  struct tm
/* code -  cpu time measurment */
#if !Wnt
#ifdef CLOCKS_PER_SEC
#define tiKcps  CLOCKS_PER_SEC
#elif  &CLK_TCK
#define tiKcps  CLK_TCK
#else 
error;
#endif 
/* code -  ti_cpu - get cpu time */
int ti_cpu(
tiTcpu *cpu )
{ clock_t res ;
  res = clock ();
  if( res == -1)return 0;
#if tiKcps < 1000
  res *= (1000/tiKcps);
#elif  tiKcps > 1000
  res /= (tiKcps/1000);
#endif 
  if ( cpu) {*cpu = res ;}
  return ( (int )res);
} 
#endif 
#if Wnt
/* code -  ti_cpu - get cpu ticks */
#define tiKcps  1000
ti_cpu(
tiTcpu *cpu )
{ int val = GetTickCount ();
  if ( cpu) {*(ULONG *)cpu = val ;}
  return ( (int )val);
} 
#endif 
/* code -  ti_clk - get clock value */
int ti_clk(
tiTval *val )
{ time ((time_t *)val);
  return 1;
} 
/* code -  ti_cmp - compare times (lft-rgt) */
int ti_cmp(
tiTval *lft ,
tiTval *rgt )
{ if( lft > rgt)return ( 1 );
  if( lft < rgt)return ( -1 );
  return ( 0);
} 
/* code -  ti_sub - subtract times (res=lft-rgt) */
ti_sub(
tiTval *lft ,
tiTval *rgt ,
tiTval *res )
{ *res = *rgt - *lft;
} 
/* code -  ti_val - plex to value */
int ti_val(
tiTplx *plx ,
tiTval *val )
{ tiTccc exp ;
  exp.tm_sec = plx->Vsec;
  exp.tm_min = plx->Vmin;
  exp.tm_hour = plx->Vhou;
  exp.tm_mday = plx->Vday;
  exp.tm_mon = plx->Vmon;
  exp.tm_year = plx->Vyea - 1900;
  exp.tm_isdst = plx->Vdst;
  *(time_t *)val = mktime (&exp);
} 
/* code -  ti_plx - value to plex */
int ti_plx(
tiTval *val ,
tiTplx *plx )
{ tiTccc *exp ;
  exp = localtime ((time_t *)val);
  plx->Vmil = 0;
  plx->Vsec = exp->tm_sec;
  plx->Vmin = exp->tm_min;
  plx->Vhou = exp->tm_hour;
  plx->Vday = exp->tm_mday;
  plx->Vmon = exp->tm_mon;
  plx->Vyea = exp->tm_year + 1900;
  plx->Vdst = exp->tm_isdst;
  return 1;
} 
/* code -  ti_msk - mask time fields */
int ti_msk(
tiTval *val ,
tiTval *res ,
int mod )
{ tiTplx plx ;
  ti_plx (val, &plx);
  if ( !(mod & tiMIL_)) {plx.Vmil = 0 ;}
  if ( !(mod & tiSEC_)) {plx.Vsec = 0 ;}
  if ( !(mod & tiMIN_)) {plx.Vmin = 0 ;}
  if ( !(mod & tiHOU_)) {plx.Vhou = 0 ;}
  if ( !(mod & tiDAY_)) {plx.Vday = 0 ;}
  if ( !(mod & tiMON_)) {plx.Vmon = 0 ;}
  if ( !(mod & tiYEA_)) {plx.Vyea = 0 ;}
  if ( !(mod & tiDST_)) {plx.Vdst = 0 ;}
  return 1;
} 
#if Dos
/* code -  ti_fds - from dos filetime to value */
int ti_fds(
tiTdos *fil ,
tiTval *val )
{ tiTplx plx = {0};
  int tim = fil->Vtim;
  int dat = fil->Vdat;
  plx.Vsec = (tim & 0x1F) * 2;
  plx.Vmin = (tim>>5) & 0x3F;
  plx.Vhou = (tim>>11) & 0x1F;
  plx.Vday = dat & 0x1F;
  plx.Vmon = ((dat >> 5) & 0x0F) - 1;
  plx.Vyea = ((dat >> 9) & 0x7F) + 1980;
  ti_val (&plx, val);
  return 1;
} 
/* code -  ti_tds - to dos filetime */
int ti_tds(
tiTval *val ,
tiTdos *fil )
{ tiTplx plx = {0};
  ti_plx (val, &plx);
  fil->Vtim = (plx.Vsec / 2) + ((plx.Vmin << 5) | (plx.Vhou << 11));
  fil->Vdat = (plx.Vday) + (((plx.Vmon + 1) >> 5) + (((plx.Vyea - 1980) << 9)));
  return 1;
} 
#endif 
#if Wnt
/* code -  tm_fnt - from Wnt filetime to value */
int ti_fnt(
tiTwnt *fil ,
tiTval *val )
{ tiTplx plx ;
  SYSTEMTIME sys ;
  if( (FileTimeToSystemTime ((FILETIME *)fil, &sys)) == 0)return ( 0 );
  plx.Vmil = sys.wMilliseconds;
  plx.Vsec = sys.wSecond;
  plx.Vmin = sys.wMinute;
  plx.Vhou = sys.wHour;
  plx.Vday = sys.wDay;
  plx.Vmon = sys.wMonth;
  plx.Vyea = sys.wYear;
   ti_val (&plx, val);return 1;
} 
/* code -  ti_tnt - to wnt filetime */
int ti_tnt(
tiTval *val ,
tiTwnt *fil )
{ SYSTEMTIME sys ;
  tiTplx plx ;
  if( (ti_plx (val, &plx)) == 0)return ( 0 );
  sys.wMilliseconds = plx.Vmil;
  sys.wSecond = plx.Vsec;
  sys.wMinute = plx.Vmin;
  sys.wHour = plx.Vhou;
  sys.wDay = plx.Vday;
  sys.wMonth = plx.Vmon;
  sys.wYear = plx.Vyea;
  SystemTimeToFileTime (&sys, (FILETIME *)fil);
  return 1;
} 
#endif 
#if Dos
/* code -  ti_clv - clock as values */
#define tiTplx  struct tm
ti_clv(
int *dtv ,
int *tmv )
{ time_t tim ;
  tiTplx *plx ;
  tim = time (NULL);
  plx = localtime (&tim);
  *dtv = ((plx->tm_mday) | (((plx->tm_mon + 1) << 5) | ((plx->tm_year - 80) << 9)));
  *tmv = ((plx->tm_sec/2) | ((plx->tm_min << 5) | ((plx->tm_hour << 11))));
  return 1;
} 
#endif 
