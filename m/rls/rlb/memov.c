/* file -  memov - move memory */
#include "m:\rid\rider.h"
#include "m:\rid\medef.h"
/* code -  me_mov - move overlapping memory */
void *me_mov(
register void *src ,
register void *dst ,
size_t cnt )
{ void *res ;
#if meKrts
#include <string.h>
  memmove (dst, src, cnt);
  return ( (char *)dst + cnt);
#else 
  if( cnt == 0)return ( dst );
  if ( src > dst) {
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
    } else {
    (char *)src += cnt;
    (char *)dst += cnt;
    res = dst;
    while ( cnt >= 16U) {
      (char *)dst -= 16, (char *)src -= 16;
      ((long *)dst)[3] = ((long *)src)[3];
      ((long *)dst)[2] = ((long *)src)[2];
      ((long *)dst)[1] = ((long *)src)[1];
      ((long *)dst)[0] = ((long *)src)[0];
      cnt -= 16; }
    while ( cnt--) {
      *--((char *)dst) = *--((char *)src); }
    return ( res);
  } 
#endif 
} 
