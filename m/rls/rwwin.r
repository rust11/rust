file	rwvms - raw file operations - vms
include rid:rider
include	rid:rwdef
include	rid:medef
include	rid:stdef

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

	rwVini : int own = 2		; once-only flag
code	rw_ini - init read/write files

  func	rw_ini
	()  : int			; fine/fail
  is	fine if (rwVini >>= 1) eq	; once only flag
	fine				;
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
	rw_ini ()			; setup
	reply <> if fail		; crazy
	fil = rw_alc ()			; allocate a file block
	pass <>				; some error
     repeat				; fail block
	fil->Pspc = spc			; got a new spec
	fil->Vmod = mod			; setup the flags
	fil->Vctl = 0			;
					;
	sta = sys$open (fab)		; open the file
	quit if (sta & 1) eq		; failed
	fil->Vctl |= rwOPN_		; file is open
					;
	rw_chr (fil)			; get characteristics
	if fil->Vchr & rwDEV_		; device oriented open
	   fil->Vlen = 0		; no length
	else				;
	   fil->Vlen = that		; thats the length of it
	.. fil->Vctl |= rwLEN_		; length is known
					;
	fil->Vmod |= rwBIN_		; binary file
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
					;
	if mod & rwBIN_			; binary file
	else				; text file
	..
					;
	sta = sys$create (fab)		; create it
	quit if (sta & 1) eq		; some error
	fil->Vctl |= (rwOPN_|rwNEW_)	; open & new file
	reply fil			;
     never				;
	rw_dlc (fil)			; cleanup
	reply <>			;
  end
code	rw_rea - read file

  func	rw_rea
	fil : * rwTfil			; file block
	buf : * char			; buffer address
	cnt : int			; byte count
	blk : long			; block number
	()  : int			; bytes transferred - 0 for eof/error
  is	sta : int			;
	len : int			;
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
  is	sta : int			;
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
  is 	fine if (fil->Vctl & rwOPN_) eq		; not open
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
  is	sta : int				;
						;
	fine if fil eq <>			; not setup
	fine if (fil->Vctl & rwOPN_) eq		; not open
						;
	if fil->Vctl & rwNEW_			; we were creating it
	&& (fil->Vchr & rwDEV_) eq		; and not a device
	.. fab->fab$l_fop |= FAB$M_DLT		; delete it
	sys$close (fab)				; purge it
						;
	rw_dlc (fil)				; deallocate it
	fine					;
  end
