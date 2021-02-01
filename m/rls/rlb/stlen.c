/* file -  stlen - string length */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_len - get string length */
int st_len(
register char *str )
{ register char *bas ;
  bas = str;
  while ( *str++) { }
  return ( str - bas - 1);
} 
