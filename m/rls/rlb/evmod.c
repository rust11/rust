/* file -  evmod - environment operations */
#include "m:\rid\rider.h"
#include "m:\rid\mxdef.h"
#include "m:\rid\evdef.h"
#include "m:\rid\fidef.h"
#if Win
#include <windows.h>
#endif 
/* code -  ev_get - get environment variable */
int ev_get(
char *nam ,
char *buf ,
int len )
{ char *ptr ;
  *buf = 0;
#if Win
  return ( (GetEnvironmentVariable (nam, buf, len)));
#else 
  if( (ptr = getenv (nam)) == 0)return ( 0 );
  st_cop (ptr, buf);
  return 1;
#endif 
} 
/* code -  ev_set - get environment variable */
#if Win
int ev_set(
char *nam ,
char *buf )
{ 
  return ( (SetEnvironmentVariable (nam, buf)));
} 
#endif 
#if Win
/* code -  in_rea - get ini file data */
in_rea(
char *spc ,
char *sec ,
char *key ,
char *buf ,
int len )
{ char *dft = "";
  char loc [mxLIN];
  fi_loc (spc, loc);
  return ( (GetPrivateProfileString (sec, key, dft, buf, len, loc)));
} 
/* code -  ev_wri - set ini file data */
ev_wri(
char *spc ,
char *sec ,
char *key ,
char *buf )
{ char loc [mxLIN];
  fi_loc (spc, loc);
  return ( (WritePrivateProfileString (sec, key, buf, loc)));
} 
#endif 
