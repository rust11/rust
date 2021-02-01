/* header eldef - pdp-11 definitions */
#ifndef _RIDER_H_eldef
#define _RIDER_H_eldef 1
#include "f:\m\rid\rider.h"
#include "f:\m\rid\eldef.h"
/* code -  cpu environment */
typedef void elTfun (void );
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
#define elPAS (elVAS)
#define elHWM (elPAS-_8k)
#define elNMX (elPAS-elVAS)
#define elMCH (elPAS-elVAS)
#define elREG (elPAS)
#define elMEM (elPAS+128)
#define MMU(x)  el_mmu(x)
#define VPR(x)  el_vpr(x)
#define VPW(x)  el_vpr(x)
#define PNB(x) ((elTbyt *)(elPmem + (x)))
#define PNW(x) ((elTwrd *)(elPmem + (x)))
#define MNB(x) ((elTbyt *)(elPmch + (x)))
#define MNW(x) ((elTwrd *)(elPmch + (x)))
#define NMX(x) ((x)-elNMX)
#define el_fmw(x) (*MNW(x))
#define el_fmb(x) (*MNB(x))
#define el_smw(x,y) (*MNW(x)=(y))
#define el_smb(x,y) (*MNB(x)=(y))
extern elTbyt elPmem [];
extern elTbyt *elPmch ;
extern elTwrd *elPreg ;
extern elTwrd elVpsw ;
extern char elAzer [];
extern int elVlsi ;
extern int elVmmu ;
extern int elVmmu ;
extern int elV22b ;
extern elTadr elVevn ;
extern elTwrd elVopc ;
extern int elVsch ;
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
#define OP  elVopc
#define R0  elPreg[0]
#define R1  elPreg[1]
#define R2  elPreg[2]
#define R3  elPreg[3]
#define R4  elPreg[4]
#define R5  elPreg[5]
#define SP  elPreg[6]
#define PC  elPreg[7]
#define PS  elVpsw
#define elMtbt(x) ((x) & ~(elT_))
#define TBIT ((PS & elT_) >> 4)
#define NBIT ((PS & elN_) >> 3)
#define ZBIT ((PS & elZ_) >> 2)
#define VBIT ((PS & elV_) >> 1)
#define CBIT (PS & elC_)
#define CLC (PS &= (~elC_))
#define CLV (PS &= (~elV_))
#define CLZ (PS &= (~elZ_))
#define CLN (PS &= (~elN_))
#define SEC (PS |= elC_)
#define SEV (PS |= elV_)
#define SEZ (PS |= elZ_)
#define SEN (PS |= elN_)
#endif
