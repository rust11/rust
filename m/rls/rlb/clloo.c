/* file -  clloo - lookup keyword */
#include "m:\rid\rider.h"
#include "m:\rid\cldef.h"
#include "m:\rid\chdef.h"
/* code -  cl_loo - lookup keyword */
int cl_loo(
char *str ,
char *tab [],
int *pol )
{ char *ent ;
  int idx = 0;
  int neg = 1;
  for(;;)  {
    if( (ent = *tab++) == NULL)return ( idx );
    if ( *ent != '*') {
      if( cl_mat (str, ent))break;
      } else {
      if( *++ent == 0)break;
      if( cl_mat (str, ent))break;
      if (( ch_low (str[0]) == 'n')
      &&(ch_low (str[1]) == 'o')) {
        if( (cl_mat (str+2, ent)) != 0){ neg = 0 ; break;} } }
    ++idx;
  } 
  if ( pol != NULL) {*pol = neg ;}
  return ( idx);
} 
