/* file -  pcscr - screen operations */
#include "m:\rid\rider.h"
#include "m:\rid\medef.h"
#include "m:\rid\mxdef.h"
#include "m:\pcb\pcdef.h"
#include "m:\pcb\pcvid.h"
#include "m:\rid\imdef.h"
int *ptPlat = NULL;
int *(*ptPlon )= NULL;
int *ptPhgt = NULL;
int *ptPwid = NULL;
/* code -  pt_ref - refresh screen */
void pt_ref(
pcTwld *wld )
{ pt_upd (wld);
  while ( 1) {pt_pnt (wld) ;}
} 
/* code -  pt_pnt - paint screen */
void pt_pnt(
pcTwld *wld )
{ ws_upd (wld->Pevt);
} 
/* code -  pt_upd - update screen */
void pt_upd(
pcTwld *wld )
{ pcTins *(*idx )= wld->Pidx;
  pcTidx *map = wld->Pmap;
  pcTscr *scr ;
  int *lat ;
  int *lon ;
  int mlt = wld->Vmlt;
  int row = HGT+1;
  int col ;
  int fst ;
  int lst ;
  int lft ;
  int rgt ;
  pcTins *ins ;
  wld->Vupd = 1;
  DBG5;
  row = HGT-HEL;
  while ( row > HEV) {
    DBG0;
    fst = ptPlat[--row] + wld->Vlat;
    lst = ptPlat[row-1] + wld->Vlat;
    while ( fst < lst) {
      DBG1;
      if( (unsigned )fst > mlt)break;
      col = 0;
      ins = IDX(wld->Pmap[fst++]);
      lon = ptPlon[row]+(WID/2);
      rgt = wld->Vlon - *lon;
      while (( ins != NULL)
      &&(ins->Vlon < rgt)) {
        ins = IDX(ins->Vsuc); }
      if( ins == NULL)continue;
      DBG2;
      while ( col < (WID/2)) {
        lft = rgt;
        if ( col != (WID/2)-1) {rgt = wld->Vlon - *--lon ;} else {
          rgt = wld->Vlon + *--lon ; }
        while (( ins != NULL)
        &&(ins->Vlon < rgt)) {
          pt_ins (wld, ins, row, col);
          ins = IDX(ins->Vsuc); }
        ++col;
      } 
      DBG3;
      while ( col < WID-1) {
        lft = rgt, rgt = wld->Vlon + *++lon;
        while (( ins != NULL)
        &&(ins->Vlon < rgt)) {
          pt_ins (wld, ins, row, col);
          ins = IDX(ins->Vsuc); }
        ++col;
      } 
    } 
  } 
} 
/* code -  pt_ins - paint instance */
void pt_ins(
pcTwld *wld ,
pcTins *ins ,
WORD row ,
WORD col )
{ 
} 
/* code -  pt_blk - blank screen image */
int xxx = 1;
void pt_blk(
pcTwld *wld )
{ pcTscr *scr = wld->Pscr;
  pcTatr *ats = scr->Patr;
  bmTbmp *bmp = scr->Pbmp;
  scr->Vkey = 0;
  bm_fil (bmp, 0, 0, WID, HEV, ++xxx);
  bm_fil (bmp, 0, HEV, WID, EAR, ++xxx);
  bm_fil (bmp, 0, HGT-HEL, WID, HEL, ++xxx);
} 
/* code -  pt_scr - paint screen */
#include "m:\rid\tidef.h"
void pt_scr(
pcTwld *wld )
{ wsTevt *evt = wld->Pevt;
  pcTscr *scr = wld->Pscr;
  bmTbmp *bmp = scr->Pbmp;
  char txt [128];
  pf_beg (wld, pfBEG);
  if( !gr_beg (evt))return;
  pf_end (wld, pfBEG);
  pm_hid (wld);
  pf_beg (wld, pfBLK);
  pt_blk (wld);
  pf_end (wld, pfBLK);
  pf_beg (wld, pfCOO);
  pt_coo (wld);
  pf_end (wld, pfCOO);
  pf_beg (wld, pfPAD);
  pt_pad (wld);
  pf_end (wld, pfPAD);
  pf_beg (wld, pfUPD);
  pt_upd (wld);
  pf_end (wld, pfUPD);
  pf_beg (wld, pfBMP);
  bm_pnt (evt, bmp, 0, 0);
  pf_end (wld, pfBMP);
  pf_rep (wld, txt);
  pf_ini (wld);
  gr_txt (evt, 0, 0, txt);
  pf_beg (wld, pfEND);
  gr_end (evt);
  pf_end (wld, pfEND);
  pm_sho (wld);
  wld->Vupd = 1;
} 
/* code -  pf_beg - performance */
#include "m:\rid\stdef.h"
pf_ini(
pcTwld *wld )
{ pcTper *per = wld->Pper;
  int *tim = per->Atim;
  int cnt = pfALC;
  while ( cnt--) {*tim++ = 0 ;}
} 
pf_beg(
pcTwld *wld ,
int idx )
{ pcTper *per = wld->Pper;
  int *tim = per->Atim;
  tim[idx] = ti_cpu (NULL);
} 
pf_end(
pcTwld *wld ,
int idx )
{ pcTper *per = wld->Pper;
  int *tim = per->Atim;
  tim[idx] = ti_cpu (NULL) - tim[idx];
} 
pf_itm(
pcTwld *wld ,
char *txt ,
int val ,
char *hdr )
{ if( val <= 1)return 1;
  FMT(st_end (txt), "%s=%d ", hdr, val);
} 
pf_rep(
pcTwld *wld ,
char *txt )
{ pcTper *per = wld->Pper;
  int *tim = per->Atim;
  st_cop ("Time: ", txt);
  pf_itm (wld, txt, tim[pfBLK], "Blk");
  pf_itm (wld, txt, tim[pfCOO], "Coo");
  pf_itm (wld, txt, tim[pfPAD], "Pad");
  pf_itm (wld, txt, tim[pfUPD], "Upd");
  pf_itm (wld, txt, tim[pfBEG], "Beg");
  pf_itm (wld, txt, tim[pfBMP], "Bmp");
  pf_itm (wld, txt, tim[pfEND], "End");
  pf_itm (wld, txt, wld->Vlat, "Lat");
  pf_itm (wld, txt, wld->Vlon, "Lon");
} 
