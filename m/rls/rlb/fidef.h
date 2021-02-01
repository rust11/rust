/* header fidef - file operations */
#ifndef _RIDER_H_fidef
#define _RIDER_H_fidef 1
#include <stdio.h>
#include "m:\rid\tidef.h"
#define fiLspc  128
#define fiCmax  20
FILE *fi_opn (char *,char *,char *);
int fi_clo (FILE *,char *);
int fi_chk (FILE *,char *);
int fi_del (char *,char *);
int fi_ren (char *,char *,char *);
int fi_exs (char *,char *);
int fi_mis (char *,char *);
char *fi_spc (FILE *);
#define fi_err(f,m) (!fi_chk (f,m))
int fi_gtm (char *,tiTval *,char *);
int fi_stm (char *,tiTval *,char *);
int fi_gat (char *,int *,char *);
int fi_sat (char *,int ,int ,char *);
#define fl_opn(f,m)  fi_opn(f,m,"")
#define fl_clo(f)  fi_clo(f,"")
#define fl_chk(f)  fi_chk(f,"")
#define fl_err(f) (!fi_chk (f,""))
#define fl_del(f)  fi_del(f,"")
#define fl_ren(o,n)  fi_ren(o,n,"")
int fi_def (char *,char *,char *);
void fi_loc (char *,char *);
int fi_trn (char *,char *,int );
int fi_get (FILE *,char *,int );
int fi_put (FILE *,char *);
int fi_prt (FILE *,char *);
int fi_rea (FILE *,void *,size_t );
int fi_wri (FILE *,void *,size_t );
#if Dos
int fi_drd (FILE *,void *,size_t );
int fi_dwr (FILE *,void *,size_t );
#else 
#define fi_drd  fi_rea
#define fi_dwr  fi_wri
#endif 
size_t fi_ipt (FILE *,void *,size_t );
size_t fi_opt (FILE *,void *,size_t );
int fi_see (FILE *,long );
int fi_end (FILE *);
long fi_pos (FILE *);
long fi_len (FILE *);
long fi_siz (char *);
int fi_cop (char *,char *,char *,int );
size_t fi_buf (void *,size_t );
int fi_tra (FILE *,FILE *,size_t );
int fi_kop (FILE *,FILE *,long );
fi_loa (char *,void **,size_t *,FILE **,char *);
fi_sto (char *,void *,size_t ,int ,char *);
int fi_dlc (void *);
int fi_rep (char *,char *,char *);
#endif
