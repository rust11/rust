/* file -  stdup - string duplicate */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
#include "m:\rid\medef.h"
/* code -  st_dup - duplicate string */
char *st_dup(
char *str )
{ char *dup ;
  dup = me_alc ((st_len (str) + 1));
  st_cop (str, dup);
  return ( dup);
} 
