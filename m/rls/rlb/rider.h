/* header rider - common header */
#ifndef _RIDER_H_rider
#define _RIDER_H_rider 1
#include <stddef.h>
#undef Cpp
#define Cpp 0
#if (__cplusplus)
#undef Cpp
#define Cpp 1
#endif
#undef Ztc
#define Ztc 0
#ifdef __ZTC__
#if (__ZTC__)
#undef Ztc
#define Ztc 1
#endif
#endif
#undef Syc
#define Syc 0
#ifdef __SC__
#if (__SC__)
#undef Syc
#define Syc 1
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
#undef Wdw
#define Wdw 0
#ifdef _WINDOWS
#if (_WINDOWS)
#undef Wdw
#define Wdw 1
#endif
#endif
#undef Wnt
#define Wnt 0
#ifdef __NT__
#if (__NT__)
#undef Wnt
#define Wnt 1
#endif
#endif
#undef Msc
#define Msc 0
#ifdef _MSC_VER
#if (_MSC_VER)
#undef Msc
#define Msc 1
#endif
#endif
#undef Os2
#define Os2 0
#ifdef __OS2__
#if (__OS2__)
#undef Os2
#define Os2 1
#endif
#endif
#if Wdw || Wnt || Os2
#define Dos  0
#define Win  1
#else 
#define Dos  1
#define Win  0
#endif 
#define Unx  0
#define Vms  0
#ifndef BIT
#define BIT(n) (1<<(n))
#endif
typedef signed char sbyte ;
typedef signed short word ;
typedef unsigned char BYTE ;
typedef unsigned short WORD ;
typedef unsigned long ULONG ;
typedef unsigned int nat ;
#if Dos
#define TOFAR(t,s,o) ((t far *)(((ULONG )(s)<<16)|(WORD )(o)))
#if Ztc
#define SEG(a)  ((WORD )((ULONG )(a)>>16))
#define OFF(a)  ((WORD )(a))
#define SGP(a)  (((WORD *)(&a))[1])
#elif  Msc
#define SEG(a)  (*((WORD __far *)&(a)+1))
#define SGP(a)  ((WORD __far *)&(a)+1)
#define OFF(a)  (*((WORD __far *)&(a)))
#endif 
#endif 
#if Syc
#define FARW  
#else 
#define FARW  _far
#endif 
#if Win
#define NOMINMAX  1
#define wiTcha  char
#define wiTsho  short
#define wiTlng  long
#define handle  void*
#endif 
#if Cpp
#define CC  __cdecl
int __cdecl puts (const char *);
int __cdecl printf (const char *,... );
int __cdecl sprintf (char *,const char *,... );
int __cdecl sscanf (const char *,const char *,... );
#else 
#define CC  
int puts (const char *);
int printf (const char *,... );
int sprintf (char *,const char *,... );
int sscanf (const char *,const char *,... );
#endif 
#define PUT  printf
#define FMT  sprintf
#define SCN  sscanf
#define DBG(n)  PUT("DBG%d\n",n)
#ifndef MAX
#define MAX(a,b) (((a) > (b)) ? (a): (b))
#endif
#ifndef MIN
#define MIN(a,b) (((a) < (b)) ? (a): (b))
#endif
#ifndef ABS
#define ABS(a) (((a) > 0) ? (a): -(a))
#endif
#ifndef SGN
#define SGN(a) (((a) == 0) ? 0: (((a) > 0) ? 1: -1))
#endif
#endif
