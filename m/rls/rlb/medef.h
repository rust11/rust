/* header medef - rider memory operations */
#ifndef _RIDER_H_medef
#define _RIDER_H_medef 1
#include "m:\rid\rider.h"
#define meKrts  1
void *me_alc (size_t );
void *me_acc (size_t );
void *me_ral (void *,size_t );
void me_dlc (void *);
void *me_alg (void *,size_t ,int );
#define meCLR_  BIT(0)
#define meALC_  BIT(1)
void *me_ulk (void *);
void *me_lck (void *);
void *me_fix (void *);
void *me_flt (void *);
void *me_clr (void *,size_t );
void *me_set (void *,size_t ,int );
void *me_cop (void *,void *,size_t );
void *me_mov (void *,void *,size_t );
void *me_dup (void *,size_t );
void *me_lnk (void *,size_t );
#if Win
void *mg_alc (size_t );
void *mg_acc (size_t );
void *mg_ral (void *,size_t );
int mg_dlc (void *);
void *mg_alg (void *,size_t ,int );
void *mg_dup (void *,size_t );
void *mg_lck (void *);
void *mg_ulk (void *);
void *mg_fix (void *);
void *mg_flt (void *);
#else 
#define mg_alc  me_alc
#define mg_acc  me_acc
#define mg_ral  me_ral
#define mg_dlc  me_dlc
#define mg_alg  me_alg
#define mg_dup  me_dup
#define mg_lck  me_lck
#define mg_ulk  me_ulk
#define mg_fix  me_lck
#define mg_flt  me_ulk
#endif 
extern size_t meValc ;
extern size_t meVdlc ;
int me_alp (void **,size_t );
int me_apc (void **,size_t );
void me_dlp (void **);
#endif
