header	dsdef - dos definitions
include	<dos.h>				; psp for some
include	<stdlib.h>			; psp etc for some compilers

data	dos interface

	dsVpsp	:= _psp			; process psp
	dsVerr	:= _doserrno		; dos errors
	dsVmaj	:= _osmajor		; major dos version
	dsVmin	:= _osminor		; minor dos version

; type	LONG : long unsigned		; moved to rider.h
; type	WORD : unsigned
; type	BYTE : char unsigned
;	FAR(t,s,o) := (<*far t>((<LONG>(s)<<16)|<WORD>(o)))
;	SEG (a)	   := FP_SEG (a)	; segment part of far address
;	OFF (a)	   := FP_OFF (a)	; offset part of far address
;	FAR (t,s,o) := (<*far t>((<long unsigned>(s)<<16)|<unsigned>(o)))
;	SEG (a)	:= FP_SEG (a)		; segment part of far address
;	OFF (a)	:= FP_OFF (a)		; offset part of far address

	dsTreg	:= union REGS		; general registers (Msc misses x.flags)
	dsTseg	:= struct SREGS		; segment registers

	US := unsigned
	AL := reg.h.al
	AH := reg.h.ah
	BL := reg.h.bl
	BH := reg.h.bh
	CL := reg.h.cl
	CH := reg.h.ch
	DL := reg.h.dl
	DH := reg.h.dh
	AX := reg.x.ax
	BX := reg.x.bx
	CX := reg.x.cx
	DX := reg.x.dx
	SI := reg.x.si
	DI := reg.x.di
	FL := reg.x.flags
If Ztc
	ZF := (reg.x.flags & 64)
	CF := (reg.x.flags & 1)
Else
	ZF := (reg.x.cflag & 64)
	CF := (reg.x.cflag & 1)
End
	DS := seg.ds
	ES := seg.es
	SS := seg.ss
	CS := seg.cs
;	FS := (reserved)
;	GS := (reserved)

	ds_Int86r : (int, *far dsTreg) int
	ds_Int86s : (int, *far dsTreg, *far dsTseg) int
	ds_GetSeg : (*far dsTseg) void
	ds_Cal86r : (*far void, *far dsTreg) int
	ds_Cal86s : (*far void, *far dsTreg, *far dsTseg) int

	ds_21r (a,r)     := ((*r).x.ax = (a), ds_Int86r (0x21,r))
	ds_21s (a,r,s)   := ((*r).x.ax = (a), ds_Int86s (0x21,r,s))
	ds_2fr (a,r)	 := ((*r).x.ax = (a), ds_Int86r (0x2f,r))
	ds_2fs (a,r,s)	 := ((*r).x.ax = (a), ds_Int86s (0x2f,r,s))
	ds_86r (i,a,r)   := ((*r).x.ax = (a), ds_Int86r (i,r))
	ds_86s (i,a,r,s) := ((*r).x.ax = (a), ds_Int86s (i,r,s))
	ds_seg (s)       := ds_GetSeg (s)

;	ds_seg (s)       := segread (s)	; dos system call interfaces
;	ds_21r (a,r)     := ((*r).x.ax = (a), intdos  (r,r))
;	ds_21s (a,r,s)   := ((*r).x.ax = (a), intdosx (r,r,s))
;	ds_2fr (a,r)	 := ((*r).x.ax = (a), int86   (0x2f,r,r))
;	ds_2fs (a,r,s)	 := ((*r).x.ax = (a), int86x  (0x2f,r,r,s))
;	ds_86r (i,a,r)   := ((*r).x.ax = (a), int86   (i,r,r))
;	ds_86s (i,a,r,s) := ((*r).x.ax = (a), int86x  (i,r,r,s))

	ds_r21 (a)	 := ds_21r (a, &reg)
	ds_s21 (a)	 := ds_21s (a, &reg, &seg)
	ds_r2f (a)	 := ds_2fr (a, &reg)
	ds_s2f (a)	 := ds_2fs (a, &reg, &seg)
	ds_r86 (i,a)	 := ds_86r (i, a, &reg)
	ds_s86 (i,a)	 := ds_86s (i, a, &reg, &seg)

	ds_rou (a,v)	:= AX=v, ds_Cal86r (a, &reg)
	ds_sub (a,v)	:= AX=v, ds_Cal86s (a, &reg, &seg)

	ds_ipb (p)	:= inp (p)
	ds_opb (p,b)	:= outp (p,b)
If Tbc
	ds_ipw (p)	:= inport (p)
	ds_opw (p,w)	:= outport (p,w)
	ds_enb ()	:= enable ()
	ds_dsb ()	:= disable ()
	ds_int (i)	:= geninterrupt (i)
Elif Ztc
include <int.h>
	ds_ipw (p)	:= inpw (p)
	ds_opw (p,w)	:= outpw (p,w)
	ds_enb ()	:= int_on ()
	ds_dsb ()	:= int_off ()
	ds_int (i)	:= int_gen (i)
End
end header
end file
;	Simple dos calls

	ds_....v		=> void
	ds_....0		=> al eq 0 => success
	ds_....a		=> al
	ds_....r	(..,reg)=> reg

	d	dl
	dx	dx
	B	DS:BX
	D	DS:DX
	E	ES:BX

	ds_v___a	()	=> al & 255
	ds_d___a	(dl)	=> al & 255
	ds_dx__v	(dx)	=>
	ds_D___a	(DS:DX)	=> al & 255
	ds_v___r
	ds_d___r	(dl,reg)=> reg
	ds_v___E	()	=> ES:BX

	v	void
	0	al eq 0 => fine
	r	reg
	al...	
	DD	ds:dx
	DB	ds:dx
	EB	es:bx
	AX	cf eq 1 => AX = error code, else value

	dsChkKbd ()		:= ds_v__al (0x0b00)
	dsStDDrv (drv)		:= ds_dl_al (0x0e00, drv)
	dsGtDDrv (drv)		:= ds_v__al (0x1900)
	dsSetDta (adr)		:= ds_DD__v (0x1a00, adr)
?	dsGetDdt (drv,reg)	:= ds_dl__r (0x1c00, drv, reg)
	dsGtDDpb ()		:= ds_v__EB (0x1f00)
	dsSetVec (vec,adr)	:= ds_DD__v (0x2500|((vec)&255), adr)
	dsCrePsp (seg)		:= ds_dx__v (0x2600, seg)
	dsGetDat (reg)		:= ds_v___r (0x2a00)
	dsSetDat (reg)		:= ds_r___0 (0x2b00, reg)
	dsGetTim (reg)		:= ds_v___r (0x2c00)
	dsSetTim (reg)		:= ds_r___0 (0x2d00, reg)
	dsSetWck (val)		:= ds_v___v (0x2e00|((val)&255)))
	dsGetDta ()		:= ds_v__bx (0x2f00)
	dsGetOem (reg)		:= ds_v___r (0x3000, reg)
	dsGetVer (reg)		:= ds_v___r (0x3001, reg)
	dsExiTsr (cod,siz)	:= ds_dl__v (0x3100|((cod)&255), siz)
ds:bx	dsGetDpb (drv)		:= ds_dl_DB (0x3200, drv)
	dsGetCtc ()		:= ds_v__dl (0x3300)
	dsSetCtc (val)		:= ds_dl__v (0x3301, val)
d?	dsSwiCtc (val)		:= ds_dl_dl (0x3302, val)
	dsGetBoo ()		:= ds_v__dl (0x3305)
	dsGetRel (reg)		:= ds_v___r (0x3306, reg)
	dsGetInd ()		:= ds_v__EB (0x3400)
	dsGetVec (vec)		:= ds_v__EB (0x3500|((vec)&255))
	dsGetFre (drv,reg)	:= ds_d___r (0x3600, drv)	; ext	
???	dsGetCty (buf)		:= ds_DD
	dsMakDir (spc)		:= ds_DD_AX (0x3900, spc, 0, 0)
	dsRemDir (spc)		:= ds_DD_AX (0x3a00, spc)
	dsChgDir (spc)		:= ds_DD_AX (0x3b00, spc)
.	dsCreFil (spc,atr)	:= ds_DDcAX (0x3c00, spc, atr) 
.	dsOpnFil (spc,atr)	:= ds_DD_AX (0x3d00|((atr)&255)), spc)
.	dsCloFil (han)		:= ds_bx_AX (0x3e00, han)
.	dsReaHan (han,buf,cnt)	:= ds_trn_AX (0x3f00, buf, han, cnt)
.	dsWriHan (han,buf,cnt)	:= ds_trn_AX (0x4000, buf, han, cnt)
.	dsDelFil (spc)		:= ds_DD_AX (0x4100, spc)
.	dsSeeHan (han,pos,mod)	:= ds_see_AX (0x4200, han, pos, mod)

	dsGetPsp ()  		:= ds_n___i (0x5100)
	dsSetPsp (psp)		:= ds_B___v (0x5000, psp)
	dsExiPrg (sta)		:= ds_n___v (0x4c00|((sta)&255)
End

code	ds_n___i 

	ds_B___v	ES:BX -> far point

  func	ds_n____i
	cod : int		; ax and al
	dxv : int		; dx value
	()  : int		; ax result
  is	reg : dsTreg		; the registers
	reg.x.ax = cod		; setup the code
	reg.x.dx = dxv		; dx value
	ds_cal (reg, reg)	; do it
	reply reg.x.al		; reply to it
  end

	_ax(cod), _dx(mm), INT21, ptr=DS_DX, _cf ? _ax ? 0

  func	ds_i21
  is	reg : * dsTreg = &dsSreg 
	ds_int (dsSreg, dsSreg)
module	"dls:dsChkKbd.r"
include	"dlb:dsmod.h"

ds_ChkKbd:
	mov	ax,dsChkKbd
	int	21h
	and	ax,255
	RET


  func	ds_ChkKbd			; check keyboard
 	()  : int 			; fine => input ready
  is	reg : dsTreg			;
	reg.x.ax = dsChkKbd		; check keyboard hit
	ds_cal (reg, reg)		; do it
	reply reg.h.al & 255		; 1 => input ready
  end

module	"dls:dsStDDrv.r"
include	"dlb:dsmod.h"

  func	ds_StDDrv			; set default drive	
	drv : int			; drive number (0=A, ...)
 	()  : int 			; logical drive count
  is	reg : dsTreg			;
	reg.x.ax = dsStDDrv		; function
	reg.h.dl = drv			; drive
	ds_cal (reg, reg)		; do it
	reply reg.h.al & 255		; logical drive count
  end

module	"dls:dsGtDDrv.r"
include	"dlb:dsmod.h"

  func	ds_GtDDrv			; get default drive	
 	()  : int 			; default drive (0=A...)
  is	reg : dsTreg			;
	reg.x.ax = dsGtDDrv		; function
	ds_cal (reg, reg)		; do it
	reply reg.h.al & 255		; default drive
  end

module	"dls:dsSetDta.r"
include	"dlb:dsmod.h"

  proc	ds_SetDta			; set dta address	
	dta : * void far		; dta address
 	()  : int 			; default drive (0=A...)
  is	reg : dsTreg			;
	seg : dsTseg			; segment registers
	reg.x.ax = dsSetDta		; function
	ds_seg (seg)			; setup segment registers
	seg.ds = SEG(dta)		;
	reg.x.dx = OFF(dta)		;
	ds_ful (reg, reg, seg)		; do it
  end

module	"dls:dsGetDdt.r"
include	"dlb:dsmod.h"

;	al	spc	sectors per cluster
;	cx	bps	bytes per sector
;	dx	cls	clusters


  proc	ds_GetDdt			; get device data
	drv : * void far		; drive (0=def, 1=A)
	reg : * dsTreg			;
 	()  : int 			; fine/fail
  is	reg->x.ax = dsGetDdt		; function
	reg->h.dl = drv			; drive number
	ds_cal (reg, reg)		; do it
	reply reg.h.al ne 0xff		; 
  end

	dsGtDDpb ()		:= ds_v__EB (0x1f00)
	dsSetVec (vec,adr)	:= ds_DD__v (0x2500|((vec)&255), adr)
	dsCrePsp (seg)		:= ds_dx__v (0x2600, seg)
	dsGetDat (reg)		:= ds_v___r (0x2a00)
	dsSetDat (reg)		:= ds_r___0 (0x2b00, reg)
	dsGetTim (reg)		:= ds_v___r (0x2c00)
	dsSetTim (reg)		:= ds_r___0 (0x2d00, reg)
	dsSetWck (val)		:= ds_v___v (0x2e00|((val)&255)))
	dsGetDta ()		:= ds_v__bx (0x2f00)
	dsGetOem (reg)		:= ds_v___r (0x3000, reg)
	dsGetVer (reg)		:= ds_v___r (0x3001, reg)
	dsExiTsr (cod,siz)	:= ds_dl__v (0x3100|((cod)&255), siz)
ds:bx	dsGetDpb (drv)		:= ds_dl_DB (0x3200, drv)
	dsGetCtc ()		:= ds_v__dl (0x3300)
	dsSetCtc (val)		:= ds_dl__v (0x3301, val)
d?	dsSwiCtc (val)		:= ds_dl_dl (0x3302, val)
	dsGetBoo ()		:= ds_v__dl (0x3305)
	dsGetRel (reg)		:= ds_v___r (0x3306, reg)
	dsGetInd ()		:= ds_v__EB (0x3400)
	dsGetVec (vec)		:= ds_v__EB (0x3500|((vec)&255))
	dsGetFre (drv,reg)	:= ds_d___r (0x3600, drv)	; ext	
???	dsGetCty (buf)		:= ds_DD
	dsMakDir (spc)		:= ds_DD_AX (0x3900, spc, 0, 0)
	dsRemDir (spc)		:= ds_DD_AX (0x3a00, spc)
	dsChgDir (spc)		:= ds_DD_AX (0x3b00, spc)
.	dsCreFil (spc,atr)	:= ds_DDcAX (0x3c00, spc, atr) 
.	dsOpnFil (spc,atr)	:= ds_DD_AX (0x3d00|((atr)&255)), spc)
.	dsCloFil (han)		:= ds_bx_AX (0x3e00, han)
.	dsReaHan (han,buf,cnt)	:= ds_trn_AX (0x3f00, buf, han, cnt)
.	dsWriHan (han,buf,cnt)	:= ds_trn_AX (0x4000, buf, han, cnt)
.	dsDelFil (spc)		:= ds_DD_AX (0x4100, spc)
.	dsSeeHan (han,pos,mod)	:= ds_see_AX (0x4200, han, pos, mod)

	dsGetPsp ()  		:= ds_n___i (0x5100)
	dsSetPsp (psp)		:= ds_B___v (0x5000, psp)
	dsExiPrg (sta)		:= ds_n___v (0x4c00|((sta)&255)

