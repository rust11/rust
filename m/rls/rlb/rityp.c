/* file -  rityp - convert rider type to C type */
#include "m:\rid\ridef.h"
#include "m:\rid\eddef.h"
#include "m:\rid\medef.h"
#include "m:\rid\imdef.h"
#include "m:\rid\ctdef.h"
#include "m:\rid\stdef.h"
/* code -  locals */
static char *ri_abs (char *,char *,int );
/* code -  ri_typ - convert type */
int ri_typ(
register char *str ,
char *dst )
{ char buf [128];
  int len ;
  buf[0] = 0;
  if( ! st_fnd (" : ", str))return 0;
  str = ri_abs (str, buf, '=');
  len = st_len (buf);
  st_mov (str, dst + len);
  me_mov (buf, dst, len);
  return 1;
} 
/* code -  ri_cst - cast */
ri_cst(
char *str )
{ char *dst ;
  char dat [128];
  char *res = &dat[0];
  int len ;
  while ( *str != 0) {
    if (( *str == '"')
    ||(*str == '\'')) {
      str = st_bal (str);
      continue; }
    if( *str != '<'){ ++str ; continue;}
    if (( str[1] == '<')
    ||(str[1] == '>')) {
       str += 2;continue; }
    *str++ = '(';
    dst = str;
    *res = 0;
    str = ri_abs (str, res, '>');
    if ( *str == '>') {
      *str = ')';
      } else {
      im_rep ("W-Missing [>] in cast [%s]", str); }
    len = st_len (res);
    st_mov (str, dst + len);
    me_mov (res, dst, len);
    str = dst + len;
  } 
  return 1;
} 
/* code -  ri_abs - get abstract declarator */
#define skip(str)  ++str while ct_spc (*str)
#define last(str)  ++str while *str != 0
char *ri_abs(
register char *str ,
register char *res ,
int ter )
{ char buf [64];
  register char *ptr ;
  int alp = 0;
  int kon = 0;
  char *pex ;
  if ( (ptr = st_fnd (" bits", str)) != NULL) {
    res = st_end (res);
    while ( str < ptr) {
      if (( *str == '[')
      ||(*str == ']')) {
        } else {
        *res++ = *str; }
      ++str;
    } 
    *res = 0;
    str += 5;
    return ( str); }
  while ( *str) {
    if( *str == ter)break;
    if( *str == ',')break;
    str = st_skp (str);
    if ( st_scn (": ", str)) {
      str += 2;
      alp = 0;
      if ( st_scn ("* \"", str)) {
        st_ins ("char = ", str+2);
        continue; }
      if( *str != '"')continue;
      st_ins ("[] char = ", str);
      continue; }
    pex = "*";
    ptr = NULL;
    if (( ct_alp (*str))
    ||((ptr = st_scn ("...", str)) != 0)) {
      ++alp;
      if ( ptr != NULL) {
        str = ptr;
        st_cop ("... ", buf);
        } else {
        ptr = buf;
        while ( ct_aln (*str)) {
          *ptr++ = *str++; }
        *ptr++ = ' ', *ptr = 0; }
      str = st_skp (str);
      if ( st_cmp (buf, "near ")) {
        pex = " near *";
      } else if ( st_cmp (buf, "far ")) {
        pex = " far *";
        } else {
         st_ins (buf, res);continue; }
      --alp;
      if ( *str == '*' || *str == '@') {
        } else {
         st_ins (buf, res);continue; } }
    if ( alp) {
      im_rep ("W-Invalid type in (%s)", riAseg); }
    switch ( *str & 255) {
    case '@':
      ++kon;
    case '*':
      ++str;
      str = st_skp (str);
      if ( ! *res) {
         st_ins (pex, res);continue; }
      if ( ct_alp (*str)) {
         st_ins (pex, res);continue; }
      st_ins (pex, res);
      st_ins ("(", res);
      st_app (")", res);
      continue;
     break; case '[':
      ptr = st_end (res);
      for(;;)  {
        if( *str == 0)break;
        *ptr++ = *str;
        *ptr = 0;
      if( *str++ == ']')break; }
      continue;
     break; case '(':
      ++str;
      st_app ("(", res);
      for(;;)  {
        str = st_skp (str);
        if ( *str == ')') {
          st_app (")", res);
           ++str;break; }
        str = (ri_abs (str, st_end (res), ')'));
        if ( *str == ',') {
          st_app (",", res);
           ++str;continue;
        } else if ( *str == ')') {
          ++str;
          st_app (")", res);
          } else {
          im_rep ("W-Missing [)] in type [%s]", str);
        } 
       break;} 
      continue;
       }
    im_rep ("W-Unknown type in [%s]", str);
    break;
  } 
  if ( kon != 0) {
    st_ins (" const ", res); }
  return ( str);
} 
/* code -  ri_siz - sizeof operator */
void ri_siz()
{ char *pnt ;
  if( (pnt = ed_fnd ("#")) == NULL)return;
  if (( st_scn ("#include", pnt) != NULL)
  ||(st_scn ("#if ", pnt) != NULL)
  ||(st_scn ("#ifdef", pnt) != NULL)
  ||(st_scn ("#ifndef", pnt) != NULL)
  ||(st_scn ("#elif", pnt) != NULL)
  ||(st_scn ("#else", pnt) != NULL)
  ||(st_scn ("#endif", pnt) != NULL)
  ||(st_scn ("#undef", pnt) != NULL)) {
    return; }
  for(;;)  {
    if( (pnt = ed_rep ("#"," sizeof")) == NULL)break;
    pnt = st_skp (pnt);
    if( *pnt == '(')continue;
    st_mov (pnt, pnt+1);
    *pnt++ = '(';
    while (( ct_aln (*pnt))
    ||(*pnt == '_')
    ||(*pnt == '$')) {
      ++pnt; }
    st_mov (pnt, pnt+1);
    *pnt = ')';
  } 
} 
/* code -  ri_kon - pointer to constant operator */
void ri_kon()
{ char *pnt ;
  for(;;)  {
    if( (pnt = ed_rep ("@", "*")) == NULL)break;
    pnt = st_skp (pnt);
    if ( *pnt == '(') {
      pnt = st_bal (pnt);
      } else {
      while (( ct_aln (*pnt))
      ||(*pnt == '_')
      ||(*pnt == '$')) {
        ++pnt; } }
    st_mov (pnt, pnt+7);
    me_mov (" const ", pnt, 7);
  } 
} 
/* code -  ri_bit - bit operator */
void ri_bit()
{ char *pnt ;
  int par = 0;
  int cnt ;
  for(;;)  {
    if( (pnt = ed_rep ("`", "")) == NULL)break;
    pnt = st_skp (pnt);
    cnt = 7;
    if ( *pnt == '(') {
      --cnt, ++par; }
    st_mov (pnt, pnt+cnt);
    pnt = (me_mov ("(1 << (", pnt, cnt));
    if ( par) {
      pnt = st_bal (pnt);
      } else {
      while (( ct_aln (*pnt))
      ||(*pnt == '_')
      ||(*pnt == '$')) {
        ++pnt; } }
    cnt = par ? 1: 2;
    st_mov (pnt, pnt+cnt);
    me_mov ("))", pnt, cnt);
  } 
} 
