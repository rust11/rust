cio$c := 0	; use C I/O
;???	sysgen compatibility
;???	driver present
;???	BOOT.SYS present
;???	SWAP.SYS present (and correct size)
file	vucop - copy boot to volume
include	rid:rider
include	rid:fidef
include	rid:imdef
include	rid:medef
include rid:rtboo
include rid:rtcst
include rid:rtdir
include rid:rtdrv
include rid:rtrea
include	vub:vumod

code	cm_cop - copy bootstrap to volume

;	COPY/BOOT[:dd] sys:system dev:
;
;	VUP dev:*=sys:system.*/U:drv[/L][/M]
;
;	DEV:	DUP defaults DEV: to the system device.
;		VUP issues a message "no output device specified".
;
;		RT-11 requires that DEV: be an RT11A volume.
;		So do we at present, but that might change.
;
;	SYS: 	RT-11 defaults to DK:
;		VUP forces DEV:
;
;		RT-11 requires that SYS: be an RT11A volume (because
;		it does the directory scan internally).
;		We use ordinary lookups and don't require RT11A.
;		VUP requires an explicit driver for non-RT11A volumes.
;
;	DD	Defaults to DEV:DD?.SYS, where "?" is the suffix.
;
;		RT-11 searchs SYSTEM.SYS for the suffix.
;		So do we, but we also accept an explicit suffix.
;
;		The driver must be present on the target device.
;
;		RT-11 uses an internal lookup. We don't.
;
;		RT-11 requires that DD?.SYS and SYSTEM.SYS have the
;		same SYSGEN options. We don't for BOOT.SYS.
;		(BOOT.SYS has no SYSGEN options).
;
;	/WAIT	RT-11 prompts for "Input device" only.
;
;	o  Copy the primary bootstrap
;	o  Copy the secondary bootstrap
; ???	o  Restore the original bootstrap if the secondary fails

code	cm_cop - copy bootstrap to device

	cst : rtTcst- = {0}		; channel status
	dri : drTinf- = {0}		; driver info
	suf : [4] char-			; suffix
	img : [4] word-			; image rad50
	hdr : * btThdr-			; monitor header

	dev := vuIdev
	boo := vuIboo
	roo := vuIroo
	mon := vuImon
	drv := vuIdrv
	bas := vuIbas
	ipt := cmAspc[3]
	opt := cmAspc[0]

  proc	cm_cop
  is
	if !(*ipt.Pnam && *opt.Pnam)		; check files specified
	.. exit vu_inv ()			; invalid command

;	Device (DL1:)

	exit if !vu_opn (&dev, opt.Pnam, "rbp+"); "DL1:"
	vu_cln (&dev, &boo)			; clone boot object
	vu_cln (&dev, &roo)			;

;	Monitor (DL1:RUST.SYS)

	exit if !vu_opn (&mon, ipt.Pnam, "rb")	; "DL1:RUSTSJ[.SYS]"
	vu_cln (&mon, &roo)			; clone control block
	exit if !vu_rea (&mon, 1, roo.Pbuf, 2048) ; read secondary boot
						;
	hdr = <*void>(roo.Pbuf+(btHDR/2))	; hdr -> boot header
	exit if !bt_chk (hdr, "")		; ensure bootable
	bt_suf (hdr, suf)			; get boot suffix

;	Driver (DL1:DL.SYS)

	rt_cst (dev.Pfil, &cst)			; get device channel status
	rx_unp (cst.Vdev, dev.Atmp)		; unpack device name
	st_cop (dev.Atmp, drv.Atmp)		; assume driver is the same
	drv.Atmp[2] = 0				; zap unit number

;	copy/boot=drv ...

	rx_unp (cmVdrv, drv.Atmp) if cmVdrv	; got explicit driver

;	Select and read the driver

	if !rt_drv (dev.Anam, drv.Atmp, suf[0], &dri)
	.. exit im_rep ("E-Driver not found [%s]", dri.Aspc)
						;
	drv.Pfil = dri.Pfil			; grab the file
	vu_alc (&drv)				; allocate control block
	vu_cln (&drv, &bas)			; clone it
	exit if !vu_get (&bas)			; read driver base

;	Read the driver bootstrap

	if !bt_drv (drv.Pfil, boo.Pbuf, &hdr->Vrea, "")
	.. exit im_rep ("E-Error reading driver boot [%s]", dri.Aspc)

;	Secondary boot header

	rx_pck (dri.Adrv, &hdr->Vdvn, 1)	; device name with suffix
	rx_scn (mon.Anam, img)			; convert monitor name
	hdr->Amon[0] = img[1]			; store it
	hdr->Amon[1] = img[2]			; (see above for hdr->Vrea)

;	SYSGEN compatibility

;	if *roo->Pbuf ne 0167			; not BOOT.SYS
;	   if hdr->Vsyg ne xxx->Vsyg
;	   if !fi_exs ("SWAP.SYS")

	if (cmVopt & cmLOG_) || (cmVopt & cmQUE_) ; /LOG
	   PUT("Monitor: %s, ", mon.Anam) 	; monitor
	   PUT("Boot driver: %s, " , dri.Aspc) 	; bootstrap driver
	   PUT("System driver: %s\n" , dri.Adrv); runtime driver with suffix
	end					;
						;
	if cmVopt & cmQUE_			; /QUERY
	   rt_qry("Copy/Boot ", mon.Anam, <>)	; are you sure?
	.. pass fail				;

;	Write boot block and secondary boot

If cio$c
	if !fi_see (dev.Pfil, 0L)
	|| !fi_wri (dev.Pfil, boo.Pbuf, 512)
	|| !fi_see (dev.Pfil, 1024L)
	|| !fi_wri (dev.Pfil, roo.Pbuf, 2048)
	.. exit im_rep ("E-Error writing bootstrap [%s]", dev.Anam)
Else
	if !rt_wri (dev.Pfil, 0, boo.Pbuf, 512/2, rtWAI)
	|| !rt_wri (dev.Pfil, 2, roo.Pbuf, 2048/2, rtWAI)
	.. exit im_rep ("E-Error writing bootstrap [%s]", dev.Anam)
End
	fi_clo (dev.Pfil, "")	
       ;fi_prg (dri.Pfil, "")	; channel was cloned
  end
