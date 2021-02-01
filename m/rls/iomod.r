file	iomod - generic text I/O
include rid:rider
If !Pdp
include <stdio.h>	
End
include rid:iodef
include rid:imdef
include rid:chdef
include rid:medef
include rid:fidef
include rid:stdef
 
;	file	id
;		0	current input file
;		1	source file
;		2:9	include files
;	ioClst	10	last include file
;	ioCout	11	output file
;	ioClst  12	listing file
;	ioCtot  13

data	locals

  type	ioTfil				; file
  is	Pfil : * FILE			; file block
	Vlin : int			; line in file (first is '1')
	Aspc : [ioLspc] char		; file name
  end
	io_map : (int) *ioTfil		; map handle to FILE
	ioLfil := sizeof (ioTfil)	;
	ioAfil : [ioCtot] * ioTfil	; file block pointer array
	ioVsrc : int static = 0		; current source (0=>none)

code	io_ini - initialize file database

  func	io_ini
  is	ioVsrc = 0			; no input
	fine				; no problems
  end

code	io_map - map i/o file block

  func	io_map
	fid : int			; file id
	()  : * ioTfil			; file
  is	fil : * ioTfil			; file block
	fid = ioVsrc if !fid		; default to source
	fil = ioAfil[fid]		; get slot address
	if !fil				; not setup yet
	   fil = me_acc (ioLfil)	; get the space
	.. ioAfil[fid] = fil		; save it
	reply fil			; send it back
  end

code	io_spc	return file spec

  func	io_spc
	fid : int			; file id
	()  : * char			; file spec
  is	reply io_map (fid)->Aspc	; supply the file spec
  end

code	io_lin - return current line number

  func	io_lin
	fid : int
	()  : int			; line number
  is	reply io_map (fid)->Vlin	; supply line in file
  end
code	io_src - open source file

;	Open next source or include file

  func	io_src
	nam : * char			; file name
	def : * char			; default name
	()  : int			; fine/fail
  is	fid : int = ioVsrc + 1		; next file id
	if fid ge ioClst		; too many
	.. fail im_rep ("E-Too many Includes at [%s]", nam) 
	io_opn (fid, nam, def, "r")	; open the file
	pass fail			; no way
	ioVsrc = fid			; update current source
	fine				;
  end

code	io_opn - open file

  func	io_opn
	fid : int			; file id
	nam : * char			; file name
	def : * char			; default name
	mod : * Char			; open mode
	()  : int			; fine/fail
  is	fil : * ioTfil = io_map (fid)	; file block
	spc : * char = fil->Aspc	; result spec address
	if !fi_def (nam, def, spc)	; apply defaults
	.. fail im_rep ("E-Invalid file specification [%s]", nam)

	fil->Vlin = 0			; line 0
	fil->Pfil = fi_opn (spc, mod,""); open it
	fine if fil->Pfil		; open succeeded
	im_rep ("E-File not opened [%s]", spc) if *mod eq 'r'
	im_rep ("E-File not created [%s]", spc) otherwise
	fail
  end

code	io_clo - close file

  func	io_clo 
	fid : int			; file id
	()  : int			; fine/fail
  is	fil : * ioTfil = io_map (fid)	; get the file
	fine if !fil			; ignore unknown files
	fil->Vlin = 0			; mark file closed
	fine if !fil->Pfil		; no file block
	fi_clo (fil->Pfil, "")		; close the file
;	fil->Pfil = 0			;
	fine				;
  end
code	io_get - get next input record

;	Returns to previous file if necessary

  func	io_get
	buf : * char			; record buffer
	()  : int			; fine/fail
  is	fil : * ioTfil			; file block
	lst : * Char			; last char in line

      repeat				;
	fail if ioVsrc eq		; no source open
	fil = io_map (ioVsrc)		; map the file block
	fi_get (fil->Pfil, buf, ioLlin)	; read it
	quit if that ne EOF		; got a line
	io_clo (ioVsrc)			; close this file
	--ioVsrc			; previous source file
      forever				; try again

;	Replace line terminator with null

	if *buf ne			; got something on the line
	   lst = st_lst (buf)		; point at the last
	   if *--lst eq _cr		; got cr/lf terminator
	   || *++lst eq _nl		; got newline terminator
	.. .. *lst = 0			; remove it
					;
	++fil->Vlin			; next line number
	fine				;
  end

code	io_put - put next output record

;	Aborts if no output file open, or output error

  func	io_put
	buf : * char			; record to put
	()  : int			; fine/fail
  is	fil : * ioTfil = io_map (ioCout); map output file
	if !fil->Pfil			; is none
	.. fail im_rep ("E-No output file open", <>)
					;
	fi_wri (fil->Pfil, buf, ~(1))	; write it
	++fil->Vlin			; next line (???)
	fine				;
  end
