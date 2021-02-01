/* file -  cowin - console window interface */
#include "m:\rid\rider.h"
#include "m:\rid\codef.h"
#include "m:\rid\vkdef.h"
#include <windows.h>
/* code -  co_att - attach terminal */
int coVatt = 0;
HANDLE coHhan = INVALID_HANDLE_VALUE;
ULONG coVmod = 0;
#define _coGSH  "%COHAN-E-Error connecting console\n"
#define _coGCM  "%COHAN-E-Error getting console mode\n"
#define _coGSM  "%COHAN-E-Error setting console mode\n"
#define _coRCI  "%COHAN-E-Console read failed\n"
int co_att(
void *res )
{ HANDLE han ;
  ULONG mod ;
  for(;;)  {
    if( coVatt)break;
    han = GetStdHandle (STD_INPUT_HANDLE);
    if( han == INVALID_HANDLE_VALUE){ PUT (_coGSH) ; return 0;}
    if( (GetConsoleMode (han, &mod)) == 0){ PUT (_coGCM) ; return 0;}
    coVmod = mod;
    mod &= ~(ENABLE_ECHO_INPUT);
    if( (SetConsoleMode (han, mod)) == 0){ PUT (_coGSM) ; return 0;}
    coHhan = han;
    coVatt = 1;
   break;} 
  if ( res) {*(HANDLE *)res = han ;}
  return 1;
} 
/* code -  co_det - detach terminal */
co_det()
{ if( !coVatt)return 1;
  SetConsoleMode (coHhan, coVmod);
   coVatt = 0;return 1;
} 
/* code -  co_get - get next character */
co_get()
{ HANDLE han ;
  INPUT_RECORD rec ;
  ULONG cnt ;
  int cha ;
  if( !co_att (&han))return 0;
  for(;;)  {
    PUT("... ");
    ReadConsoleInput (han, &rec, 1, &cnt);
    if( rec.EventType != KEY_EVENT)continue;
    if( rec.Event.KeyEvent.bKeyDown == 0)continue;
    break;
  } 
  if( (cha = rec.Event.KeyEvent.uChar.AsciiChar) != 0)return ( cha );
  return ( vkMenc (rec.Event.KeyEvent.wVirtualKeyCode));
} 
