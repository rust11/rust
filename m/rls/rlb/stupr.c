/* file -  st_upr - uppercase string */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
#include "m:\rid\chdef.h"
/* code -  st_upr - uppercase line */
char *st_upr(
char *str )
{ char *ptr = str;
  while ( (*ptr++ = ch_upr (*ptr)) != 0) {;}
  return ( str);
} 
