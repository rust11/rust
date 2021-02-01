/* file -  ridef - type definition */
#include "m:\rid\ridef.h"
#include "m:\rid\imdef.h"
#include "m:\rid\eddef.h"
#include "m:\rid\chdef.h"
#include "m:\rid\stdef.h"
void ri_def (char *,int );
/* code -  kw_typ - type definition */
void kw_typ()
{ ri_def ("struct", 'S');
} 
/* code -  kw_uni - union definition */
void kw_uni()
{ ri_def ("union", 'U');
} 
/* code -  ri_def - definition common */
void ri_def(
char *kwd ,
int typ )
{ char Anam [64];
  char Astr [64];
  register char *ptr ;
  int fwd = 0;
  if (( typ == 'S')
  &&(ed_fnd (" : {"))) {
    ri_enm ();
    return; }
  if ( ed_rep (" : forward", "")) {
    ++fwd;
  } else if ( ed_fnd (" : ")) {
    ri_typ (edPdot, edPdot);
    ed_pre ("typedef");
    ed_app (";");
    return;
  } else if ( ! riVis) {
    im_rep ("W-Invalid type [%s]", edPdot);
    return; }
  ptr = st_skp (edPdot);
  st_app (kwd, (st_app (" ", (st_cop (ptr, Anam)))));
  st_app ("_t ", (st_cop (ptr, Astr)));
  ri_dis ("#define ");
  ri_dis (Anam);
  ri_dis (" ");
  ri_prt (Astr);
  ++riVsup;
  if( fwd)return;
  ri_dis (kwd);
  ri_dis (" ");
  ri_dis (ptr);
  ri_prt ("_t");
  for(;;)  {
    ri_get ();
    if ( riPcur->Veof) {
      im_rep ("EOF in type [%s]", Anam);
      return; }
    if( ed_del (" end"))break;
    if ( ed_del (" type")) {
      kw_typ ();
      continue;
    } else if ( ed_del (" unit")) {
      kw_uni ();
      continue; }
    if ( ! ed_fnd (" : ")) {
      im_rep ("Invalid type spec [%s]", Anam);
      break; }
    ri_typ (edPdot, edPdot);
    ed_app (";");
    if ( riVend == 0) {
      ri_put (); }
  if( riVend)break; }
  ed_app (" };");
  riPcur->Vend = 0;
  ri_put ();
  --riVnst;
  ++riVsup;
} 
