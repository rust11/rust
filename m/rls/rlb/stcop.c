/* file -  stcop - copy string */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_cop - string copy */
char *st_cop(
register char *src ,
register char *dst )
{ while ( *src) {
    *dst = *src;
    ++src, ++dst;
  } 
  *dst = 0;
  return ( dst);
} 
