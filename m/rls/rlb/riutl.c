/* file -  riutl - various things */
#include "m:\rid\ridef.h"
#include "m:\rid\eddef.h"
#include "m:\rid\ctdef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\medef.h"
/* code -  ut_idt - parse or skip an identifier */
char *ut_idt(
char *str ,
char *idt )
{ while (( ct_aln (*str))
  ||(*str == '_')
  ||(*str == '$')) {
    if ( idt != NULL) {
      *idt++ = *str; }
    ++str; }
  if ( idt != NULL) {*idt = 0 ;}
  return ( str);
} 
/* code -  ut_tok - parse or skip a token */
char *ut_tok(
char *str ,
char *idt )
{ char *lim = str;
  if ( *lim == '(') {
    lim = st_bal (lim);
    } else {
    while ( *lim != 0) {
      if( *lim == ' ')break;
      if (( *lim == '(')
      ||(*lim == '\'')
      ||(*lim == '\"')) {
        lim = st_bal (lim);
        } else {
        ++lim; } } }
  if ( idt != NULL) {
    *(char *)(me_mov (str, idt, lim-str)) = 0; }
  return ( lim);
} 
/* code -  ut_seg - extract segment name */
void ut_seg(
char *sec ,
char *str )
{ char seg [64];
  if ( str == NULL) {str = edPdot ;}
  if( (st_seg ("Spn", "AD$_", str, seg)) == NULL)return;
  st_cop (seg, riAseg);
} 
