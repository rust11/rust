/* header dgdef - dialog client definitions */
#ifndef _RIDER_H_dgdef
#define _RIDER_H_dgdef 1
#define dgTdlg struct dgTdlg_t 
struct dgTdlg_t
{ int Vtyp ;
  int Vcod ;
  void *Pdat ;
  long Vval ;
   };
int dg_opn (char *,char *,char *,int );
int dg_fnt (wsTevt *,wsTfnt *);
dgTdlg *dg_beg (wsTevt *,int ,int );
dg_end (wsTevt *,dgTdlg *);
#define dgDRG  1
int dg_drg (wsTevt *,dgTdlg *,int ,char *);
int dg_fnd (wsTevt *,char *,char *,int );
#define dgNXT  2
#define dgREP  3
#define dgALL  4
#define dgTER  5
#endif
