#if Log
#define LOG(m)  db_msg (m)
#define LOGe(m)  db_err(m)
#define LOGs(m, o)  db_str(m, (char *)o)
#define LOGv(m, o)  db_val(m, (int )o)
#define LOGw(m)  db_log(m)
#else 
#define LOG(m)  
#define LOGe(m)  
#define LOGs(m, o)  
#define LOGv(m, o)  
#define LOGw(m)  
#endif 
/* header dbdef - debug */
#ifndef _RIDER_H_dbdef
#define _RIDER_H_dbdef 1
#include "m:\rid\mxdef.h"
#define dbTctx struct dbTctx_t 
struct dbTctx_t
{ long Vrts ;
  long Vsys ;
  long Vsev ;
   };
#define _dbLOG  "DEBUGLOG"
int db_msg (char *);
int db_val (char *,int );
int db_str (char *,char *);
int db_err (char *);
int db_log (char *);
void db_sav (dbTctx *);
void db_res (dbTctx *);
#if Win
int db_clr (void );
int db_lst (char *);
char *dbw_msg (nat );
char *dbw_err (nat );
#endif 
#if Win
#define dbTexc struct dbTexc_t 
struct dbTexc_t
{ BYTE *Pip ;
  ULONG *Psp ;
  int Vcod ;
  int Vflg ;
  ULONG *Vadr ;
  char Aspc [mxSPC];
   };
typedef int dbTprc (dbTexc *);
dbTprc db_rev ;
int db_hoo (dbTprc *);
/* code -  read/write memory */
#define dbTacc struct dbTacc_t 
struct dbTacc_t
{ void *Hprc ;
   };
int db_opn (dbTacc *,char *,long ,int );
db_clo (dbTacc *);
int db_rea (dbTacc *,void *,void *,size_t );
int db_wri (dbTacc *,void *,void *,size_t );
void *db_dis (void *);
#endif 
#endif
