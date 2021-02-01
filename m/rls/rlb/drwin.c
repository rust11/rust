/* file -  drwin - WNT directory operations */
#include "c:\rid\rider.h"
#include "c:\rid\medef.h"
#include "c:\rid\mxdef.h"
#include "c:\rid\stdef.h"
#include <stdio.h>
#include <stdlib.h>
#include "c:\rid\drdef.h"
#include <windows.h>
#if !Wnt
Error Need Win32;
#endif 
/* code -  drText - native extensions to drTdir */
#define drText struct drText_t 
struct drText_t
{ HANDLE Vhan ;
   };
/* code -  dr_avl - check directory available */
dr_avl(spc)
char *spc ;
{ char pth [mxLIN];
  int atr ;
  nat typ ;
  char *col ;
  if( *spc == 0)return 0;
  fi_loc (spc, pth);
  if( (col = st_fnd (":", pth)) == 0)return 0;
  col[1] = '\\', col[2] = 0;
  typ = GetDriveType (pth);
  if( (!typ) || (typ == 1))return 0;
  if( dr_roo (spc))return 1;
  if( !fi_gat (spc, &atr))return 0;
  return ( (atr & drDIR_) != 0);
} 
/* code -  dr_sho - current drive/directory */
dr_sho(pth,cas)
char *pth ;
int cas ;
{ char spc [mxLIN];
  char *dir ;
  if( (GetCurrentDirectory (mxLIN-1, spc)) <= 0)return 0;
  if ( cas != drPTH) {
    if( (dir = st_fnd ("\\", spc)) == NULL)return 0;
    if ( cas == drDRV) {*dir = 0 ;} else {
      st_mov (dir, spc) ; } }
   st_cop (spc, pth);return 1;
} 
/* code -  dr_mak - make a directory */
dr_mak(spc)
char *spc ;
{ return ( CreateDirectory (spc, NULL));
} 
/* code -  dr_rem - remove directory */
dr_rem(spc)
char *spc ;
{ return ( RemoveDirectory (spc));
} 
/* code -  dr_enu - enumerate */
#define NMF  ERROR_NO_MORE_FILES
#define IHV  INVALID_HANDLE_VALUE
#define wiThan  HANDLE
#define wiTfnd  WIN32_FIND_DATA
#define wiTboo  BOOL
#define First  FindFirstFile
#define Next  FindNextFile
#define Error  GetLastError
drTent *dr_enu(dir,ent,nth)
drTdir *dir ;
drTent *ent ;
int nth ;
{ wiTfnd nxt ;
  wiTboo fnd ;
  drText *ext ;
  if ( dir->Pext == 0) {
    dir->Pext = me_acc ( sizeof(drText)); }
  ext = dir->Pext;
  if ( nth == 0) {
    ext->Vhan = First (dir->Ppth, &nxt);
    if( ext->Vhan == IHV)return ( NULL );
    } else {
    fnd = Next (ext->Vhan, &nxt);
    if ( !fnd && (Error() != NMF)) {
       ++dir->Verr;return 0; }
    if( !fnd)return 0; }
  if ( !ent) {
    if( (ent = malloc ( sizeof(drTent))) == NULL){ ++dir->Vovr ; return 0;} }
  me_clr (ent,  sizeof(drTent));
  ent->Vatr = nxt.dwFileAttributes;
  ent->Vsiz = nxt.nFileSizeLow;
  ent->Pnam = st_dup (nxt.cFileName);
  ent->Palt = st_dup (nxt.cAlternateFileName);
  st_low (ent->Palt);
  ti_imp ((tiTwnt *)&nxt.ftCreationTime, &ent->Icre);
  ti_imp ((tiTwnt *)&nxt.ftLastAccessTime, &ent->Iacc);
  ti_imp ((tiTwnt *)&nxt.ftLastWriteTime, &ent->Itim);
  return ( ent);
} 
/* code -  dr_don - end enumeration */
void dr_don(dir)
drTdir *dir ;
{ ;
} 
