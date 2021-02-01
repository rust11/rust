/* file -  ctcfg - character tests */
#include "m:\rid\rider.h"
#include "m:\rid\ctdef.h"
#undef ct_cfg
#undef ct_ass
#undef ct_set
#undef ct_clr
/* code -  ct_cfg - setup known configurations */
/* code -  ct_ass - assign character mask */
void ct_ass(
int cha ,
int mod )
{ ctMtab(cha) = mod;
} 
/* code -  ct_ass - set character mask bits */
void ct_set(
int cha ,
int mod )
{ ctMtab(cha) |= mod;
} 
/* code -  ct_clr - assign character mask bits */
void ct_clr(
int cha ,
int mod )
{ ctMtab(cha) &= ~(mod);
} 
