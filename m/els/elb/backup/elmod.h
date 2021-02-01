/* header elmod - PDP-11 emulator definitions */
#ifndef _RIDER_H_elmod
#define _RIDER_H_elmod 1
#include "c:\m\rid\rider.h"
#include "c:\m\rid\mxdef.h"
#include "c:\m\rid\fidef.h"
#include "c:\m\rid\eldef.h"
#include <setjmp.h>
#define MEMARR  0
/* code -  cpu environment */
typedef void elTfun (void );
#define elWRD_  0xffff
#define elBYT_  0xff
#define _1k (1024)
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
extern int elVhwm ;
extern int elVnmx ;
#define elREG (elPAS)
#define elDUM (elPAS+18)
#define elMEM (elPAS+128)
#define VPR(x)  el_vpr(x)
#define VPW(x)  el_vpr(x)
#define PNB(x) ((elTbyt *)(elPmem + (x)))
#define PNW(x) ((elTwrd *)(elPmem + (x)))
#define MNB(x) ((elTbyt *)(elPmch + (x)))
#define MNW(x) ((elTwrd *)(elPmch + (x)))
#define NMX(x) ((x)-elNMX)
#define MBX(x) ((x & ~(1))-elVIO)
#define DEV(x) (MBX(x)/2)
#define ODD(x) ((x) & 1)
void el_map (elTadr ,int );
elTadr el_vpr (elTadr );
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
#define elPRI_  0340
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
/* code -  basic data */
#if MEMARR
extern elTbyt elPmem [];
#else 
extern elTbyt *elPmem ;
#endif 
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
elTwrd elAstk [4];
#define STK(mod) (elAstk[((mod)>>14)&03])
extern char elAzer [];
extern jmp_buf elIjmp ;
extern int elFlsi ;
extern int elFvrt ;
extern int elFmap ;
extern elTadr elVevn ;
extern elTwrd elVopc ;
extern int elVsch ;
extern int elVmmu ;
extern int elV22b ;
int elVprb ;
int elVhwm ;
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
/* code -  CPU definitions */
/* code -  various */
elTfun el_ini ;
elTfun el_dis ;
extern char *elPcmd ;
extern int elVdbg ;
extern int elVmai ;
extern int elVpau ;
extern int elVxdp ;
extern int elVemt ;
extern int elVlog ;
extern FILE *elPlog ;
extern int elFwri ;
extern int elVclk ;
void xx_int (int );
/* code -  devices */
#define elCON  0
#define elCON_  BIT(0)
#define elCLK  1
#define elKBD  2
#define elTER  3
#define elTER_  BIT(3)
#define elHDD  4
#define elDLD  5
#define elDVS  6
#define elRKD  7
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
   };
extern elTvec elAvec [];
#define elTdev struct elTdev_t 
struct elTdev_t
{ int Vtyp ;
  int Vsts ;
  size_t Vsiz ;
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
#define rlVEC  0160
#define rlPRI  0240
#define rkSTA  0177400
#define rkERR  0177402
#define rkCSR  0177404
#define rkCNT  0177406
#define rkBUF  0177410
#define rkADR  0177412
#define rkVEC  0220
#define rkPRI  0240
#define hdCSR  0177110
#define hdCNT  0177112
#define hdBLK  0177114
#define hdBUF  0177116
#define hdVEC  0120
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
#define elNOP  4
#define elENB_  0100
#define elRDY_  0200
#define elACT_  01
/* code -  terminal */
#define elTKS  0177560
#define elTKB  0177562
#define elTPS  0177564
#define elTPB  0177566
#define elPSW  0177776
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
/* code -  VXI - VRT interconnect */
#define vxVXI  0110706
#define vxVMP  1
#define vxMKD  2
#define vxDEF  3
void el_vxi (void );
/* code -  debugger */
extern int bgVuni ;
extern int bgVhlt ;
extern int bgVstp ;
extern int bgVovr ;
extern int bgVcnt ;
extern int bgVict ;
extern int bgVreg ;
extern int bgVdsk ;
extern int bgVfst ;
extern elTwrd bgVbpt ;
extern int bgVbus ;
extern int bgVcpu ;
extern int bgVcty ;
extern elTwrd bgVwat ;
extern elTwrd bgVwad ;
extern elTwrd bgVwvl ;
extern int bgVzed ;
extern int bgVprv ;
extern int bgVval ;
/* code -  events */
/* code -  instruction history */
#define hiLEN  256
extern int hiVput ;
extern int hiVget ;
extern elTwrd hiAhis [hiLEN];
/* code -  prototypes */
int vr_boo (void );
int vr_int (elTwrd );
elTfun hi_put ;
elTwrd hi_prv (void );
elTwrd hi_nxt (void );
elTfun el_exi ;
int el_dbg (char *);
int el_mnt (elTdev *,int ,char *);
void el_aut (void );
void el_rmt ();
elTdev *el_trn (int ,ULONG ,int ,int ,int );
void el_put (int );
void el_new ();
void el_tim (int *,int *);
void el_boo (int );
void el_int (elTwrd );
elTfun el_evt ;
elTfun el_trc ;
void el_bus (int );
elTfun el_cpu ;
int el_tti (void );
elTfun el_kbd ;
elTfun el_pol ;
void el_sch (int );
elTfun el_clk ;
elTfun el_rst ;
elTwrd el_fwd (elTadr );
void el_swd (elTadr ,elTwrd );
elTbyt el_fbt (elTadr );
void el_sbt (elTadr ,elTbyt );
elTwrd el_fpc (void );
void el_psh (elTwrd );
elTwrd el_pop (void );
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
/* code -  el_dbg - debuggger */
elTfun bg_reg ;
elTfun bg_wrd ;
elTfun bg_byt ;
bg_adr (elTadr );
elTfun bg_dev ;
elTfun bg_dsk ;
elTfun bg_sho ;
#define elTrev struct elTrev_t 
struct elTrev_t
{ WORD Vloc ;
  WORD Vopc ;
  WORD Adat [3];
  int Vlen ;
  WORD Vpst ;
  char Astr [128];
  char *Pstr ;
   };
void el_rev (elTrev *);
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
