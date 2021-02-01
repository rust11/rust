/* file -  fidef - default file spec */
#include "m:\rid\rider.h"
#include "m:\rid\fidef.h"
#include "m:\rid\chdef.h"
#include "m:\rid\medef.h"
#include "m:\rid\mxdef.h"
#include "m:\rid\stdef.h"
/* code -  fiAdef - state table */
char fiAdef [] =  {
  0 , ':', ':',0 , ':', -1,
  '[', ']', -1,
  0 , '.', 0,
  '.', ';', 0,
  ';', 0, 0,
  -1,
  };
static int fi_itm (char *,char *);
/* code -  fi_def - merge default spec */
int fi_def(
char *src ,
char *def ,
char *dst )
{ char buf [mxSPC];
  char *spc = buf;
  register int sps ;
  register int dfs ;
  register char *sta = fiAdef;
  register char *out = dst;
  st_cop (src, spc);
  for(;;)  {
    sps = fi_itm (sta, spc);
    dfs = fi_itm (sta, def);
    if ( sps) {
      out = me_cop (spc, out, sps);
      } else {
      out = me_cop (def, out, dfs); }
    *out = 0;
    spc += sps;
    def += dfs;
    sta += 3;
  if( *sta == -1)break; }
  *out = 0;
  if( *spc || out == dst)return 0;
   fi_loc (dst, dst);return 1;
} 
/* code -  fi_itm - get file spec item */
int fi_itm(
register char *sta ,
register char *ptr )
{ register char *str = ptr;
  if( str == NULL)return 0;
  for(;;)  {
    if ( *sta++) {
      if( *(sta-1) != *str)return 0; }
    while ( *str != *sta) {
      if ( *str == 0) {
        if (( (*sta == '.'))
        ||((*sta == ';'))) {
          break; }
        return 0; }
      ++str; }
    if( *++sta == 0)break;
    ++str;
    if ( *sta != -1) {
      if( *sta != *str)return 0;
      ++str; }
   break;} 
  return ( str-ptr);
} 
