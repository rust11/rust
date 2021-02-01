/* file -  tistr - time to string operations */
#include "m:\rid\rider.h"
#include "m:\rid\tidef.h"
/* code -  ti_dts - make date string */
static char *tiAday [] =  {
  "Sunday", "Monday", "Tuesday","Wednesday", "Thursday",
  "Friday", "Saturday",
  };
static char *tiAmon [] =  {
  "Jan", "Feb", "Mar", "Apr",
  "May", "Jun", "Jul", "Aug",
  "Sep", "Oct", "Nov", "Dec",
  };
/* code -  ti_day - the day of the week */
ti_day(
tiTplx *plx ,
char *str )
{ st_cop (tiAday[plx->Vdow], str);
} 
/* code -  ti_dat - the date */
ti_dat(
tiTplx *plx ,
char *str )
{ FMT(str, "%02d-%s-%04d",plx->Vday, tiAmon[plx->Vmon], plx->Vyea);
  return 1;
} 
/* code -  ti_tim - the time */
ti_tim(
tiTplx *plx ,
char *str )
{ FMT(str, "%02d:%02d:%04d",plx->Vhou, plx->Vmin, plx->Vsec);
  return 1;
} 
