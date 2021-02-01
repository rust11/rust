/* file -  riput - write output */
#define RIFMT  1
#include "m:\rid\ridef.h"
#include "m:\rid\eddef.h"
#include "m:\rid\iodef.h"
#include "m:\rid\stdef.h"
/* code -  locals */
/* code -  ri_put - emit line */
void ri_put()
{ register riTlin *lin = riPcur;
  register int nst = riVnst;
  if ( *lin->Atxt == '#') {
    ri_prt (lin->Atxt);
    *lin->Atxt = 0; }
  while ( --(lin->Vis) >= 0) {
    ed_pre ("{ ");
    ++riVnst; }
  while ( --(lin->Vbeg) >= 0) {
    ed_app (" {");
    ++riVnst; }
  while ( --(lin->Vend) >= 0) {
    ed_app (" }");
    --riVnst; }
  if ( *lin->Asrc == '\f') {
    ri_dis ("\f");
    *lin->Asrc = 0; }
  if ( *lin->Atxt != 0) {
    while ( --nst >= 0) {
      ri_dis ("  "); }
    ri_prt (lin->Atxt); }
} 
/* code -  ri_idn - indent for case */
void ri_idn(
int ext )
{ register int nst ;
  nst = riVnst + ext;
  while ( --nst >= 0) {
    ri_dis ("  "); }
} 
/* code -  ri_prt - print a line */
void ri_prt(
register char *str )
{ ri_dis (str);
  ri_new ();
} 
/* code -  ri_new - print a newline */
void ri_new()
{ ri_dis ("\n");
} 
/* code -  ri_dis - print string */
void ri_dis(
register char *str )
{ 
  if( riVinh)return;
  io_put (str);
} 
/* code -  ri_fmt - write formatted string */
void ri_fmt(
char *msg ,
void *p1 ,
void *p2 ,
void *p3 ,
void *p4 )
{ int par = 1;
  void *var ;
  int val ;
  int mod ;
  char buf [128];
  char *dst = buf;
  while ( *msg != 0) {
    if ( *msg == '%') {
      ++msg;
      if ( *msg) {mod = *msg++ ;} else {
        mod = '?' ; }
      if ( mod == '%') {
         *dst++ = mod;continue; }
      switch ( par++) {
      case 1:
        var = p1;
       break; case 2:
        var = p2;
       break; case 3:
        var = p3;
       break; case 4:
        var = p4;
       break; default: 
        var = "???";
         }
      switch ( mod) {
      case 's':
        dst = (st_cop((char *)var, dst));
       break; case 'd':
        val = *(int *)var;
        dst += (sprintf (dst, "%d", val));
       break; default: 
        *dst++ = '[';
        *dst++ = '%';
        *dst++ = par;
        *dst++ = ']';
         }
      continue;
    } 
    while ( *msg != 0) {
      if( *msg == '%')break;
      if (( msg[0] == '\\')
      &&(msg[1] != 0)) {
        *dst++ = *msg++; }
      *dst++ = *msg++;
    } 
  } 
  *dst = 0;
  ri_prt (buf);
} 
