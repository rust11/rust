/* file -  ricas - case statements */
#include "m:\rid\ridef.h"
#include "m:\rid\ridat.h"
#include "m:\rid\chdef.h"
#include "m:\rid\imdef.h"
#include "m:\rid\eddef.h"
#include "m:\rid\stdef.h"
#define riKcas  32
int riVcas = 0;
int riAcas [riKcas]= {0};
/* code -  ri_orf - or/of preprocessor */
void ri_orf(
int brk )
{ char Alab [128];
  register char *lab = &Alab[0];
  char *dot = edPdot;
  *lab = 0;
  if ( ! riAcas[riVcas]) {
    if ( riVfil != 0) {
      im_rep ("W-of/or not in case in (%s)", riAseg); }
    riAcas[++riVcas] = 2; }
  if (( brk)
  &&(riAcas[riVcas] != 1)) {
    st_app (" break; ", lab); }
  ++riAcas[riVcas];
  ed_del (" ");
  if ( ed_del ("other")) {
    st_app ("default: ", lab);
    ri_idn (-1);
    ri_prt (lab);
    return; }
  dot = ut_tok (dot, (st_app ("case ", lab)));
  st_app (":", lab);
  ri_idn (-1);
  ri_prt (lab);
  st_mov (dot, edPdot);
  ed_del (" ");
} 
/* code -  kw_cas - case statement */
void kw_cas()
{ ed_pre ("switch (");
  ed_app (")");
  ri_beg ();
  riAcas[++riVcas] = 1;
} 
/* code -  kw_eca - end-case statement */
void kw_eca()
{ ri_end ();
  if ( ! riVcas) {
    im_rep ("W-end_case not in case in (%s)", riAseg);
    } else { --riVcas; }
} 
/* code -  kw_or - handle of ... to ... */
void kw_or()
{ char Alab [128];
  register char *lab = &Alab[0];
  register char *dot = edPdot;
  register char cha ;
  char ter ;
  int cnt ;
  cha = dot[1];
  ter = dot[8];
  dot[1] = 'a';
  dot[8] = 'a';
  if ( (st_cmp (dot, "'a' to 'a'"))) {
    dot[1] = cha;
    dot[8] = ter; }
  st_mov ("case 'a': ", lab);
  cnt = 8;
  while ( cha != ter) {
    if ( --cnt == 0) {
      cnt = 8;
      ri_new (); }
    lab[6] = cha;
    ri_dis (lab);
    if ( ter > cha) {
      ++cha;
      } else { --cha; } }
  ri_new ();
  ++riVsup;
} 
