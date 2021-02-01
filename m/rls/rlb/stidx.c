/* file -  stidx - character index in string */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_idx - character index in string */
int st_idx(
int cha ,
char *str )
{ int idx = 0;
  int tmp ;
  if( str == NULL)return ( -1 );
  while ( (tmp = *str++) != 0) {
    if( ((BYTE )tmp == (BYTE )cha))return ( idx );
    ++idx;
  } 
  return ( -1);
} 
