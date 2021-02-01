/* file -  stwld - wildcard compare */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
#include "m:\rid\chdef.h"
/* code -  st_wld - find wildcard substring */
int st_wld(
char *mod ,
char *str )
{ for(;;)  {
    if( !*mod && !*str)return 1;
    if ( *mod == '*') {
      ++mod;
      if( !*mod)return 1;
      while ( *str) {
        if( st_wld (mod,str++))return 1; }
      return 0; }
    if (( *mod == '?')
    ||(*mod == '%')) {
      if( !*str)return 0;
       ++mod, ++str;continue; }
    if( (ch_low (*mod) != ch_low (*str)) != 0)return 0;
    ++mod, ++str;
  } 
} 
