/* file -  abwin - Windows abort control */
#include "m:\rid\rider.h"
#include "m:\rid\abdef.h"
void (*abPbrk )(void )= NULL;
volatile int abVboo = 0;
volatile int abVcan = 0;
void (*abPcan )(void )= NULL;
volatile int abVabt = 0;
void (*abPabt )(void )= NULL;
int abVmod = 1;
static int abVini = 0;
int abFcri = 0;
int abVcri = 0;
int (*abPcri )(void *)= NULL;
/* code -  ab_dsb - disable aborts */
void ab_dsb()
{ abVmod = 0;
  ab_ini ();
} 
/* code -  ab_enb - enable aborts */
void ab_enb()
{ abVmod = 1;
  ab_ini ();
} 
/* code -  ab_chk - check & clear */
int ab_chk()
{ int res = abVabt;
  abVabt = 0;
  abVcan = 0;
  return ( res);
} 
/* code -  abort internals */
static void ab_exi (void );
static int abVerr = 0;
/* code -  ab_ini - init system stuff */
int ab_ini()
{ if( abVini != 0)return 1;
  ++abVini;
  return 1;
} 
/* code -  ab_exi - exit cleanup */
void ab_exi()
{ if( abVini == 0)return;
  abVini = 0;
} 
