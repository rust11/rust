/* file -  imrep - image report */
#include "m:\rid\rider.h"
#include "m:\rid\imdef.h"
#if Win
int ws_msg (char *,char *);
#endif 
imTrep *imPrep ;
/* code -  im_rep - image report */
int im_rep(
char *msg ,
char *obj )
{ if ( imPrep) {
    return ( (*imPrep)(msg, obj)); }
#if Win
  ws_msg (msg, obj);
#else 
  PUT ("%s%s-", imPpre, imPfac);
  PUT (msg, obj);
  PUT ("\n");
#endif 
  im_sev (msg);
  return 1;
} 
/* code -  im_sev - set image severity */
int im_sev(
char *msg )
{ switch ( *msg) {
  case 'W':
    im_war ();
   break; case 'E':
    im_err ();
   break; case 'F':
    im_fat ();
     }
  return 1;
} 
/* code -  im_dec - convert decimal */
char imAbuf [32]= "";
char *im_dec(
int val ,
char *buf )
{ if ( !buf) {buf = imAbuf ;}
  FMT (buf, "%d", val);
  return ( buf);
} 
/* code -  im_hex - convert hexadecimal */
char *im_hex(
int val ,
char *buf )
{ if ( !buf) {buf = imAbuf ;}
  FMT (buf, "%x", val);
  return ( buf);
} 
