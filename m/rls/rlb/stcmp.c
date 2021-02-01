/* file -  stcmp - string compare */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_cmp - compare strings */
int st_cmp(
register char *mod ,
register char *tar )
{ while ( *mod == *tar) {
    if( *tar == 0)return ( 0 );
    ++mod, ++tar;
  } 
  return ( (*mod > *tar) ? 1: -1);
} 
