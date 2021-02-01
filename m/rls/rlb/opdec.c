/* file -  opdec - output decimal */
#include "m:\rid\rider.h"
static int opVdec = 0;
/* code -  op_dec - decimal output */
char *op_dec(
int val ,
char *buf )
{ int dig ;
  int prt = 0;
  int div = opVdec;
  if ( div == 0) {
    div = 10000;
    while ( (div * 10) > 0) {
      div *= 10; }
    opVdec = div; }
  if ( val < 0) {
    val = -val;
    *buf++ = '-'; }
  for(;;)  {
    dig = 0;
    while ( div <= val) {
      ++dig;
      val -= div; }
    if ( prt |= dig) {
      *buf++ = dig + '0'; }
  if( (div /= 10) <= 1)break; }
  *buf++ = val + '0';
  *buf = 0;
  return ( buf);
} 
