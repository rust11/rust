/* file -  meclr - clear memory */
#include "m:\rid\rider.h"
#include "m:\rid\medef.h"
/* code -  me_clr - clear memory */
void *me_clr(
register void *buf ,
size_t cnt )
{ 
#if meKrts
#include <string.h>
  memset (buf, 0, cnt);
  return ( (char *)buf + cnt);
#else 
  while ( cnt >= 64U) {
    ((long *)buf)[0] = 0;
    ((long *)buf)[4] = 0;
    ((long *)buf)[8] = 0;
    ((long *)buf)[12] = 0;
    ((long *)buf)[16] = 0;
    ((long *)buf)[20] = 0;
    ((long *)buf)[24] = 0;
    ((long *)buf)[28] = 0;
    ((long *)buf)[32] = 0;
    ((long *)buf)[36] = 0;
    ((long *)buf)[40] = 0;
    ((long *)buf)[44] = 0;
    ((long *)buf)[48] = 0;
    ((long *)buf)[52] = 0;
    ((long *)buf)[56] = 0;
    ((long *)buf)[60] = 0;
    (char *)buf += 64, cnt -= 64;
  } 
  while ( cnt >= 16U) {
    ((long *)buf)[0] = 0;
    ((long *)buf)[4] = 0;
    ((long *)buf)[8] = 0;
    ((long *)buf)[12] = 0;
    (char *)buf+= 16, cnt -= 16;
  } 
  while ( cnt--) {
    *((char *)buf)++ = 0; }
#endif 
  return ( buf);
} 
