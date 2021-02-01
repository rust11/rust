/* file -  stloo - string lookup */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_loo - string lookup */
int st_loo(
char *mod ,
char *(*tab ))
{ int idx = 0;
  char *ent ;
  while ( (ent = *tab++) != NULL) {
    if ( st_cmp (mod, ent) == 0) {
      return ( idx); }
    ++idx; }
  return ( -1);
} 
