/* header wvdef - wave file operations */
#ifndef _RIDER_H_wvdef
#define _RIDER_H_wvdef 1
#define wvEOF  0
#define wvGEN  1
#define wvMRK  2
#define wvBAR_  BIT(0)
#define wvTXT_  BIT(1)
#define wvTatr struct wvTatr_t 
struct wvTatr_t
{ wvTatr *Psuc ;
  int Vtyp ;
  int Vflg ;
  size_t Vbeg ;
  size_t Vsiz ;
  void *Pdat ;
   };
#define wvTwav struct wvTwav_t 
struct wvTwav_t
{ char *Pdat ;
  size_t Vtot ;
  size_t Vcnt ;
  int Vchn ;
  ULONG Vrat ;
  int Vwid ;
  size_t Vbeg ;
  size_t Vsiz ;
  int Vsta ;
  size_t Vpos ;
  char *Pspc ;
  void *Phdr ;
  void *Vhan ;
  wvTatr *Patr ;
  int Vflg ;
  size_t Vpnt ;
  size_t Vavg ;
  size_t Vlft ;
  size_t Vrgt ;
   };
#define wvTseg struct wvTseg_t 
struct wvTseg_t
{ wvTwav *Pwav ;
  size_t Vbeg ;
  size_t Vsiz ;
   };
#define wvSTP  0
#define wvPLY  1
#define wvLOO  2
#define wvPAU  3
#define wvCON  4
#define wvREC  5
#define wvSEG_  BIT(1)
#define wvFST_  BIT(2)
#define wvLST_  BIT(3)
#define wvLOO_ (wvFST_|wvLST_)
wvTwav *wv_loa (char *,char *);
int wv_sto (wvTwav *,char *,char *);
int wv_clo (wvTwav *);
int wv_out (wvTwav *,int );
wvTwav *wv_rec (wvTwav *,int );
int wv_sta (wvTwav *);
int wv_pos (wvTwav *);
int wv_fun (wvTwav *,int );
int wv_ext (wvTwav *,size_t ,size_t );
int wv_ply (char *,int );
wvTwav *wv_dup (wvTwav *);
wvTwav *wv_alc (wvTwav *,size_t );
int wv_dlc (wvTwav *);
wvTwav *wv_cat (wvTwav *,wvTseg *,wvTseg *,wvTseg *,int );
#if WVDEF_LOCAL
#pragma  pack(2)
#define wvThdr struct wvThdr_t 
struct wvThdr_t
{ char Arif [4];
  ULONG Vfsz ;
  char Awav [8];
  ULONG Vunk ;
  WORD Vfmt ;
  WORD Vchn ;
  ULONG Vrat ;
  ULONG Vavg ;
  WORD Valn ;
  WORD Vwid ;
  char Adta [4];
  ULONG Vdsz ;
   };
#define wvTfil struct wvTfil_t 
struct wvTfil_t
{ wvThdr Ihdr ;
  BYTE Adat [1];
   };
#pragma  pack()
int wv_hdr (wvTwav *);
int wv_nor (wvTwav *);
#endif 
#endif
