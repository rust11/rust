/* file -  rider - rider compiler */
#include "m:\rid\rider.h"
#include "m:\rid\iodef.h"
/* code -  locals */
/* code -  main */
int main(
int cnt ,
char *(*vec ))
{ 
  if ( (io_opn (ioCout, "a.a", "", "w")) == 0) {
    PUT("Open failed\n");
    im_exi (); }
  io_put ("thiss is lots of text");
  im_exi ();
} 
