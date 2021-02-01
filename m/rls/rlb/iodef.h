/* header iodef - source/listing i/o */
#ifndef _RIDER_H_iodef
#define _RIDER_H_iodef 1
int io_ini (void );
char *io_spc (int );
int io_lin (int );
int io_src (char *,char *);
int io_opn (int ,char *,char *,char *);
int io_clo (int );
int io_get (char *);
int io_put (char *);
#define ioClst  10
#define ioCout  10
#define ioCtot  13
#define ioLspc  32
#define ioLlin  134
#endif
