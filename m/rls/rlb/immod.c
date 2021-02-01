/* file -  immod - image routines */
#include "m:\rid\rider.h"
#include "m:\rid\imdef.h"
#include "m:\rid\osdef.h"
/* code -  immod */
char *imPpre = "%";
char *imPfac = "NONAME";
static imTcbk im_nop ;
imTcbk *imPwar = &im_nop;
imTcbk *imPerr = &im_nop;
imTcbk *imPfat = &im_nop;
imTcbk *imPexi = &im_nop;
/* code -  im_ini - image init */
int im_ini(
char *fac )
{ if ( fac != NULL) {
    imPfac = fac; }
  os_ini ();
  return 1;
} 
/* code -  im_nop - do nothing */
static void im_nop()
{ return;
} 
/* code -  im_war - image warning */
int im_war()
{ os_war ();
  (*imPwar) ();
  return 1;
} 
/* code -  im_err - image error */
int im_err()
{ os_err ();
  (*imPerr) ();
  return 1;
} 
/* code -  im_fat - image fatal */
int im_fat()
{ os_fat ();
  (*imPfat) ();
  return ( (im_exi ()));
} 
/* code -  im_exi - exit image */
int im_exi()
{ (*imPexi) ();
  return ( (os_exi ()));
} 
