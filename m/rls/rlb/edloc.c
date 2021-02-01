/* file -  edloc - find substring */
#include "m:\rid\rider.h"
#include "m:\rid\chdef.h"
#include "m:\rid\ctdef.h"
#include "m:\rid\stdef.h"
/* code -  ed_loc - find substring */
char *ed_loc(
register char *mod ,
register char *str )
{ register char *Str ;
  char *Mod = mod;
  int alp ;
  alp = ct_alp (mod[0]);
  for(;;)  {
    while ( *mod != *str) {
      if (( *str == _quotes)
      ||(*str == _apost)) {
        str = st_bal (str);
        continue; }
      if( ! *str++)return 0; }
    if (( alp)
    &&(ct_aln (str[-1]))
    &&(ct_aln (*str))) {
      while ( ct_aln (*str)) {
        ++str; }
      continue; }
    Str = str;
    for(;;)  {
      if ( ! *mod) {
        if (( ct_aln (mod[-1]))
        &&(ct_aln (str[0]))) {
          break; }
        return ( Str); }
    if( *mod++ != *str++)break; }
    mod = Mod;
    str = ++Str;
  } 
} 
