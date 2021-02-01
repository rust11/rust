/* file -  imexe - execute image */
#include "m:\rid\rider.h"
#include "m:\rid\imdef.h"
#if Dos
#include "m:\rid\dsdef.h"
#include "m:\rid\dslib.h"
#elif  Win || Wnt
#include "m:\rid\stdef.h"
#include "m:\rid\mxdef.h"
#include <windows.h>
#endif 
#define STDOUT (2)
/* code -  im_exe - execute an image */
im_exe(
char *spc ,
char *cmd ,
int flg )
{ 
#if Dos
  return ( ds_ExePrg (spc, rem));
#elif  Win || Wnt
  STARTUPINFO sup = {0};
  PROCESS_INFORMATION inf = {0};
  char tmp [mxLIN];
  ULONG sts = 0;
  HANDLE opt = 0;
  HANDLE err = 0;
  char *ptr ;
  HANDLE han ;
  st_cop (spc, tmp);
  st_app (" ", tmp);
  st_app (cmd, tmp);
  if ( flg && (ptr = st_fnd (" > ", tmp)) != 0) {
    *ptr = 0;
    han = CreateFile (ptr+3, GENERIC_WRITE,FILE_SHARE_WRITE, 0,CREATE_ALWAYS, 0, 0);
    PUT("Handle=%X\n", han);
    opt = GetStdHandle (STD_OUTPUT_HANDLE);
    err = GetStdHandle (STD_ERROR_HANDLE);
    SetStdHandle (STD_OUTPUT_HANDLE, han);
    PUT("SetStdHandle=%d\n", (SetStdHandle (STD_ERROR_HANDLE, han)));
    CloseHandle (han);
  } 
  for(;;)  {
    if( (sts = CreateProcess (NULL, tmp,NULL, NULL, 1, 0, NULL, NULL, &sup, &inf)) == 0)break;
    WaitForSingleObject (inf.hProcess, INFINITE);
    GetExitCodeProcess (inf.hProcess, &sts);
   break;} 
  if ( opt) {SetStdHandle (STD_OUTPUT_HANDLE, opt) ;}
  if ( err) {SetStdHandle (STD_ERROR_HANDLE, err) ;}
  return ( sts);
#endif 
} 
