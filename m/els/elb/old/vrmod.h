/* header vrmod - vrt modules */
#ifndef _RIDER_H_vrmod
#define _RIDER_H_vrmod 1
#include "c:\m\rid\rider.h"
#include "c:\m\rid\tidef.h"
#include "c:\m\elb\elmod.h"
#include "c:\m\elb\rtdef.h"
#define vrTenv struct vrTenv_t 
#define vrTdev struct vrTdev_t 
#define vrTfcb struct vrTfcb_t 
struct vrTfcb_t
{ int Vchn ;
  int Vsta ;
  int Vuni ;
  vrTdev *Pdev ;
  elTwrd Vdev ;
  rtTchn *Pchn ;
  FILE *Pfil ;
  size_t Vsiz ;
  elTwrd Arad [4];
  char Aasc [vrSPC];
  elTwrd Anew [4];
  char Aten [vrSPC];
  char Apen [vrSPC];
   };
#define vrOPN_  BIT(0)
#define vrTEN_  BIT(1)
#define vrWRI_  BIT(2)
#define vrRAW_  BIT(3)
#define vrTreq struct vrTreq_t 
struct vrTreq_t
{ elTbyt Vchn ;
  elTbyt Vcod ;
  elTwrd Vp1 ;
  elTwrd Vp2 ;
  elTwrd Vp3 ;
  elTwrd Vp4 ;
  elTwrd Vp5 ;
  elTwrd Vp6 ;
  elTwrd Vp7 ;
  int Vsta ;
  vrTfcb *Pfcb ;
  elTwrd Vbuf ;
  elTwrd Vcnt ;
  elTwrd Vblk ;
  elTwrd Vast ;
  elTbyt Vfun ;
  elTbyt Verr ;
  void *Pbuf ;
  vrTenv *Penv ;
   };
typedef int vrTdis (vrTreq *,vrTfcb *,int );
#define vrTdev struct vrTdev_t 
struct vrTdev_t
{ char Anam [4];
  int Vacp ;
  int Vsys ;
  vrTdis *Pdis ;
   };
#define vrEacp enum vrEacp_t
enum vrEacp_t 
{ vrTER, vrNAT, vrNUL
   };
#define vrEsys enum vrEsys_t
enum vrEsys_t 
{ vrNON, vrLOC, vrFAT, vrRTA, vrRSX, vrVMS
   };
#define vrEfun enum vrEfun_t
enum vrEfun_t 
{ vrLOO, vrENT, vrDEL, vrREN
  ,vrWAI, vrCLO, vrPUR, vrABT
  ,vrGET, vrSET, vrSIZ
  ,vrREA, vrWRI, vrQIO
  ,vrSAV, vrRST, vrEXI, vrRES
   };
#define vrTspc struct vrTspc_t 
struct vrTspc_t
{ elTwrd Vdev ;
  elTwrd Vfil ;
  elTwrd Vnam ;
  elTwrd Vtyp ;
   };
/* code -  vrTenv - monitor environment */
#define vrTenv struct vrTenv_t 
struct vrTenv_t
{ elTwrd Vmon ;
  rtTmon *Pmon ;
  rtTimg *Pimg ;
  rtTdev *Pdev ;
  rtTchn *Pchn ;
  elTwrd Vchn ;
  int Verr ;
  vrTfcb *Afcb [256];
  vrTdev Adev [dvMAX];
  char Aimg [mxSPC];
  elTwrd Vctc ;
  elTwrd Vtrp ;
   };
extern vrTenv *vrPenv ;
/* code -  prototypes */
typedef void vrTfun (vrTreq *);
void vr_err (vrTreq *,int );
vrTfun vr_loo ;
vrTfun vr_ent ;
vrTfun vr_del ;
vrTfun vr_ren ;
vrTfun vr_rea ;
vrTfun vr_wri ;
vrTfun vr_qio ;
vrTfun vr_wai ;
vrTfun vr_clo ;
vrTfun vr_pur ;
vrTfun vr_abt ;
vrTfun vr_375 ;
vrTfun vr_pee ;
vrTfun vr_374 ;
vrTfun vr_dst ;
vrTfun vr_fet ;
vrTfun vr_csi ;
vrTfun vr_gln ;
vrTfun vr_qst ;
vrTfun vr_cst ;
vrTfun vr_gjb ;
vrTfun vr_hrs ;
vrTfun vr_srs ;
/* code -  show things */
int vr_chn (rtTchn *);
#endif
