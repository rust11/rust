/* file -  stexc - exchange leading substring */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_exc - exchange leading substring */
char *st_exc(
register char *rep ,
register char *str ,
int cnt )
{ st_mov (str+cnt, str);
  return ( (st_ins (rep, str)));
} 
