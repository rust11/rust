/* header kbdef - keyboard definitions */
#ifndef _RIDER_H_kbdef
#define _RIDER_H_kbdef 1
#include "m:\rid\wcdef.h"
typedef WORD kbTord ;
#define kbBUF  128
#define kbSYS_  BIT(0)
#define kbVIR_  BIT(1)
#define kbASC_  BIT(2)
#define kbENH_  BIT(4)
#define kbCTL_  BIT(5)
#define kbSHF_  BIT(6)
#define kbALT_  BIT(7)
#define kbTcha struct kbTcha_t 
struct kbTcha_t
{ char Vflg ;
  kbTord Vord ;
   };
#define kbTkbd struct kbTkbd_t 
struct kbTkbd_t
{ int Vflt ;
  int Vflg ;
  size_t Vget ;
  size_t Vput ;
  size_t Lbuf ;
  kbTcha Abuf [kbBUF];
   };
kbTkbd *kb_att (wsTevt *);
kb_det (wsTevt *);
int kb_put (wsTevt *,kbTcha *);
#define kbWAI_  BIT(12)
#define kbPEE_  BIT(13)
#define kbGET_  0
int kb_get (wsTevt *,kbTcha *,int );
#define kbCinv  0
#define kbClbt  1
#define kbCrbt  2
#define kbCcan  3
#define kbCmbt  4
#define kbCbsp  8
#define kbCtab  9
#define kbCclr  0xc
#define kbCesc  
#define kbCcap  
#define kbCshf  0x10
#define kbCctl  0x11
#define kbCalt  0x12
#define kbCprt  
#define kbCscr  
#define kbCpau  0x13
#define kbKcap  0x14
#define kbCcup  1
#define kbCcdn  2
#define kbCcrt  3
#define kbCclf  4
#define kbCua0  5
#define kbCua1  6
#define kbCua2  7
#define kbCub0  8
#define kbCub1  9
#define kbCub2  10
#define kbCf0  20
#define kbCf1  21
#define kbCf2  22
#define kbCf3  23
#define kbCf4  24
#define kbCf5  25
#define kbCf6  26
#define kbCf7  27
#define kbCf8  28
#define kbCf9  29
#define kbCf10  30
#define kbCf11  31
#define kbCf12  32
#define kbCf13  33
#define kbCf14  34
#define kbCf15  35
#define kbCf16  36
#define kbCf17  37
#define kbCf18  38
#define kbCf19  39
#define kbCf20  40
#define kbCka0  50
#define kbCka1  51
#define kbCka2  52
#define kbCka3  53
#define kbCkb0  54
#define kbCkb1  55
#define kbCkb2  56
#define kbCkb3  57
#define kbCkc0  58
#define kbCkc1  59
#define kbCkc2  60
#define kbCkc3  61
#define kbCkd0  62
#define kbCkd1  63
#define kbCkd2  64
#define kbCkd3  65
#define kbCke0  66
#define kbCke1  67
#define kbCke2  68
#define kbCke3  69
#define kbCatA  70
#define kbCatB  71
#define kbCatC  72
#define kbCatD  73
#define kbCatE  74
#define kbCatF  75
#define kbCatG  76
#define kbCatH  77
#define kbCatI  78
#define kbCatJ  79
#define kbCatK  80
#define kbCatL  81
#define kbCatM  82
#define kbCatN  83
#define kbCatO  84
#define kbCatP  85
#define kbCatQ  86
#define kbCatR  87
#define kbCatS  88
#define kbCatT  89
#define kbCatU  90
#define kbCatV  91
#define kbCatW  92
#define kbCatX  93
#define kbCatY  94
#define kbCatZ  95
#endif
