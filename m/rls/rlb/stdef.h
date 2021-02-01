/* header stdef - string definitions */
#ifndef _RIDER_H_stdef
#define _RIDER_H_stdef 1
char *st_app (char *,char *);
char *st_bal (char *);
char *st_chg (char *,char *,char *);
int st_cmp (char *,char *);
char *st_cop (char *,char *);
char *st_cln (char *,char *,size_t );
char *st_del (char *,size_t );
int st_dif (char *,char *,size_t );
char *st_dup (char *);
char *st_end (char *);
char *st_exc (char *,char *,int );
char *st_ext (char *,char *,char *,char *);
char *st_fit (char *,char *,size_t );
char *st_fnd (char *,char *);
int st_idx (int ,char *);
char *st_ins (char *,char *);
int st_len (char *);
int st_loo (char *,char **);
char *st_low (char *);
char *st_lst (char *);
int st_mem (int ,char *);
char *st_mov (char *,char *);
char *st_par (char *,char *,char *);
char *st_rem (char *,char *);
char *st_rep (char *,char *,char *);
char *st_rev (char *);
int st_sam (char *,char *);
char *st_scn (char *,char *);
char *st_seg (char *,char *,char *,char *);
char *st_skp (char *);
int st_sub (char *,char *);
char *st_trm (char *);
char *st_upr (char *);
int st_wld (char *,char *);
#endif
