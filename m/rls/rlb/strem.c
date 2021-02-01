/* file -  st_rem - remove leading substring */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
char *st_rem(
register char *mod ,
register char *tar )
{ char *pst ;
  if( (pst = st_scn (mod, tar)) == NULL)return ( NULL );
  st_mov (pst, tar);
  return ( tar);
} 
