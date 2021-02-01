/* header lndef - logical names */
#ifndef _RIDER_H_lndef
#define _RIDER_H_lndef 1
#define _lnFIL  "@ini@:roll.def"
#define _lnLOG  "@ini@"
#define _lnENV  "INI"
#define _lnDEF  "c:\\ini\\"
#define lnLIM  30
int ln_ini (void );
void ln_exi (void );
int ln_upd (void );
int ln_def (char *,char *,int );
int ln_und (char *,int );
int ln_trn (char *,char *,int );
int ln_rev (char *,char *,int );
char *ln_loo (char *);
int ln_nth (int ,char **,char **);
extern int lnVchg ;
extern int lnVerr ;
#endif
