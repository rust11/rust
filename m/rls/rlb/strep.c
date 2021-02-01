/* file -  strep - replace substring */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
/* code -  st_rep - replace string if found */
char *st_rep(
char *mod ,
char *rep ,
char *str )
{ char *pnt ;
  if( (pnt = st_fnd (mod, str)) == NULL)return ( NULL );
  if( rep == NULL)return ( pnt );
  return ( (st_exc (rep, pnt, st_len (mod))));
} 
