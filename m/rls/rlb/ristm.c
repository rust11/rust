/* file -  ristm - ordinary statements */
#include "m:\rid\ridef.h"
#include "m:\rid\imdef.h"
#include "m:\rid\eddef.h"
#include "m:\rid\chdef.h"
#include "m:\rid\medef.h"
#include "m:\rid\stdef.h"
void ri_dec (void );
void ri_ini (void );
int ri_lab (int );
riTkwd kw_stm ;
riTkwd kw_ini ;
/* code -  kw_nth - nothing keyword */
void kw_nth()
{ ed_del (" ");
  if ( *edPdot == 0) {
     ed_app (";");return; }
  kw_stm ();
} 
/* file -  kw_stm - ordinary statements */
void kw_stm()
{ char *pnt ;
  char *tmp ;
  if( ed_scn ("#"))return;
  if ( ed_fnd (" : ")) {
     ri_dec ();return; }
  if ( riVwas) {
    if ( riVend) {
      im_rep ("W-Invalid [that] with end in (%s)", riAseg); }
    ed_pre ("(");
    ed_app (")");
    tmp = edPbod;
    ed_set (riPnxt->Atxt,riPnxt->Pbod);
    ed_rep ("that", tmp);
    ed_set (riPcur->Atxt, tmp);
    *tmp = 0;
    return; }
  ed_del (" ");
  if( *edPdot == 0)return;
  if( (riVcnd | riVcon))return;
  if ( (pnt = ed_rep ("until","; if (")) != 0) {
    ed_pre ("for(;;) {");
    ed_app (") break;}");
    return; }
  if (( (pnt = ed_fnd ("if")) != 0)
  ||((pnt = ed_fnd ("while")) != 0)) {
    } else {
     ed_app (";");return; }
  ed_app (") {");
  *(char*)(me_mov (edPdot, st_end (edPdot), pnt-edPdot)) = 0;
  st_mov (pnt, edPdot);
  ed_app (";}");
  if ( ed_del (" while")) {
    ed_pre ("while (");
    return; }
  if ( ! ed_del (" if")) {
    im_rep ("E-Invalid embedded if statement (%s)", riAseg);
    return; }
  ed_pre ("if (");
  tmp = edPbod;
  ed_set (riPnxt->Atxt,riPnxt->Pbod);
  pnt = ed_fnd ("otherwise");
  ed_set (riPcur->Atxt, tmp);
  if( pnt == NULL)return;
  *pnt = 0;
  ed_app (" else {");
  ri_put ();
  ++riVsup;
  ++riVnst;
  ++riPnxt->Vend;
} 
/* code -  ri_dec - declaration */
void ri_dec()
{ register int bod = 0;
  if ( ed_rep(" is","=") != NULL) {++bod ;}
  ri_typ (edPdot, edPdot);
  if( ! bod){ ed_app (";") ; return;}
  ri_ini ();
} 
/* code -  kw_ini - init keyword */
void kw_ini()
{ if ( ed_fnd (" is") != NULL) {
     ri_dec ();return; }
  ri_typ (edPdot, edPdot);
  if ( riPnxt->Vis == 0) {
    ed_app (" = {0};");
    return; }
  ed_app (" = ");
  --riPnxt->Vis;
  ri_ini ();
} 
/* code -  ri_ini - handle initializers */
void ri_ini()
{ int lab = 0;
  ed_app (" {");
  ri_put ();
  ++riVnst;
  ++riVini;
  for(;;)  {
    if ( ! ri_get ()) {
      im_rep ("W-EOF in initializer (%s)", riAseg);
      break; }
    if ( riVend) {
       --riPcur->Vend;break; }
    if ( ed_del (" end")) {
      break; }
    lab = ri_lab (lab);
    if (( ed_mor ())
    &&(*ed_lst () != ',')) {
      ed_app (","); }
    ri_put ();
  } 
  --riVini;
  ed_app ("};");
  ri_put ();
  --riVnst;
  ++riVsup;
} 
/* code -  ri_lab - handle init labels */
int ri_lab(
int lab )
{ char idt [64];
  char *ptr ;
  int inc = 1;
  ed_mor ();
  if ( *ut_idt (edPdot, NULL) == ':') {
    ed_sub (":", "", idt);
    ed_mor ();
    ri_fmt ("#define %s %d", idt, &lab); }
  if ( *edPdot == ':') {
    *edPdot++ = '{';
    ++lab, inc = 0; }
  ed_mor ();
  ptr = edPdot;
  if ( *ptr != 0) {lab += inc ;}
  while ( *ptr != 0) {
    switch ( *ptr) {
    case ',':
      if ( ptr[1] != 0) {lab += inc ;}
     break; case '\"':
    case '\'':
    case '(':
      ptr = st_bal (ptr);
      continue;
       }
    ++ptr;
  } 
  if ( inc == 0) {*ptr++ = '}' ;}
  return ( lab);
} 
