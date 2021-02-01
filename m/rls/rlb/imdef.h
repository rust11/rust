/* header imdef - image definitions */
#ifndef _RIDER_H_imdef
#define _RIDER_H_imdef 1
typedef void imTcbk (void );
extern imTcbk *imPwar ;
extern imTcbk *imPerr ;
extern imTcbk *imPfat ;
extern imTcbk *imPexi ;
extern int im_ini (char *);
extern int im_exi (void );
extern int im_war (void );
extern int im_err (void );
extern int im_fat (void );
typedef int imTrep (char *,char *);
imTrep im_rep ;
imTrep im_con ;
extern int im_sev (char *);
char *im_dec (int ,char *);
char *im_hex (int ,char *);
extern char *imPpre ;
extern char *imPfac ;
extern imTrep *imPrep ;
int im_arg (int ,char *,int ,int ,char **);
im_exe (char *,char *,int );
#endif
