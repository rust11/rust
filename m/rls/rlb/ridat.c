/* file -  ridat - compiler dependent data */
#include "m:\rid\ridef.h"
#include "m:\rid\ridat.h"
int quFdec = 0;
int quFdos = Dos || Win || Wnt;
int quFunx = 0;
int quFver = 0;
riTlin *riPcur = NULL;
riTlin *riPnxt = NULL;
char *riPswd = "short";
char *riPuwd = "short unsigned";
#if Vms
char *riPsop = "tt:";
#else 
char *riPsop = "con";
#endif 
int riVdbg = 0;
