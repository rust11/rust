/* header sdmod - SRCDIF definitions */
#ifndef _RIDER_H_sdmod
#define _RIDER_H_sdmod 1
#include "rid:rider.h"
#include "rid:fidef.h"
#include "rid:fsdef.h"
#include "rid:imdef.h"
#include "rid:rtcsi.h"
#include "rid:rtdir.h"
#define sdTlin struct sdTlin_t 
struct sdTlin_t
{ WORD Vflg ;
  WORD Vpos ;
  WORD Vhsh ;
   };
#define sdHOP_  0000777
#define sdLEN_  0077000
#define sdLEN  9
#define sdEOF_  0100000
#define sdMAX  132
#define sd_eof(lin) (lin->Vflg & sdEOF_)
#define sdTsid struct sdTsid_t 
struct sdTsid_t
{ sdTlin *Pcur ;
  sdTlin *Pbas ;
  sdTlin *Pipt ;
  sdTlin *Pfst ;
  sdTlin *Pmat ;
  sdTlin *Plea ;
  sdTlin *Plim ;
  char *Pspc ;
  FILE *Hfil ;
  char *Pmod ;
  fsTcla Icla ;
  long Vipt ;
  long Vpos ;
  char Alin [sdMAX];
  char Ared [sdMAX];
  int Vsid ;
  int Vpag ;
  int Vlin ;
  int Vdon ;
  int Vtak ;
   };
#define sdTopt struct sdTopt_t 
struct sdTopt_t
{ char *Pspc ;
  FILE *Pfil ;
  fxText Iext ;
   };
#define sdTctl struct sdTctl_t 
struct sdTctl_t
{ int Vmin ;
  int Vlim ;
  int Vblk ;
  int Vcas ;
  int Vchg ;
  int Vcmt ;
  int Vedi ;
  int Vexa ;
  int Vfrm ;
  int Vlog ;
  int Vmis ;
  int Vmax ;
  int Vopt ;
  int Vspc ;
  int Veig ;
  int Vver ;
  int Vwid ;
  int Vins ;
  int Vdel ;
  int Vnum ;
  int Vmrg ;
  int Vtra ;
  int Vpar ;
  int Vwin ;
  int Vtrm ;
  int Vaud ;
  int Vdis ;
  int Vhdr ;
  int Vdif ;
  int Vsec ;
  int Vtot ;
  int Vabt ;
  int Vovr ;
  int Vnew ;
  int Vonl ;
  int Vsta ;
  char Aaud [14];
  rtTscn *Pscn ;
  int Vfst ;
   };
#define sdNOP  0
#define sdMRG  1
#define sdCHG  2
#define sdPAR  3
#define sdUND  0
#define sdSAM  1
#define sdDIF  2
#define sdINI  0
#define sdHDR  1
#define sdLOG  2
#define sdMAT  3
#define sdMIS  4
#define sdMIX  5
#define sdFIN  6
#define sdDIV  7
#define sdNON  0
#define sdONE  1
#define sdBTH  2
extern sdTsid lft ;
extern sdTsid rgt ;
extern sdTctl ctl ;
extern csTcsi csi ;
extern sdTopt opt ;
extern rtTscn *sdPscn ;
char *sd_tak ();
#endif
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              