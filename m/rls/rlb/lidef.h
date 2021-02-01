/* header lidef - line operations */
#ifndef _RIDER_H_lidef
#define _RIDER_H_lidef 1
#define liTroo  liTlin
#define liTlin struct liTlin_t 
struct liTlin_t
{ liTlin *Psuc ;
  liTlin *Ppre ;
  liTroo *Proo ;
  int Vcnt ;
  int Vflg ;
  char Adat [4];
   };
#define liROO_  BIT(0)
#define liMOD_  BIT(1)
#define liMAN_  BIT(2)
#define liNUM_  BIT(15)
liTroo *li_ini (void );
int li_exi (liTroo *);
liTroo *li_cre (void );
liTroo *li_rea (char *,char *);
int li_wri (liTroo *,char *,char *);
liTroo *li_roo (liTlin *);
liTlin *li_suc (liTlin *);
liTlin *li_prd (liTlin *);
liTlin *li_fst (liTlin *);
liTlin *li_lst (liTlin *);
liTlin *li_nth (liTlin *,int );
int li_cnt (liTlin *);
char *li_dat (liTlin *);
int li_num (liTlin *);
int li_flg (liTlin *);
void li_set (liTlin *,int );
void li_tou (liTlin *);
liTlin *li_imp (char *);
char *li_exp (liTlin *);
liTlin *li_ins (liTlin *,liTlin *,char *);
liTlin *li_app (liTlin *,char *);
liTlin *li_del (liTlin *);
#endif
