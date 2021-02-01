/* header rider - DOS rider front-end (ridos.h) */
#ifndef _RIDER_H_rider
#define _RIDER_H_rider 1
#include <stddef.h>
#define Dos  1
#define Unx  0
#define Vms  0
#undef Ztc
#define Ztc 0
#ifdef __ZTC__
#if (__ZTC__)
#undef Ztc
#define Ztc 1
#endif
#endif
#undef Stc
#define Stc 0
#ifdef __STDC__
#if (__STDC__)
#undef Stc
#define Stc 1
#endif
#endif
#ifndef BIT
#define BIT(n) (1<<(n))
#endif
typedef unsigned long ULONG ;
typedef unsigned short WORD ;
typedef unsigned char BYTE ;
typedef unsigned int nat ;
#define TOFAR(t,s,o) ((t far *)(((ULONG )(s)<<16)|(WORD )(o)))
#if Ztc
#define SEG(a)  ((WORD )((ULONG )(a)>>16))
#define OFF(a)  ((WORD )(a))
#define SGP(a)  (((WORD *)(&a))[1])
#else 
#define SEG(a)  (*((WORD __far *)&(a)+1))
#define SGP(a)  ((WORD __far *)&(a)+1)
#define OFF(a)  (*((WORD __far *)&(a)))
#endif 
int printf (const char *,... );
int sprintf (char *,const char *,... );
int sscanf (const char *,const char *,... );
#define PUT  printf
#define FMT  sprintf
#define SCN  sscanf
#endif
