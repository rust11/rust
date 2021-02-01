file	wvmod - wave file operations
include	rid:rider
include	rid:imdef
include	rid:fidef
include	rid:medef
include	rid:stdef
include	rid:mxdef
include	<windows.h>
include <stdio.h>
WVDEF_LOCAL := 1
include	rid:wvdef
include	rid:wsdef

  type	wvTbuf
  is	Psuc : * wvTbuf
	Vflg : int			; flags
	Hout : HWAVEOUT			; output handle
	Hrec : HWAVEIN			; record handle
	Phdr : * WAVEHDR		; the header
	Pwav : * wvTwav			; the wave
  end

	wvIhdx : wvThdr = {0}
  init	wvItem : wvTwav			;
  is	<>, 0, 0, 1, 11025, 1		; default wave
  end

	wvSout	: wvTbuf = {0}		; output buffer
	wvSrec	: wvTbuf = {0}		; record buffer

	wvPout	: *wvTbuf = <>		; output queue
	wvPpnd	: *wvTbuf = <>		; pending output
	wvVout	: int = wvSTP		; output state
					;
	wvPrec	: *wvTbuf = <>		; input queue
	wvPwav  : *wvTwav = <>
	wvVrec	: int = wvSTP		; input state
	wvVrde	: int = 0		; record done event number
					;
	wvHDR	:= 44			; length of header

	wv11K	:= 11025	; 11.025 kHz
	wv22K	:= 22050	; 22.05 kHz
	wv44K	:= 44100	; 44.1 kHz

	wvINV	:= 0		; invalid format
	wv1MB	:= 1		; 11.025kHz, Mono, byte
	wv1SB	:= 2		; stereo
	wv1MW	:= 4		; mono word
	wv1SW	:= 8		; stereo
				;
	wv2MB	:= (1<<4)	; 22.05kHz, Mono, byte
	wv2SB	:= (2<<4)	; stereo
	wv2MW	:= (4<<4)	; mono word
	wv2SW	:= (8<<4)	; stereo
				;
	wv4MB	:= (1<<8)	; 44.1kHz, Mono, byte
	wv4SB	:= (2<<8)	; stereo
	wv4MW	:= (4<<8)	; mono word
	wv4SW	:= (8<<8)	; stereo

	wvPCM := 1		; wave format type

	wv_rec_clo : (*wvTbuf) int
	wv_pcm : (*wvTwav, *PCMWAVEFORMAT) int
	wv_deq : (void) int
	wv_evt : wsTast

code	wv_hoo - hook up to events

  func	wv_hoo
  is	fac : * wsTfac
	fac = ws_fac (<>, "wave")		; hook us in
	fac->Past = wv_evt			; our event
;	wsPwav = &wv_evt			; setup event handler
 	fine
  end
code	wv_ply - play a sound file

  func	wv_ply
	spc : * char
	mod : int
  is	reply PlaySound (spc, 0, 0)
  end

code	wv_fun - various things

  func	wv_fun
	wav : * wvTwav
	fun : int
  is	out : * wvTbuf = wvPout		;
	rec : * wvTbuf = wvPrec		;

	fail if !wav			; aint no wave
					;
	if wvVrec eq wvREC		; recording
	   wvVrec = wvSTP		; set it stopped
	   waveInReset (rec->Hrec)	; stop it
	   wv_rec_clo (rec)		;
	   fine if fun eq wvSTP		; can only stop recording
	end				;
					;
	fail if wvVout eq wvSTP		; nothing open
	fine if wvVout eq fun		; repeat is nop
	fail if !wvPout			; no output
					;
	case fun			;
	of wvSTP  waveOutReset (out->Hout) ; stop wave
		  wvVout = wvSTP	
	of wvPAU  waveOutPause (out->Hout) ; pause
		  wvVout = wvPAU	
	of wvCON  waveOutRestart (out->Hout) ; continue
		  wvVout = wvPLY	;
	end case
	fine
  end

code	wv_sta - get wave status

  func	wv_sta
	wav : * wvTwav
  is	reply wvVout if wav 
	reply wvREC if wvVrec eq wvREC
	reply wvSTP
  end

code	wv_pos - get wave position

;	returns Record position if recording
;	else returns output position

  func	wv_pos
	wav : * wvTwav
	()  : int
  is	buf : * wvTbuf = wvPout		; current output buffer
	han : HWAVEOUT			;
	tim : MMTIME			;
	typ : nat			;
	fail if !wav			; no wave
	fail if !buf			; no output wave
	tim.wType = TIME_SAMPLES	; set it up
	if wvVrec eq wvREC		; we are recording
	   waveInGetPosition (buf->Hout, &tim, #MMTIME)
	   pass fail			;
	else				;
	   fail if !buf			; nothing being output
	   waveOutGetPosition (buf->Hout, &tim, #MMTIME)
	.. pass fail			;
	wav->Vpos = tim.u.sample	;
	fine
  end

code	wv_ext - setup logical extent

  func	wv_ext
	wav : * wvTwav
	beg : size
	siz : size
  is	rem : size
	fail if !wav
	beg = wav->Vcnt if beg gt wav->Vcnt
	rem = wav->Vcnt - beg
	siz = rem if rem lt siz
	wav->Vbeg = beg
	wav->Vsiz = siz
  end
code	wv_out - output a wave

  func	wv_out
	wav : * wvTwav
	flg : int				; repeat etc
  is	buf : * wvTbuf = &wvSout		; output buffer
	wav->Vflg = flg				; set the flags
	buf->Pwav = wav				;
	wvPpnd = buf				; pending output
	wv_deq () if !wvPout			; dequeue it
	fine					;
  end

  proc	wv_out_rep
	res : int
  is	buf : [256] char
	exit if res eq
	waveOutGetErrorText (res, buf, 256)
	im_rep ("I-%s", buf)
  end

  func	wv_out_clo
	buf : * wvTbuf
  is	han : HWAVEOUT = buf->Hout
	hdr : * WAVEHDR = buf->Phdr
	res : int
	wvPout = <>				; no output (benign errors)
	if buf->Phdr
	   res = waveOutUnprepareHeader (han, hdr, #WAVEHDR)
	.. wv_out_rep (res)
	if han
	   res = waveOutClose (han)		; close it
	.. wv_out_rep (res)
	mg_dlc (buf->Phdr)
	buf->Hout = 0
	buf->Phdr = <>
  end

  func	wv_out_err
	buf : * wvTbuf
	res : int
  is	wv_out_rep (res)			; report error
	wv_out_clo (buf)			; close down
  end

  func	wv_deq
	()  : int
  is	dat : * char
	len : size
	svr : * wsTctx = ws_ctx ()		;
	han : HWAVEOUT = 0			;
	pcm : PCMWAVEFORMAT			;
	hdr : * WAVEHDR = <>			;
	win : LONG = <LONG>svr->Hwnd		; server window
	mod : LONG = CALLBACK_WINDOW		; 
	buf : * wvTbuf
	wav : * wvTwav				;
	res : int				;

	buf = wvPpnd				; switch buffers
	fail if !buf				; no buffer
	wvPout = buf
	wvPpnd = <>

	wav = buf->Pwav				;
	fine if !wav				;
	fail if buf->Hout			; already open

	wv_hoo ()				; hook events
						;
	dat = wav->Pdat + (wav->Vbeg * wav->Vpnt) ; start of data
	len = wav->Vsiz * wav->Vpnt		; data count
						;
	wv_pcm (wav, &pcm)			; fill in pcm
	res = waveOutOpen (&han, WAVE_MAPPER, &<WAVEFORMAT>pcm, win, 0, mod)
	fail wv_out_err (buf, res) if res	; report error
	buf->Hout = han				; save the handle
						;
	buf->Phdr = hdr = mg_acc (#WAVEHDR)	; make global header
						;
	hdr->lpData = <*BYTE>dat		; point at the data
	hdr->dwBufferLength = len		; length
	 WHDR_BEGINLOOP|WHDR_ENDLOOP		;
	hdr->dwFlags = that if wav->Vflg & wvLOO_ ; set looping
	hdr->dwLoops = ~(0)			; loop forever if looping
	hdr->dwUser = <DWORD>buf		;
	res = waveOutPrepareHeader (han, hdr, #WAVEHDR)
	fail wv_out_err (buf, res) if res ne	; prepare header failed
	res = waveOutWrite (han, hdr, #WAVEHDR)	; send it out
	fail wv_out_err (buf, res) if res	; write failed
	wvVout = wvPLY
	fine
  end
code	wv_evt - wave event handler

;	close wave handle when sound is done
;???	no prototype

  func	wv_evt
	evt : * wsTevt
	fac : * wsTfac
  is	hdr : * WAVEHDR	= <*WAVEHDR>evt->Vlng
	buf : * wvTbuf

	case evt->Vmsg
	of MM_WOM_DONE			; wave out done
	   buf = <*wvTbuf>hdr->dwUser	; get the header
	   wv_out_clo (buf)		; close it
	   wvVout = wvSTP		; all over now
	   wv_deq ()			; dequeue anything waiting

	of MM_WIM_DATA			; wave in data
	   fine if !wvPrec		; not recording
	   if wvVrec eq wvREC		; not already stopped
	      wvVrec = wvSTP		; do it now
	      buf = <*wvTbuf>hdr->dwUser; get the header
	   .. wv_rec_clo (buf)		;
;	   evt->Vwrd = wvVrec		; tell user process
;	   wc_cmd (evt)			;
;	   wv_deq ()			; dequeue anything waiting
	of other			;
	   fail				; not a wave signal
	end case			;
	fine
  end
code	wv_rec - record

code	wv_rec_rep - report

  proc	wv_rec_rep
	res : int
  is	buf : [256] char
	exit if res eq
	waveInGetErrorText  (res, buf, 256)
	im_rep ("I-%s", buf)
  end

code	wv_rec_clo - close

  func	wv_rec_clo
	buf : * wvTbuf
  is	han : HWAVEIN = buf->Hrec
	hdr : * WAVEHDR = buf->Phdr
	res : int
	wav : * wvTwav = wvPwav			;
	wvPrec = <>				; signal closed
	if han

	   res = waveInStop (han)
	.. wv_rec_rep (res)

	if buf->Phdr				;
a
	   res = waveInUnprepareHeader (han, hdr, #WAVEHDR)
	.. wv_rec_rep (res)
	if 0;han
b
	   res = waveInClose (han) if han	; close it
	.. wv_rec_rep (res)			;
	buf->Hrec = 0				;
	buf->Phdr = <>				;

	wav->Vcnt = hdr->dwBytesRecorded / wav->Vpnt
PUT("rec=%d ", hdr->dwBytesRecorded)
PUT("cnt=%d ", wav->Vcnt)


;	wav->Vflg |= wvTRU_			; truncate pending
;V4	mg_dlc (buf->Phdr)			;
;;;	wv_nor (wav)				; reset things
  end

code	wv_rec_err - errors

  func	wv_rec_err
	buf : * wvTbuf
	res : int
  is	wv_rec_rep (res)		; must be first to get message
	wv_rec_clo (buf)		; close down
  end

code	wv_rec - record

	alt : WAVEHDR = {0}

  func	wv_rec
	tem : * wvTwav			; recording template
	don : int			; record done event code
	()  : * wvTwav
  is	svr : * wsTctx = ws_ctx ()	;
	buf : * wvTbuf			;
	han : HWAVEIN = 0		;
	pcm : PCMWAVEFORMAT		;
	fmt : WAVEFORMAT		;
	hdr : * WAVEHDR			;
	win : LONG = <LONG>svr->Hwnd	; server window
	mod : LONG = CALLBACK_WINDOW	; 
	wav : * wvTwav = wvPwav		;
	dat : * char			;
	len : size			;
	res : int			;
m
	fail if wvPrec			; already recording
	wv_hoo ()			; hook events
;	wsPwav = &wv_evt		; setup event handler
	buf = wvPrec = &wvSrec		; get it
	buf->Hrec = 0			;
	buf->Phdr = <>			;
					;
n
	if !wav
	   wav = wv_alc (tem, 500000)	; allocate a wave buffer
	   wvPwav = that
	.. pass fail			; oops
o
	dat = wav->Pdat			;
	len = wav->Vcnt			;
	me_clr (dat, len * wav->Vpnt)	;
	wv_pcm (wav, &pcm)		;

a
	res = waveInOpen (&han, WAVE_MAPPER, &<WAVEFORMAT>pcm, win, 0, mod)
	fail wv_rec_err (buf, res) if res	; report error
	buf->Hrec = han				; save the handle

	buf->Phdr = hdr = mg_acc (#WAVEHDR)	; make global header
	hdr->lpData = <*BYTE>dat
	hdr->dwBufferLength = len
	hdr->dwBytesRecorded = 0
	hdr->dwUser = <DWORD>buf

	alt.lpData = <*BYTE>dat
	alt.dwBufferLength = len
	alt.dwBytesRecorded = 0
	alt.dwUser = <DWORD>buf
b
	res = waveInPrepareHeader (han, hdr, #WAVEHDR)
	fail wv_rec_err (buf, res) if res	; report error
	res = waveInPrepareHeader (han, &alt, #WAVEHDR)
	fail wv_rec_err (buf, res) if res	; report error
c
	res = waveInAddBuffer (han, hdr, #WAVEHDR) if !res
	fail wv_rec_err (buf, res) if res	; report error
	res = waveInAddBuffer (han, &alt, #WAVEHDR) if !res
	fail wv_rec_err (buf, res) if res	; report error

	wvVrec = wvREC
d
	res = waveInStart (han)
	fail wv_rec_err (buf, res) if res	; report error
e
PUT("wav=%x ", wav)
	reply wav
  end
code	wv_pcm - fill in pcm descriptor

  func	wv_pcm
	wav : * wvTwav
	pcm : * PCMWAVEFORMAT
  is
	pcm->wf.wFormatTag = WAVE_FORMAT_PCM	;
	pcm->wf.nChannels = wav->Vchn		;1
	pcm->wf.nSamplesPerSec = wav->Vrat	;11025
	pcm->wf.nAvgBytesPerSec = wav->Vavg	;
	pcm->wf.nBlockAlign = wav->Vchn * wav->Vwid
	pcm->wBitsPerSample = wav->Vwid * 8	;8

;	pcm.wf.wFormatTag = WAVE_FORMAT_PCM
;	pcm.wf.nChannels = 1
;	pcm.wf.nSamplesPerSec = 11025
;	pcm.wf.nAvgBytesPerSec = 11025
;	pcm.wf.nBlockAlign = wav->Vchn * wav->Vwid
;	pcm.wf.nBlockAlign = 1
;	pcm.wBitsPerSample = 8
  end
code	wv_clr - clear a wave

  proc	wv_clr
	wav : * wvTwav
  is	wv_nor (wav)			; crashs if caller forgets
	me_set (wav->Pdat, wav->Vtot, 128) if wav->Vwid eq 1
	me_clr (wav->Pdat, wav->Vtot)	otherwise
  end

code	wv_dup - duplicate a wave buffer

  func	wv_dup
	old : * wvTwav
	()  : * wvTwav
  is	new : * wvTwav
	wv_nor (old)			; crashs if caller forgets
	new = wv_alc (old, old->Vcnt)	; make the wave
	pass fail			; oops
	me_cop (old->Pdat, new->Pdat, old->Vtot) ; fill it in
	reply new
  end

code	wv_cat -- catenate upto 3 segments

;	Assembles up to three pieces into a new wave
;
;	Used to perform convert, cut, paste, delete, insert etc.
;	Can be extended to handle disparate wave types (stereo/mono etc).

  	wv_trn : (*wvTwav, *wvTseg, *char, int) *char; translate and copy
	wv_est : (*wvTwav, *wvTseg) size

  func	wv_cat
	tem : * wvTwav				; template wave
	s1  : * wvTseg
	s2  : * wvTseg
	s3  : * wvTseg
	mod : int				; unused
	()  : * wvTwav
  is	alc : size
	new : * wvTwav
	ptr : * char
	cnt : size
	alc =  wv_est (tem, s1)			; estimate size
	alc += wv_est (tem, s2)			;  including expansion
	alc += wv_est (tem, s3)			;  or contraction
	new = wv_alc (tem, alc)			; allocate target space
	pass fail				; no space
	ptr = new->Pdat				;

	if mod & (wvLCO_|wvRCO_)		; single channel out
	&& tem->Vchn eq 2			; and is stereo
	   cnt = tem->Vcnt			; estimate size
	   cnt = alc if alc lt cnt		;
	   me_cop (tem->Pdat,ptr,cnt*tem->Vpnt) ; copy it 
	   ptr = wv_trn (tem, s1, ptr, mod)	; translate and copy
	   ptr = wv_trn (tem, s2, ptr, mod) 	;
	   reply new	
	end

	ptr = wv_trn (tem, s1, ptr, mod)	; translate and copy
	ptr = wv_trn (tem, s2, ptr, mod) 	;
	ptr = wv_trn (tem, s3, ptr, mod) 	;
	reply new	
  end

code	wv_trn - translate and copy a wave segment

;	Handles disparate wave types
;	Can handle individual operations on left or right channels
;	Cannot overflow

	wvBMK	:= 0xff				; byte mask
	wvBOF	:= 128				; byte offset
	wvMbgt (p) := ((((p) & wvBMK)-wvBOF)<<8); byte get
	wvMwgt (p) := (p)			; word get
	wvMbpt (v) := (((v)>>8) + wvBOF)	; byte put
	wvMwpt (v) := (v)			; word put

  func	wv_trn
	tem : * wvTwav				; target template
	seg : * wvTseg				; source segment
	dst : * char				; destination stream
	mod : int				; mode -- unused 
	()  : * char				;
  is	wav : * wvTwav = seg->Pwav		;
	src : * char = wav->Pdat + (seg->Vbeg * wav->Vpnt)
	siz : size = seg->Vsiz			;
	lft : int				;
	rgt : int = 0				; default stereo value
	swd : * WORD = <*WORD>src		; word source
	dwd : * WORD = <*WORD>dst		; destination word
	fil : int = 1				; fill count
	skp : int = 0				; skip count
	cnt : int				;
	byt : int = (wav->Vwid eq 1)		; is byte source data
	dbt : int = (tem->Vwid eq 1)		; is destination byte data
						;
	if tem->Vchn eq wav->Vchn		; same channel count
	&& tem->Vwid eq wav->Vwid		; same width
	&& tem->Vrat eq wav->Vrat		; same rate
	&& !mod					; and nothing special
	.. reply me_cop (src, dst,siz*wav->Vpnt); fast copy
						;
;	2/1=2 4/1=4 4/2=2
	if tem->Vrat gt wav->Vrat		; adjust for rate
	   fil = tem->Vrat / wav->Vrat		; fill this many times
;	1/2=2 1/4=4 2/4=2
	elif wav->Vrat gt tem->Vrat		;
	   skp = (wav->Vrat/tem->Vrat)		; skip this points
	   siz /= skp				; adjust loop size
	   skp -= 1				; remainder after one point
	   skp *= wav->Vpnt if byt		; adjust for point size
	.. skp *= wav->Vpnt / 2 otherwise	;
						;
	while siz--				; get mono/stereo byte/word
	   lft = wvMbgt(*src++) if byt		; left channel
	   lft = wvMwgt(*swd++) otherwise 	;
	   if wav->Vchn eq 2			; right channel
	      rgt = wvMbgt(*src++) if byt	;
	      rgt = wvMwgt(*swd++) otherwise	;
	   else					;
	   .. rgt = lft				; assume mono to stereo
						;
	   if wav->Vchn gt tem->Vchn		; stereo to mono
	   .. lft = ((lft + rgt) / 2) 		; mix them
						;
	   cnt = fil				; expand from 11k to 22k etc

	   if tem->Vchn eq 1			; mono copy
	     while cnt--			; 
	      *dst++ = wvMbpt(lft) if dbt	; store left
	      *dwd++ = wvMwpt(lft) otherwise	;
	     end
	   elif mod & wvLCO_			; left channel out
	     while cnt--			; 
	      *dst++ = wvMbpt(lft) if dbt	; store left
	      *dwd++ = wvMwpt(lft) otherwise	;
	      ++dst if dbt			; skip right
	      ++dwd otherwise			;
	     end				;
	   elif mod & wvRCO_			; right channel out
	     while cnt--			; 
	      ++dst if dbt			; skip left
	      ++dwd otherwise			;
	      *dst++ = wvMbpt(lft) if dbt	; store right
	      *dwd++ = wvMwpt(lft) otherwise	;
	     end				;
	   else					; stereo copy
	     while cnt--			; put mono/stereo byte/word
	      *dst++ = wvMbpt(lft) if dbt	; store left
	      *dwd++ = wvMwpt(lft) otherwise	;
	      next if tem->Vchn eq 1		; mono
	      *dst++ = wvMbpt(rgt) if dbt	; store right
	      *dwd++ = wvMwpt(rgt) otherwise	;
	     end				;
	   end

	   next if !skp				;
	   src += skp if byt			; reduce from 22k to 11k etc
	   swd += skp otherwise			;
	end					;
	reply (dbt) ? dst ?? <*char>dwd		; past the segment
  end

code	wv_est - estimate size of a segment

  func	wv_est
	tem : * wvTwav
	seg : * wvTseg
	()  : size
  is	wav : * wvTwav = seg->Pwav
	siz : size = seg->Vsiz
	if tem->Vrat gt wav->Vrat		;
	   siz *= tem->Vrat / wav->Vrat		; will need more points
	elif wav->Vrat gt tem->Vrat		;
	.. siz /= wav->Vrat / tem->Vrat		; will need more points
	reply siz
  end
code	wv_alc - allocate a wave buffer

  func	wv_alc 
	tem : * wvTwav			; template
	cnt : size			; #points if len ne, else #databytes
	()  : * wvTwav			; result wave
  is	buf : * char			;
	wav : * wvTwav			;
	hdr : * wvThdr			;
	dat : * char			;
	tot : size = cnt		; basic length
	if !tem				; no template
	   tem = &wvItem		; use our template
	.. tem->Phdr = &wvIhdx		; make a header
	wv_nor (tem)			; normalise all headers
					;
	tot *= tem->Vpnt		; template point size
	tot += #wvTwav + #wvThdr + 128	; overhead and idiot/rounding space
	buf = mv_alc (tot)		; get the wave -- do not clear
	if !buf				; we got none
	   im_rep ("I-Insufficient memory for wave file", <>)
	.. fail				;
					;
	wav = <*wvTwav>buf		; the wave
	hdr = <*wvThdr>(buf+#wvTwav)	; the header
	dat = buf + #wvTwav + #wvThdr	; the data
					;
	me_cop (tem, wav,#wvTwav)	; copy the template
	wav->Pdat = dat			;
	wav->Vtot = tot			;
	wav->Vcnt = cnt			;
	wav->Vsiz = cnt			;
	wav->Phdr = hdr			;
	wv_nor (wav) 			; update derived things
	reply wav			;
  end

code	wv_dlc - deallocate wave

  func	wv_dlc
	wav : * wvTwav
  is	suc : * wvTatr
	atr : * wvTatr
	fine if !wav			; nothing to delete
	suc = wav->Patr			; get next attribute
	while (atr = suc) ne		;
	   suc = atr->Psuc		;
	   if atr->Vflg & wvTXT_	; got an object
	   .. me_dlc (atr->Pdat)	; deallocate it
	   me_dlc (atr)			;
	end				;
;	mg_dlc (wav)			; deallocate it
	mv_dlc (wav)			; deallocate it
	fine
  end
code	wv_nor - normalize header

;	Compute point size, average and total

  func	wv_nor
	wav : * wvTwav
  is	wav->Vpnt = wav->Vchn * wav->Vwid	; point size in bytes
	wav->Vavg = wav->Vrat * wav->Vpnt	; average bytes second
	wav->Vtot = wav->Vcnt * wav->Vpnt	; total data bytes
	wv_hdr (wav)				; now update the header
	fine
  end

code	wv_hdr - wave to header

  init	wvIhdr : wvThdr
  is	"RIFF"		;
	0		; filesize
	"WAVEfmt "	;
	16		; fmt chunk size
	wvPCM		; PCM format 
	1		; 1 channel
	wv22K		; sampling rate
	wv22K		; bytes per second
	1		; byte alignment
	8		; 8-bit data
	"data"		;
	0		; data size
  end

  func	wv_hdr
	wav : * wvTwav
	()  : int
  is	hdr : * wvThdr = wav->Phdr
	fine if !hdr			; has no header
	me_mov (&wvIhdr, hdr, #wvThdr)	; copy in the prototype
	hdr->Vfsz = wav->Vtot + #wvThdr	;
	hdr->Vdsz = wav->Vtot		;
	hdr->Vchn = wav->Vchn		;
	hdr->Vwid = wav->Vwid * 8	;
	hdr->Vrat = wav->Vrat		; rate
	hdr->Vavg = wav->Vavg		;
	fine
  end
code	wv_sho - display wave internals

  proc	wv_sho
	wav : * wvTwav
  is	txt : [512] char
	if !wav
	   FMT (txt, "No wave")
	else
	   FMT (txt,
	      "spec=%s\ntot=%d\ncnt=%d\nchn=%d\nwid=%d\n",
	       wav->Pspc,
	       wav->Vtot, wav->Vcnt,
	       wav->Vchn, wav->Vwid)
	   FMT (st_end (txt),
	      "rat=%d\navg=%d\npnt=%d\n",
	       wav->Vrat, wav->Vavg,
	       wav->Vpnt)
	   FMT (st_end (txt),
	      "beg=%d\nsiz=%d\ndat=%x",
	       wav->Vbeg, wav->Vsiz,
	       wav->Pdat)
	end
	im_rep ("I-%s", txt)
  end

end file
	   while cnt--				; put mono/stereo byte/word
	      *dst++ = wvMbpt(lft) if dbt	; store left
	      *dwd++ = wvMwpt(lft) otherwise	;
	      next if tem->Vchn eq 1		; mono
	      *dst++ = wvMbpt(rgt) if dbt	; store right
	      *dwd++ = wvMwpt(rgt) otherwise	;
	   end					;


	cap : WAVEOUTCAPS
	cnt : nat
	idx : nat = 0
	cnt = waveOutGetNumDevs ()
	FMT(obj, "%d", cnt)
	im_rep ("I-Devices = %s", obj)
	while idx lt cnt
	   res = waveOutGetDevCaps (idx, &cap, #WAVEOUTCAPS)
	   if ne
	      FMT(obj, "%d", res)
	   .. quit im_rep ("waveOutGetDevCaps failed (%s)", obj)
	   im_rep ("I-Device = (%s)", cap.szPname)
	   ++idx
	end
code	fl_drd - direct read file

  func	fl_drd
	fil : * FILE
	buf : * voidL
	cnt : long
	()  : int 			; fine/fail
  is
If Msc
	_read (fileno (fil), buf, cnt)	;
	reply <size>that eq cnt		; -1 or wrong count
Else
	reg : dsTreg
	seg : dsTseg
	DS=SEG(buf), DX=OFF(buf)	;
	BX = fileno (fil), CX=cnt	;
	ds_s21 (0x3f00)			;
	reply !CF && AX eq cnt		;
End
  end

code	fl_dwr - direct write file

  func	fl_dwr
	fil : * FILE
	buf : * voidL
	cnt : long
	()  : int 			; fine/fail
  is
If Msc
	fine if cnt eq			; do not truncate file
	_write (fileno (fil), buf, cnt)	;
	reply <size>that eq cnt		; -1 or wrong count
Else
	reg : dsTreg
	seg : dsTseg
	fine if cnt eq			; do not truncate file
	DS=SEG(buf), DX=OFF(buf)	;
	BX = fileno (fil), CX=cnt	;
	ds_s21 (0x4000)			;
	reply !CF && AX eq cnt		;
End
  end
end file
 	case err
#define MMSYSERR_NOERROR      0                    // no error
#define MMSYSERR_ERROR        (MMSYSERR_BASE + 1)  // unspecified error
#define MMSYSERR_BADDEVICEID  (MMSYSERR_BASE + 2)  // device ID out of range
#define MMSYSERR_NOTENABLED   (MMSYSERR_BASE + 3)  // driver failed enable
#define MMSYSERR_ALLOCATED    (MMSYSERR_BASE + 4)  // device already allocated
#define MMSYSERR_INVALHANDLE  (MMSYSERR_BASE + 5)  // device handle is invalid
#define MMSYSERR_NODRIVER     (MMSYSERR_BASE + 6)  // no device driver present
#define MMSYSERR_NOMEM        (MMSYSERR_BASE + 7)  // memory allocation error
#define MMSYSERR_NOTSUPPORTED (MMSYSERR_BASE + 8)  // function isn't supported
#define MMSYSERR_BADERRNUM    (MMSYSERR_BASE + 9)  // error value out of range
#define MMSYSERR_INVALFLAG    (MMSYSERR_BASE + 10) // invalid flag passed
#define MMSYSERR_INVALPARAM   (MMSYSERR_BASE + 11) // invalid parameter passed
#define MMSYSERR_HANDLEBUSY   (MMSYSERR_BASE + 12) // handle being used
                                                   // simultaneously on another
                                                   // thread (eg callback)
#define MMSYSERR_INVALIDALIAS (MMSYSERR_BASE + 13) // "Specified alias not found in WIN.INI
#define MMSYSERR_LASTERROR    (MMSYSERR_BASE + 13) // last error in range



	han : HMMIO
	inf->fccIOproc = FOURCC_MEM
	inf->pIOproc
	inf->wErrorRet
	inf->hTask
	inf->cchBuffer = doc->Vlen
	inf->pchBuffer = doc->Pdat
	inf->pchNext = doc->Pdat
	inf->pchEndRead
	inf->pchEndWrite
	inf->lBufOffset
	inf->lDiskOffset = 0
	inf->adwInfo[0] = 0
	inf->hmmio

	han = mmioOpen (<>, <>, MMIO_READ|MMIO_COMPAT) 
	fail im_rep ("I-Open failed", <>) if fail
	mmioWrite (han, 


/****************************************************************************
*   Structures for the lpdwParams (dwParam2) of mciSendCommand for those
*   command messages that may be parsed in string form.
*****************************************************************************/



#define MCI_ALL_DEVICE_ID               ((MCIDEVICEID)-1)    // Matches all MCI devices

// constants for predefined MCI device types
//#define MCI_DEVTYPE_VCR                 (MCI_STRING_OFFSET + 1)
//#define MCI_DEVTYPE_VIDEODISC           (MCI_STRING_OFFSET + 2)
//#define MCI_DEVTYPE_OVERLAY             (MCI_STRING_OFFSET + 3)
//#define MCI_DEVTYPE_CD_AUDIO            (MCI_STRING_OFFSET + 4)
//#define MCI_DEVTYPE_DAT                 (MCI_STRING_OFFSET + 5)
//#define MCI_DEVTYPE_SCANNER             (MCI_STRING_OFFSET + 6)
//#define MCI_DEVTYPE_ANIMATION           (MCI_STRING_OFFSET + 7)
//#define MCI_DEVTYPE_DIGITAL_VIDEO       (MCI_STRING_OFFSET + 8)
//#define MCI_DEVTYPE_OTHER               (MCI_STRING_OFFSET + 9)
//#define MCI_DEVTYPE_WAVEFORM_AUDIO      (MCI_STRING_OFFSET + 10)
//#define MCI_DEVTYPE_SEQUENCER           (MCI_STRING_OFFSET + 11)

// Constant values are used because RC does not like the parentheses
#define MCI_DEVTYPE_VCR                 513
#define MCI_DEVTYPE_VIDEODISC           514
#define MCI_DEVTYPE_OVERLAY             515
#define MCI_DEVTYPE_CD_AUDIO            516
#define MCI_DEVTYPE_DAT                 517
#define MCI_DEVTYPE_SCANNER             518
#define MCI_DEVTYPE_ANIMATION           519
#define MCI_DEVTYPE_DIGITAL_VIDEO       520
#define MCI_DEVTYPE_OTHER               521
#define MCI_DEVTYPE_WAVEFORM_AUDIO      522
#define MCI_DEVTYPE_SEQUENCER           523

