/* file -  clmat - match keyword with abbreviation */
#include "m:\rid\rider.h"
#include "m:\rid\cldef.h"
#include "m:\rid\chdef.h"
/* code -  cl_mat - match keyword with abbreviation */
int cl_mat(
char *str ,
char *pat )
{ int abb = 0;
  if( *pat == '*' && pat[1] == 0)return 1;
  if( *pat ==  0&& *str == 0)return 1;
  for(;;)  {
    if( *pat == '*'){ ++abb, ++pat ; continue;}
    if ( *str == 0) {
      if( *pat == 0)return 1;
      return ( abb); }
    if( (ch_low (*pat) != ch_low (*str)) != 0)return 0;
    ++pat, ++str;
  } 
} 
