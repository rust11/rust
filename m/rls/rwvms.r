file	rwvms - raw file operations - vms
include rid:rider
include	rid:rwdef
include	rid:medef
include	rid:stdef
include	<devdef.h>
include	<rmsdef.h>

;	Raw read/write block-oriented file I/O
;
;	Most high-level language I/O systems massage the data before it is
;	passed to user buffers. It is often difficult to force such I/O
;	systems to perform simple block I/O. 
;
;	This raw I/O package handles that task. It is kept separate from
;	the regular I/O package - which simplifies both packages. Regular
;	I/O is best handled by the standard C library.
;
;	Raw I/O is mostly used for operations that ignore local file formats.
;	For example, dump, patch, binary compare, file conversion, exchanges
;
;	Raw bio		rwTfil	rw_rea	rw_put	rw_clo	Block I/O
;	    vms		fab/rab	$read	$write	$close
;	    rtx		channel	.readx	.writx	.close
;	    unx		fid	uread	uwrite	uclose
;	    dos		fid/bin	fread	fwrite	fclose
;
;	rw_ini ()			setup
;	rw_opn (fil)			open file
;	rw_cre (fil)			create file
;	rw_rea (fil, buf, cnt, blk)	read file
;	rw_wri (fil, buf, cnt, blk)	write file
;	rw_prg (fil)			purge file
;	rw_clo (fil)			close file

data	locals

	rwPxab : * rmTfhc own = <>	; common xab
	rwVini : int own = 2		; once-only flag
code	rw_ini - init read/write files

  func	rw_ini
	()  : int			; fine/fail
  is	fine if (rwVini >>= 1) eq	; once only flag
	rwPxab = rm_fhc ()		; make an fhc xab
	fine				;
  end

code	rw_alc - allocate rwTfil block

  func	rw_alc
	()  : * rwTfil			; file block or <>
  is	fil : * rwTfil			; the file block
	fil = me_acc (#rwTfil)		; allocate & clear
	fil->Pfab = rm_fab ()		; get a fab
	fil->Prab = rm_rab ()		; get a rab
	reply fil			;
  end

code	rw_dlc - deallocate file block

  proc	rw_dlc
	fil : * rwTfil
  is	exit if fil eq <>		; not setup
	me_dlc (fil->Pbuf)		; buffer, if any
	me_dlc (fil->Pfab)		; deallocate internals
	me_dlc (fil->Prab)		;
 	me_dlc (fil)			; deallocate file block
  end

code	rm_fab - make a fab

  func	rm_fab
	()  : * rmTfab
  is	fab : * rmTfab
	fab = me_alc (#rmTfab)
	me_mov (&cc$rms_fab, fab, #rmTfab)
	reply fab
  end

code	rm_rab - make a rab

  func	rm_rab
	()  : * rmTrab
  is	rab : * rmTrab
	rab = me_alc (#rmTrab)
	me_mov (&cc$rms_rab, rab, #rmTrab)
	reply rab
  end

code	rm_fhc - make a xabfhc

  func	rm_fhc
	()  : * rmTfhc
  is	xab : * rmTfhc
	xab = me_alc (#rmTfhc)
	me_mov (&cc$rms_xabfhc, xab, #rmTfhc)
	reply xab
  end
file	rw_opn - open file

  func	rw_opn
	spc : * char			; specification
	mod : int			; mode flags (fil->Vmod)
	()  : * rwTfil			; <> for errors
  is	fil : * rwTfil			; file block
	fab : * rmTfab			;
	rab : * rmTrab			;
	xab : * rmTfhc			;
	sta : int			; status
	len : long			;
					;
	rw_ini ()			; setup
	reply <> if fail		; crazy
	xab = rwPxab			; fhc xab (rw_ini allocates rwPxab)
	fil = rw_alc ()			; allocate a file block
	pass <>				; some error
     repeat				; fail block
	fil->Pspc = spc			; got a new spec
	fil->Vmod = mod			; setup the flags
	fil->Vctl = 0			;
	fab = fil->Pfab			; get a fab
	rab = fil->Prab			; get a rab
	fab->fab$l_xab = xab		; setup fhc xab
	fab->fab$w_ifi = 0		; clear ifi
					;
	fab->fab$l_fna = spc		; the filespec
	fab->fab$b_fns = st_len (spc)	;
					;
	 FAB$M_GET|FAB$M_BRO		; get block/record
	fab->fab$b_fac = that		; file access 
	if mod & rwUPD_			; want to update it
	.. fab->fab$b_fac |= FAB$M_PUT	; setup for that as well
	 FAB$M_PUT|FAB$M_GET|FAB$M_DEL	;
	 FAB$M_UPD|FAB$M_UPI|that	;
	fab->fab$b_shr = that		; sharing
					;
	sta = sys$open (fab)		; open the file
	quit if (sta & 1) eq		; failed
	fil->Vctl |= rwOPN_		; file is open
					;
	rw_chr (fil)			; get characteristics
	if fil->Vchr & rwDEV_		; device oriented open
	   fil->Vlen = 0		; no length
	else				;
	   (xab->xab$l_ebk-1) * 512	; bytes in logical blocks
	   xab->xab$w_ffb + that	; bytes in last block 
	   fil->Vlen = that		; thats the length of it
	.. fil->Vctl |= rwLEN_		; length is known
					;
	if (fab->fab$b_rat & FAB$M_CR) eq ; no carriage control
	.. fil->Vmod |= rwBIN_		; binary file
	reply fil if rw_con (fil)	; connect rab to fab
     never				;
	rw_dlc (fil)			; cleanup
	reply <>			;
  end
code	rw_cre - create file

;	ptr = rw_cre ("name", rwBIN_)

  func	rw_cre
	spc : * char
	mod : int
	()  : * rwTfil			; <> for errors
  is	fil : * rwTfil			; file block
	fab : * rmTfab			;
	rab : * rmTrab			;
	sta : int			;
					;
	rw_ini ()			; setup
	reply <> if fail		; crazy
	fil = rw_alc ()			; get one
	pass <>				; out of space
     repeat				;
	fil->Pspc = spc			; get the filespec
	fil->Vmod = mod			; setup the flags
	fil->Vctl = 0			;
	fab = fil->Pfab			; get a fab
	rab = fil->Prab			; get a rab
					;
	fab->fab$l_fna = spc		; the filespec
	fab->fab$b_fns = st_len (spc)	;
					;
	 FAB$M_PUT|FAB$M_BRO		;
	fab->fab$b_fac |= that		; file access
	fab->fab$l_fop = FAB$M_SUP	; supersede
	 FAB$M_PUT|FAB$M_GET|FAB$M_DEL	;
	 FAB$M_UPD|FAB$M_UPI|that	;
	fab->fab$b_shr = that		; sharing
	fab->fab$l_alq = 0		;
	fab->fab$l_xab = 0		; no xab
	fab->fab$w_ifi = 0		; zappata
					;
	if mod & rwBIN_			; binary file
	   fab->fab$b_rat = 0		; no rat
	   fab->fab$b_rfm = FAB$C_FIX	; fixed length records
	   fab->fab$w_mrs = 512		;
	else				; text file
	   fab->fab$b_rat = FAB$M_CR	; has carriage return control
	   fab->fab$b_rfm = FAB$C_STM	; stream text file
	.. fab->fab$w_mrs = 0		;
					;
	sta = sys$create (fab)		; create it
	quit if (sta & 1) eq		; some error
	fil->Vctl |= (rwOPN_|rwNEW_)	; open & new file
					;
	rw_chr (fil)			; setup characteristics
	reply fil if rw_con (fil)	; connect rab to fab
     never				;
	rw_dlc (fil)			; cleanup
	reply <>			;
  end
code	rw_chr - setup characteristics

  func	rw_chr
	fil : * rwTfil
  is	dev : long = fil->Pfab->fab$l_dev; get the flags
	chr : short = fil->Vchr		;
					;
	if (dev & DEV$M_FOD) eq		; not file oriented
	|| (dev & DEV$M_SPL) ne		; or is spooled
	.. chr |= rwDEV_		; device oriented open
	chr |= rwTER_ if dev & DEV$M_TRM; a terminal
	chr |= rwNET_ if dev & DEV$M_NET; network device
	chr |= rwMBX_ if dev & DEV$M_MBX; mailbox
	fil->Vchr = chr			; reset them
  end

code	rw_con - connect

  func	rw_con
	fil : * rwTfil
	()  : int			; fine/fail
  is	fab : * rmTfab = fil->Pfab
	rab : * rmTrab = fil->Prab

	rab->rab$l_fab = fab		; setup fab address
	rab->rab$l_rop = RAB$M_NLK	; don't lock records
	rab->rab$w_isi = 0		; zap rab
					;
	if fil->Vmod & rwUFO_		; want user open
	   fil->Vval = fab->fab$l_stv	; the channel number
	.. fine				; and don't connect it
					;
	sys$connect (rab)		; connect rab
	reply that & 1			; convert to TRUE/FALSE
  end

code	rw_bio - switch to block I/O

  func	rw_bio 
	fil : * rwTfil
	()  : int				; fine/fail
  is	rab : * rmTrab = fil->Prab		;
	fine if rab->rab$l_rop & RAB$M_BIO	; already setup
	sys$disconnect (rab)			; disconnect it
	fail if (that & 1) eq			; some error
	rab->rab$l_rop |= RAB$M_BIO		; setup BIO
	sys$connect (rab)			; connect rab
	reply that & 1				;
  end
code	rw_rea - read file

  func	rw_rea
	fil : * rwTfil			; file block
	buf : * char			; buffer address
	cnt : int			; byte count
	blk : long			; block number
	()  : int			; bytes transferred - 0 for eof/error
  is	fab : * rmTfab = fil->Pfab	;
	rab : * rmTrab = fil->Prab	;
	sta : int			;
	len : int			;
	fail if rw_bio (fil) eq		; force block I/O
					;
	rab->rab$l_ubf = buf		; buffer address
	fail if null			; is no buffer
	rab->rab$w_usz = (short) cnt	; setup the transfer count
	rab->rab$l_bkt = blk		; block number
	if (fil->Vchr & rwDEV_) eq	; not a device
	.. ++rab->rab$l_bkt		; virtual block number
					;
	fil->Vctl &= ~(rwEOF_|rwERR_)	; clear errors
	sta = sys$read (rab)		; read it
	len = rab->rab$w_rsz		; get transfer size
	reply len if sta & 1		; succeeded
					;
	if sta eq RMS$_EOF		; got eof
	   reply len if len ne		; got last partial
	   fil->Vctl |= rwEOF_		; eof
	.. fail				; nothing read
	fil->Vctl |= (rwEOF_|rwERR_)	; some error
	fail				;
  end
code	rw_wri - write

  func	rw_wri
	fil : * rwTfil
	buf : * char
	cnt : int
	blk : long
	()  : int			; bytes transferred
  is	fab : * rmTfab = fil->Pfab	;
	rab : * rmTrab = fil->Prab	;
	sta : int			;
	fail if rw_bio (fil) eq		; force block I/O
					;
	rab->rab$l_rbf = buf		; buffer address
	fail if null			;
	rab->rab$w_rsz = (short) cnt	; setup the transfer count
	rab->rab$l_bkt = blk		; block number
	if (fil->Vchr & rwDEV_) eq	; not a device
	.. ++rab->rab$l_bkt		; virtual block number
					;
	fil->Vctl &= ~(rwEOF_|rwERR_)	; clear errors
	fail if cnt eq			; null writes truncate files sometimes
	sta = sys$write (rab)		; write it
	reply cnt if sta & 1		; succeeded
					;
	fil->Vctl |= (rwEOF_|rwERR_)	; at least EOF
	fail				;
  end
code	rw_clo - close file

  func	rw_clo
	fil : * rwTfil
	()  : int
  is	fab : * rmTfab = fil->Pfab		; the fab
	rab : * rmTrab = fil->Prab		; the rab
	sta : int				;
 	fine if (fil->Vctl & rwOPN_) eq		; not open
	sys$disconnect (rab)			; disconnect it
	sta = sys$close (fab)			; close that
	fail if (sta & 1) eq			; failed
	rw_dlc (fil)				; deallocate it
	fine					;
  end

code	rw_prg - purge file

;	Purges file and ignores errors

  func	rw_prg
	fil : * rwTfil
	()  : int
  is	fab : * rmTfab = fil->Pfab		;
	rab : * rmTrab = fil->Prab		;
	sta : int				;
						;
	fine if fil eq <>			; not setup
	fine if (fil->Vctl & rwOPN_) eq		; not open
	sys$disconnect (rab)			; disconnect rab
						;
	if fil->Vctl & rwNEW_			; we were creating it
	&& (fil->Vchr & rwDEV_) eq		; and not a device
	.. fab->fab$l_fop |= FAB$M_DLT		; delete it
	sys$close (fab)				; purge it
						;
	rw_dlc (fil)				; deallocate it
	fine					;
  end
