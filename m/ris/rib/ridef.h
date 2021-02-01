/* header ridef - rider data */
#ifndef _RIDER_H_ridef
#define _RIDER_H_ridef 1
#define riTlin struct riTlin_t 
struct riTlin_t
{ char Atxt [256];
  char Asrc [256];
  char *Pbod ;
  int Vbal ;
  char Veof ;
  char Vnul ;
  char Vis ;
  char Vbeg ;
  char Vend ;
  char Vcnd ;
  char Vcon ;
  char Vext ;
  char Vwas ;
   };
#define riLlin   sizeof(riTlin)
extern riTlin *riPcur ;
extern riTlin *riPnxt ;
extern char riVcod ;
extern char riVcnd ;
extern char riVcon ;
extern char riVsup ;
extern char riVsup ;
extern char riVinh ;
extern char riVis ;
extern char riVend ;
extern char riVwas ;
extern char riVnst ;
extern char riVhdr ;
extern char riAseg [64];
extern char riVini ;
extern int riVfil ;
extern int riVpre ;
extern int quFdec ;
extern int quFdos ;
extern int quFunx ;
extern int quFver ;
extern int quFlin ;
extern int quFear ;
extern int quFpro ;
extern char *riPswd ;
extern char *riPuwd ;
extern char *riPsop ;
extern char riAver [];
extern int riVdbg ;
extern char *riPswd ;
extern char *riPuwd ;
extern char *riPsop ;
extern char *riPver ;
typedef void riTkwd (void );
int ri_get (void );
int ri_raw (void );
riTkwd ri_beg ;
riTkwd ri_end ;
void ri_orf (int );
riTkwd ri_enm ;
void ri_par (void );
void ri_cnd (char *,char *);
void ri_put (void );
void ri_idn (int );
void ri_prt (char *);
void ri_new (void );
void ri_dis (char *);
#if Win
#ifndef RIFMT
void ri_fmt (char *,... );
#endif 
#else 
void ri_fmt ();
#endif 
int ri_typ (char *,char *);
riTkwd ri_kon ;
riTkwd ri_siz ;
riTkwd ri_bit ;
int ri_cst (char *);
void ri_pif (void );
char *ut_idt (char *,char *);
char *ut_tok (char *,char *);
void ut_seg (char *,char *);
riTkwd pp_if ;
riTkwd pp_elf ;
riTkwd pp_els ;
riTkwd pp_end ;
riTkwd pp_fix ;
#endif
