/* file -  figet - get next line */
#include <stdio.h>
#include "m:\rid\rider.h"
#include "m:\rid\fidef.h"
#include "m:\rid\chdef.h"
/* code -  fi_get - Returns next line from a file */
int fi_get(
FILE *fid ,
char *buf ,
register int cnt )
{ register char *dot = buf;
  register int cha ;
  for(;;)  {
    *dot = 0;
    if( cnt == 0)break;
    if( (cha = getc (fid)) == EOF)return ( EOF );
    if(( cha == 0)
    ||(cha == _cr))continue;
    if( cha == _nl)break;
    *dot++ = cha;
    --cnt;
  } 
  return ( (dot - buf));
} 
