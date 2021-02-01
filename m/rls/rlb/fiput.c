/* file -  fiput - put next line */
#include "m:\rid\rider.h"
#include "m:\rid\fidef.h"
#include "m:\rid\chdef.h"
#include "m:\rid\cldef.h"
/* code -  fi_put - Write line to file */
int fi_put(
register FILE *fil ,
register char *buf )
{ register char cha ;
#if Wdw
  if ( cl_tty (fil) != NULL) {
    PUT (buf);
    return 1; }
#endif 
  for(;;)  {
    if (( ((cha = *buf++) == _cr)
    &&(*buf == _nl))
    ||(cha == 0)) {
      cha = _nl; }
    putc (cha, fil);
  if( (cha == _nl))break; }
  return 1;
} 
/* code -  fi_prt - Put line without nl */
int fi_prt(
register FILE *fil ,
register char *buf )
{ register char cha ;
#if Wdw
  if ( cl_tty (fil) != NULL) {
    PUT ("%s", buf);
    return 1; }
#endif 
  while ( (cha = *buf++) != 0) {
    putc (cha, fil);
  } 
  return 1;
} 
