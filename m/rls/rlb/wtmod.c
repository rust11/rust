/* file -  wtmod - windows terminal emulator */
#include "m:\rid\rider.h"
#include "m:\rid\wsdef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\txdef.h"
#include "m:\rid\wtdef.h"
txTtxt *wtPtxt = NULL;
/* code -  wt_opn - open terminal window */
txTtxt *wt_opn()
{ wsTctx *ctx = ws_ctx ();
  wsTevt evt ;
  txTtxt *txt = wtPtxt;
  evt.Hwnd = ctx->Hwnd;
  if ( !ctx) {txt = tx_cre (&evt) ;}
  return ( wtPtxt = txt);
} 
/* code -  wt_clo - close terminal window */
wt_clo()
{ return 1;
} 
/* code -  wt_put - put to window */
wt_put(
char *buf ,
int cnt )
{ txTtxt *txt = wt_opn ();
  tx_opt (NULL, txt, buf, cnt);
  return 1;
} 
/* code -  wt_get - get from window */
wt_get(
char *buf ,
int cnt )
{ return 0;
} 
/* code -  wt_evt - terminal event */
wt_evt()
{ 
} 
/* code -  wt_pnt - paint terminal */
wt_pnt()
{ 
} 
