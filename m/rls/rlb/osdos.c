/* file -  osdos - O/S MS-DOS support */
#include "m:\rid\rider.h"
#include "m:\rid\osdef.h"
#include <stdlib.h>
/* code -  locals */
#define esCsuc  0
#define esCwar  0
#define esCerr  1
#define esCfat  1
int osVsys = osKdos;
int osVimp = osKdos;
int osVhst = osKdos;
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
{ exit ( osVsev);
  return 0;
} 
/* code -  rt_ctc - zortech code */
#ifdef __ZTC__
#include <int.h>
typedef struct INT_DATA rtTint ;
volatile int rtFctc = 0;
int rtFres = 0;
/* code -  rt_ctc - catch ctrl/c */
int rt_ctc(
rtTint *frm )
{ ++rtFctc;
  return ( 0);
} 
/* code -  rt_ini - init system stuff */
rt_ini()
{ 
#if ! Wdw
  if ( (int_intercept (0x1b, &rt_ctc, 200)) == 0) {++rtFres ;}
#endif 
} 
/* code -  rt_exi - exit cleanup */
rt_exi()
{ 
#if ! Wdw
  if ( rtFres) {
    int_restore (0x1b); }
#endif 
} 
#endif
/* code -  os_upt - uptime checks */
#include "m:\rid\dsdef.h"
#include "m:\rid\dslib.h"
void os_upt()
{ 
#if 0
  dsTreg reg ;
  short far *wrd ;
  char far *byt ;
  byt = TOFAR(char, 0x40, 0x17);
  *byt &= ~(BIT(5));
  if( ds_DetWin ())return;
  ds_SndOff ();
  wrd = TOFAR(short, 0x40, 0x13);
  if ( *wrd < 640-2) {
    ut_rep ("W-Less than 640k low memory\n", NULL); }
#endif 
} 
