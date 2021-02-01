/* file -  st_scn - scan leading substring */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
char *st_scn(
register char *mod ,
register char *tar )
{ while ( *mod != 0) {
    if( *mod != *tar)return ( NULL );
    ++mod, ++tar; }
  return ( tar);
} 
