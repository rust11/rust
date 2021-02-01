/* file -  stseg - extract leading string segment */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
#include "m:\rid\medef.h"
/* code -  st_seg - extract leading string segment */
char *st_seg(
char *ctl ,
char *prg ,
char *str ,
char *seg )
{ char *pst ;
  *seg = 0;
  if ( *ctl == 'S') {
    ++ctl, str = st_skp (str); }
  if( (pst = st_par (ctl, prg, str)) == NULL)return ( NULL );
  *(char *)(me_mov (str, seg, pst-str)) = 0;
  return ( pst);
} 
