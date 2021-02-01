/* file -  cldis - dispatch command */
#include "m:\rid\rider.h"
#include "m:\rid\cldef.h"
#include "m:\rid\imdef.h"
#define E_InvCmd  "E-Invalid command"
/* code -  cl_dis - dispatch command */
int cl_dis(
void *env ,
char *str ,
clTdis *tab ,
char *msg )
{ while ( tab->Pkwd != NULL) {
    if ( cl_mat (str, tab->Pkwd)) {
       (*tab->Pfun)(env);return 1; }
    ++tab;
  } 
  if( msg == NULL)return 0;
  if ( *msg == 0) {msg = E_InvCmd ;}
   im_rep (msg, str);return 0;
} 
