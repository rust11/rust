/* file -  sttrm - trim whitespace */
#include "m:\rid\rider.h"
#include "m:\rid\ctdef.h"
#include "m:\rid\stdef.h"
/* code -  st_trm - trim spaces from ends of string */
char *st_trm(
register char *str )
{ register char *ptr = str;
  while ( *ptr != 0) {
    if( ! ct_spc (*ptr))break;
    ++ptr;
  } 
  if ( ptr != str) {st_mov (ptr, str) ;}
  ptr = st_end (str);
  while ( ptr != str) {
    if ( ! ct_spc (*--ptr)) {
      return ( ++ptr); }
    *ptr = 0; }
  return ( ptr);
} 
