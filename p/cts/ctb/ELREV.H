/* header elrev - reverse compile PDP-11 */
#ifndef _eLrEv
#define _eLrEv 1
#define elTrev struct elTrev_t 
struct elTrev_t
{ int Vflg ;
  WORD Vloc ;
  WORD Vopc ;
  WORD Adat [3];
  int Vlen ;
  WORD Vdst ;
  char Astr [128];
  char *Pstr ;
   };
#define elSKE_  BIT(0)
#define elNFP_  BIT(1)
void el_rev ();
#endif
                                                                                                                                                                                