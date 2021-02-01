/* file -  fimod - file operations */
#include "m:\rid\rider.h"
#if Vms
#include <unixio>
#elif  Dos
#undef __STDC__
#include <stdio.h>
#endif 
#include "m:\rid\fidef.h"
#include "m:\rid\imdef.h"
#include "m:\rid\stdef.h"
#include "m:\rid\medef.h"
#define E_OpnFil  "E-Error opening file [%s]"
#define E_CreFil  "E-Error creating file [%s]"
#define E_PrcFil  "E-Error processing file [%s]"
#define E_CloFil  "E-Error closing file [%s]"
#define E_DelFil  "E-Error deleting file [%s]"
#define E_RenFil  "E-Error renaming file [%s]"
#define E_ExsFil  "E-Missing file [%s]"
#define E_MisFil  "E-File already exists [%s]"
#define fiTinf struct fiTinf_t 
struct fiTinf_t
{ short Vlen ;
  char *Pspc ;
  FILE *Pfil ;
   };
imTrep *fiPrep = &im_rep;
static fiTinf fiAinf [fiCmax]= {0};
static int fi_reg (FILE *,char *);
static void fi_drg (FILE *);
static fiTinf *fi_inf (FILE *);
/* code -  fi_opn - open file */
FILE *fi_opn(
char *spc ,
char *mod ,
char *msg )
{ FILE *fil ;
  char loc [fiLspc];
  if ( !st_sam (spc, "con")) {
    fi_loc (spc, loc);
    } else {
#if Wnt
    if ( st_fnd ("r", mod)) {st_cop ("conin$", loc) ;} else {
      st_cop ("conout$", loc) ; }
#endif 
  } 
  if ( (fil = fopen (loc, mod)) != 0) {
    fi_reg (fil, loc);
    return ( fil); }
  if( msg == 0)return ( NULL );
  if ( *msg == 0) {
    if (( st_mem ('r', mod) == 0)
    &&(st_mem ('w', mod) != 0)) {
      msg = E_CreFil;
      } else {
      msg = E_OpnFil; } }
  fi_rep (msg, loc, msg);
  return ( NULL);
} 
/* code -  fi_clo - close file */
int fi_clo(
FILE *fil ,
char *msg )
{ int sta ;
  if( fil == NULL)return 1;
  sta = fi_chk (fil, msg);
  fi_drg (fil);
  if( fclose (fil) != EOF)return ( sta );
  if( sta == 0)return 0;
   fi_rep (msg, fi_spc (fil), E_CloFil);return 0;
} 
/* code -  fi_del - delete file */
int fi_del(
char *spc ,
char *msg )
{ char loc [fiLspc];
  fi_loc (spc, loc);
  if( remove (loc) == 0)return 1;
   fi_rep (msg, spc, E_DelFil);return 0;
} 
/* code -  fi_ren - rename file */
fi_ren(
char *old ,
char *new ,
char *msg )
{ char src [(fiLspc*2)+2];
  char dst [fiLspc];
  fi_loc (old, src);
  fi_loc (new, dst);
  if( rename (src, dst) == 0)return 1;
  st_app ("] [", src);
  st_app (dst, src);
   fi_rep (msg, src, E_RenFil);return 0;
} 
/* code -  fi_exs - check file exists */
fi_exs(
char *spc ,
char *msg )
{ FILE *fil ;
  fil = fi_opn (spc, "rb", NULL);
  if( fil){ fi_clo (fil, NULL) ; return 1;}
   fi_rep (msg, spc, E_ExsFil);return 0;
} 
/* code -  fi_mis - check file missing */
fi_mis(
char *spc ,
char *msg )
{ FILE *fil ;
  fil = fi_opn (spc, "rb", NULL);
  if( !fil)return 1;
  fi_clo (fil, NULL);
   fi_rep (msg, spc, E_MisFil);return 0;
} 
/* code -  fi_chk - check file for errors */
int fi_chk(
FILE *fil ,
char *msg )
{ char *spc ;
  if( ferror (fil) == 0)return 1;
  spc = fi_spc (fil);
   fi_rep (msg, spc, E_PrcFil);return 0;
} 
/* code -  fi_rep - report file error */
int fi_rep(
char *msg ,
char *spc ,
char *def )
{ if( msg == NULL)return 1;
  if ( *msg == 0) {msg = def ;}
  (*fiPrep)(msg, spc);
  return 1;
} 
/* code -  fi_spc - workout filespec */
char *fi_spc(
FILE *fil )
{ fiTinf *inf ;
  if( fil == NULL)return ( "(null)" );
  if( (inf = fi_inf (fil)) == NULL)return ( "(invalid)" );
  if( inf->Pspc != 0)return ( inf->Pspc );
  if( fil == stdin)return ( "(stdin)" );
  if( fil == stdout)return ( "(stdout)" );
  if( fil == stderr)return ( "(stderr)" );
  return ( "(unknown)");
} 
/* code -  fi_reg - register spec */
int fi_reg(
FILE *fil ,
char *spc )
{ fiTinf *inf ;
  int len = st_len (spc) + 1;
  if( (inf = fi_inf (fil)) == NULL)return 0;
  inf->Pfil = fil;
  if ( inf->Vlen < len) {
    me_alp ((void **)&inf->Pspc, (inf->Vlen = (len + 31) & ~(31))); }
  st_cop (spc, inf->Pspc);
  return 1;
} 
/* code -  fi_drg - deregister file */
void fi_drg(
FILE *fil )
{ fiTinf *inf ;
  if( (inf = fi_inf (fil)) == NULL)return;
  inf->Pfil = NULL;
} 
/* code -  fi_inf - get info entry address */
fiTinf *fi_inf(
FILE *fil )
{ unsigned idx ;
  idx = fileno (fil);
  if( idx >= fiCmax)return ( NULL );
  return ( &fiAinf[idx]);
} 
