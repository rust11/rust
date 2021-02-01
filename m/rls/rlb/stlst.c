/* file -  stlst - last character */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_lst - look at last character */
char *st_lst(
register char *str )
{ if( *str == 0)return ( str );
  while ( *str++) {;}
  return ( str - 2);
} 
