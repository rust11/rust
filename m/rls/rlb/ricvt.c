/* file -  ricvt - convert things */
#include "m:\rid\rider.h"
#include "m:\rid\ridef.h"
#include "m:\rid\fidef.h"
#include "m:\rid\eddef.h"
#include "m:\rid\chdef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\lndef.h"
#include <stdlib.h>
static void cv_dos (void );
static void cv_unx (void );
static int cv_trn (char *);
/* code -  kw_inc - include */
char *cvAstd [] =  {
  "dos",
  "setjmp",
  "assert",
  "errno",
  "float",
  "limits",
  "locale",
  "math",
  "signal",
  "stdarg",
  "stddef",
  "stdio",
  "stdlib",
  "string",
  "time",
  NULL,
  };
/* code -  kw_inc - include */
void kw_inc()
{ char *dot ;
  char *(*std )= cvAstd;
  ed_del (" ");
  dot = edPdot;
  while ( *std != 0) {
    if( !st_sam (*std++, dot))continue;
    st_ins ("<", dot);
    st_app (".h>", dot);
    break;
  } 
  if (( *dot != '\"' && *dot != '<')
  &&(*dot != '(')) {
    if ( !st_fnd (".", edPdot)) {
      st_app (".h", dot); }
    st_ins ("\"", dot);
    st_app ("\"", dot); }
  st_rep ("(", "", dot);
  st_rep (")", "", dot);
  if ( quFdos != 0) {
    cv_dos ();
  } else if ( quFunx != 0) {
    cv_unx (); }
  ed_pre ("#include ");
} 
/* code -  cv_dos - convert to DOS name */
void cv_dos()
{ char *trm ;
  if( !ed_del ("\""))return;
  if( !ed_rep ("\"", ""))return;
  fi_loc (edPdot, edPdot);
  ed_pre ("\"");
  ed_app ("\"");
} 
/* code -  cv_unx - convert to UNIX name */
void cv_unx()
{ if( ! ed_del ("\""))return;
  if ( ed_rep (":", "/")) {
    ed_pre ("/"); }
  ed_pre ("\"");
} 
