/* file -  stsam - strings same test */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_sam - string equality test */
int st_sam(
register char *mod ,
register char *tar )
{ while ( *mod++ == *tar) {
    if( *tar++ == 0)return 1;
  } 
  return 0;
} 
