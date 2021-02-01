/* file -  clwin - windows calls */
#include "m:\rid\rider.h"
#include "m:\rid\cldef.h"
#include "m:\rid\stdef.h"
#include <windows.h>
/* code -  cl_lin - get command line */
cl_lin(
char *lin )
{ char *cmd ;
  if( (cmd = GetCommandLine ()) == 0)return ( 0 );
  st_cop (cmd, lin);
  return 1;
} 
