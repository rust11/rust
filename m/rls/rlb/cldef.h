/* header cldef - command language definitions */
#ifndef _RIDER_H_cldef
#define _RIDER_H_cldef 1
#include <stdio.h>
#define clTdis struct clTdis_t 
struct clTdis_t
{ char *Pkwd ;
  void (*Pfun )(void *);
   };
int cl_dis (void *,char *,clTdis *,char *);
int cl_loo (char *,char *[],int *);
int cl_mat (char *,char *);
int cl_prm (FILE *,char *,char *,int );
int cl_cmd (char *,char *);
FILE *cl_tty (FILE *);
int cl_ass (char *,int ,char **);
int cl_mrg (char *,int ,char **);
int cl_vec (char *,int *,char *(**));
#define cl_nth(n,s,d)  cl_arg (n,s,d,0,NULL)
int cl_arg (int ,char *,char *,int ,char *);
#if Wnt
int cl_lin (char *);
#endif 
#endif
