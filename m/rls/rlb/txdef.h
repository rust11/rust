/* header txdef - text routines */
#ifndef _RIDER_H_txdef
#define _RIDER_H_txdef 1
#if wsSVR
#define txTtxt struct txTtxt_t 
struct txTtxt_t
{ HGLOBAL Hwnd ;
  HFONT Hfnt ;
  LOGFONT Sfnt ;
   };
#else 
#define txTtxt  void
#endif 
#define txTbuf struct txTbuf_t 
struct txTbuf_t
{ txTtxt *Ptxt ;
  char *Pdat ;
  size_t Vtot ;
  int Vflg ;
  size_t Vbot ;
  size_t Vlim ;
  size_t Vtop ;
  size_t Vbeg ;
  size_t Vend ;
  char Adat [1];
   };
#define tx_cmp  "Use st_dif (...)"
#define tx_cop  "Use st_cln (...)"
txTtxt *tx_cre (wsTevt *);
int tx_des (wsTevt *,txTtxt *);
int tx_loa (wsTevt *,txTtxt *,char *,int );
#define txINS_  BIT(0)
int tx_sto (wsTevt *,txTtxt *,char *,int );
#define txSEL_  BIT(1)
tx_clo (wsTevt *,txTtxt *);
tx_fun (wsTevt *,txTtxt *,int );
#define txUND  1
#define txCUT  2
#define txCOP  3
#define txPAS  4
#define txDEL  5
#define txALL  6
#define txCLO  7
wsTfnt *tx_fnt (wsTevt *,txTtxt *,wsTfnt *);
int tx_get (wsTevt *,txTbuf *);
int tx_set (wsTevt *,txTbuf *);
tx_fnd (wsTevt *,txTbuf *,int ,char *);
tx_ipt (wsTevt *,txTtxt *,char *,int );
tx_opt (wsTevt *,txTtxt *,char *,int );
#endif
