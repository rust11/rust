/* file -  wvmod - wave file operations */
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
#define wvTbuf struct wvTbuf_t 
struct wvTbuf_t
{ wvTbuf *Psuc ;
  int Vflg ;
  HWAVEOUT Hout ;
  HWAVEIN Hrec ;
  WAVEHDR *Phdr ;
  wvTwav *Pwav ;
   };
wvThdr wvIhdx = {0};
wvTwav wvItem  =  {
  NULL, 0, 0, 1, 11025, 1,
  };
wvTbuf wvSout = {0};
wvTbuf wvSrec = {0};
wvTbuf *wvPout = NULL;
int wvVout = wvSTP;
wvTbuf *wvPrec = NULL;
int wvVrec = wvSTP;
int wvVrde = 0;
#define wvHDR  44
#define wv11K  11025
#define wv22K  22050
#define wv44K  44100
#define wvINV  0
#define wv1MB  1
#define wv1SB  2
#define wv1MW  4
#define wv1SW  8
#define wv2MB (1<<4)
#define wv2SB (2<<4)
#define wv2MW (4<<4)
#define wv2SW (8<<4)
#define wv4MB (1<<8)
#define wv4SB (2<<8)
#define wv4MW (4<<8)
#define wv4SW (8<<8)
#define wvPCM  1
/* code -  wv_ply - play a sound file */
wv_ply(
char *spc ,
int mod )
{ return ( PlaySound (spc, 0, 0));
} 
/* code -  wv_fun - various things */
wv_fun(
wvTwav *wav ,
int fun )
{ wvTbuf *out = wvPout;
  wvTbuf *rec = wvPrec;
  if( !wav)return 0;
  if ( wvVrec == wvREC) {
    wvVrec = wvSTP;
    waveInReset (rec->Hrec);
    wv_rec_clo (rec);
    if( fun == wvSTP)return 1;
  } 
  if( wvVout == wvSTP)return 0;
  if( wvVout == fun)return 1;
  switch ( fun) {
  case wvSTP:
    waveOutReset (out->Hout);
    wvVout = wvSTP;
   break; case wvPAU:
    waveOutPause (out->Hout);
    wvVout = wvPAU;
   break; case wvCON:
    waveOutRestart (out->Hout);
    wvVout = wvPLY;
     }
  return 1;
} 
/* code -  wv_sta - get wave status */
wv_sta(
wvTwav *wav )
{ if( wav)return ( wvVout );
  if( wvVrec == wvREC)return ( wvREC );
  return ( wvSTP);
} 
/* code -  wv_pos - get wave position */
int wv_pos(
wvTwav *wav )
{ wvTbuf *buf = wvPout;
  HWAVEOUT han ;
  MMTIME tim ;
  nat typ ;
  if( !wav)return 0;
  tim.wType = TIME_SAMPLES;
  if ( wvVrec == wvREC) {
    if( (waveInGetPosition (buf->Hout, &tim,  sizeof(MMTIME))) == 0)return ( 0 );
    } else {
    if( !buf)return 0;
    if( (waveOutGetPosition (buf->Hout, &tim,  sizeof(MMTIME))) == 0)return ( 0 ); }
  wav->Vpos = tim.u.sample;
  return 1;
} 
/* code -  wv_ext - setup logical extent */
wv_ext(
wvTwav *wav ,
size_t beg ,
size_t siz )
{ size_t rem ;
  if( !wav)return 0;
  if ( beg > wav->Vcnt) {beg = wav->Vcnt ;}
  rem = wav->Vcnt - beg;
  if ( rem < siz) {siz = rem ;}
  wav->Vbeg = beg;
  wav->Vsiz = siz;
} 
/* code -  wv_out - output a wave */
wv_out(
wvTwav *wav ,
int flg )
{ wvTbuf *buf = &wvSout;
  wav->Vflg = flg;
  buf->Pwav = wav;
  wvPout = buf;
  wv_deq ();
  return 1;
} 
void wv_out_rep(
int res )
{ char buf [256];
  if( res == 0)return;
  waveOutGetErrorText (res, buf, 256);
  im_rep ("I-%s", buf);
} 
wv_out_clo(
wvTbuf *buf )
{ HWAVEOUT han = buf->Hout;
  WAVEHDR *hdr = buf->Phdr;
  int res ;
  wvPout = NULL;
  if ( buf->Phdr) {
    res = waveOutUnprepareHeader (han, hdr,  sizeof(WAVEHDR));
    wv_out_rep (res); }
  if ( han) {
    if ( han) {res = waveOutClose (han) ;}
    wv_out_rep (res); }
  mg_dlc (buf->Phdr);
  buf->Hout = 0;
  buf->Phdr = NULL;
} 
wv_out_err(
wvTbuf *buf ,
int res )
{ wv_out_rep (res);
  wv_out_clo (buf);
} 
int wv_deq()
{ char *dat ;
  size_t len ;
  wsTctx *svr = ws_ctx ();
  HWAVEOUT han = 0;
  PCMWAVEFORMAT pcm ;
  WAVEHDR *hdr = NULL;
  ULONG win = (ULONG )svr->Hwnd;
  ULONG mod = CALLBACK_WINDOW;
  wvTbuf *buf = wvPout;
  wvTwav *wav ;
  int res ;
  if( !buf)return 0;
  wav = buf->Pwav;
  if( !wav)return 1;
  if( buf->Hout)return 0;
  wsPwav = &wv_evt;
  dat = wav->Pdat + (wav->Vbeg * wav->Vpnt);
  len = wav->Vsiz * wav->Vpnt;
  wv_pcm (wav, &pcm);
  res = waveOutOpen (&han, WAVE_MAPPER, &(WAVEFORMAT )pcm, win, 0, mod);
  if( res){ wv_out_err (buf, res) ; return 0;}
  buf->Hout = han;
  buf->Phdr = hdr = mg_acc ( sizeof(WAVEHDR));
  hdr->lpData = (BYTE *)dat;
  hdr->dwBufferLength = len;
  if ( wav->Vflg & wvLOO_) {hdr->dwFlags = (WHDR_BEGINLOOP|WHDR_ENDLOOP) ;}
  hdr->dwLoops = ~(0);
  hdr->dwUser = (DWORD )&buf;
  res = waveOutPrepareHeader (han, hdr,  sizeof(WAVEHDR));
  if( res != 0){ wv_out_err (buf, res) ; return 0;}
  res = waveOutWrite (han, hdr,  sizeof(WAVEHDR));
  if( res){ wv_out_err (buf, res) ; return 0;}
  wvVout = wvPLY;
  return 1;
} 
/* code -  wv_evt - wave event handler */
wv_evt(
wsTevt *evt )
{ WAVEHDR *hdr = (WAVEHDR *)evt->Vlng;
  wvTbuf *buf ;
  switch ( evt->Vmsg) {
  case MM_WOM_DONE:
    buf = (wvTbuf *)hdr->dwUser;
    buf = wvPout;
    wv_out_clo (buf);
    wvVout = wvSTP;
    wv_deq ();
   break; case MM_WIM_DATA:
    if( !wvPrec)return 1;
    buf = wvPrec;
    if ( wvVrec == wvREC) {
      wvVrec = wvSTP;
      buf = (wvTbuf *)hdr->dwUser;
      wv_rec_clo (buf); }
   break; default: 
    return 0;
     }
  return 1;
} 
/* code -  wv_rec - record */
/* code -  wv_rec_rep - report */
void wv_rec_rep(
int res )
{ char buf [256];
  if( res == 0)return;
  waveInGetErrorText (res, buf, 256);
  im_rep ("I-%s", buf);
} 
/* code -  wv_rec_clo - close */
wv_rec_clo(
wvTbuf *buf )
{ HWAVEIN han = buf->Hrec;
  WAVEHDR *hdr = buf->Phdr;
  int res ;
  wvTwav *wav ;
  wvPrec = NULL;
  if ( buf->Phdr) {
    res = waveInUnprepareHeader (han, hdr,  sizeof(WAVEHDR));
    wv_rec_rep (res); }
  if ( han) {
    if ( han) {res = waveInClose (han) ;}
    wv_rec_rep (res); }
  buf->Hrec = 0;
  buf->Phdr = NULL;
  mg_dlc (buf->Phdr);
} 
/* code -  wv_rec_err - errors */
wv_rec_err(
wvTbuf *buf ,
int res )
{ wv_rec_rep (res);
  wv_rec_clo (buf);
} 
/* code -  wv_rec - record */
wvTwav *wv_rec(
wvTwav *tem ,
int don )
{ wsTctx *svr = ws_ctx ();
  wvTbuf *buf ;
  HWAVEIN han = 0;
  PCMWAVEFORMAT pcm ;
  WAVEFORMAT fmt ;
  WAVEHDR *hdr ;
  ULONG win = (ULONG )svr->Hwnd;
  ULONG mod = CALLBACK_WINDOW;
  wvTwav *wav ;
  char *dat ;
  size_t len ;
  int res ;
  if( wvPrec)return 0;
  wsPwav = &wv_evt;
  buf = wvPrec = &wvSrec;
  buf->Hrec = 0;
  buf->Phdr = NULL;
  if( (wav = wv_alc (tem, 500000)) == 0)return ( 0 );
  dat = wav->Pdat;
  len = wav->Vcnt;
  me_clr (dat, len * wav->Vpnt);
  wv_pcm (wav, &pcm);
  res = waveInOpen (&han, WAVE_MAPPER, &(WAVEFORMAT )pcm, win, 0, mod);
  if( res){ wv_rec_err (buf, res) ; return 0;}
  buf->Hrec = han;
  buf->Phdr = hdr = mg_acc ( sizeof(WAVEHDR));
  hdr->lpData = (BYTE *)dat;
  hdr->dwBufferLength = len;
  hdr->dwBytesRecorded = 0;
  hdr->dwUser = (DWORD )&buf;
  res = waveInPrepareHeader (han, hdr,  sizeof(WAVEHDR));
  if( res){ wv_rec_err (buf, res) ; return 0;}
  if ( !res) {res = waveInAddBuffer (han, hdr,  sizeof(WAVEHDR)) ;}
  if( res){ wv_rec_err (buf, res) ; return 0;}
  wvVrec = wvREC;
  res = waveInStart (han);
  if( res){ wv_rec_err (buf, res) ; return 0;}
  return ( wav);
} 
/* code -  wv_pcm - fill in pcm descriptor */
wv_pcm(
wvTwav *wav ,
PCMWAVEFORMAT *pcm )
{ 
  pcm->wf.wFormatTag = WAVE_FORMAT_PCM;
  pcm->wf.nChannels = wav->Vchn;
  pcm->wf.nSamplesPerSec = wav->Vrat;
  pcm->wf.nAvgBytesPerSec = wav->Vavg;
  pcm->wf.nBlockAlign = wav->Vchn * wav->Vwid;
  pcm->wBitsPerSample = wav->Vwid * 8;
} 
/* code -  wv_dup - duplicate a wave buffer */
wvTwav *wv_dup(
wvTwav *old )
{ wvTwav *new ;
  wv_nor (old);
  if( (new = wv_alc (old, old->Vcnt)) == 0)return ( 0 );
  me_cop (old->Pdat, new->Pdat, old->Vtot);
  return ( new);
} 
/* code -  wv_cat -- catenate upto 3 segments */
char *wv_trn (wvTwav *,wvTseg *,char *,int );
size_t wv_est (wvTwav *,wvTseg *);
wvTwav *wv_cat(
wvTwav *tem ,
wvTseg *s1 ,
wvTseg *s2 ,
wvTseg *s3 ,
int mod )
{ size_t alc ;
  wvTwav *new ;
  char *ptr ;
  alc = wv_est (tem, s1);
  alc += wv_est (tem, s2);
  alc += wv_est (tem, s3);
  if( (new = wv_alc (tem, alc)) == 0)return ( 0 );
  ptr = new->Pdat;
  ptr = wv_trn (tem, s1, ptr, 0);
  ptr = wv_trn (tem, s2, ptr, 0);
  ptr = wv_trn (tem, s3, ptr, 0);
  return ( new);
} 
/* code -  wv_trn - translate and copy a wave segment */
#define wvBMK  0xff
#define wvBOF  128
#define wvMbgt(p)  ((((p) & wvBMK)-wvBOF)<<8)
#define wvMwgt(p)  (p)
#define wvMbpt(v)  (((v)>>8) + wvBOF)
#define wvMwpt(v)  (v)
char *wv_trn(
wvTwav *tem ,
wvTseg *seg ,
char *dst ,
int mod )
{ wvTwav *wav = seg->Pwav;
  char *src = wav->Pdat + (seg->Vbeg * wav->Vpnt);
  size_t siz = seg->Vsiz;
  int lft ;
  int rgt = 0;
  WORD *swd = (WORD *)src;
  WORD *dwd = (WORD *)dst;
  int fil = 1;
  int skp = 0;
  int cnt ;
  int byt = (wav->Vwid == 1);
  int dbt = (tem->Vwid == 1);
  if (( tem->Vchn == wav->Vchn)
  &&(tem->Vwid == wav->Vwid)
  &&(tem->Vrat == wav->Vrat)) {
    return ( me_cop (src, dst,siz*wav->Vpnt)); }
  if ( tem->Vrat > wav->Vrat) {
    fil = tem->Vrat / wav->Vrat;
  } else if ( wav->Vrat > tem->Vrat) {
    skp = (wav->Vrat/tem->Vrat);
    siz /= skp;
    skp -= 1;
    if ( byt) {skp *= wav->Vpnt ;} else {
      skp *= wav->Vpnt / 2 ; } }
  while ( siz--) {
    if ( byt) {lft = wvMbgt(*src++) ;} else {
      lft = wvMwgt(*swd++) ; }
    if ( wav->Vchn == 2) {
      if ( byt) {rgt = wvMbgt(*src++) ;} else {
        rgt = wvMwgt(*swd++) ; }
      } else {
      rgt = lft; }
    if ( wav->Vchn > tem->Vchn) {
      lft = ((lft + rgt) / 2); }
    cnt = fil;
    while ( cnt--) {
      if ( dbt) {*dst++ = wvMbpt(lft) ;} else {
        *dwd++ = wvMwpt(lft) ; }
      if( tem->Vchn == 1)continue;
      if ( dbt) {*dst++ = wvMbpt(rgt) ;} else {
        *dwd++ = wvMwpt(rgt) ; }
    } 
    if( !skp)continue;
    if ( byt) {src += skp ;} else {
      swd += skp ; }
  } 
  return ( (dbt) ? dst: (char *)dwd);
} 
/* code -  wv_est - estimate size_t of a segment */
size_t wv_est(
wvTwav *tem ,
wvTseg *seg )
{ wvTwav *wav = seg->Pwav;
  size_t siz = seg->Vsiz;
  if ( tem->Vrat > wav->Vrat) {
    siz *= tem->Vrat / wav->Vrat;
  } else if ( wav->Vrat > tem->Vrat) {
    siz /= wav->Vrat / tem->Vrat; }
  return ( siz);
} 
/* code -  wv_alc - allocate a wave buffer */
wvTwav *wv_alc(
wvTwav *tem ,
size_t cnt )
{ char *buf ;
  wvTwav *wav ;
  wvThdr *hdr ;
  char *dat ;
  size_t tot = cnt;
  if ( !tem) {
    tem = &wvItem;
    tem->Phdr = &wvIhdx;
    wv_nor (tem); }
  tot *= tem->Vpnt;
  tot +=  sizeof(wvTwav) +  sizeof(wvThdr) + 128;
  buf = mg_alg (NULL, tot, meALC_);
  if ( !buf) {
    im_rep ("I-Insufficient memory for wave file", NULL);
    return 0; }
  wav = (wvTwav *)buf;
  hdr = (wvThdr *)(buf+ sizeof(wvTwav));
  dat = buf +  sizeof(wvTwav) +  sizeof(wvThdr);
  me_cop (tem, wav, sizeof(wvTwav));
  wav->Pdat = dat;
  wav->Vtot = tot;
  wav->Vcnt = cnt;
  wav->Vsiz = cnt;
  wav->Phdr = hdr;
  wv_nor (wav);
  return ( wav);
} 
/* code -  wv_dlc - deallocate wave */
wv_dlc(
wvTwav *wav )
{ wvTatr *suc ;
  wvTatr *atr ;
  if( !wav)return 1;
  suc = wav->Patr;
  while ( (atr = suc) != 0) {
    suc = atr->Psuc;
    if ( atr->Vflg & wvTXT_) {
      me_dlc (atr->Pdat); }
    me_dlc (atr);
  } 
  if ( wav) {mg_dlc (wav) ;}
  return 1;
} 
/* code -  wv_nor - normalize header */
wv_nor(
wvTwav *wav )
{ wav->Vpnt = wav->Vchn * wav->Vwid;
  wav->Vavg = wav->Vrat * wav->Vpnt;
  wav->Vtot = wav->Vcnt * wav->Vpnt;
  wv_hdr (wav);
  return 1;
} 
/* code -  wv_hdr - wave to header */
wvThdr wvIhdr  =  {
  "RIFF",
  0,
  "WAVEfmt ",
  16,
  wvPCM,
  1,
  wv22K,
  wv22K,
  1,
  8,
  "data",
  0,
  };
int wv_hdr(
wvTwav *wav )
{ wvThdr *hdr = wav->Phdr;
  if( !hdr)return 1;
  me_mov (&wvIhdr, hdr,  sizeof(wvThdr));
  hdr->Vfsz = wav->Vtot +  sizeof(wvThdr);
  hdr->Vdsz = wav->Vtot;
  hdr->Vchn = wav->Vchn;
  hdr->Vwid = wav->Vwid * 8;
  hdr->Vrat = wav->Vrat;
  hdr->Vavg = wav->Vavg;
  return 1;
} 
/* code -  wv_sho - display wave internals */
void wv_sho(
wvTwav *wav )
{ char txt [512];
  if ( !wav) {
    FMT (txt, "No wave");
    } else {
    FMT (txt,"spec=%s\ntot=%d\ncnt=%d\nchn=%d\nwid=%d\n",wav->Pspc,wav->Vtot, wav->Vcnt,wav->Vchn, wav->Vwid);
    FMT (st_end (txt),"rat=%d\navg=%d\npnt=%d\n",wav->Vrat, wav->Vavg,wav->Vpnt);
    FMT (st_end (txt),"beg=%d\nsiz=%d\ndat=%x",wav->Vbeg, wav->Vsiz,wav->Pdat);
  } 
  im_rep ("I-%s", txt);
} 
