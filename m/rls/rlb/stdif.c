/* file -  stdif - differ -- compare limited strings */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_dif - differ -- compare limited strings */
st_dif(
char *mod ,
char *tar ,
size_t lim )
{ for(;;)  {
    if( lim-- == 0)return ( 0 );
    if( *mod != *tar)break;
    if( *tar == 0)return ( 0 );
    ++mod, ++tar;
  } 
  return ( (*mod > *tar) ? 1: -1);
} 
