/* header abdef - abort control */
#ifndef _RIDER_H_abdef
#define _RIDER_H_abdef 1
int ab_ini (void );
void ab_dsb (void );
void ab_enb (void );
int ab_chk (void );
extern void (*abPbrk )();
extern volatile int abVboo ;
extern void (*abPcan )();
extern volatile int abVcan ;
extern void (*abPabt )();
extern volatile int abVabt ;
extern int abVmod ;
extern int abFcri ;
extern int abVcri ;
extern int (*abPcri )(void *);
#endif
