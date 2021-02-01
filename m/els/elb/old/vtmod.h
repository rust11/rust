/* header vtmod - vrt modules */
#ifndef _RIDER_H_vtmod
#define _RIDER_H_vtmod 1
#include "c:\m\rid\rider.h"
#include "c:\m\rid\fidef.h"
#include "c:\m\rid\drdef.h"
#include "c:\m\elb\elmod.h"
#include "c:\m\elb\vrmod.h"
#define REQ(x) (x & 0xff)
void vr_unp (elTwrd *,char *,int );
extern char vtApad [512];
rtTchn *vt_chn (int );
#define vtTqel struct vtTqel_t 
typedef void vtTfun (vtTqel *);
typedef int vtTiop (vtTqel *,int );
void vt_trn (vtTqel *,int );
vt_cmd (char *);
void vt_io_set (vtTqel *,int );
vtTfun vt_io_eof ;
vtTfun vt_io_her ;
vtTiop vt_no_iop ;
vtTiop vt_nl_iop ;
vtTiop vt_vx_iop ;
vtTiop vt_ld_iop ;
vtTiop vt_dy_iop ;
vtTiop vt_vm_iop ;
vtTiop vt_im_iop ;
#define ADR(x) ((void *)(elPmem + x))
elTfun vt_boo ;
elTfun vt_rmn ;
int vt_iot ();
int vt_emt ();
void vt_unp (elTwrd *,char *,int );
#define JSW (*(elTwrd *)(elPmem+jsw))
#define JR0 (*(elTwrd *)(elPmem+j_reg0))
#define vtKmon  0140000
extern elTwrd vtVjsw ;
#define vtREA  0
#define vtWRI  1
#define vtQIO  2
#define cabTrep struct cabTrep_t 
struct cabTrep_t
{ cabTrep *Psuc ;
  int Vblk ;
  int Vcnt ;
  char Abuf [512];
   };
#define cabRTA  1
#define cabVMS  2
#define cabTcab struct cabTcab_t 
struct cabTcab_t
{ cabTcab *Psuc ;
  int Vtyp ;
  int Vflg ;
  int Vchn ;
  int Vseq ;
  int Vhgh ;
  int Vlen ;
  rtTchn *Pchn ;
  FILE *Pfil ;
  cabTrep *Prep ;
  char Aspc [82];
   };
#define cabLOO  0
#define cabENT  1
#define cabREP  2
#define cabDEV  3
#define cabRON_  1
#define cabVAX_  2
#define cabRTA_  4
#define cabDIR_  4+2
cabTcab *cab_cre (int ,FILE *,char *,int ,int );
cabTcab *cab_opn (int );
void cab_clo (int );
void cab_res (int );
void cab_rep (cabTcab *,void *,int ,int );
int cab_rea (cabTcab *,void *,int ,int );
cabTrep *cab_loc (cabTcab *,int );
#define vtTter struct vtTter_t 
struct vtTter_t
{ char Abuf [1024];
  int Vget ;
  int Vnxt ;
  int Vonc ;
   };
extern vtTter vtSter ;
void vt_kb_hoo ();
/* code -  VRT queue element */
#define vtTqel struct vtTqel_t 
struct vtTqel_t
{ elTwrd Vqlk ;
  elTwrd Vqgt ;
  elTwrd Vqcm ;
  elTwrd Vqry ;
  elTwrd Vqch ;
  elTwrd Vqa1 ;
  elTwrd Vqa2 ;
  elTwrd Vqa3 ;
  elTwrd Vqa4 ;
  elTwrd Vqa5 ;
  elTwrd Vqa6 ;
  elTwrd Vqa7 ;
  elTwrd Vqa8 ;
  elTwrd Vqx0 ;
  elTwrd Vqx1 ;
  elTwrd Vqx2 ;
  elTwrd Vqx3 ;
  elTwrd Vqx4 ;
  elTwrd Vqx5 ;
  elTwrd Vqx6 ;
  elTwrd Vqx7 ;
  elTwrd Vqdc ;
  elTwrd Vqck ;
  elTwrd Vqdk ;
  elTwrd Vlnk ;
  elTwrd Vcsw ;
  elTwrd Vblk ;
  elTbyt Vfun ;
  elTbyt Vuni ;
  elTwrd Vbuf ;
  elTwrd Vcnt ;
  elTwrd Vast ;
  elTwrd Vpar ;
  elTwrd Vfr1 ;
  elTwrd Vfr2 ;
  elTwrd Vtwc ;
  elTwrd Vjob ;
  elTwrd Vvid ;
  elTwrd Vtyp ;
  elTwrd Vmch ;
  elTwrd Vjch ;
  elTwrd Vmwc ;
  elTwrd Vsp ;
   };
#define Vjob  Vuni
#define Vqcs  Vqcs
#define Vqer  Vqa7
#define Vqr0  Vqa6
#define Vqfn  Vqa4
#define Vqdu  Vqa4
#define Vqwc  Vqa3
#define Vqbu  Vqa2
#define Vqbl  Vqa1
/* code -  VRT constants */
#define j_buff  04746
#define _chkey  0260
#define j_even  0144056
#define jxABT_  0100001
#define jxCTC_  0100002
#define j_jnum  0606
#define __sid  0532
#define _unam1  0142572
#define _unam2  0142674
#define usersp  042
#define dkassg  0142670
#define syassg  0142672
#define _pname  0142776
#define _hentr  0143074
#define _stat  0143174
#define _dvsiz  0143466
#define _type  0143564
#define ty_dma  01
#define _syind  0364
#define __host  03776
#define __slot  03774
#define __loca  04000
#define t_ocou  04132
#define _rmon  0140000
#define j_reg0  0144052
#define bang  0162472
#define sn_pur  0171502
#define e340l  0167156
#define mrkt  0161456
#define _mrkt  0167334
#define cmkt  0161556
#define _cmkt  0167336
#define aid  0163504
#define _aid  0140612
#define _power  0140550
#define _net  0140526
#define userps  0140472
#define _mtpx  0452
#define _mfpx  0464
#define kaput  0165734
#define mo_res  0160472
#define vtREN  040
#define _paths  0140576
#define _top  0140266
#define _smon  0140554
#define _job  0140540
#define _jobc  0140546
/* code -  more */
#define ttspc_  010000
#define sysptr  054
#define spusr  0272
#define r50sys  075273
#define r50_tt  0100040
#define r50_vx  0106500
#define r50_sy  075250
#define r50_dk  015270
#define r50_nl  054540
#define r50_ld  045640
#define r50_dy  016350
#define r50_vx7  0106545
#define r50DIR  015172
#define radVX7  0106545
#define radDIR  015172
#define lddev  0102446
#define dydev  0102446
#define vxdev  012200
#define nldev  025
#define config  0300
#define confg2  0370
#define eis_  0400
#define sysgen  0372
#define rtem_  010
#define emTTO  0341
#define emPRI  0351
#define vxslot  2
#define nlslot  4
#define ldslot  6
#define dyslot  8
#define joslot  12
#endif
