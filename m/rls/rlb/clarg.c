/* code -  cl_arg - returns nth argument */
#include "m:\rid\rider.h"
#include "m:\rid\cldef.h"
#include "m:\rid\ctdef.h"
#include "m:\rid\medef.h"
#include "m:\rid\mxdef.h"
#include "m:\rid\stdef.h"
static int cl_ptr (int ,char *,int ,char *,char **);
/* code -  cl_ass - assemble command line from vector */
int cl_ass(
char *str ,
int cnt ,
char *(*vec ))
{ 
#if Wnt
  char buf [mxLIN];
  char *cmd = buf;
  if( (cl_lin (cmd)) == 0)return ( 0 );
  while ( *cmd && *cmd != ' ') {++cmd ;}
  while ( *cmd && *cmd == ' ') {++cmd ;}
  st_cop (cmd, str);
  return 1;
#else 
  int nth = 0;
  ++vec, --cnt;
  *str = 0;
  while ( cnt--) {
    if( ((st_len (*vec) + st_len (str)) + 2) >= mxLIN)return 0;
    if ( nth++) {st_app (" ", str) ;}
    st_app (*vec++, str);
  } 
  return 1;
#endif 
} 
/* code -  cl_vec - convert to string vector */
int cl_vec(
char *str ,
int *cnt ,
char *(*(*ptr )))
{ int nth = 0;
  char *(*vec )= *ptr;
  char buf [256];
  if ( vec == NULL) {
    vec = me_alc (33 *  sizeof(char *));
    *ptr = vec; }
  *cnt = 0;
  *vec = st_dup ("");
  for(;;)  {
    *vec = NULL, *cnt = nth;
    if( nth == 32)return 0;
    if( (cl_nth (nth++, str, buf)) == 0)return 1;
    *vec++ = st_dup (buf);
  } 
  return 1;
} 
/* code -  cl_arg - get nth argument from string */
int cl_arg(
int nth ,
char *str ,
char *dst ,
int sep ,
char *bal )
{ char *src ;
  int len ;
  if( (len = cl_ptr(nth,str,sep,bal,&src)) == 0)return ( 0 );
  *(char *)me_mov (src,dst,len) = 0;
  return 1;
} 
/* code -  cl_ptr - get pointer to nth argument */
static int cl_ptr(
int nth ,
char *str ,
int sep ,
char *bal ,
char *(*res ))
{ if( nth < 0)return 0;
  if ( sep == 0) {sep = ' ' ;}
  if ( bal == 0) {bal = "\"\'" ;}
  for(;;)  {
    while ( ct_spc (*str)) {++str ;}
    if( *str == 0)break;
    *res = str;
    while ( *str != 0) {
      bal = "\"\'";
      while ( *bal != 0) {
        if ( *str == *bal++) {
           str = st_bal (str);break; } }
      if( *str == ' ' || !*str)break;
      ++str;
    } 
    if( nth-- == 0)break;
    if ( *str != 0) {++str ;}
  } 
  if( nth >= 0)return 0;
  return ( str-*res);
} 
