/* file -  wcmai - default wc_mai */
#include "m:\rid\rider.h"
#include "m:\rid\wcdef.h"
#include "m:\rid\cldef.h"
#include "m:\rid\imdef.h"
extern int _main (int ,char **);
/* code -  wc_mai - cusp main */
wc_mai(
wsTevt *evt )
{ char *cmd = ws_str (evt, wsCMD);
  int cnt = 0;
  char *(*vec )= NULL;
  cl_vec (cmd, &cnt, &vec);
  _main (cnt, vec);
  im_exi ();
} 
