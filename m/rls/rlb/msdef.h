/* header msdef - mouse definitions */
#ifndef _RIDER_H_msdef
#define _RIDER_H_msdef 1
#define msTpos struct msTpos_t 
struct msTpos_t
{ WORD Vmou ;
  WORD Vclk ;
  WORD Vprs ;
  WORD Vrel ;
  WORD Vdbl ;
  WORD Vbut ;
  int Vcol ;
  int Vrow ;
  int Vobt ;
  int Vocl ;
  int Vorw ;
  int Vdrg ;
  int Vhor ;
  int Vver ;
  int Vhgt ;
  int Vwid ;
  int Vbot ;
  int Vrgt ;
   };
#define msLFT_  BIT(0)
#define msRGT_  BIT(1)
#define msMID_  BIT(2)
#define msCTL_  BIT(3)
#define msSHF_  BIT(4)
#define msNON  0
#define msDRG  1
#define msDRP  2
int ms_ini (msTpos *);
ms_qui (msTpos *);
ms_res (msTpos *);
void ms_get (msTpos *);
void ms_set (msTpos *,int ,int );
void ms_sho (msTpos *);
void ms_hid (msTpos *);
int ms_clk (msTpos *,int );
int ms_drg (msTpos *,int );
#endif
