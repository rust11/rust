/* file -  rifun - function declarations */
#include "m:\rid\ridef.h"
#include "m:\rid\imdef.h"
#include "m:\rid\ctdef.h"
#include "m:\rid\medef.h"
#include "m:\rid\eddef.h"
#include "m:\rid\chdef.h"
#include "m:\rid\stdef.h"
/* code -  locals */
int quFpro = 1;
#define riLstr  64
#define riTfun struct riTfun_t 
struct riTfun_t
{ char Anam [riLstr];
  char Alst [riLstr];
  char Atyp [riLstr];
  char Afml [riLstr*24];
   };
riTfun riVfun = {0};
void ri_fun (char *);
riTkwd kw_fun ;
riTkwd kw_pro ;
#define riTfns struct riTfns_t 
struct riTfns_t
{ riTfns *Psuc ;
  char *Pnam ;
   };
riTfns *riPfns = NULL;
/* code -  kw_fun - function preface */
void kw_fun()
{ ut_seg ("func", NULL);
  ri_fun ("");
} 
/* code -  kw_pro - procedure preface */
void kw_pro()
{ ut_seg ("proc", NULL);
  ri_fun ("void");
} 
/* code -  ri_fun - process function header */
void ri_fun(
char *typ )
{ register riTfun *fun = &riVfun;
  riTfns *fns ;
  register char *dot ;
  register char *ptr ;
  char *fml = &fun->Afml[0];
  int loc = 0;
  int cnt = 0;
  ++riVcod;
  if ( ed_fnd ("()")) {
    im_rep ("W-Removed [()] from func/proc statement [%s]", riAseg);
    ed_rep ("()", " "); }
  if ( ed_rep (" static", "")) {++loc ;}
  ed_skp (" ");
  st_cop (typ, fun->Atyp);
  st_cop ("(", fun->Alst);
  if ( (riVnst)) {
    im_rep ("W-Nested function [%s]", riAseg);
    riVnst = 0; }
  st_cop (edPdot, fun->Anam);
  fns = riPfns;
  while ( fns != NULL) {
    if ( st_sam (fun->Anam, fns->Pnam)) {
      im_rep ("E-Duplicate function name [%s]", fun->Anam); }
    fns = fns->Psuc;
  } 
  fns = me_acc ( sizeof(riTfns));
  fns->Psuc = riPfns;
  riPfns = fns;
  fns->Pnam = st_dup (fun->Anam);
  while ( ! (riVis|riVend)) {
    if ( ri_get () == 0) {
      im_rep ("E-End of file in func/proc header [%s]", riAseg);
      break; }
    if ( ed_del (" end")) {
       ++riVend;break; }
    if( ed_fnd (" : ") == NULL)break;
    if ( ed_del (" ()")) {
      ri_typ (edPdot, edPdot);
      st_cop (edPdot, fun->Atyp);
      break; }
    ed_del (" ");
    dot = edPdot;
    if ( ed_fnd ("...")) {
      st_app ("...,", fun->Alst);
      if ( quFpro) {
        st_cop ("...", fml);
        fml += riLstr, ++cnt; }
      continue; }
    if( ! ct_alp (*dot))break;
    if ( !quFpro) {
      ptr = st_end (fun->Alst);
      while ( ct_aln (*dot)) {
        *ptr++ = *dot++; }
      *ptr++ = _comma;
      *ptr = 0; }
    ri_typ (edPdot, edPdot);
    st_cop (edPdot, fml);
    if ( !quFpro) {st_app (";", fml) ;}
    fml += riLstr, ++cnt;
  } 
  if ( ! (riVis|riVend)) {
    im_rep ("E-Invalid func/proc header [%s]", riAseg); }
  *fml = 0;
  if ( !quFpro) {
    ptr = st_end (fun->Alst);
    if ( ptr[-1] == _comma) {--ptr ;}
    *ptr++ = paren_;
    *ptr = 0; }
  riVsup = 1;
  ed_tru ();
  if ( loc) {ed_app ("static ") ;}
  ed_app (fun->Atyp);
  ed_app (fun->Anam);
  if ( ! riVis) {
    im_rep ("E-Func/proc missing (is) [%s]", riAseg);
    ed_app (" ();");
    ri_prt (edPdot);
    return; }
  if ( quFpro) {
    ed_app ("(");
    if ( !cnt) {ed_app (")") ;}
    } else {
    ed_app (fun->Alst); }
  ri_prt (edPdot);
  fml = &fun->Afml[0];
  while ( *fml) {
    if ( quFpro) {
      if ( fml[riLstr]) {st_app (",", fml) ;} else {
        st_app (")", fml) ; } }
    ri_prt (fml);
    fml += riLstr; }
} 
