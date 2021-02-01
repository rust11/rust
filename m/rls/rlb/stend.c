/* file -  stend - string end */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_end - get string end */
char *st_end(
register char *str )
{ while ( *str++) {;}
  return ( --str);
} 
