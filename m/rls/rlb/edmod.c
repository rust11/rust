/* file -  edmod - editing functions */
#include "m:\rid\rider.h"
#include "m:\rid\chdef.h"
#include "m:\rid\ctdef.h"
#include "m:\rid\medef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\eddef.h"
char *ed_lst ();
char *edPlin = NULL;
char *edPbod = NULL;
char *edPdot = NULL;
/* code -  ed_ini - init editor */
int ed_ini()
{ return 1;
} 
/* code -  ed_set - setup editor pointers */
void ed_set(
char *lin ,
char *bod )
{ edPlin = lin;
  edPbod = bod;
  edPdot = bod;
} 
/* code -  ed_del - delete string if found */
int ed_del(
char *str )
{ register char *pnt ;
  if( (pnt = ed_scn (str)) == NULL)return 0;
  st_mov (pnt, edPdot);
  return 1;
} 
/* code -  ed_chg - change leading substring */
ed_chg(
char *str ,
char *rep )
{ register char *dot ;
  if( ! ed_del (str))return 0;
  dot = edPdot;
  ed_pre (rep);
  edPdot = dot;
  return 1;
} 
/* code -  ed_skp - skip string if found */
int ed_skp(
char *str )
{ register char *pnt ;
  if( (pnt = ed_scn (str)) == NULL)return 0;
  edPbod = pnt;
  edPdot = pnt;
  return 1;
} 
/* code -  ed_scn - scan leading substring */
char *ed_scn(
char *str )
{ register char *dot = edPdot;
  if ( *str == _space) {
    str++;
    dot = st_skp (dot); }
  if( (dot = st_scn (str, dot)) == NULL)return ( NULL );
  if (( ct_aln (*str))
  &&(ct_aln (*dot))) {
    return ( NULL); }
  return ( dot);
} 
/* code -  ed_sub - substring locate/remove, copy prefix */
char *ed_sub(
char *mod ,
char *rep ,
char *dst )
{ char *pnt ;
  ed_del (" ");
  if( (pnt = ed_rep (mod, rep)) == NULL)return ( NULL );
  *(char *)(me_mov (edPdot, dst, pnt-edPdot))=0;
  st_mov (pnt, edPdot);
  return ( (st_trm (dst)));
} 
/* code -  ed_rst - copy/delete rest of line */
char *ed_rst(
char *dst )
{ ed_del (" ");
  st_mov (edPdot, dst);
  ed_tru ();
  return ( (st_trm (dst)));
} 
/* code -  ed_rep - replace string if found */
char *ed_rep(
register char *mod ,
char *rep )
{ register char *pnt ;
  if( (pnt = ed_fnd (mod)) == NULL)return ( NULL );
  if( rep == NULL)return ( pnt );
  return ( (ed_exc (rep, pnt, st_len (mod))));
} 
/* code -  ed_fnd - find substring */
char *ed_fnd(
char *str )
{ return ( ed_loc (str, edPdot));
} 
/* code -  ed_exc - exchange substring */
char *ed_exc(
register char *rep ,
register char *dst ,
int old )
{ int new = st_len (rep);
  int dif = old - new;
  if ( dif >= 0) {
    dst = me_mov (rep, dst, new);
    if ( dif) {
      st_mov (dst+dif, dst); }
    return ( dst); }
  st_mov (dst, dst-dif);
  me_mov (rep, dst, new);
  return ( dst+new);
} 
/* code -  ed_tru - truncate line */
void ed_tru()
{ *edPdot = 0;
} 
/* code -  ed_pre - prepend substring */
char *ed_pre(
register char *str )
{ register int len = st_len (str);
  if ( ed_gap (str, edPbod)) {
    ed_pre (" "); }
  st_mov (edPbod, edPbod+len);
  me_mov (str, edPbod, len);
  return ( edPdot += len);
} 
/* code -  ed_app - append substring */
char *ed_app(
register char *str )
{ if ( ed_gap (edPdot, str)) {
    ed_app (" "); }
  return ( st_app (str, edPdot));
} 
/* code -  ed_gap - check alpha gap */
ed_gap(
char *src ,
char *dst )
{ int lst ;
  int fst ;
  int res ;
  lst = ct_aln (*st_lst (src));
  fst = ct_aln (*dst);
  res = fst && lst;
  return ( res);
} 
/* code -  ed_mor - skip spaces and check more on line */
int ed_mor()
{ ed_del (" ");
  if( *edPdot != 0)return 1;
  return 0;
} 
/* code -  ed_lst - look at last character */
char *ed_lst()
{ return ( st_lst (edPdot));
} 
