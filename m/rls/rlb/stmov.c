/* file -  stmov - move string */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
#include "m:\rid\medef.h"
/* code -  st_mov - move string - copy overlapping strings */
char *st_mov(
char *src ,
char *dst )
{ 
  return ( ((char *)me_mov (src, dst, (st_len (src) + 1))) - 1);
} 
