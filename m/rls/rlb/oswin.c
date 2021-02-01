/* file -  oswin - Windows support */
#include "m:\rid\rider.h"
#include "m:\rid\osdef.h"
#include <stdlib.h>
#include <windows.h>
/* code -  locals */
#define esCsuc  0
#define esCwar  0
#define esCerr  1
#define esCfat  1
#if Wnt
int osVsys = osKw32;
int osVimp = osKwnt;
int osVhst = osKwnt;
#else 
int osVsys = osKw16;
int osVimp = osKwin;
int osVhst = osKdos;
#endif 
int osVcpu = osKx86;
int osVend = osKbig;
int osVsev = 0;
/* code -  os_ini - init for o/s */
os_ini()
{ return 1;
} 
/* code -  os_war - register warning */
void os_war()
{ if ( osVsev < esCwar) {osVsev = esCwar ;}
} 
/* code -  os_err - register error */
void os_err()
{ if ( osVsev < esCerr) {osVsev = esCerr ;}
} 
/* code -  os_fat - register fatal error */
void os_fat()
{ osVsev = esCfat;
} 
/* code -  os_exi - exit image */
os_exi()
{ 
#if Wnt
  exit ( osVsev);
#else 
  exit ( osVsev);
#endif 
  return 0;
} 
/* code -  os_idl - execute system idle loop */
os_idl()
{ 
  return 1;
} 
/* code -  os_wai - wait n milliseconds */
os_wai(
ULONG cnt )
{ int min ;
  if( !cnt)return 1;
  while ( cnt--) {
    min = 1000000;
    while ( --min) {;}
  } 
  return 1;
} 
/* code -  rt_ctc - zortech code */
#ifdef __SC__
volatile int rtFctc = 0;
int rtFres = 0;
/* code -  rt_ctc - catch ctrl/c */
int rt_ctc()
{ ++rtFctc;
  return ( 0);
} 
/* code -  rt_ini - init system stuff */
rt_ini()
{ 
} 
/* code -  rt_exi - exit cleanup */
rt_exi()
{ 
} 
#endif
