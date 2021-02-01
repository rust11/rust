/* file -  strev - reverse string */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_rev - reverse string */
char *st_rev(
char *str )
{ char *res ;
  char *lst ;
  int cha ;
  if( *str == 0)return ( str );
  lst = res = st_end (str);
  while ( str < --lst) {
    cha = *lst;
    *lst = *str;
    *str++ = cha;
  } 
  return ( res);
} 
