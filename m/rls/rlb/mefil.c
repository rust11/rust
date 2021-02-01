/* file -  meset - set memory */
#include "m:\rid\rider.h"
#include "m:\rid\medef.h"
#include <string.h>
void *me_set(
void *dst ,
size_t cnt ,
int val )
{ memset (dst, val, cnt);
  return ( (char *)dst + cnt);
} 
