/* header ftdef */
#ifndef _RIDER_H_ftdef
#define _RIDER_H_ftdef 1
#define ftMAX  64*64
#define ftTRA  0
#define ftPAP  1
#define ftINK  2
#define ftTfnt struct ftTfnt_t 
struct ftTfnt_t
{ void *Hdev ;
  void *Hfnt ;
  void *Hold ;
  int Vhgt ;
  int Vasc ;
  int Vdes ;
  int Vwid ;
  char Anam [32];
  int Ldat ;
  char *Pdat ;
  char Agly [ftMAX/8];
  bmTbmp Ibmp ;
  char Abmp [ftMAX];
   };
ftTfnt *ft_alc ();
int ft_dlc (ftTfnt *);
int ft_map (ftTfnt *);
ft_rel (ftTfnt *);
int ft_gly (ftTfnt *,int );
#endif
