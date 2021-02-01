/* header rtdef - rt11 definitions */
#ifndef _RIDER_H_rtdef
#define _RIDER_H_rtdef 1
/* code -  rad50 constants */
#define rxDK  015270
#define rxNL  054540
#define rxSY  075250
#define rxSYS  075273
#define rxTT  0100040
#define rxVS  0106170
#define rxVX  0106500
#define rxVX0  0106536
/* code -  rtXXX - hard errors */
#define rtUSR  -1
#define rtUNL  -2
#define rtDIO  -3
#define rtFET  -4
#define rtOVR  -5
#define rtFUL  -6
#define rtADR  -7
#define rtCHN  -8
#define rtEMT  -9
#define rtBUS  -10
#define rtCPU  -11
#define rtDIR  -12
#define rtXFT  -13
#define rtFPU  -14
#define rtPAR  -15
#define rtMMU  -16
/* code -  rtTimg - RT-11 executable image */
#define rtTimg struct rtTimg_t 
struct rtTimg_t
{ elTwrd Vexi ;
  char Af0 [040-02];
  elTwrd Vupc ;
  elTwrd Vusp ;
  elTwrd Vjsw ;
  elTwrd Vusa ;
  elTwrd Vtop ;
  elTbyt Verr ;
  elTbyt Vsev ;
  elTwrd Vsys ;
  char Af1 [0500-056];
  elTwrd Acha [4];
  elTwrd Vcct ;
  elTwrd Vcst ;
  char Af2 [01000-0514];
   };
/* code -  rtTchn - RT-11 I/O channel */
#define rtTchn struct rtTchn_t 
struct rtTchn_t
{ elTwrd Vcsw ;
  elTwrd Vblk ;
  elTwrd Vlen ;
  elTwrd Vuse ;
  elTbyt Vioc ;
  elTbyt Vuni ;
   };
#define chHER_  01
#define chIDX_  076
#define chTEN_  0200
#define chEOF_  020000
#define chACT_  0100000
#define chIMG  15
/* code -  rtTdst - RT-11 device status */
#define rtTdst struct rtTdst_t 
struct rtTdst_t
{ elTwrd Vcha ;
  elTwrd Vhsz ;
  elTwrd Vadr ;
  elTwrd Vsiz ;
   };
/* code -  rtTdev - device data */
#define dvMAX  16
#define rtTdev struct rtTdev_t 
struct rtTdev_t
{ elTwrd Alog [dvMAX];
  elTwrd Vldk ;
  elTwrd Vlsy ;
  elTwrd Aequ [dvMAX];
  elTwrd Vedk ;
  elTwrd Vesy ;
  elTwrd Anam [dvMAX];
  elTwrd Aent [dvMAX];
  elTwrd Vgua ;
  elTwrd Asta [dvMAX];
  elTwrd Asiz [dvMAX];
   };
#define dvCOD_  0377
#define dvVAR_  0400
#define dvGAB_  01000
#define dvFUN_  02000
#define dvHAB_  04000
#define dvSTR_  010000
#define dvWON_  020000
#define dvRON_  040000
#define dvRTA_  0100000
#define dvFIL_ (dvSTR_|dvRTA_)
#define dvTTI  0
#define dvSYI  1
#define dvNLI  2
/* code -  rtTqel - RT-11 queue element */
#define rtTqel struct rtTqel_t 
struct rtTqel_t
{ elTwrd Vlnk ;
  elTwrd Vcsw ;
  elTwrd Vblk ;
  elTbyt Vfun ;
  elTbyt Vuni ;
  elTwrd Vbuf ;
  elTwrd Vcnt ;
  elTwrd Vast ;
   };
/* code -  rtTmon - monitor header */
#define rtTmon struct rtTmon_t 
struct rtTmon_t
{ elTwrd Amon [2];
  rtTchn Achn [17];
  elTwrd Vblk ;
  elTwrd Vchk ;
  elTwrd Vdat ;
  elTwrd Vdfl ;
  elTwrd Vusr ;
  elTwrd Vqco ;
  elTwrd Vspu ;
  elTwrd Vsyu ;
  elTbyt Vsyv ;
  elTbyt Vsup ;
  elTwrd Vcfg ;
  elTwrd Vscr ;
  elTwrd Vtks ;
  elTwrd Vtkb ;
  elTwrd Vtps ;
  elTwrd Vtpb ;
  elTwrd Vmax ;
  elTwrd Ve16 ;
  elTwrd Atim [2];
  elTwrd Vsyn ;
  elTbyt Almp [24];
  elTwrd Vusl ;
  elTwrd Vgtv ;
  elTwrd Verc ;
  elTwrd Vmtp ;
  elTwrd Vmfp ;
  elTwrd Vsyi ;
  elTwrd Vcfs ;
  elTwrd Vcf2 ;
  elTwrd Vsyg ;
  elTwrd Vusa ;
  elTbyt Verl ;
  elTbyt Vcfn ;
  elTwrd Vemr ;
  elTwrd Vfrk ;
  elTwrd Vpnp ;
  elTwrd Amnm [2];
  elTwrd Vsuf ;
  elTwrd Vdcn ;
  elTbyt Vinx ;
  elTbyt Vins ;
  elTwrd Vmes ;
  elTwrd Vclg ;
  elTwrd Vtcf ;
  elTwrd Vidv ;
  elTwrd Vmpt ;
  elTwrd Vp1x ;
  elTwrd Vgcs ;
  elTwrd Vgvc ;
  elTwrd Vdwt ;
  elTwrd Vtrs ;
  elTwrd Vnul ;
  elTwrd Viml ;
  elTwrd Vkmn ;
  elTbyt Aprd [2];
  elTbyt Vwld ;
  elTbyt Vf00 ;
  elTwrd Af01 [64];
  rtTdev Idev ;
  elTwrd Abus [3];
  elTwrd Acpu [3];
  elTwrd Aemt [3];
  elTwrd Aclk [3];
   };
#endif
