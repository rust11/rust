/* header mndef - windows menu routines */
#ifndef _RIDER_H_mndef
#define _RIDER_H_mndef 1
#include "m:\rid\dfdef.h"
#define mnENB_  BIT(0)
#define mnGRY_  BIT(1)
#define mnCHK_  BIT(2)
#define mnUNC_  BIT(3)
#define mnBMP_  BIT(4)
int mn_beg (char *);
int mn_sim (int ,char *);
int mn_com (int ,char *,int );
int mn_but (int ,void *,int );
int mn_skp (void );
int mn_sho (void );
int mn_trk (wsTevt *evt );
/* code -  mnThis - menu history support */
#define mnThis struct mnThis_t 
struct mnThis_t
{ int Vbas ;
  int Vcnt ;
  char *Atab [1];
   };
mnThis *mn_alc (int ,int );
void mn_dlc (mnThis *);
void mn_new (mnThis *,char *);
void mn_dis (mnThis *);
int mn_fil (mnThis *,int );
char *mn_sel (mnThis *,int );
char *mn_enu (mnThis *,int );
int mn_loa (mnThis *,dfTctx *,char *);
int mn_sto (mnThis *,dfTctx *,char *);
void *mn_han (int );
#define mnUP0  0
#define mnUP1  1
#define mnDN0  2
#define mnDN1  3
#define mnLF0  4
#define mnLF1  5
#define mnRG0  6
#define mnRG1  7
#define mnRD0  8
#define mnRD1  9
#define mnZO0  10
#define mnZO1  11
#define mnRS0  12
#define mnRS1  13
#define OBM_CLOSE  32754
#define OBM_UPARROW  32753
#define OBM_DNARROW  32752
#define OBM_RGARROW  32751
#define OBM_LFARROW  32750
#define OBM_REDUCE  32749
#define OBM_ZOOM  32748
#define OBM_RESTORE  32747
#define OBM_REDUCED  32746
#define OBM_ZOOMD  32745
#define OBM_RESTORED  32744
#define OBM_UPARROWD  32743
#define OBM_DNARROWD  32742
#define OBM_RGARROWD  32741
#define OBM_LFARROWD  32740
#define OBM_MNARROW  32739
#define OBM_COMBO  32738
#define OBM_UPARROWI  32737
#define OBM_DNARROWI  32736
#define OBM_RGARROWI  32735
#define OBM_LFARROWI  32734
#define OBM_OLD_CLOSE  32767
#define OBM_SIZE  32766
#define OBM_OLD_UPARROW  32765
#define OBM_OLD_DNARROW  32764
#define OBM_OLD_RGARROW  32763
#define OBM_OLD_LFARROW  32762
#define OBM_BTSIZE  32761
#define OBM_CHECK  32760
#define OBM_CHECKBOXES  32759
#define OBM_BTNCORNERS  32758
#define OBM_OLD_REDUCE  32757
#define OBM_OLD_ZOOM  32756
#define OBM_OLD_RESTORE  32755
#define OCR_NORMAL  32512
#define OCR_IBEAM  32513
#define OCR_WAIT  32514
#define OCR_CROSS  32515
#define OCR_UP  32516
#define OCR_SIZE  32640
#define OCR_ICON  32641
#define OCR_SIZENWSE  32642
#define OCR_SIZENESW  32643
#define OCR_SIZEWE  32644
#define OCR_SIZENS  32645
#define OCR_SIZEALL  32646
#define OCR_ICOCUR  32647
#define OCR_NO  32648 /*! in win3.1 */
#define OIC_SAMPLE  32512
#define OIC_HAND  32513
#define OIC_QUES  32514
#define OIC_BANG  32515
#define OIC_NOTE  32516
#endif
