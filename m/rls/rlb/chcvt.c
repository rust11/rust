/* file -  chcvt - character conversions */
#include "m:\rid\rider.h"
#include "m:\rid\chdef.h"
#include "m:\rid\ctdef.h"
/* code -  ch_upr - convert to uppercase */
int ch_upr(
int cha )
{ if (( ct_low (cha))
  &&(!(cha == '_' || cha == '$'))) {
    cha += (_A - _a); }
  return ( cha);
} 
/* code -  ch_low - convert to lowercase */
int ch_low(
int cha )
{ if (( ct_upr (cha))
  &&(!(cha == '_' || cha == '$'))) {
    cha += (_a - _A); }
  return ( cha);
} 
