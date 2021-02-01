/* file -  stdel - delete leading substring */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_del - delete leading substring */
char *st_del(
register char *str ,
size_t cnt )
{ st_mov (str+cnt, str);
  return ( str);
} 
