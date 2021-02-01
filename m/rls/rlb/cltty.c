/* file -  cltty - test file for terminal */
#include "m:\rid\rider.h"
#undef __STDC__
#include <stdio.h>
#include <io.h>
/* code -  cl_tty - test file for terminal */
FILE *cl_tty(
FILE *fil )
{ 
  if( (isatty (fileno (fil))) == 0)return ( NULL );
  if( fileno (fil) == 0)return ( stderr );
  return ( fil);
} 
