/* file -  wvfil - wave file operations */
#include "m:\rid\rider.h"
#include "m:\rid\imdef.h"
#include "m:\rid\fidef.h"
#include "m:\rid\medef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\mxdef.h"
#include <windows.h>
#include <stdio.h>
#define WVDEF_LOCAL  1
#include "m:\rid\wvdef.h"
#include "m:\rid\wsdef.h"
static FILE *wv_opn (char *,char *,char *);
/* code -  wv_clo - close and deallocate buffer */
wv_clo(
wvTwav *wav )
{  wv_dlc (wav);return 1;
} 
/* code -  wv_loa - load wave file */
wvTwav *wv_loa(
char *spc ,
char *msg )
{ char atr [128];
  wvTwav *wav = NULL;
  wvThdr *hdr ;
  size_t len = 0L;
  size_t tot ;
  size_t cnt ;
  FILE *fil = NULL;
  char *buf = NULL;
  int cod = 0;
  HGLOBAL gbl ;
  for(;;)  {
    if( (len = fi_siz (spc)) == 0)break;
    if( (fil = wv_opn (spc, ".wav", "rb")) == 0)break;
    if( (wav = wv_alc (NULL, len)) == 0)break;
    if( !fi_rea (fil, wav->Phdr, len))break;
    if( !fi_clo (fil, ""))break;
    hdr = wav->Phdr;
    wav->Vchn = hdr->Vchn;
    wav->Vwid = hdr->Vwid / 8;
    wav->Vrat = hdr->Vrat;
    wav->Vpnt = wav->Vchn * wav->Vwid;
    wav->Vavg = wav->Vrat * wav->Vpnt;
    tot = hdr->Vdsz;
    if ( tot > (len -  sizeof(wvThdr))) {
      tot = len -  sizeof(wvThdr); }
    cnt = tot / wav->Vpnt;
    wav->Vcnt = cnt;
    wav->Vtot = cnt * wav->Vpnt;
    wav->Vsiz = cnt;
    return ( wav);
   break;} 
  if ( wav) {wv_dlc (wav) ;}
  if ( fil) {fi_clo (fil, "") ;}
  return ( NULL);
} 
/* code -  wv_sto -- store file */
wv_sto(
wvTwav *wav ,
char *spc ,
char *msg )
{ FILE *fil ;
  char *buf ;
  size_t siz ;
  if( !wav)return 0;
  wv_nor (wav);
  buf = (char *)wav->Phdr;
  siz = wav->Vtot +  sizeof(wvThdr);
  if (( (fil = wv_opn (spc, ".wav", "wb")) == 0)
  ||(fi_wri (fil, buf, siz) == 0)) {
    fi_rep (spc, msg, "");
    fi_clo (fil, "");
    return 0; }
  fi_clo (fil, "");
  wv_opt (wav, spc);
  return 1;
} 
/* code -  wv_ipt - input attributes */
wv_ipt(
wvTwav *wav ,
char *spc )
{ char txt [512];
  FILE *fil ;
  wvTatr *(*lst )= &(wav->Patr);
  wvTatr *atr ;
  size_t beg ;
  int siz ;
  int typ ;
  int flg ;
  fil = wv_opn (spc, ".wat", "rb");
  if( !fil)return 0;
  for(;;)  {
    if( (fscanf (fil, "%lx,%lx,%lx,%lx",&beg, &siz, &typ, &flg)) == 0)break;
    fi_get (fil, txt, 126);
    if( typ == wvEOF)break;
    atr = me_acc ( sizeof(wvTatr));
    atr->Vbeg = beg;
    atr->Vsiz = siz;
    atr->Vtyp = typ;
    atr->Vflg = flg;
    if ( flg & wvTXT_) {
      if( (fi_rea (fil, &txt, NULL)) == 0)break;
      atr->Pdat = st_dup (txt); }
    *lst = atr;
    lst = &(atr->Psuc);
  } 
  fi_clo (fil, "");
  return 1;
} 
/* code -  wv_opt - output attributes */
wv_opt(
wvTwav *wav ,
char *spc )
{ FILE *fil ;
  wvTatr *atr = wav->Patr;
  if ( !atr) {
    return 1; }
  fil = wv_opn (spc, ".wat", "wb");
  while ( atr) {
    fprintf (fil, "%lx,%lx,%lx,%lx",atr->Vbeg, atr->Vsiz,atr->Vtyp, atr->Vflg);
    if ( atr->Vflg & wvTXT_) {
      fi_put (fil, atr->Pdat); }
    fi_put (fil, "\n");
    atr = atr->Psuc;
  } 
  fi_clo (fil, "");
  return 1;
} 
/* code -  wv_opn - open a wave file */
FILE *wv_opn(
char *spc ,
char *typ ,
char *mod )
{ char nam [mxSPC];
  st_cop (spc, nam);
  if ( st_sam (typ, ".wat")) {
    st_rep (".wav", ".wat", nam);
  } else if ( st_sam (typ, ".wav")) {
    st_rep (".wat", ".wav", nam); }
  return ( fi_opn (nam, mod, ""));
} 
