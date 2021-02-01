/* header htdef - hash trees */
#ifndef _RIDER_H_htdef
#define _RIDER_H_htdef 1
#define htTnod struct htTnod_t 
struct htTnod_t
{ char *Pnam ;
  void *Psym ;
  int Vhsh ;
  htTnod *Plft ;
  htTnod *Prgt ;
   };
int ht_ini (void );
char *ht_nam (htTnod *);
void *ht_sym (htTnod *);
void ht_set (htTnod *,void *);
htTnod *ht_ins (char *);
htTnod *ht_fnd (char *);
typedef void htTcbk (htTnod *);
void ht_wlk (htTcbk *);
void ht_anl (void );
#endif
