/* file -  stpar - string partition */
#include "m:\rid\rider.h"
#include "m:\rid\ctdef.h"
#include "m:\rid\stdef.h"
/* code -  st_par - string partition */
char *st_par(
char *ctl ,
char *lft ,
char *rgt )
{ char *prg ;
  char *beg = rgt;
  char *lst = NULL;
  int pos ;
  int cha ;
  int don ;
  int tst ;
  int req = 1;
  if ( *ctl == '-') {req = 0, ++ctl ;}
  if( *ctl == 0)return ( NULL );
  pos = *ctl++;
  for(;;)  {
    if( (cha = *rgt) == 0)break;
    prg = lft;
    tst = 0;
    don = 0;
    for(;;)  {
      switch ( *prg++ & 255) {
      case '|':
        ++don;
       break; case 'A':
        tst = ct_aln (cha);
       break; case 'C':
        tst = ct_ctl (cha);
       break; case 'D':
        tst = ct_dig (cha);
       break; case 'L':
        tst = ct_low (cha);
       break; case 'P':
        tst = ct_pun (cha);
       break; case 'S':
        tst = ct_spc (cha);
       break; case 'U':
        tst = ct_upr (cha);
       break; case 'X':
        tst = ct_hex (cha);
       break; case 'Z':
        tst = cha;
       break; default: 
        --prg, ++don;
         }
    if( (tst|don))break; }
    if ( *ctl && tst == 0) {
      tst = st_mem (cha, prg); }
    tst = tst ? 1: 0;
    if ( tst == req) {
      switch ( pos) {
      case 'f':
        return ( rgt);
       break; case 'j':
        return ( rgt + 1);
       break; case 'l':
        lst = rgt;
       break; case 'p':
        lst = rgt + 1;
       break; default: 
        return ( NULL);
         }
    } 
    ++rgt;
  } 
  if( lst != NULL)return ( lst );
  switch ( *ctl) {
  case 'b':
    return ( beg);
   break; case 'e':
    return ( rgt);
   break; case 'n':
    return ( NULL);
  default: 
    return ( NULL);
     }
} 
