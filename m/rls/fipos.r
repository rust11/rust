file	fipos - file position
include rid:rider
include rid:fidef
include <stdio.h>

code	fi_see - seek

  func	fi_see
	fil : * FILE
	pos : long
	()  : int			; fine/fail
  is	fseek (fil, pos, SEEK_SET)	; seek
	reply not that			; invert result
  end

code	fi_pos - current file position

  func	fi_pos
	fil : * FILE
	()  : long
  is	reply ftell (fil)		; current position
  end

code	fi_siz - get file size - by name

  func	fi_siz
	spc : * char
	()  : long			; 0 also for no such file
  is	fil : * FILE			;
	siz : long			;
	fil = fi_opn (spc, "r", <>)	; open it
	reply 0 if null			; no such file
	siz = fi_len (fil)		; get the length
	fi_clo (fil, <>)		; close it
	reply siz			;
  end

code	fi_len - get file length - by handle

  func	fi_len
	fil : * FILE
	()  : long
  is	pos : long = fi_pos (fil)	; get current position
	len : long			;
	fseek (fil, 0, SEEK_END)	; seek to end of file
	len = fi_pos (fil)		; get actual length
	fi_see (fil, pos)		; reset position
	reply len			;
  end

code	fi_lim - set file limit

  func	fi_lim
	fil : * FILE
	pos : long
	()  : int			; fine/fail
  is	buf : [4] char
	fail if !fi_see (fil, pos)	; position
	reply fi_wri (fil, buf, 0)	; chop
  end
