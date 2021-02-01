/* header dsdef - dos definitions */
#ifndef _RIDER_H_dsdef
#define _RIDER_H_dsdef 1
#include <dos.h>
#include <stdlib.h>
/* code -  dos interface */
#define dsVpsp  _psp
#define dsVerr  _doserrno
#define dsVmaj  _osmajor
#define dsVmin  _osminor
#define dsTreg  union REGS
#define dsTseg  struct SREGS
#define US  unsigned
#define AL  reg.h.al
#define AH  reg.h.ah
#define BL  reg.h.bl
#define BH  reg.h.bh
#define CL  reg.h.cl
#define CH  reg.h.ch
#define DL  reg.h.dl
#define DH  reg.h.dh
#define AX  reg.x.ax
#define BX  reg.x.bx
#define CX  reg.x.cx
#define DX  reg.x.dx
#define SI  reg.x.si
#define DI  reg.x.di
#define FL  reg.x.flags
#if Ztc
#define ZF (reg.x.flags & 64)
#define CF (reg.x.flags & 1)
#else 
#define ZF (reg.x.cflag & 64)
#define CF (reg.x.cflag & 1)
#endif 
#define DS  seg.ds
#define ES  seg.es
#define SS  seg.ss
#define CS  seg.cs
int ds_Int86r (int ,dsTreg far *);
int ds_Int86s (int ,dsTreg far *,dsTseg far *);
void ds_GetSeg (dsTseg far *);
int ds_Cal86r (void far *,dsTreg far *);
int ds_Cal86s (void far *,dsTreg far *,dsTseg far *);
#define ds_21r(a,r)  ((*r).x.ax = (a), ds_Int86r (0x21,r))
#define ds_21s(a,r,s)  ((*r).x.ax = (a), ds_Int86s (0x21,r,s))
#define ds_2fr(a,r)  ((*r).x.ax = (a), ds_Int86r (0x2f,r))
#define ds_2fs(a,r,s)  ((*r).x.ax = (a), ds_Int86s (0x2f,r,s))
#define ds_86r(i,a,r)  ((*r).x.ax = (a), ds_Int86r (i,r))
#define ds_86s(i,a,r,s)  ((*r).x.ax = (a), ds_Int86s (i,r,s))
#define ds_seg(s)  ds_GetSeg (s)
#define ds_r21(a)  ds_21r (a, &reg)
#define ds_s21(a)  ds_21s (a, &reg, &seg)
#define ds_r2f(a)  ds_2fr (a, &reg)
#define ds_s2f(a)  ds_2fs (a, &reg, &seg)
#define ds_r86(i,a)  ds_86r (i, a, &reg)
#define ds_s86(i,a)  ds_86s (i, a, &reg, &seg)
#define ds_rou(a,v)  AX=v, ds_Cal86r (a, &reg)
#define ds_sub(a,v)  AX=v, ds_Cal86s (a, &reg, &seg)
#define ds_ipb(p)  inp (p)
#define ds_opb(p,b)  outp (p,b)
#if Tbc
#define ds_ipw(p)  inport (p)
#define ds_opw(p,w)  outport (p,w)
#define ds_enb()  enable ()
#define ds_dsb()  disable ()
#define ds_int(i)  geninterrupt (i)
#elif  Ztc
#include <int.h>
#define ds_ipw(p)  inpw (p)
#define ds_opw(p,w)  outpw (p,w)
#define ds_enb()  int_on ()
#define ds_dsb()  int_off ()
#define ds_int(i)  int_gen (i)
#endif 
#endif
