/* file -  rienu - orders */
#include "m:\rid\ridef.h"
#include "m:\rid\imdef.h"
#include "m:\rid\eddef.h"
#include "m:\rid\stdef.h"
void ri_enm (void );
/* code -  kw_enu - enum specification */
void kw_enu()
{ char nam [64];
  int pnd = 0;
  if ( ed_fnd (" : {")) {
     ri_enm ();return; }
  if ( ! riVis) {
    im_rep ("W-Enum missing (is) [%s]", edPdot);
    return; }
  ed_rst (nam);
  ri_fmt ("#define %s enum %s_t", nam, nam);
  ++riVsup;
  ri_fmt ("enum %s_t ", nam);
  for(;;)  {
    ri_get ();
    if ( riPcur->Veof) {
      im_rep ("EOF in enum [%s]", nam);
      return; }
    if ( riVend) {
       --riPcur->Vend;break; }
    if ( ed_mor ()) {
      if( ed_del (" end"))break;
      if ( pnd != 0) {ed_pre (",") ;}
      pnd = (*ed_lst () != ','); }
    ri_put ();
  } 
  ed_app (" };");
  riPcur->Vend = 0;
  ri_put ();
  --riVnst;
  ++riVsup;
} 
/* code -  ri_enm - inline enum type */
void ri_enm()
{ char nam [64];
  ed_sub (" : ", "", nam);
  ri_fmt ("#define %s enum %s_t", nam, nam);
  st_app ("_t", nam);
  ed_pre (" ");
  ed_pre (nam);
  ed_pre ("enum ");
  ed_app (";");
} 
