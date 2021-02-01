/* header codef - console definitions */
#ifndef _RIDER_H_codef
#define _RIDER_H_codef 1
#define coThis struct coThis_t 
struct coThis_t
{ int Vcur ;
  int Vfst ;
  int Vlst ;
  int Vmax ;
  char *Ahis [64];
   };
coThis *co_his (void );
int co_sto (coThis *,char *);
int co_fet (coThis *,char *,int );
#define coMAX  63
int co_prm (char *,char *,int ,int );
int co_rea (char *,int ,int );
int co_get (void );
int co_att (void *);
int co_det (void );
#endif
