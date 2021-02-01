/* file -  st_low - lowercase string */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
#include "m:\rid\chdef.h"
/* code -  st_low - lowercase line */
char *st_low(
char *str )
{ char *ptr = str;
  while ( (*ptr++ = ch_low (*ptr)) != 0) {;}
  return ( str);
} 
