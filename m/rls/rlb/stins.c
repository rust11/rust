/* file -  stins - insert string */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
#include "m:\rid\medef.h"
/* code -  st_ins - insert string */
char *st_ins(
char *ins ,
char *dst )
{ int len = st_len (ins);
  st_mov (dst, dst+len);
  return ( (char *)(me_cop (ins, dst, len)));
} 
