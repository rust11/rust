/* file -  stfnd - find substring */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_fnd - find substring */
char *st_fnd(
char *mod ,
char *str )
{ char *src ;
  char *dst ;
  for(;;)  {
    while ( *mod != *str) {
      if( *str++ == 0)return ( NULL ); }
    src = mod, dst = str;
    for(;;)  {
      if( *src == 0)return ( str );
    if( *src++ != *dst++)break; }
    ++str;
  } 
} 
