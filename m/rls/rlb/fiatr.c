/* file -  fiatr - file attribute operations */
#include "m:\rid\rider.h"
#include "m:\rid\fidef.h"
#include "m:\rid\tidef.h"
#define E_AccFil  "E-Error accessing file [%s]"
#define E_SetFil  "E-Error setting file [%s]"
static char *fiAacc = E_AccFil;
static char *fiAset = E_SetFil;
#if Dos
#include "m:\rid\dsmod.h"
/* code -  fi_gtm - get file date/time */
int fi_gtm(
char *spc ,
tiTval *tim ,
char *msg )
{ int han ;
  dsTreg reg ;
  dsTseg seg ;
  tiTdos dos ;
  for(;;)  {
    ds_seg (&seg);
    DS = SEG(spc), DX = OFF(spc);
    han = ds_s21 (0x3d00);
    if( CF)break;
    BX=han, ds_r21 (0x5700);
    if( CF){ ds_r21 (0x3e00) ; break;}
    dos.Vdat = DX, dos.Vtim = CX;
    BX=han, ds_r21 (0x3e00);
    ti_fds (&dos, tim);
    return 1;
  } 
   fi_rep (msg, spc, fiAacc);return 0;
} 
/* code -  fi_stm - set file date/time */
int fi_stm(
char *spc ,
tiTval *tim ,
char *msg )
{ tiTdos dos ;
  dsTreg reg ;
  dsTseg seg ;
  int han ;
  int res ;
  ti_tds (tim, &dos);
  for(;;)  {
    ds_seg (&seg);
    DS = SEG(spc), DX = OFF(spc);
    han = ds_s21 (0x3d00);
    if( CF)break;
    CX = dos.Vtim, DX = dos.Vdat;
    BX=han, ds_r21 (0x5701);
    res = !CF;
    BX=han, ds_r21 (0x3e00);
    if( res)return 1;
   break;} 
   fi_rep (msg, spc, fiAset);return 0;
} 
/* code -  fi_gat - get attributes */
int fi_gat(
char *spc ,
int *atr ,
char *msg )
{ dsTreg reg ;
  dsTseg seg ;
  for(;;)  {
    ds_seg (&seg);
    DS = SEG(spc), DX = OFF(spc);
    ds_s21 (0x4300);
    if( CF){ *atr = 0 ; break;}
     *atr = CX;return 1;
   break;} 
   fi_rep (msg, spc, fiAacc);return 0;
} 
/* code -  fi_sat - set attributes */
int fi_sat(
char *spc ,
int bic ,
int bis ,
char *msg )
{ dsTreg reg ;
  dsTseg seg ;
  for(;;)  {
    ds_seg (&seg);
    DS = SEG(spc), DX = OFF(spc);
    ds_s21 (0x4300);
    if( CF)break;
    CX &= ~(bic);
    CX |= bis;
    DS = SEG(spc), DX = OFF(spc);
    ds_s21 (0x4301);
    if( !CF)return 1;
   break;} 
   fi_rep (msg, spc, fiAset);return 0;
} 
#endif 
#if Wnt
/* code -  fi_gtm - get file date/time */
#include "m:\rid\mxdef.h"
#include <windows.h>
#define diTsta  struct stat
int fi_gtm(
char *spc ,
tiTval *val ,
char *msg )
{ char nam [mxLIN];
  HANDLE han ;
  FILETIME fil ;
  fi_loc (spc, nam);
  if (( (han = CreateFile (nam, GENERIC_READ,FILE_SHARE_READ|FILE_SHARE_WRITE,NULL, OPEN_EXISTING, 0, 0)) != NULL)
  &&(GetFileTime (han, NULL,NULL,&fil))
  &&(CloseHandle (han))
  &&(ti_fnt (&(tiTwnt )fil, val))) {
    return 1; }
   fi_rep (msg, spc, fiAacc);return 0;
} 
/* code -  fi_stm - set file date/time */
int fi_stm(
char *spc ,
tiTval *val ,
char *msg )
{ char nam [mxLIN];
  HANDLE han ;
  FILETIME fil ;
  fi_loc (spc, nam);
  ti_tnt (val, &(tiTwnt )fil);
  if (( (han = CreateFile (nam, GENERIC_WRITE,FILE_SHARE_READ|FILE_SHARE_WRITE,NULL, OPEN_EXISTING, 0, 0)) != NULL)
  &&(SetFileTime (han, NULL,NULL,&fil))
  &&(CloseHandle (han))) {
    return 1; }
   fi_rep (msg, spc, fiAacc);return 0;
} 
/* code -  fi_gat - get attributes */
int fi_gat(
char *spc ,
int *atr ,
char *msg )
{ ULONG res ;
  res = GetFileAttributes (spc);
  if ( res != 0xFFFFFFFF) {
     *atr = (int )res;return 1; }
   fi_rep (msg, spc, fiAacc);return 0;
} 
/* code -  fi_sat - set attributes */
int fi_sat(
char *spc ,
int bic ,
int bis ,
char *msg )
{ int atr ;
  for(;;)  {
    if( !fi_gat (spc, &atr, NULL))break;
    atr &= ~(bic);
    atr |= bis;
    if( (SetFileAttributes (spc, (WORD )atr)) != 0)return ( 1 );
   break;} 
   fi_rep (msg, spc, fiAset);return 0;
} 
#endif 
