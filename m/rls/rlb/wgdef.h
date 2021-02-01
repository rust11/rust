/* header wgdef - windows client/server generic definitions */
#ifndef _RIDER_H_wgdef
#define _RIDER_H_wgdef 1
wsTcal ws_cod ;
void ws_pch (int );
ws_prt (const char *,... );
wsTcal *wsPloo ;
int wc_bld (wsTevt *,char *);
wsTcal wc_cre ;
wsTcal wc_cmd ;
wsTcal wc_mou ;
wsTcal wc_pnt ;
wsTcal wc_qui ;
wsTcal wc_loo ;
wsTcal ws_loo ;
wsTcal wv_evt ;
wc_fnd (wsTevt *,int ,int ,char *,char *);
wsTcal wv_evt ;
wsTcal ws_cod ;
int ws_pee (wsTevt *,int );
wsTcal ws_upd ;
wsTcal wc_exi ;
wsTcal ws_exi ;
int ws_run (char *,int );
int ws_msg (char *,char *);
int ws_dec (char *,int );
int ws_lnk (void );
#define wsDIH  1
#define wsDIW  2
#define wsDSX  10
#define wsDSY  11
#define wsDTH  12
#define wsDTW  13
#define wsCLR  14
#define wsMIN  15
#define wsBOX  16
#define wsSTY  17
#define wsCLA  18
#define wsBUT  19
#define wsCMD  20
#define wsCHH  21
#define wsCHW  22
int ws_int (wsTevt *,int );
char *ws_str (wsTevt *,int );
#define wsPNT  3
int ws_set (wsTevt *,int ,int );
ws_mov (wsTevt *);
wsTcal ws_pnt ;
ws_tit (wsTevt *,char *);
wsTcal gr_beg ;
wsTcal gr_end ;
int gr_pol (wsTevt *,long *,int );
int gr_txt (wsTevt *,int ,int ,char *);
int gr_col (wsTevt *,int ,int );
int gr_fnt (wsTevt *,int );
tm_sta (wsTevt *,long ,wsTcal *);
tm_stp (wsTevt *);
#endif
