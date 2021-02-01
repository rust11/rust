/* file -  st_kop - copy counted string */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_kop - copy counted */
char *st_kop(
char *src ,
char *dst ,
int cnt )
{ if( cnt == 0)return ( dst );
  while ( cnt-- != 0) {
    if( (*dst++ = *src++) == 0)break;
  } 
  *--dst = 0;
  return ( dst);
} 
