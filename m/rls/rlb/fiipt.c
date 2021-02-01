/* file -  fiipt - input/output file */
#include "m:\rid\rider.h"
#include "m:\rid\fidef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\cldef.h"
#include <stdio.h>
/* code -  fi_ipt - input file */
size_t fi_ipt(
FILE *fil ,
void *buf ,
size_t cnt )
{ 
  return ( (fread (buf, 1, cnt, fil)));
} 
/* code -  - fi_opt - write file */
size_t fi_opt(
FILE *fil ,
void *buf ,
size_t cnt )
{ char *tmp ;
  if ( cnt == (~1)) {cnt = st_len(buf) ;}
#if Wdw
  if ( cl_tty (fil)) {
    tmp = buf;
    while ( cnt--) {putchar (*tmp++) ;}
    return ( cnt); }
#endif 
  return ( (fwrite (buf, 1, cnt, fil)));
} 
