????????
file	rwdos - raw file operations - dos
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
;	The dos implementation must also handle direct device I/O. 
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

	rwVini : int own = 2		; once-only flag
code	rw_ini - init read/write files

  func	rw_ini
	()  : int			; fine/fail
  is	fine				; nought to do
  end

code	rw_alc - allocate rwTfil block

  func	rw_alc
	()  : * rwTfil			; file block or <>
  is	fil : * rwTfil			; the file block
	fil = me_acc (#rwTfil)		; allocate & clear
	reply fil			;
  end

code	rw_dlc - deallocate file block

  proc	rw_dlc
	fil : * rwTfil
  is	exit if fil eq <>		; not setup
	me_dlc (fil->Pbuf)		; buffer, if any
 	me_dlc (fil)			; deallocate file block
  end
file	rw_opn - open file

  func	rw_opn
	spc : * char			; specification
	mod : int			; mode flags (fil->Vmod)
	()  : * rwTfil			; <> for errors
  is	fil : * rwTfil			; file block
	sta : int			; status
	len : long			;
					;
	fil = rw_alc ()			; allocate a file block
	pass <>				; some error
     repeat				; fail block
	fil->Pspc = spc			; got a new spec
	fil->Vmod = mod			; setup the flags
	fil->Vctl = 0			;
					;
	rw_dev (fil)			; pickup device stuff
	reply fil if ne			; was a device open
	fil->Pfil = fi_acc (spc, "rb+") ; open binary file
	quit if <>			; failed miserably
	fil->Vctl |= rwOPN_		; file is open
					;
	rw_chr (fil)			; get characteristics
;	if fil->Vchr & rwDEV_		; device oriented open
;	   fil->Vlen = 0		; no length
;	else				;
;	   fil->Vlen = ????		; thats the length of it
;	.. fil->Vctl |= rwLEN_		; length is known
					;
;	if file->... & ...		;
;	.. fil->Vmod |= rwBIN_		; binary file
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
code	rw_spc - analyse file spec

;	""		invalid
;	"a:"		logical i/o

  func	rw_spc
	fil : * rwTfil
  is	spc : * char = fil->Pspc	; get the spec
	fail if *spc eq			; is no spec
	if ct_alp (*spc++)		; got an alpha
	&& *spc++ eq ':'		; and a colon
	   chr |= rwDRV_		; its a drive
	   if *spc eq			; just by itself?
	   .. ctl |= rwLIO_		; use logical I/O

	if spc[1] eq ':'		; assume a drive



code	rw_chr - setup characteristics

  func	rw_chr
	fil : * rwTfil
  is	dev : long = fil->fab->fab$l_dev; get the flags
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
code	rw_rea - read file

;	ds_ReaLog	Logical block device
;	dsReaPhy	Physical block device
;	fread ()	Ordinary files

  func	rw_rea
	fil : * rwTfil			; file block
	buf : * char			; buffer address
	cnt : int			; byte count
	blk : long			; block number
	()  : int			; bytes transferred - 0 for eof/error
  is	len : int			;
					;
	fil->Vctl &= ~(rwEOF_|rwERR_)	; clear errors
	fseek (fil->Pfil, blk*512, 0)	; setup the position
	fread (fil->Pfil, buf, cnt)	; read it
	if (len = that) eq		;
	   fil->Vctl |= rwEOF_		;
	   if ferror (fil->Pfil)	; check hardware errors
	.. .. fil->Vctl |= rwERR_	; got error
	reply len			;
  end
code	rw_wri - write

  func	rw_wri
	fil : * rwTfil			; file block
	buf : * char			; buffer address
	cnt : int			; byte count
	blk : long			; block number
	()  : int			; bytes transferred - 0 for eof/error
  is	len : int			;
					;
	fil->Vctl &= ~(rwEOF_|rwERR_)	; clear errors
	fseek (fil->Pfil, blk*512, 0)	; setup the position
	fwrite (fil->Pfil, buf, cnt)	; write it
	if (len = that) lt cnt		; wrote too few
	.. fil->Vctl |= rwEOF_|rwERR_	;
	reply len			;
  end
code	rw_clo - close file

  func	rw_clo
	fil : * rwTfil
	()  : int
  is	if fil->Vctl & (rwLIO_|rwPIO_) eq	; not logical/physical
	.. fclose (fil->Pfil)			; close it
	rw_dlc (fil)				; deallocate it
	fine					;
  end

code	rw_prg - purge file

;	Deletes new files

  func	rw_prg
	fil : * rwTfil
	()  : int
  is	sta : int				;
	if fil->Vctl & (rwLIO_|rwPIO_) eq	; not logical/physical I/O
	   fclose (fil->Pfil)			; close it
	   if fil->Vctl & rwNEW_		; we were creating it
	   && (fil->Vchr & rwDEV_) eq		; and not a device
	.. .. remove (fil->Pspc)		; delete it
	rw_dlc (fil)				; deallocate it
	fine					;
  end
