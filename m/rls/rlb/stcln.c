/* file -  st_cln - clone -- copy limited string */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_cln - clone -- copy limited string */
char *st_cln(
char *src ,
char *dst ,
size_t cnt )
{ if( cnt == 0)return ( dst );
  while ( cnt-- != 0) {
    if( (*dst = *src) == 0)break;
    ++dst, ++src;
  } 
  *dst = 0;
  return ( dst);
} 
