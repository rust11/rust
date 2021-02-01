/* file -  riloo - for and repeat */
#include "m:\rid\ridef.h"
#include "m:\rid\imdef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\medef.h"
#include "m:\rid\eddef.h"
/* code -  kw_for - for statements */
static char foAvar [64]= {0};
static char foAbas [64]= {0};
static char foAlim [64]= {0};
static char foAstp [64]= {0};
void kw_for()
{ char *var = &foAvar[0];
  char *bas = &foAbas[0];
  char *lim = &foAlim[0];
  char *stp = &foAstp[0];
  int dwn = 0;
  st_cop ("+1", stp);
  if ( ed_sub (" down ", "", var) != NULL) {
    dwn = 1;
  } else if ( ed_sub (" in ", "", var) == NULL) {
    im_rep ("W-Invalid [while] in [%s]", riAseg);
    return; }
  if ( (ed_sub ("..", "", bas)) == NULL) {st_cop ("0", bas) ;}
  if ( (ed_sub (" by ", "", lim)) == NULL) {st_cop (edPdot, lim) ;} else {
    st_cop (edPdot, stp) ; }
  ed_tru ();
  ed_app ("for (");
  ed_app (var);
  ed_app (" = (");
  ed_app (bas);
  ed_app ("); ");
  ed_app (var);
  if ( dwn == 0) {ed_app ("<=(") ;} else {
    ed_app (">=(") ; }
  ed_app (lim);
  ed_app ("); ");
  if (( dwn)
  ||(st_cmp (stp, "-1") == 0)) {
    ed_app ("--");
    ed_app (var);
  } else if ( st_cmp (stp, "+1") == 0) {
    ed_app ("++");
    ed_app (var);
    } else {
    ed_app (var);
    ed_app (" += (");
    ed_app (stp);
    ed_app (")"); }
  ed_app (")");
  ri_beg ();
} 
/* code -  kw_rpt - repeat keyword */
void kw_rpt()
{ if ( ! ed_del (" if")) {
    ed_pre ("for(;;) ");
    ri_beg ();
    return; }
  im_rep ("W-Obselete (repeat if) in [%s]", riAseg);
  ed_pre ("for(;;) { if (!(");
  ed_app (")) break;");
  ri_put ();
  ++riVnst;
  ++riVsup;
} 
/* code -  kw_nvr - never keyword */
void kw_nvr()
{ --riVnst;
  ed_pre (" break;} ");
} 
/* code -  kw_fvr - forever keyword */
void kw_fvr()
{ --riVnst;
  ed_pre ("} ");
} 
/* code -  kw_unt - until keyword */
void kw_unt()
{ ri_cnd ("if", "break;");
  ed_app (" }");
  --riVnst;
} 
/* code -  kw_cnt - count keyword */
void kw_cnt()
{ --riVnst;
  ed_pre (" if (--(");
  ed_app (") <= 0) break;}");
} 
