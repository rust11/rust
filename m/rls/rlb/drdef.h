/* header drdef - directories */
#ifndef _RIDER_H_drdef
#define _RIDER_H_drdef 1
#include "m:\rid\mxdef.h"
#include "m:\rid\tidef.h"
#define drTent struct drTent_t 
struct drTent_t
{ drTent *Psuc ;
  char *Pnam ;
  char *Palt ;
  int Vatr ;
  int Vflg ;
  ULONG Vsiz ;
  ULONG Vext ;
  tiTval Itim ;
  tiTval Icre ;
  tiTval Iacc ;
   };
#define drTdir struct drTdir_t 
struct drTdir_t
{ char *Ppth ;
  drTent *Proo ;
  drTent *Pnxt ;
  int Vatr ;
  int Vsrt ;
  int Vovr ;
  int Verr ;
  int Vcnt ;
  void *Pext ;
   };
#define drNON  0
#define drNAM  1
#define drTYP  2
#define drSIZ  3
#define drTIM  4
#define drSRT_  15
#define drREV_  BIT(5)
#define drEXC_  BIT(6)
#define drCAS_  BIT(7)
#define drPTH  5
#define drDIR  6
#define drDRV  7
drTdir *dr_scn (char *,int ,int );
drTent *dr_nxt (drTdir *);
void dr_dlc (drTdir *);
char *dr_spc (char *,char *,char *);
int dr_roo (char *);
int dr_sho (char *,int );
int dr_set (char *,int );
int dr_avl (char *);
int dr_mak (char *);
int dr_rem (char *);
typedef size_t drTsiz ;
int dr_fre (char *,drTsiz *);
drTent *dr_enu (drTdir *,drTent *,int ,int );
void dr_don (drTdir *);
int dr_mat (drTdir *,char *);
/* code -  Dos/Windows file attributes */
#define drNOR_  0
#define drRON_  BIT(0)
#define drHID_  BIT(1)
#define drSYS_  BIT(2)
#define drVOL_  BIT(3)
#define drLAB_  BIT(3)
#define drDIR_  BIT(4)
#define drARC_  BIT(5)
#define drPER_  BIT(6)
#define drSHR_  BIT(8)
#define drFST_  BIT(15)
#define drALL_  0xffff
#endif
