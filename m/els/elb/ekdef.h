/* header ekdef - threaded keyboard */
#ifndef _RIDER_H_ekdef
#define _RIDER_H_ekdef 1
#include "f:\m\rid\kbdef.h"
typedef int ekThoo (kbTcha *);
void ek_ini (ekThoo *);
int ek_get (kbTcha *,int );
void ek_can (void );
void ek_brk (void );
#endif
