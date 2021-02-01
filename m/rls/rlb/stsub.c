/* file -  stsub - test substring */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_sub - test substring */
int st_sub(
char *mod ,
char *str )
{ char *src ;
  char *dst ;
  for(;;)  {
    while ( *mod != *str) {
      if( *str++ == 0)return 0; }
    src = mod, dst = str;
    for(;;)  {
      if( *src == 0)return 1;
    if( *src++ != *dst++)break; }
    ++str;
  } 
} 
