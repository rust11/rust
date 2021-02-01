/* header ctdef - rider character type definitions */
#ifndef _RIDER_H_ctdef
#define _RIDER_H_ctdef 1
#include "m:\rid\rider.h"
#define ctMctl (0)
#define ctMupr (1<<0)
#define ctMlow (1<<1)
#define ctMdig (1<<2)
#define ctMpun (1<<3)
#define ctMext (1<<4)
#define ctMspc (1<<5)
#define ctMprn (1<<6)
#define ctMhex (1<<7)
#define ctMlet (ctMupr|ctMlow)
#define ctMalp (ctMupr|ctMlow|ctMext)
#define ctMaln (ctMalp|ctMdig)
#define ctMgra (ctMaln|ctMpun)
extern int ct_aln (int );
extern int ct_alp (int );
extern int ct_ctl (int );
extern int ct_dig (int );
extern int ct_ext (int );
extern int ct_gra (int );
extern int ct_hex (int );
extern int ct_let (int );
extern int ct_low (int );
extern int ct_pun (int );
extern int ct_spc (int );
extern int ct_upr (int );
extern int ct_whi (int );
#define ctDEF  0
#define ctANS  1
extern void ct_cfg (int );
extern void ct_ass (int ,int );
extern void ct_set (int ,int );
extern void ct_clr (int ,int );
extern BYTE ctAtab [256];
#define ctMtab(cha)  ctAtab[(cha) & 255]
#define ct_aln(cha) (ctMtab(cha) & ctMaln)
#define ct_ctl(cha) (!(ctMtab(cha) & ctMprn))
#define ct_dig(cha) (ctMtab(cha) & ctMdig)
#define ct_ext(cha) (ctMtab(cha) & ctMext)
#define ct_gra(cha) (ctMtab(cha) & ctMgra)
#define ct_hex(cha) (ctMtab(cha) & ctMhex)
#define ct_let(cha) (ctMtab(cha) & ctMlet)
#define ct_low(cha) (ctMtab(cha) & ctMlow)
#define ct_pun(cha) (ctMtab(cha) & ctMpun)
#define ct_spc(cha) (ctMtab(cha) & ctMspc)
#define ct_upr(cha) (ctMtab(cha) & ctMupr)
#define ct_ass(c,m) (ctMtab(c) = (m))
#define ct_set(c,m) (ctMtab(c) |= (m))
#define ct_clr(c,m) (ctMtab(c) &= ~(m))
#endif
