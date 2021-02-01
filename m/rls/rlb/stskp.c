/* file -  stskp - string skip whitespace */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_skp - string skip whitespace */
char *st_skp(
register char *str )
{ while (( *str == ' ')
  ||(*str == '\t')) {
    ++str; }
  return ( str);
} 
