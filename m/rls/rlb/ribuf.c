/* file -  ribuf - buffered i/o */
#include "m:\rid\ridef.h"
#include "m:\rid\ridat.h"
#include "m:\rid\chdef.h"
#include "m:\rid\ctdef.h"
#include "m:\rid\eddef.h"
#include "m:\rid\imdef.h"
#include "m:\rid\iodef.h"
#include "m:\rid\medef.h"
#include "m:\rid\stdef.h"
/* code -  locals */
static void ri_ipt (void );
static void ri_kwk (void );
static int ri_red (char *);
int ri_dbg (char *);
char *riAcnd []= {
  "&&", "||",
  "!&", "!|", NULL};
char *riAext []= {
  "&&", "||",
  "!&", "!|", NULL};
char *riArep []= {
  " ??", ":",
  "not", "!",
  "<>", "NULL",
  "own", "static",
  "size", "size_t",
  "#include", "include",
  "byte", "sbyte",
  "LONG", "ULONG",
  "FAR", "TOFAR",
  "fast", "register",
  "Int", "int register",
  "Char", "char register",
  "reply null", "reply NULL",
  NULL, NULL};
char *riAifs []= {
  "if fail", "if that eq 0","if fine", "if that ne 0",
  "if null", "if that eq NULL",
  "if NULL", "if that eq NULL",
  "if real", "if that ne NULL",
  "if eof", "if that eq EOF",
  "if EOF", "if that eq EOF",
  "if eq", "if that eq",
  "if ne", "if that ne",
  "if gt", "if that gt",
  "if ge", "if that ge",
  "if lt", "if that lt",
  "if le", "if that le",
  "if <>", "if that eq NULL",
  NULL, NULL};
char *riAunt []= {
  "until fail", "until that eq 0","until fine", "until that ne 0",
  "until null", "until that eq NULL",
  "until NULL", "until that eq NULL",
  "until real", "until that ne NULL",
  "until eof", "until that eq EOF",
  "until EOF", "until that eq EOF",
  "until eq", "until that eq",
  "until ne", "until that ne",
  "until gt", "until that gt",
  "until ge", "until that ge",
  "until lt", "until that lt",
  "until le", "until that le",
  "until <>", "until that eq NULL",
  NULL, NULL};
char *riApas []= {
  "pass fail", "reply 0 if that == 0",
  "pass fine", "reply 1 if that != 0",
  "pass null", "reply NULL if that == NULL",
  "pass NULL", "reply NULL if that == NULL",
  "pass <>", "reply NULL if that == NULL",
  "pass eof", "reply EOF if that == EOF",
  "pass EOF", "reply EOF if that == EOF",
  NULL, NULL};
char *riAzer []= {
  "eq", "==", "ne", "!=","gt", ">", "ge", ">=",
  "lt", "<", "le", "<=",
  NULL, NULL};
/* code -  ri_beg - increment nesting level */
void ri_beg()
{ ++riPcur->Vbeg;
} 
/* code -  ri_end - decrement nesting level */
void ri_end()
{ ++riPcur->Vend;
} 
/* code -  ri_get - get next line */
int ri_get()
{ register riTlin *lin ;
  register riTlin *nxt ;
  char msg [128];
  if ( riPcur == NULL) {
    riPcur = me_alc (riLlin);
    riPnxt = me_alc (riLlin);
    ri_ipt (); }
  for(;;)  {
    lin = riPnxt;
    nxt = riPcur;
    riPnxt = nxt;
    riPcur = lin;
    if( lin->Veof)return 0;
    ri_ipt ();
    ed_set (lin->Atxt, lin->Pbod);
    ri_dbg (edPdot);
    if ( ed_del (" If")) {
      pp_if ();
    } else if ( ed_del (" Elif")) {
      pp_elf ();
    } else if ( ed_del (" Else")) {
      pp_els ();
    } else if ( ed_del (" End")) {
      pp_end ();
      } else {
      break; }
    ri_put ();
  } 
  while (( lin->Vcon)
  ||(nxt->Vext)) {
    ed_set (lin->Atxt, lin->Pbod);
    if( (st_len (nxt->Asrc) + (st_len (lin->Asrc))) >= 200)break;
    ed_app (nxt->Pbod);
    st_app (nxt->Asrc, lin->Asrc);
    lin->Vbal += nxt->Vbal;
    lin->Vwas += nxt->Vwas;
    lin->Vend += nxt->Vend;
    lin->Vcon = nxt->Vcon;
    ri_ipt ();
    if( nxt->Veof)break; }
  ed_set (lin->Atxt,lin->Pbod);
  riVend = lin->Vend;
  riVcnd = nxt->Vcnd;
  riVis = nxt->Vis;
  riVwas = nxt->Vwas;
  if ( quFver) {
    printf ("%s\n", lin->Atxt); }
  if ( lin->Vbal != 0) {
    if ( riVcnd) {
      nxt->Vbal += lin->Vbal;
    } else if ( lin->Vbal > 0) {
      FMT (msg, "(%s)[%s]", riAseg, lin->Pbod);
      im_rep ("W-Missing [)] in %s", msg);
      } else {
      FMT (msg, "(%s)[%s]", riAseg, lin->Pbod);
      im_rep ("W-Extra [)] in %s", msg); } }
  if ( ed_del (" of")) {
    ri_orf (1);
  } else if ( ed_del (" or")) {
    ri_orf (0); }
  if ( ed_fnd (" ?= ")) {
    pp_fix (); }
  return 1;
} 
/* code -  ri_ipt - input edited line */
void ri_ipt()
{ register riTlin *lin = riPnxt;
  register char *txt = &lin->Atxt[0];
  register char *(*opr );
  char *tmp ;
  lin->Vnul = -1;
  lin->Veof = 0;
  lin->Vis = 0;
  lin->Vbeg = 0;
  lin->Vend = 0;
  lin->Vcnd = 0;
  lin->Vcon = 0;
  lin->Vext = 0;
  lin->Vwas = 0;
  lin->Vbal = 0;
  for(;;)  {
    ++lin->Vnul;
    if ( io_get (txt) == 0) {
      ++lin->Veof;
      return; }
    st_cop (txt, lin->Asrc);
    lin->Vbal = ri_red (txt);
  if( *(st_skp (txt)) != 0)break; }
  ed_set (txt, txt);
  ed_del ("\f");
  if (( ! ed_scn ("include"))
  &&(! ed_scn ("#include"))) {
    ri_cst (txt); }
  if (( (tmp = ed_rep (":=", " ")) != NULL)
  ||((tmp = ed_rep ("#=", " 0x")) != NULL)) {
    while ( st_rem (" ", tmp)) {;}
    ed_rep (" (", "(");
    ri_siz ();
    ed_pre ("#define ");
    ed_set (txt, txt);
    } else {
    ri_siz (); }
  ri_kon ();
  ri_bit ();
  if ( ! ed_scn (" ...")) {
    while ( ed_del (" ..")) {++lin->Vend ;}
    while ( ed_del (" is")) {++lin->Vis ;}
    while ( ed_del (" ..")) {++lin->Vend ;} }
  ed_mor ();
  opr = riAcnd;
  while ( (txt = *opr++) != NULL) {
    if( ed_skp (txt) == 0)continue;
    if ( *txt == '!') {lin->Vcnd = -1 ;} else {
      lin->Vcnd = 1 ; }
    break;
  } 
  ed_mor ();
  opr = riAext;
  while ( *opr != NULL) {
    if ( ed_scn (*opr++)) {
       ++lin->Vext;break; } }
  ri_kwk ();
  if ( quFdos == 0) {
    while ( ed_rep ("far", "")) {;}
    while ( ed_rep ("near", "")) {;}
  } 
  if ( ed_fnd ("pass")) {
    opr = riApas;
    while ( *opr != NULL) {
      if( (ed_rep (opr[0], opr[1])) != 0)break;
      opr += 2; } }
  if ( ed_fnd ("if")) {
    opr = riAifs;
    while ( *opr != NULL) {
      if( (ed_rep (opr[0], opr[1])) != NULL)break;
      opr += 2; } }
  if ( ed_scn ("until")) {
    opr = riAunt;
    while ( *opr != NULL) {
      if( (ed_rep (opr[0], opr[1])) != NULL)break;
      opr += 2; } }
  if ( ed_fnd ("that")) {
    ++lin->Vwas; }
  txt = ed_lst ();
  if (( riVini == 0)
  &&(*txt == ',' || *txt == '(')) {
    ++lin->Vcon;
  } else if ( *txt == '\\') {
    ++lin->Vcon;
    *txt = 0; }
  opr = riAzer;
  while ( *opr != NULL) {
    txt = ed_rep (opr[0], opr[1]);
    if ( txt != NULL) {
      txt = st_skp (txt);
      if (( *txt == ')')
      ||(*txt == ',')
      ||(*txt == '|' && txt[1] == '|')
      ||(*txt == '&' && txt[1] == '&')
      ||(*txt == '!' && txt[1] == '|')
      ||(*txt == '!' && txt[1] == '&')) {
        st_mov (txt, txt+2);
        me_mov (" 0", txt, 2);
      } else if ( *txt == 0) {
        ed_app (" 0"); }
      continue; }
    opr += 2; }
  lin->Pbod = edPdot;
} 
/* code -  ri_kwk - replace keywords in context */
void ri_kwk()
{ char *(*opr );
  char *dot ;
  char *ptr ;
  opr = riArep;
  dot = edPdot;
  while ( *opr != NULL) {
    for(;;)  {
      if( (ptr = ed_fnd (opr[0])) == NULL)break;
      if ( ptr-edPdot >= 2) {
        if (( (ptr[-1] == '.')
        &&(ptr[-2] != '.'))
        ||(st_scn ("->", ptr-2))) {
           edPdot = ptr+1;continue; } }
      ed_exc (opr[1], ptr, st_len (opr[0]));
      edPdot = ptr+1;
    } 
    edPdot = dot;
    opr += 2;
  } 
} 
/* code -  ri_red - reduce line */
ri_red(
char *txt )
{ char *lin = txt;
  char *dst = txt;
  int cha ;
  int bal = 0;
  lin = st_skp (lin);
  while ( (*lin)) {
    if ( *lin == _tab) {*lin = _space ;}
    switch ( *lin) {
    case _space:
      if ( ct_spc (lin[1])) {
         ++lin;continue; }
     break; case _paren:
      ++bal;
     break; case paren_:
      --bal;
     break; case _semi:
       *lin = 0;continue;
     break; case _slash:
      if ( lin[1] == _slash) {
         *lin = 0;continue; }
     break; case _quotes:
    case _apost:
      *dst++ = cha = *lin++;
      while ( *lin) {
        if( (*dst++ = *lin++) == cha)break;
        if (( lin[-1] == _back)
        &&(*lin)) {
          *dst++ = *lin++; }
      } 
      continue;
       }
    *dst++ = *lin++;
  } 
  if (( *txt)
  &&(dst[-1] == _space)) {
    --dst; }
  *dst = 0;
  return ( bal);
} 
/* code -  ri_dbg - debug support */
ri_dbg(
char *nxt )
{ char buf [256];
  if (( *nxt >= 'a')
  &&(*nxt <= 'z')
  &&(nxt[1] <= ' ')) {
    switch ( *nxt) {
    case 'y':
      riVdbg = 1;
     break; case 'z':
      riVdbg = 0;
     break; default: 
      FMT(buf, "printf (\"#%s", riAseg);
      FMT(st_end (buf), ".%c\\n\");\n", *nxt);
      *nxt = ' ';
      ri_dis (buf);
       } }
} 
