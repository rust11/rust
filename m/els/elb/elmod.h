/* header elmod - PDP-11 emulator definitions */
#ifndef _RIDER_H_elmod
#define _RIDER_H_elmod 1
#include "f:\m\rid\rider.h"
#include "f:\m\rid\mxdef.h"
#include "f:\m\rid\fidef.h"
#include "f:\m\rid\eldef.h"
#include "f:\m\rid\rtmod.h"
#define MEMARR  0
#define DMP(x)  el_vrb(x)
/* code -  cpu environment */
typedef void elTfun (void );
#define elWRD_  0xffff
#define elBYT_  0xff
#define _1k (1024)
#define _4k (4 * _1k)
#define _8k (8 * _1k)
#define _64k (64 * _1k)
#define _256k (256 * _1k)
#define _1m (_1k * _1k)
#define _4m (4 * _1m)
#define elVAS  _64k
#define elUAS  _256k
#define elQAS  _4m
#define elVIO (elVAS - _8k)
#define elUIO (elUAS - _8k)
#define elQIO (elQAS - _8k)
#define elPAS (elQAS)
#define elHWM (elPAS-_8k)
#define elNMX (elPAS-elVAS)
#define elMCH (elPAS-elVAS)
extern elTadr elVhwm ;
extern elTadr elVvio ;
extern elTadr elVnmx ;
extern elTadr elVeow ;
#define elREG (elPAS)
#define elDUM (elPAS+18)
#define elMEM (elPAS+128)
#define mmRAC_  02
#define mmWAC_  04
#define VPR(x)  el_vpx(x, mmRAC_)
#define VPW(x)  el_vpx(x, mmWAC_)
#define PNB(x) ((elTbyt *)(elPmem + (x)))
#define PNW(x) ((elTwrd *)(elPmem + (x)))
#define MNB(x) ((elTbyt *)(elPmch + (x)))
#define MNW(x) ((elTwrd *)(elPmch + (x)))
#define NMX(x) ((x)-elNMX)
#define MBX(x) ((x & ~(1))-elVIO)
#define DEV(x) (MBX(x)/2)
#define ODD(x) ((x) & 1)
elTadr el_vpx (elTadr ,elTwrd );
int el_mma (elTadr ,int ,elTwrd *);
#define el_fmw(x) (*MNW(x))
#define el_fmb(x) (*MNB(x))
#define el_smw(x,y) (*MNW(x)=(y))
#define el_smb(x,y) (*MNB(x)=(y))
#define OP  elVopc
#define R0  elPreg[0]
#define R1  elPreg[1]
#define R2  elPreg[2]
#define R3  elPreg[3]
#define R4  elPreg[4]
#define R5  elPreg[5]
#define SP  elPreg[6]
#define PC  elPreg[7]
#define PS  elPreg[8]
#define elMM0  0177572
#define elMAP_  BIT(0)
#define elMM1  0177574
#define elMM2  0177576
#define elMM3  0172516
#define el22b_  BIT(4)
#define MM0 (*MNW(elMM0))
#define MM1 (*MNW(elMM1))
#define MM2 (*MNW(elMM2))
#define MM3 (*MNW(elMM3))
#define elT_  BIT(4)
#define elN_  BIT(3)
#define elZ_  BIT(2)
#define elV_  BIT(1)
#define elC_  BIT(0)
#define elMtbt(x) ((x) & ~(elT_))
#define TBIT ((PS & elT_) >> 4)
#define NBIT ((PS & elN_) >> 3)
#define ZBIT ((PS & elZ_) >> 2)
#define VBIT ((PS & elV_) >> 1)
#define CBIT (PS & elC_)
#define CCC (PS &= ~(elN_|elZ_|elV_|elC_))
#define CLC (PS &= (~elC_))
#define CLV (PS &= (~elV_))
#define CLZ (PS &= (~elZ_))
#define CLN (PS &= (~elN_))
#define SEC (PS |= elC_)
#define SEV (PS |= elV_)
#define SEZ (PS |= elZ_)
#define SEN (PS |= elN_)
#define veBUS  04
#define veCPU  010
#define veBPT  014
#define veIOT  020
#define vePWF  024
#define veEMT  030
#define veTRP  034
#define veKBD  060
#define veTER  064
#define veCLK  0100
#define vePAR  0114
#define vePRQ  0240
#define veFPU  0244
#define veMMU  0250
#define veTRC  0377
/* code -  memory & cpu */
#if MEMARR
extern elTbyt elPmem [];
#else 
extern elTbyt *elPmem ;
#endif 
extern ULONG elApar [];
extern ULONG elApdr [];
extern elTwrd *elPpar ;
extern elTwrd *elPpdr ;
extern elTwrd elVmmd ;
extern elTwrd elVspm ;
extern elTbyt *elPmch ;
extern elTwrd *elPreg ;
void el_psw (elTwrd );
#define NEWPS(x) (el_psw((x)))
extern elTwrd elVpss ;
extern elTwrd elVpsr ;
#define CURPRV (elVpss=PS,elVsch|=elMMU_)
#define CUR (elVpss&0140000)
#define PRV ((elVpss<<2)&0140000)
#define CURMOD (PS=(elVpss&037777)|CUR, elVpsr=0, MMU)
#define PRVMOD (PS=(elVpss&037777)|PRV, elVpsr=1, MMU)
#define elNAC  0
#define elFTW  1
#define elFTB  2
#define elSTW  3
#define elSTB  4
elTwrd elAstk [4];
#define STK(mod) (elAstk[((mod)>>14)&03])
extern char elAzer [];
extern int elFlsi ;
extern int elFeis ;
extern int elFmap ;
extern elTadr elVevn ;
extern elTwrd elVopc ;
extern int elVsch ;
extern int elVmmu ;
extern int elV22b ;
extern int elVprb ;
extern int elVebd ;
extern elTadr elVepc ;
extern elTadr elVcur ;
extern elTadr elVswa ;
extern elTadr elVdwa ;
extern elTadr elVsba ;
extern elTadr elVdba ;
extern elTadr elVtwa ;
extern elTadr elVtba ;
extern elTwrd elVswv ;
extern elTbyt elVsbv ;
extern elTwrd elVdwv ;
extern elTbyt elVdbv ;
extern elTwrd elVtwv ;
extern elTbyt elVtbv ;
extern elTlng elVtlv ;
extern elTlng elVslv ;
extern elTlng elVdlv ;
/* code -  various */
elTfun el_ini ;
elTfun el_dis ;
el_ddt ();
elTfun el_dkx ;
extern char elAcmd [mxLIN];
extern char elAsys [mxSPC];
extern char *elPcmd ;
extern int elVcmd ;
extern char *elPsig ;
extern int elVsig ;
extern int elVdbg ;
extern int elVmai ;
extern int elVpau ;
extern int elVxdp ;
extern int elVdos ;
extern int elVrsx ;
extern int elFold ;
extern int elVemt ;
extern int elVtrp ;
extern int elVall ;
extern int elVlog ;
extern FILE *elPlog ;
extern int elFwri ;
extern int elVclk ;
extern int elFvrb ;
extern int elFvtx ;
extern int elF7bt ;
extern int elFdlx ;
extern int elFrsx ;
extern int elFupr ;
extern int elFsma ;
extern int elFiot ;
extern int elFstp ;
extern int elFuni ;
extern int elVhtz ;
extern int elFy2k ;
extern int elFltc ;
extern int elFvrb ;
extern int elFhog ;
void ds_emt (elTwrd ,elTwrd );
void rs_emt (elTwrd ,elTwrd );
void xx_emt (elTwrd ,elTwrd );
void xx_trp (elTwrd ,elTwrd );
/* code -  devices */
#define elCON  0
#define elCON_  BIT(0)
#define elCLK  1
#define elCLK_  BIT(1)
#define elKBD  2
#define elKBD_  BIT(2)
#define elTER  3
#define elTER_  BIT(3)
#define elHDD  4
#define elDLD  5
#define elRKD  6
#define elDYD  7
#define elBST_  BIT(8)
#define elPRS_  BIT(9)
#define elMMX_  BIT(20)
#define elCPU_  BIT(21)
#define elBUS_  BIT(22)
#define elPAS_  BIT(23)
#define elGEN_  BIT(24)
#define elEXI_  BIT(25)
#define elCTC_  BIT(26)
#define elRTI_  BIT(27)
#define elRTT_  BIT(28)
#define elBRK_  BIT(29)
#define BRK (elVsch|=elBRK_)
#define elABT_  BIT(30)
#define ABT (elVsch & elABT_)
#define elMMU_  BIT(31)
#define elTvec struct elTvec_t 
struct elTvec_t
{ int Vdev ;
  elTwrd Vcsr ;
  elTwrd Venb ;
  elTwrd Vrdy ;
  elTwrd Vvec ;
  int Vlat ;
  int Vcnt ;
  int Vpri ;
   };
extern elTvec elAvec [];
#define elTdev struct elTdev_t 
struct elTdev_t
{ int Vtyp ;
  int Vsts ;
  int Vuni ;
  size_t Vext ;
  size_t Vsiz ;
  size_t Vbas ;
  FILE *Pfil ;
  char Anam [mxSPC];
  char Aspc [mxSPC];
  ULONG V0 ;
  ULONG V1 ;
   };
extern elTdev elAdsk [];
#define rlCSR  0174400
#define rlBUF  0174402
#define rlBLK  0174404
#define rlCNT  0174406
#define rlEXT  0174410
#define rlVEC  0160
#define rlPRI  0240
#define rkSTA  0177400
#define rkERR  0177402
#define rkCSR  0177404
#define rkCNT  0177406
#define rkBUF  0177410
#define rkADR  0177412
#define rkDAT  0177414
#define rkVEC  0220
#define rkPRI  0240
#define rkRK5_  04000
#define rkRDY_  0100
#define dyCSR  0177170
#define dyBUF  0177172
#define dyVEC  264
#define dyPRI  220
extern int dyVbuf ;
#define hdCSR  0177110
#define hdCNT  0177112
#define hdBLK  0177114
#define hdBUF  0177116
#define hdXX0  0177120
#define hdXX1  0177122
#define hdBAE  0177124
#define hdVEC  0234
#define hdPRI  0240
#define hdERR_  0100000
#define hdUNI_  07000
#define hdCHG_  0400
#define hdRDY_  0200
#define hdENB_  0100
#define hdEXT_  060
#define hdFUN_  016
#define hdACT_  01
#define elRES  0
#define elREA  1
#define elWRI  2
#define elSIZ  3
#define elSEE  4
#define elNOP  5
#define elENB_  0100
#define elRDY_  0200
#define elACT_  01
#define elMP0  0172100
#define elMP1  0172102
#define elMP2  0172104
#define elMP3  0172106
#define elMP4  0172110
#define elMP5  0172112
#define elMP6  0172114
#define elMP7  0172116
/* code -  terminal */
#define elTKS  0177560
#define elTKB  0177562
#define elTPS  0177564
#define elTPB  0177566
#define elPSW  0177776
#define elLTC  0177546
#define elLTC_  BIT(6)
#define TKS (*MNB(elTKS))
#define TKB (*MNB(elTKB))
#define TPS (*MNB(elTPS))
#define TPB (*MNB(elTPB))
#define DKS (*MNB(elDKS))
#define RLS (*MNB(rlCSR))
extern int elVtks ;
extern int elVtkb ;
extern int elVtpp ;
extern int elVtkc ;
/* code -  clock */
extern int elVact ;
extern int elVtik ;
extern int elVpri ;
/* code -  VAP - V11 API */
#define vrSIG  0110706
#define vrNFI  1
#define vrMKD  2
#define vrDEF  3
#define vrNFW  4
#define vrDET  5
#define vrPDP  1
#define vrVCL  6
#define vrPAU  7
#define vrEXI  8
#define vrHTZ  9
#define vrTIM  10
void el_vap (void );
/* code -  debugger */
extern int bgVuni ;
extern int bgVhlt ;
extern int bgVstp ;
extern int bgVovr ;
extern int bgVovp ;
extern int bgVcnt ;
extern int bgVsto ;
extern int bgVtop ;
extern int bgVict ;
extern int bgVreg ;
extern int bgVdsk ;
extern int bgVter ;
extern int bgVfst ;
extern elTwrd bgVdbg ;
extern int bgVbus ;
extern int bgVcpu ;
extern int bgVcth ;
extern int bgVzed ;
extern int bgVprv ;
extern int bgVval ;
extern int bgVtpb ;
extern elTwrd bgVfen ;
extern elTwrd bgVfad ;
extern elTwrd bgVfel ;
extern elTwrd bgVund ;
extern int bgVred ;
/* code -  prototypes */
int vr_boo (void );
int vr_int (elTwrd );
#define hiLEN  256
#define elThis struct elThis_t 
struct elThis_t
{ elTwrd Vloc ;
  elTwrd Vmod ;
   };
#define hiTsto struct hiTsto_t 
struct hiTsto_t
{ int Vput ;
  int Vget ;
  elThis Ahis [hiLEN];
   };
extern hiTsto hiIsto ;
elTfun hi_put ;
hi_prv (elThis *);
hi_nxt (elThis *);
elTfun el_exi ;
el_hlp ();
el_win ();
int el_dbg (char *);
el_pri (int );
int el_mnt (elTdev *,int ,char *);
void el_aut (void );
void el_chg ();
void el_rmt ();
void el_lsd ();
int el_chd (int ,int );
elTdev *el_trn (int ,ULONG ,int ,int ,int ,int );
void el_put (int );
int elVlst ;
void el_new ();
void el_sol ();
char *el_mod (elTwrd );
int el_vrb (char *);
void el_sig (int );
void el_tim (int *,int *,int *);
void el_boo (int );
void el_trp (elTwrd );
el_wai ();
el_flg ();
elTfun el_evt ;
elTfun el_trc ;
void el_bus (int );
elTfun el_cpu ;
el_flu (void );
int el_get (void );
int el_prm (char *,char *);
elTfun el_tkb ;
elTfun el_tpb ;
elTfun el_pol ;
void el_sch (int );
elTfun el_clk ;
el_htz (int );
elTfun el_bst ;
elTfun el_rst ;
void vt_ini (void );
void vt_ast (void );
elTwrd el_fwd (elTadr );
void el_swd (elTadr ,elTwrd );
elTbyt el_fbt (elTadr );
void el_sbt (elTadr ,elTbyt );
#define elNAC  0
#define elFWD  1
#define elFBT  2
#define elSWD  3
#define elSBT  4
elTwrd el_fpc (void );
void el_psh (elTwrd );
elTwrd el_pop (void );
el_fmm (elTwrd ,void *,int );
#define PSH(x) (el_psh ((x)))
#define POP (el_pop ())
#define TOP (el_fwd (SP))
void el_mmu (int );
void el_mmx (int );
void el_reset (void );
void vr_tim (tiTval *,int *,int *);
void vr_unp (elTwrd *,char *,int );
char *vr_pck (char *,elTwrd *,int );
char *vr_pck_spc (char *,elTwrd *,int ,int );
#define vrSPC  64
int nf_drv (rtTqel *,elTwrd ,elTwrd );
/* code -  el_dbg - debuggger */
elTfun bg_reg ;
elTfun bg_wrd ;
elTfun bg_byt ;
bg_mem (elTadr );
elTfun bg_dev ;
elTfun bg_dsk ;
elTfun bg_sho ;
bg_bpt (elTwrd ,int );
int bg_prb (int );
#define bgPRB  0
#define bgTST  1
#define bgCLR  2
#define bgERR  3
/* code -  breakpoint, watchpoint etc triggers */
#define bgTtrg struct bgTtrg_t 
struct bgTtrg_t
{ int Venb ;
  elTwrd Vloc ;
  int Vmod ;
  WORD *Padr ;
  elTwrd Vval ;
  elTwrd Vmat ;
  elTwrd Vflg ;
   };
#define SNAP(x,y,z)  x.Venb &&(x.Vloc == y) && (x.Vmod == (z & elCUR_))
bg_set (bgTtrg *,elTwrd ,int );
extern bgTtrg bgIbpt ;
extern bgTtrg bgIwat ;
extern bgTtrg bgIfel ;
/* code -  PDP-11 microcode */
#define SWA  el_swa()
#define DWA  el_dwa()
#define SBA  el_sba()
#define DBA  el_dba()
#define SRA  el_sra()
#define DRA  el_dra()
#define RP0 (elTwrd *)(elPmem + elVswa)
#define RP1 (elTwrd *)(elPmem + (elVswa | 2))
#define DBH (elTbyt *)(elPmem + elVdba + 1)
#define SWP  PNW(elVswa)
#define SWV  elVswv
#define SBV  elVsbv
#define DWV  elVdwv
#define DBV  elVdbv
#define TWV  elVtwv
#define TBV  elVtbv
#define TLV  elVtlv
#define SLV  elVslv
#define DLV  elVdlv
#define SWG (SWV = el_fwd (elVswa))
#define SBG (SBV = el_fbt (elVsba))
#define SRG  SWG
#define DWG (DWV = el_fwd (elVdwa))
#define DBG (DBV = el_fbt (elVdba))
#define DRG  DWG
#define SWF (SWA, SWG)
#define SBF (SBA, SBG)
#define SRF (SRA, SRG)
#define DWF (DWA, DWG)
#define DBF (DBA, DBG)
#define DRF (DRA, DRG)
#define SWS(v) (el_swd (elVswa, (v)))
#define SBS(v) (el_sbt (elVsba, (v)))
#define DWS(v) (el_swd (elVdwa, (v)))
#define DBS(v) (el_sbt (elVdba, (v)))
#define TWS (DWS(TWV))
#define TBS (DBS(TBV))
#define RLN(v) (((v) & BIT(31)) ? SEN: CLN)
#define RWN(v) (((v) & BIT(15)) ? SEN: CLN)
#define RBN(v) (((v) & BIT(7)) ? SEN: CLN)
#define RLZ(v) ((v) ? CLZ: SEZ)
#define RWZ(v) ((v) ? CLZ: SEZ)
#define RBZ(v) ((v) ? CLZ: SEZ)
#define RLNZ(v) (RLN(v), RLZ(v))
#define RWNZ(v) (RWN(v), RWZ(v))
#define RBNZ(v) (RBN(v), RBZ(v))
#define RXV(v) ((v) ? SEV: CLV)
#define RXC(v) ((v) ? SEC: CLC)
#define KERMOD (!(PS & 0140000))
#define USPMOD (PS & 0140000)
#define REGMOD (!(OP & 070))
#define INVADR(x)  el_bus(x)
#define INVINS  el_cpu()
#define BRANCH  el_bra()
#define MMUERR(x)  el_mmx(x)
#define MMU  el_mmu(0)
#define MMUPRV  el_mmu(1)
#endif
