/* header vumod - vup module */
#ifndef _RIDER_H_vumod
#define _RIDER_H_vumod 1
#define cmTspc struct cmTspc_t 
struct cmTspc_t
{ char *Pnam ;
  WORD Valc ;
   };
extern cmTspc cmAspc [9];
#define cmTval struct cmTval_t 
struct cmTval_t
{ WORD Vval ;
  BYTE Vchn ;
  BYTE Vsel ;
   };
extern cmTval cmIlst ;
extern cmTval cmIst1 ;
extern cmTval cmIst2 ;
extern WORD cmVcre ;
extern WORD cmVseg ;
extern WORD cmVret ;
extern WORD cmVext ;
extern WORD cmVdrv ;
extern WORD cmVonl ;
extern WORD cmVwai ;
extern WORD cmVnoq ;
extern WORD cmVwrd ;
extern WORD cmVopt ;
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
#define cmIGN_  BIT(13)
#define cmLOG_  BIT(14)
#define vuTobj struct vuTobj_t 
struct vuTobj_t
{ WORD Vblk ;
  WORD Vcnt ;
  char *Pmod ;
  char *Pdef ;
  char *Pdis ;
  FILE *Pfil ;
  void *Pbuf ;
  char Atmp [4];
  char Anam [16];
   };
extern vuTobj vuIdev ;
extern vuTobj vuIboo ;
extern vuTobj vuIhom ;
extern vuTobj vuIroo ;
extern vuTobj vuIseg ;
extern vuTobj vuIdrv ;
extern vuTobj vuIbas ;
extern vuTobj vuImon ;
extern vuTobj vuIsrc ;
extern vuTobj vuIdst ;
extern WORD vuAboo [];
#endif
                                                                                                                               