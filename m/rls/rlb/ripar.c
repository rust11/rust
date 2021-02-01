/* file -  ripar - parse rider files */
#include "m:\rid\ridef.h"
#include "m:\rid\imdef.h"
#include "m:\rid\eddef.h"
#include "m:\rid\medef.h"
#include "m:\rid\chdef.h"
#include "m:\rid\stdef.h"
/* code -  ripar - global data */
char riVcod = 0;
char riVcnd = 0;
char riVcon = 0;
char riVis = 0;
char riVbeg = 0;
char riVend = 0;
char riVwas = 0;
char riVsup = 0;
char riVinh = 0;
char riVnst = 0;
char riVhdr = 0;
char riAseg [64]= {0};
char riVini = 0;
int riVfil = 0;
void ri_cod (void );
void ri_ret (char *);
void ri_pst (char *);
void ri_eql (char *);
/* code -  parse rider code */
#define riTkey struct riTkey_t 
struct riTkey_t
{ char *Pnam ;
  void (*Pfun )();
   };
void kw_fun ();
void kw_pro ();
void kw_whi ();
void kw_for ();
void kw_rpt ();
void kw_nvr ();
void kw_fvr ();
void kw_unt ();
void kw_cnt ();
void kw_is ();
void kw_end ();
void kw_if ();
void kw_els ();
void kw_elf ();
void kw_fil ();
void kw_cod ();
void kw_dat ();
void kw_nxt ();
void kw_qui ();
void kw_exi ();
void kw_rep ();
void kw_fai ();
void kw_fin ();
void kw_typ ();
void kw_uni ();
void kw_nth ();
void kw_cas ();
void kw_eca ();
void kw_stm ();
void kw_ini ();
void kw_inc ();
void kw_exe ();
void kw_stp ();
void kw_abt ();
void kw_enu ();
void pp_if ();
void pp_elf ();
void pp_els ();
void pp_end ();
void pp_pra ();
void pp_hea ();
void pp_ehd ();
void pp_mod ();
void pp_emd ();
riTkey riAkey [] =  {
  "func", &kw_fun,
  "proc", &kw_pro,
  "while", &kw_whi,
  "repeat", &kw_rpt,
  "endless", &kw_nvr,
  "never", &kw_nvr,
  "forever", &kw_fvr,
  "until", &kw_unt,
  "count", &kw_cnt,
  "is", &kw_is,
  "end", &kw_end,
  "if", &kw_if,
  "else", &kw_els,
  "elif", &kw_elf,
  "file", &kw_fil,
  "code", &kw_cod,
  "data", &kw_cod,
  "next", &kw_nxt,
  "quit", &kw_qui,
  "exit", &kw_exi,
  "reply", &kw_rep,
  "fail", &kw_fai,
  "fine", &kw_fin,
  "type", &kw_typ,
  "unit", &kw_uni,
  "spin", &kw_nth,
  "nothing", &kw_nth,
  "case", &kw_cas,
  "end_case", &kw_eca,
  "include", &kw_inc,
  "stop", &kw_stp,
  "exeunt", &kw_stp,
  "abort", &kw_abt,
  "init", &kw_ini,
  "enum", &kw_enu,
  "If", &pp_if,
  "Elif", &pp_elf,
  "Else", &pp_els,
  "End", &pp_end,
  "pragma", &pp_pra,
  "header", &pp_hea,
  "module", &pp_mod,
  "", &kw_stm,
  NULL, NULL,
  };
/* code -  ri_par - top level parse */
void ri_par()
{ ed_ini ();
  riAseg[0] = 0;
  for(;;)  {
    riVsup = 0;
    if( (ri_get ()) == 0)break;
    ri_cod ();
    if ( riVnst == 0) {
      riVcod = 0; }
  } 
  if ( riVnst) {
    im_rep ("W-Program ends nested", NULL); }
  if ( riVhdr) {
    im_rep ("W-Missing [end header]", NULL); }
} 
/* code -  ri_cod - process code keywords */
void ri_cod()
{ 
#ifdef V2
  riTlin *lin = riPlin;
  riTent *ent = lin->Pent;
  ed_del (" ");
  if (( lin->Vflg & riKWD_)
  &&(ed_del (ent->Pnam))) {
    (*ent->Pfun)();
    } else {
    kw_stm (); }
#else
  register riTkey *key = riAkey;
  char msg [128];
  ed_del (" ");
  while ( key->Pnam != NULL) {
    if ( *key->Pnam == 0) {
       kw_stm ();break; }
    if ( ed_del (key->Pnam) == 0) {
       ++key;continue; }
    if ( riVwas) {
      FMT(msg, "(%s) cant be 'that' [%s]", key->Pnam, riAseg);
      im_rep ("W-%s", msg); }
     (*key->Pfun)();break;
  } 
#endif
  if( riVsup)return;
  ri_put ();
} 
/* code -  kw_is - is keyword */
void kw_is()
{ ++riPcur->Vis;
} 
/* code -  kw_end - end keyword */
void kw_end()
{ if ( ed_del (" file")) {
    ++riVsup;
    ++riPnxt->Veof;
    return; }
  if( ed_del (" case")){ kw_eca () ; return;}
  if( ed_del (" header")){ pp_ehd () ; return;}
  if( ed_del (" module")){ pp_emd () ; return;}
  if ( riVnst == 0) {
    im_rep ("W-Too many ends in [%s]", riAseg);
    return; }
  --riVnst;
  ed_pre ("} ");
} 
/* code -  kw_cod - code keyword */
void kw_cod()
{ ++riVfil;
  ut_seg ("code", NULL);
  ed_pre ("/* code - ");
  ed_app (" */");
} 
/* code -  kw_dat - data keyword */
void kw_dat()
{ ut_seg ("data", NULL);
  ed_pre ("/* data - ");
  ed_app (" */");
} 
/* code -  kw_fil - file keyword */
void kw_fil()
{ ++riVfil;
  ut_seg ("file", NULL);
  ed_pre ("/* file - ");
  ed_app (" */");
} 
/* code -  reply keywords */
void kw_rep()
{ ri_ret ("return");
} 
void kw_stp()
{ ri_ret ("exit");
} 
/* code -  ri_ret - construct temporary [return (value)] string */
void ri_ret(
char *kwd )
{ char tmp [128];
  register char *pnt ;
  st_mov (kwd, tmp);
  st_app (" (", tmp);
#ifdef V2
  if (( riPcur->Vflg & riIIF_)
  &&((pnt = ed_fnd ("if")) != NULL)) {
    *(char*)(me_mov (edPdot, st_end(tmp), pnt-edPdot)) = 0;
    st_mov (pnt, edPdot);
    } else {
    st_app (edPdot, tmp);
    ed_tru (); }
#else
  if ( (pnt = ed_fnd ("if")) != NULL) {
    *(char*)(me_mov (edPdot, st_end(tmp), pnt-edPdot)) = 0;
    st_mov (pnt, edPdot);
    } else {
    st_app (edPdot, tmp);
    ed_tru (); }
#endif
  st_app (")", tmp);
  ri_pst (tmp);
} 
/* code -  postfix if keywords */
void kw_nxt()
{ ri_pst ("continue");
} 
void kw_qui()
{ ri_pst ("break");
} 
void kw_exi()
{ ri_pst ("return");
} 
void kw_fai()
{ ri_pst ("return 0");
} 
void kw_fin()
{ ri_pst ("return 1");
} 
void kw_abt()
{ ed_del (" ");
  ed_del ("(");
  ed_del (" ");
  ed_del (")");
  ri_pst ("abort ()");
} 
/* code -  ri_pst - postfix ifs */
void ri_pst(
char *stm )
{ char tmp [128];
  char *pnt ;
  if ( ed_del (" if")) {
    st_mov (stm, tmp);
    st_app (";", tmp);
    ri_cnd ("if", tmp);
    return; }
  if ( (pnt = ed_fnd ("if")) == NULL) {
    if ( *edPdot != 0) {
      ed_app (";"); }
    ed_app (stm);
    ed_app (";");
    return; }
  *tmp = '{';
  *(char*)(me_mov (edPdot, tmp+1, pnt-edPdot)) = 0;
  st_mov (pnt, edPdot);
  ed_del (" if");
  st_app ("; ", tmp);
  st_app (stm, tmp);
  st_app (";}", tmp);
  ri_cnd ("if", tmp);
} 
/* code -  conditional keywords */
/* code -  kw_whi - while keyword */
void kw_whi()
{ if (( ed_fnd (" in "))
  ||(ed_fnd (" down "))) {
    kw_for ();
    } else {
    ri_cnd ("while ", NULL); }
} 
/* code -  kw_elf - elif keyword */
void kw_elf()
{ --riVnst;
  ri_cnd ("} else if ", NULL);
} 
/* code -  kw_if - if keyword */
void kw_if()
{ ri_cnd ("if ", NULL);
} 
/* code -  kw_els - else keyword */
void kw_els()
{ if ( *edPdot) {
    ed_app (";"); }
  ed_pre ("} else {");
} 
/* code -  ri_cnd - conditional statements */
void ri_cnd(
register char *str ,
register char *stm )
{ int cnd = riVcnd;
  ri_eql (edPdot);
  ed_pre ("(");
  ed_app (")");
  if ( cnd == 0) {
    ed_pre (str);
    } else {
    if ( cnd < 0) {ed_pre ("(!(") ;} else {
      ed_pre ("(") ; }
    ed_pre (str);
    for(;;)  {
      ri_put ();
      if ( (ri_get ()) == 0) {
        im_rep ("E-End of file in conditional [%s]", riAseg);
         ++riVsup;return; }
      ri_eql (edPdot);
      ed_pre ("(");
      ed_app (")");
      if( riVcnd == 0)break;
      if ( cnd != riVcnd) {
        im_rep ("W-Mixed conditional negation [%s]", riAseg); }
    } 
    if ( cnd < 0) {ed_app ("))") ;} else {
      ed_app (")") ; }
  } 
  if ( stm != NULL) {ed_app (stm) ;} else {
    ri_beg () ; }
} 
/* code -  ri_eql - check risky conditions */
void ri_eql(
char *cnd )
{ register char *str = cnd;
  char msg [128];
#ifdef V2
  if( (riPcur & riASN_) == 0)return;
#endif
  while ( *str) {
    if ( st_scn (" = ", str)) {
      FMT(msg, "Risky conditional [%s] in [%s]", cnd, riAseg);
      im_rep ("W-%s", msg);
      return; }
    if (( *str == _paren)
    ||(*str == _quotes)
    ||(*str == _apost)) {
      str = st_bal (str);
      } else {
      ++str; }
  } 
} 
