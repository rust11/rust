/* file -  clprm - read command with prompt */
#include "m:\rid\rider.h"
#include "m:\rid\cldef.h"
#include "m:\rid\stdef.h"
#include <stdio.h>
/* code -  cl_cmd - read command with prompt - easy call */
cl_cmd(
char *prm ,
char *buf )
{ char tmp [132];
  return ( cl_prm (stdin, prm, (buf ? buf: tmp), 128));
} 
#if Dos || Wnt || Win
/* code -  cl_prm - read command with prompt */
#include "m:\rid\stdef.h"
#include "m:\rid\dsdef.h"
#include "m:\rid\dslib.h"
int cl_prm(
FILE *fil ,
char *prm ,
char *buf ,
int max )
{ FILE *opt ;
  char *lst ;
  if ( (opt = cl_tty (fil)) != NULL) {
    fputs (prm, opt); }
#if Dos
  if ( ds_GtKLin (buf) > 0) {
    if ( max >= 0) {fputs ("\n", opt) ;}
    } else {
    if( (fgets (buf, ((max >= 0) ? max: -max), fil)) == NULL)return 0; }
#else 
  if( (fgets (buf, ((max >= 0) ? max: -max), fil)) == NULL)return 0;
#endif 
  st_rep ("\n", "", buf);
  st_rep ("\r", "", buf);
  return 1;
} 
#endif 
