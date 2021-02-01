/* file -  ht_anl - analyse tree */
#include "m:\rid\rider.h"
#include "m:\rid\htdef.h"
/* code -  ht_anl - per root data */
#define htCroo  128
#define htCsli  4
extern htTnod *(*htPfor );
extern char *htPnam ;
extern int htVdup ;
extern int htVcla ;
extern int htVins ;
extern int htVdep ;
extern int htVini ;
int htVnds = 0;
int htVlfs = 0;
int htVrgs = 0;
int htVdps = 0;
int htVnls = 0;
static int ht_prt (htTnod *);
/* code -  ht_anl - analyse tree */
void ht_anl()
{ register int roo = 0;
  register int nds = 0;
  int lfs = 0;
  int rgs = 0;
  int nls = 0;
  register int dps = 0;
  ht_ini ();
  roo = -1;
  while ( ++roo < htCroo) {
    htVlfs = 0;
    htVrgs = 0;
    htVnds = 0;
    htVdps = 0;
    htVnls = 0;
    ht_prt (htPfor[roo]);
    if( htVnds == 0)continue;
    nds += htVnds;
    lfs += htVlfs;
    rgs += htVrgs;
    nls += htVnls;
    dps += htVdps;
    printf ("Root %3d: ", roo);
    printf ("%2d nodes, ", htVnds);
    printf ("%2d right, ", htVrgs);
    printf ("%2d left, ", htVlfs);
    printf ("%2d null, ", htVnls);
    printf ("Average depth %d\n",htVdps/(htVnds ? htVnds: 1));
  } 
  printf ("Totals:\n");
  printf ("%d inserted, ", htVins);
  printf ("%d found, ", nds);
  printf ("%d duplicate, ", htVdup);
  printf ("%d clashed\n", htVcla);
  printf ("%d left, ", lfs);
  printf ("%d right, ", rgs);
  printf ("%d null, ", nls);
  printf ("Average depth %d\n", dps/(nds ? nds: 1));
} 
/* code -  ht_prt - print & walk node */
int ht_prt(
register htTnod *nod )
{ register htTnod *fnd ;
  if ( nod == NULL) {
     ++htVnls;return 0; }
  if ( ht_prt (nod->Plft)) {
    ++htVlfs; }
  if ( ht_prt (nod->Prgt)) {
    ++htVrgs; }
  ++htVnds;
  htVdep = 0;
  if ( (fnd = ht_fnd (nod->Pnam)) == NULL) {
    printf ("Node [%s] not found\n", nod->Pnam);
  } else if ( fnd != nod) {
    printf ("Found [%s] instead of [%s]\n", fnd->Pnam, nod->Pnam); }
  htVdps += htVdep;
  return 1;
} 
