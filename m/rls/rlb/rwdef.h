/* header rwdef - raw I/O definitions */
#ifndef _RIDER_H_rwdef
#define _RIDER_H_rwdef 1
#undef Vms
#define Vms 0
#ifdef vms
#if (vms)
#undef Vms
#define Vms 1
#endif
#endif
/* code -  rwTfil - file plex */
#define rwTfil struct rwTfil_t 
struct rwTfil_t
{ short Vmod ;
  short Vchr ;
  short Vctl ;
  int Vsta ;
  int Vcod ;
  int Vval ;
  char *Pspc ;
  long Vlen ;
  long Vpos ;
#if Vms
  rmTfab *Pfab ;
  rmTrab *Prab ;
#endif 
  char *Pbuf ;
  long Vadr ;
   };
/* code -  Vmod - open/create mode */
#define rwCRE_  BIT(0)
#define rwUPD_  BIT(1)
#define rwTMP_  BIT(7)
#define rwBIN_  BIT(10)
#define rwUFO_  BIT(11)
/* code -  Vctl - contol flags */
#define rwOPN_  BIT(0)
#define rwNEW_  BIT(1)
#define rwDYN_  BIT(2)
#define rwLEN_  BIT(3)
#define rwPOS_  BIT(4)
#define rwERR_  BIT(6)
#define rwEOF_  BIT(7)
#define rwMOD_  BIT(8)
/* code -  Vchr - characteristics */
#define rwDEV_  BIT(1)
#define rwDIR_  BIT(2)
#define rwTER_  BIT(3)
#define rwMBX_  BIT(4)
#define rwNET_  BIT(7)
/* code -  routines */
extern rwTfil *rw_alc ();
void rw_dlc ();
extern rwTfil *rw_opn ();
extern rwTfil *rw_cre ();
extern int rw_rea ();
extern int rw_wri ();
extern int rw_clo ();
extern int rw_prg ();
rw_buf (rwTfil *);
rw_see (rwTfil *,long );
size_t rw_get (rwTfil *,void *,size_t );
int rw_put (rwTfil *,void *,size_t );
#endif
