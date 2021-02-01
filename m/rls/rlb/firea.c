/* file -  firea - read/write file */
#undef __STDC__
#include <stdio.h>
#include "m:\rid\rider.h"
#include "m:\rid\fidef.h"
#include "m:\rid\stdef.h"
#if Wdw || Wnt || Msc
#undef putchar
#include <io.h>
#include "m:\rid\cldef.h"
#else 
#include "m:\rid\dsdef.h"
#endif 
/* code -  - fi_rea - read file */
int fi_rea(
FILE *fil ,
void *buf ,
size_t cnt )
{ 
  return ( (fread (buf, cnt, 1, fil)) == 1);
} 
/* code -  - fi_wri - write file */
int fi_wri(
FILE *fil ,
void *buf ,
size_t cnt )
{ if ( cnt == (~1)) {cnt = st_len(buf) ;}
#if Wdw
  char *tmp ;
  if ( cl_tty (fil)) {
    tmp = buf;
    while ( cnt--) {putchar (*tmp++) ;}
    return 1; }
#endif 
  return ( (fwrite (buf, cnt, 1, fil)) == 1);
} 
#if Dos
/* code -  fi_drd - direct read file */
int fi_drd(
FILE *fil ,
void *buf ,
size_t cnt )
{ 
  dsTreg reg ;
  dsTseg seg ;
  DS=SEG(buf), DX=OFF(buf);
  BX = fileno (fil), CX=cnt;
  ds_s21 (0x3f00);
  return ( !CF && AX == cnt);
} 
/* code -  fi_dwr - direct write file */
int fi_dwr(
FILE *fil ,
void *buf ,
size_t cnt )
{ 
  dsTreg reg ;
  dsTseg seg ;
  if( cnt == 0)return 1;
  DS=SEG(buf), DX=OFF(buf);
  BX = fileno (fil), CX=cnt;
  ds_s21 (0x4000);
  return ( !CF && AX == cnt);
} 
#endif 
