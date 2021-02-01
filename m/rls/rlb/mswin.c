/* file -  mswin - mouse for windows */
#include "m:\rid\wsdef.h"
#include "m:\rid\medef.h"
#include "m:\rid\msdef.h"
static wsTcal ms_evt ;
msTpos msIphy = {0};
msTpos *msPphy = &msIphy;
/* code -  ms_ini - init mouse */
ms_ini(
msTpos *pos )
{ msTpos *phy = msPphy;
  wsPmou = &ms_evt;
   phy->Vmou = pos->Vmou = 2;return 1;
} 
/* code -  ms_qui - quit mouse */
ms_qui(
msTpos *pos )
{ wsPmou = NULL;
  return 1;
} 
/* code -  ms_sho - show mouse */
void ms_sho(
msTpos *pos )
{ 
} 
/* code -  ms_hid - hide mouse */
void ms_hid(
msTpos *pos )
{ 
} 
/* code -  ms_get - get mouse position and states */
void ms_get(
msTpos *pos )
{ msTpos *phy = msPphy;
  pos->Vcol = phy->Vcol;
  pos->Vrow = phy->Vrow;
  if ( pos->Vhgt) {pos->Vrow /= pos->Vhgt ;}
  if ( pos->Vwid) {pos->Vcol /= pos->Vwid ;}
  if ( pos->Vrgt) {pos->Vcol = pos->Vrgt-pos->Vcol ;}
  if ( pos->Vbot) {pos->Vrow = pos->Vbot-pos->Vrow ;}
  pos->Vbut = phy->Vbut;
} 
/* code -  ms_set - set mouse position */
void ms_set(
msTpos *pos ,
int row ,
int col )
{ int x ;
  int y ;
  if( pos->Vmou == 0)return;
  if ( row == -1) {row = pos->Vrow ;}
  if ( col == -1) {col = pos->Vcol ;}
  if ( pos->Vhgt) {row *= pos->Vhgt ;}
  if ( pos->Vwid) {col *= pos->Vwid ;}
  SetCursorPos (col, row);
} 
/* code -  ms_clk - detect mouse click */
int ms_clk(
msTpos *pos ,
int but )
{ msTpos *phy = msPphy;
  WORD clk = 0;
  if( pos->Vmou == 0)return 0;
  clk = but & phy->Vclk;
  if( (pos->Vclk = clk) == 0)return 0;
  phy->Vclk &= ~(but);
  pos->Vobt = pos->Vbut;
  pos->Vocl = pos->Vcol;
  pos->Vorw = pos->Vrow;
  ms_get (pos);
  pos->Vbut = but;
  return ( clk);
} 
/* code -  ms_drg - check drag */
ms_drg(
msTpos *pos ,
int but )
{ if( (pos->Vbut & but) == 0)return 0;
  if( (pos->Vobt & but) == 0)return 0;
  pos->Vver = pos->Vrow - pos->Vorw;
  pos->Vhor = pos->Vcol - pos->Vocl;
  if( (pos->Vver | pos->Vhor) == 0)return 0;
  pos->Vorw = pos->Vrow;
  pos->Vocl = pos->Vcol;
  return 1;
} 
/* code -  ms_evt - mouse event handler */
ms_evt(
wsTevt *evt )
{ msTpos *phy = msPphy;
  if( !phy->Vmou)return 0;
  switch ( evt->Vmsg) {
  case WM_LBUTTONDOWN:
    phy->Vclk |= msLFT_;
   break; case WM_RBUTTONDOWN:
    phy->Vclk |= msRGT_;
   break; case WM_MBUTTONDOWN:
    phy->Vclk |= msMID_;
   break; case WM_LBUTTONUP:
   break; case WM_RBUTTONUP:
   break; case WM_MBUTTONUP:
  case WM_LBUTTONDBLCLK:
  case WM_RBUTTONDBLCLK:
  case WM_MBUTTONDBLCLK:
   break; case WM_MOUSEMOVE:
   break; default: 
    return 0;
     }
  phy->Vcol = LOWORD(evt->Vlng);
  phy->Vrow = HIWORD(evt->Vlng);
  phy->Vbut = 0;
  if ( evt->Vwrd & MK_LBUTTON) {phy->Vbut |= msLFT_ ;}
  if ( evt->Vwrd & MK_RBUTTON) {phy->Vbut |= msRGT_ ;}
  if ( evt->Vwrd & MK_MBUTTON) {phy->Vbut |= msMID_ ;}
  if ( evt->Vwrd & MK_CONTROL) {phy->Vbut |= msCTL_ ;}
  if ( evt->Vwrd & MK_SHIFT) {phy->Vbut |= msSHF_ ;}
  return 1;
} 
