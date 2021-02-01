/* file -  fi_loa - load file */
#include "m:\rid\rider.h"
#include "m:\rid\fidef.h"
#include "m:\rid\medef.h"
#include <stdio.h>
#define Log  1
#include "m:\rid\dbdef.h"
fi_loa(
char *spc ,
void *(*buf ),
size_t *len ,
FILE *(*chn ),
char *msg )
{ long siz = 0;
  FILE *fil = NULL;
  char *src = NULL;
  int res = 0;
  int cod = 0;
  char *rea ;
  for(;;)  {
    rea = "siz";
    if( (siz = fi_siz (spc)) == 0)break;
    rea = "opn";
    if( (fil = fi_opn (spc, "rb", "")) == 0)break;
    rea = "alc";
    if( (src = mg_alc (siz+2)) == 0)break;
    rea = "rea";
    if( !fi_rea (fil, src, siz))break;
    src[siz] = 0, src[siz+1] = 0;
    *buf = src;
    if ( len) {*len = siz ;}
    if ( chn) {*chn = fil ;} else {
      fi_clo (fil, "") ; }
    return 1;
   break;} 
  LOGe("fi_opn failed");
  LOGs("fi_opn failed on (%s)", rea);
  if ( src) {mg_dlc (src) ;}
  if ( fil) {fi_clo (fil, NULL) ;}
  return 0;
} 
/* code -  fi_sto -- store file */
fi_sto(
char *spc ,
void *buf ,
size_t siz ,
int fre ,
char *msg )
{ FILE *fil ;
  LOG("fi_sto");
  if ( (fil = fi_opn (spc, "wb", msg)) == 0) {
    LOGe("fi_sto");
    LOGs("fi_sto failed on (%s)", spc);
    return 0; }
  if ( fi_wri (fil, buf, siz) == 0) {
    LOGe("fi_sto");
    fi_rep (spc, msg, "");
    fi_clo (fil, "");
    return 0; }
  fi_clo (fil, "");
  if ( fre) {fi_dlc (buf) ;}
  LOG ("fi_sto - return");
  return 1;
} 
/* code -  fi_dlc - deallocate file buffer */
fi_dlc(
void *buf )
{ mg_dlc (buf);
  return 1;
} 
