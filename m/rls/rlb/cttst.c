/* file -  cttst - character tests */
#include "m:\rid\rider.h"
#include "m:\rid\ctdef.h"
#undef ct_aln
#undef ct_ctl
#undef ct_dig
#undef ct_ext
#undef ct_hex
#undef ct_let
#undef ct_low
#undef ct_pun
#undef ct_spc
#undef ct_upr
/* code -  ct_aln - check alphanumeric */
ct_aln(
int cha )
{ return ( ctMtab(cha) & ctMaln);
} 
/* code -  ct_alp - check alphabetic */
ct_alp(
int cha )
{ return ( ctMtab(cha) & ctMalp);
} 
/* code -  ct_ctl - check control */
ct_ctl(
int cha )
{ return ( !(ctMtab(cha) & ctMprn));
} 
/* code -  ct_dig - check digit */
ct_dig(
int cha )
{ return ( ctMtab(cha) & ctMdig);
} 
/* code -  ct_ext - check extended character */
ct_ext(
int cha )
{ return ( ctMtab(cha) & ctMext);
} 
/* code -  ct_hex - check hex digit */
ct_hex(
int cha )
{ return ( ctMtab(cha) & ctMhex);
} 
/* code -  ct_let - check letter */
ct_let(
int cha )
{ return ( ctMtab(cha) & ctMlet);
} 
/* code -  ct_low - check lowercase */
ct_low(
int cha )
{ return ( ctMtab(cha) & ctMlow);
} 
/* code -  ct_pun - check punctuation */
ct_pun(
int cha )
{ return ( ctMtab(cha) & ctMpun);
} 
/* code -  ct_spc - check whitespace */
ct_spc(
int cha )
{ return ( ctMtab(cha) & ctMspc);
} 
/* code -  ct_upr - check uppercase */
ct_upr(
int cha )
{ return ( ctMtab(cha) & ctMupr);
} 
