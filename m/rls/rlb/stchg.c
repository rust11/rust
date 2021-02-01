/* file -  st_chg - change leading substring */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_chg - change leading substring */
char *st_chg(
char *mod ,
char *rep ,
char *tar )
{ 
  if( (st_rem (mod, tar)) == NULL)return ( NULL );
  return ( (st_ins (rep, tar)));
} 
