/* header vudef - vup definitions */
#ifndef _vUdEf
#define _vUdEf 1
#define cmTspc struct cmTspc_t 
struct cmTspc_t
{ char *Pspc ;
  WORD Valc ;
   };
extern cmTspc cmAspc [9];
#define cmTval struct cmTval_t 
struct cmTval_t
{ WORD Vval ;
  WORD Vchn ;
   };
extern cmTval cmVlst ;
extern cmTval cmVst1 ;
extern cmTval cmVst2 ;
extern WORD cmVcre ;
extern WORD cmVseg ;
extern WORD cmVret ;
extern WORD cmVext ;
extern WORD cmVdrv ;
extern WORD cmVonl ;
extern WORD cmVwai ;
extern WORD cmVnoq ;
extern WORD cmVwrd ;
#define cmBAD_  BIT(0)
#define cmRST_  BIT(1)
#define cmLST_  BIT(3)
#define cmSTA_  BIT(4)
#define cmVER_  BIT(5)
#define cmSEG_  BIT(6)
#define cmFOR_  BIT(7)
#define cmREP_  BIT(8)
#define cmEXT_  BIT(9)
#define cmVOL_  BIT(10)
#define cmNOB_  BIT(11)
#define cmFIL_  BIT(12)
#define vuTobj struct vuTobj_t 
struct vuTobj_t
{ WORD Vblk ;
  WORD Vcnt ;
  char *Pmod ;
  FILE *Pfil ;
  void *Pbuf ;
  char Anam [16];
  char *Pdef ;
  char *Ptit ;
   };
extern vuTobj vuIboo ;
extern vuTobj vuIhom ;
extern vuTobj vuIsec ;
extern vuTobj vuIdrv ;
extern vuTobj vuIseg ;
extern vuTobj vuIsrc ;
extern vuTobj vuIdst ;
#define vuTctx struct vuTctx_t 
struct vuTctx_t
{ void *Psec ;
   };
#define vuREA  1
#define vuWRI  2
#endif
                                                                                                                                                                                                                                      