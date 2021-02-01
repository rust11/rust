/* file -  rider - rider compiler */
#include <stdio.h>
#include "m:\rid\ridef.h"
#include "m:\rid\chdef.h"
#include "m:\rid\iodef.h"
#include "m:\rid\imdef.h"
#include "m:\rid\stdef.h"
/* code -  locals */
static int ri_com (int ,char **);
static void ri_qua (char *);
static void ri_hlp (void );
/* code -  main */
int main(
int cnt ,
char *(*vec ))
{ im_ini ("RIDER");
  io_ini ();
  if ( (ri_com (cnt, vec)) != 0) {ri_par () ;}
  im_exi ();
  return ( 0);
} 
/* code -  ri_com - process command */
int ri_com(
int cnt ,
char *(*vec ))
{ char *ipt = riPsop;
  char *opt = riPsop;
  switch ( cnt) {
  case 3:
    ri_qua (vec[2]);
    if ( *vec[2]) {opt = vec[2] ;}
  case 2:
    ri_qua (vec[1]);
    if ( *vec[1]) {ipt = vec[1] ;}
   break; default: 
    ipt = "/?";
     }
  if( st_sam (ipt, "/?")){ ri_hlp () ; return 0;}
  if( !io_src(ipt, "noname.r"))return 0;
  if( !io_opn (ioCout, opt, "noname.c", "w"))return 0;
} 
/* code -  ri_qua - get qualifiers */
void ri_qua(
char *fld )
{ int qua ;
  if( !fld)return;
  while ( *fld) {
    if ( *fld != _slash) {
       fld++;continue; }
    *fld++ = 0;
    if ( (qua = *fld++) == 0) {qua = _qmark ;}
    qua = ch_upr (qua);
    switch ( qua) {
    case 'D':
      ++quFdos;
     break; case 'U':
      ++quFunx;
     break; case 'V':
      ++quFver;
     break; default: 
      im_rep ("E-Invalid qualifier /%s", im_dec (qua, NULL));
       }
  } 
} 
/* code -  ri_hlp - help */
void ri_hlp()
{ PUT("RIDER V3.0 - (c) HAMMONDsoftware 1991-1996\n");
  PUT("\n");
  PUT("      rider infile.r outfile.c/x\n");
  PUT("\n");
  PUT("/D    DOS filenames\n");
  PUT("/V    Verify input\n");
} 
