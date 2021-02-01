/* file -  tx_cop - copy counted string */
#include "c:\rid\rider.h"
#include "c:\rid\txdef.h"
/* code -  tx_cop - copy counted */
char *tx_cop(
char *src ,
char *dst ,
int cnt )
{ if( cnt == 0)return ( dst );
  while ( cnt-- != 0) {
    if( (*dst = *src) == 0)break;
    ++dst, ++src;
  } 
  *dst = 0;
  return ( dst);
} 
