/* file -  txdef - text compare */
#include "c:\rid\rider.h"
#include "c:\rid\txdef.h"
/* code -  tx_cmp - compare text */
tx_cmp(
char *mod ,
char *tar ,
int lim )
{ for(;;)  {
    if( lim-- == 0)return ( 0 );
    if( *mod != *tar)break;
    if( *tar == 0)return ( 0 );
    ++mod, ++tar;
  } 
  return ( (*mod > *tar) ? 1: -1);
} 
