/* file -  stmem - string member test */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_mem - string membership test */
int st_mem(
register int cha ,
char *str )
{ char tmp ;
  if( str == NULL)return 0;
  while ( (tmp = *str++) != 0) {
    if( (BYTE )tmp == (BYTE )cha)return 1;
  } 
  return 0;
} 
