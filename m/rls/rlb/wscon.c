/* file -  wscon - console application */
#include "m:\rid\wsdef.h"
#include "m:\rid\cldef.h"
#include "m:\rid\imdef.h"
#include "m:\rid\mxdef.h"
#include "m:\rid\medef.h"
#include "m:\rid\stdef.h"
#include <stdio.h>
extern int main (int ,char **);
int APIENTRY WinMain(
HANDLE ins ,
HANDLE prv ,
LPSTR cmd ,
int sho )
{ char buf [512];
  int cnt = 0;
  char *(*vec )= NULL;
  st_cop ("image ", buf);
  st_app (cmd, buf);
  cl_vec (buf, &cnt, &vec);
  main (cnt, vec);
  im_exi ();
} 
/* code -  ws_prt - printf replacement */
int ws_prt(
const char *fmt ,
...)
{ vprintf(fmt, (va_list )&(fmt) +  sizeof(fmt));
  return 1;
} 
/* code -  ws_msg - write message */
ws_msg(
char *msg ,
char *obj )
{ PUT ("%s%s-", imPpre, imPfac);
  PUT (msg, obj);
  PUT ("\n");
  return 1;
} 
