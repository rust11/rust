/* file -  fipos - file position */
#include "m:\rid\rider.h"
#include "m:\rid\fidef.h"
#include <stdio.h>
/* code -  fi_see - seek */
int fi_see(
FILE *fil ,
long pos )
{ 
  return ( ! (fseek (fil, pos, SEEK_SET)));
} 
/* code -  fi_pos - current file position */
long fi_pos(
FILE *fil )
{ return ( ftell (fil));
} 
/* code -  fi_siz - get file size_t - by name */
long fi_siz(
char *spc )
{ FILE *fil ;
  long siz ;
  if( (fil = fi_opn (spc, "r", NULL)) == NULL)return ( 0 );
  siz = fi_len (fil);
  fi_clo (fil, NULL);
  return ( siz);
} 
/* code -  fi_len - get file length - by handle */
long fi_len(
FILE *fil )
{ long pos = fi_pos (fil);
  long len ;
  fseek (fil, 0, SEEK_END);
  len = fi_pos (fil);
  fi_see (fil, pos);
  return ( len);
} 
