/* header osdef - operating systems */
#ifndef _RIDER_H_osdef
#define _RIDER_H_osdef 1
extern int osVsys ;
extern int osVimp ;
extern int osVhst ;
extern int osVcpu ;
extern int osVend ;
#define osKunk  0
#define osKbig  1
#define osKlit  2
#define osKvax  3
#define osKvms  4
#define osKx86  5
#define osKdos  6
#define osKw16  7
#define osKwin  8
#define osKw32  9
#define osKw95  10
#define osKwnt  11
int os_ini (void );
void os_war (void );
void os_err (void );
void os_fat (void );
int os_exi (void );
int os_idl (void );
int os_wai (ULONG );
int os_prm (void *,char *,char *,size_t );
#endif
