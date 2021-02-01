/* file -  fitra - file transfer operations */
#include "m:\rid\rider.h"
#include "m:\rid\fidef.h"
#include "m:\rid\medef.h"
#include <stdio.h>
#include <stdlib.h>
static void *fiPbuf = NULL;
static size_t fiVbuf = 0;
/* code -  fi_buf - setup a transfer buffer */
size_t fi_buf(
void *buf ,
size_t siz )
{ if ( buf != NULL) {
    fiPbuf = buf;
    fiVbuf = siz;
    return ( siz); }
  if( siz == fiVbuf)return ( siz );
  if ( fiVbuf != 0) {
    fiVbuf = 0;
    me_dlc (fiPbuf); }
  if( siz == 0)return ( 0 );
  for(;;)  {
    if( (fiPbuf = malloc (siz)) != NULL)break;
    if( (siz /= 2) < 1024)return 0;
  } 
  return ( (fiVbuf = siz));
} 
/* code -  fi_tra - transfer file */
int fi_tra(
FILE *src ,
FILE *dst ,
size_t lim )
{ char tra [1024];
  char *buf ;
  int dlc = 0;
  size_t siz ;
  size_t cnt ;
  if ( fiVbuf == 0) {
    dlc = fi_buf (NULL, 8192*3); }
  if ( fiVbuf) {
    buf = fiPbuf, siz = fiVbuf;
    } else {
    buf = tra, siz = 1024; }
  for(;;)  {
    if ( lim && lim < siz) {siz = lim ;}
    if( (cnt = fi_ipt (src, buf, siz)) == 0)break;
    if( (fi_wri (dst, buf, cnt)) == 0)break;
    if( lim && (lim -= siz) == 0)break;
  } 
  if ( dlc) {fi_buf (NULL,0) ;}
  if( fi_err (src, NULL))return 0;
  if( fi_err (dst, NULL))return 0;
  return 1;
} 
/* code -  fi_kop - kopy files (handle) */
int fi_kop(
FILE *src ,
FILE *dst ,
long len )
{ char tra [1024];
  char *buf ;
  int dlc = 0;
  long siz ;
  long cnt ;
  int res = 1;
  setvbuf (src, NULL, _IONBF, 0);
  setvbuf (dst, NULL, _IONBF, 0);
  if ( fiVbuf == 0) {
    dlc = fi_buf (NULL, 8192*3); }
  if ( fiVbuf) {
    buf = fiPbuf, siz = fiVbuf;
    } else {
    buf = tra, siz = 1024; }
  if ( !len) {
    len = fi_len(src)-fi_pos(src); }
  for(;;)  {
    cnt = (siz < len) ? siz: len;
    if (( !fi_drd (src, buf, (size_t )cnt))
    ||(!fi_dwr (dst, buf, (size_t )cnt))) {
       res = 0;break; }
    if( (len -= cnt) == 0)break;
  } 
  if ( dlc) {fi_buf (NULL,0) ;}
  if( fi_err (src, NULL))return 0;
  if( fi_err (dst, NULL))return 0;
  return ( res);
} 
