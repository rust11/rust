/* file -  imarg - get image argument */
#include "m:\rid\rider.h"
/* code -  im_arg - get image argument */
int im_arg(
int arg ,
char *dst ,
int lim ,
int cnt ,
char *(*vec ))
{ char *str ;
  int len = 0;
  *dst = 0;
  if( arg >= cnt)return ( -1 );
  str = vec[arg];
  while ( len < lim) {
    if( (*dst++ = *str++) == 0)break;
    ++len;
  } 
  return ( len);
} 
