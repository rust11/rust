/* file -  mecop - memory copy */
#include "m:\rid\rider.h"
#include "m:\rid\medef.h"
/* code -  me_cop - copy block */
void *me_cop(
register void *src ,
register void *dst ,
size_t cnt )
{ 
#if meKrts
#include <string.h>
  memcpy (dst, src, cnt);
  return ( (char *)dst + cnt);
#else 
  while ( cnt >= 16U) {
    ((long *)dst)[0] = ((long *)src)[0];
    ((long *)dst)[1] = ((long *)src)[1];
    ((long *)dst)[2] = ((long *)src)[2];
    ((long *)dst)[3] = ((long *)src)[3];
    (char *)dst += 16, (char *)src += 16;
    cnt -= 16; }
  while ( cnt--) {
    *((char *)dst)++ = *((char *)src)++; }
  return ( dst);
#endif 
} 
