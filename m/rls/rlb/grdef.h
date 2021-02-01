/* header grdef - graphics */
#ifndef _RIDER_H_grdef
#define _RIDER_H_grdef 1
#define grTpnt struct grTpnt_t 
struct grTpnt_t
{ long x ;
  long y ;
   };
#define grTdim struct grTdim_t 
struct grTdim_t
{ long w ;
  long h ;
   };
#define grText struct grText_t 
struct grText_t
{ long b ;
  long l ;
   };
#define grTlim struct grTlim_t 
struct grTlim_t
{ long b ;
  long e ;
   };
#define grSAM (-1)
#define grBLK  0
#define grRED  1
#define grGRN  2
#define grORG  3
#define grBLU  4
#define grPUR  5
#define grWHI  10
#define grGRY  11
#define grDRK  12
#define grLRD  13
#define grLGR  14
#define grYEL  15
#define grLBL  16
#define grMAU  17
int gr_ppl (wsTevt *,long *,ULONG *,ULONG );
#endif
