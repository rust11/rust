/* file -  stbal - balance substring */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
#include "m:\rid\chdef.h"
/* code -  st_bal - balance substring */
char *st_bal(
register char *str )
{ register char ter = *str++;
  if ( ter == _paren) {
    ter = paren_; }
  while ( *str) {
    if ( *str == ter) {
      return ( ++str); }
    if ( ter == paren_) {
      if (( *str == _quotes)
      ||(*str == _apost)
      ||(*str == _paren)) {
        str = st_bal (str);
        continue; }
      } else {
      if (( *str == _back)
      &&(! *++str)) {
        break; } }
    ++str;
  } 
  return ( str);
} 
