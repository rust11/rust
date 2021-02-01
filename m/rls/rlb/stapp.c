/* file -  stapp - append string */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_app - append string */
char *st_app(
register char *src ,
register char *dst )
{ while ( *dst++) {;}
  --dst;
  while ( (*dst++ = *src++) != 0) {;}
  return ( --dst);
} 
