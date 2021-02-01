/* file -  chmat - match character */
#include "m:\rid\rider.h"
#include "m:\rid\chdef.h"
/* code -  ch_mat - match character with string */
int ch_mat(
char *mod ,
int cha )
{ for(;;)  {
    if( (BYTE )*mod++ == (BYTE )cha)return 1;
  if( ! *mod)break; }
  return 0;
} 
