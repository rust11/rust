/* header eddef - ed definitions */
#ifndef _RIDER_H_eddef
#define _RIDER_H_eddef 1
extern char *edPlin ;
extern char *edPbod ;
extern char *edPdot ;
int ed_ini (void );
void ed_set (char *,char *);
int ed_del (char *);
int ed_eli (char *);
int ed_chg (char *,char *);
int ed_skp (char *);
char *ed_scn (char *);
char *ed_sub (char *,char *,char *);
char *ed_rst (char *);
char *ed_rep (char *,char *);
char *ed_fnd (char *);
char *ed_exc (char *,char *,int );
void ed_tru (void );
char *ed_pre (char *);
char *ed_app (char *);
int ed_gap (char *,char *);
int ed_mor (void );
char *ed_lst (void );
char *ed_loc (char *,char *);
#endif
