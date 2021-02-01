/* file -  filoc - convert to local specification */
#include "m:\rid\rider.h"
#include "m:\rid\fidef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\ctdef.h"
#include "m:\rid\lndef.h"
#include "m:\rid\medef.h"
/* code -  fi_loc - convert spec for local rules */
void fi_loc(
char *spc ,
char *loc )
{ char *nxt ;
  int cnt = 0;
  fi_trn (spc, loc, 0);
#if Dos || Win || Wnt
  if ( (nxt = st_fnd (";", loc)) != 0) {*nxt = 0 ;}
  if( (nxt = st_fnd (":", loc)) == NULL)return;
  if( loc[1] == ':')return;
  *nxt = 0;
  if (( st_sam (loc, "con"))
  ||(st_sam (loc, "conin$"))
  ||(st_sam (loc, "conout$"))) {
    return; }
  if ( *loc == '_') {
    me_mov(loc+1,loc,st_len(loc));
    return; }
  *nxt = '\\';
  st_ins ("\\", loc);
#elif  0
  for(;;)  {
    if( (nxt = st_fnd ("\\", nxt)) == NULL)break;
    ++cnt;
  } 
  if( cnt == 0)return;
  nxt = st_fnd ('\\', loc);
  if( --cnt == 0){ *nxt = ':' ; return;}
  *nxt = '[';
  for(;;)  {
    nxt = st_fnd ("\\", nxt);
    if( --cnt == 0)return;
    *nxt = '.';
  } 
  *nxt = ']';
#endif 
} 
/* code -  fi_trn -- translate file spec */
int fi_trn(
char *spc ,
char *res ,
int mod )
{ char lft [128];
  char rep [128];
  char *trm ;
  int idx ;
  st_cop (spc, lft);
  st_cop (lft, res);
  if ( (trm = st_fnd (":", lft)) != 0) {
    *trm++ = 0;
    } else {
    trm = lft;
    while ( *trm) {
      if( !ct_aln (*trm++))return 1; } }
  if( (ln_trn (lft, rep, 0)) == 0)return 1;
  if( (st_len (rep) + st_len (trm)) > 124)return 0;
  if (( *trm)
  &&(*st_lst (rep) != '\\')
  &&(*trm != '\\')) {
    st_app ("\\", rep); }
  st_app (trm, rep);
  st_cop (rep, res);
  return 1;
} 
