/* file -  stext - extract leading string segment */
#include "m:\rid\rider.h"
#include "m:\rid\stdef.h"
#include "m:\rid\medef.h"
/* code -  st_ext - extract leading string segment */
char *st_ext(
char *ctl ,
char *prg ,
char *str ,
char *seg )
{ char *pst ;
  *seg = 0;
  st_trm (str);
  if( (pst = st_par (ctl, prg, str)) == NULL)return ( NULL );
  *(char *)(me_mov (str, seg, pst-str)) = 0;
  st_mov (pst, str);
  st_trm (str), st_trm (seg);
  return ( str);
} 
