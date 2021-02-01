file	bimod - variable size block I/O
include rid:rider
include rid:bidef
include rid:dbdef
include rid:medef
include <windows.h>

  func	bi_opn
	spc : * char
	len : size
	msg : * char
	()  : * biTfil
  is	fil : * biTfil
	len = 512 if !len
	fil = me_alc (#biTfil)
	fil->Phan = CreateFile (spc, GENERIC_READ,0,0,OPEN_EXISTING,0,0)
	reply fil if fil->Phan ne INVALID_HANDLE_VALUE
	fail
;	hst_msg (ctx, "File not found", spc)
	fail me_dlc (fil)
  end

  func	bi_rea
	fil : * biTfil
	buf : * void
	cnt : size
	blk : size
	don : * void
	()  : size
  is	trn : LONG
	pos : LARGE_INTEGER
	pos.QuadPart = blk * fil->Vlen
	SetFilePointer (fil->Phan, pos.LowPart, &pos.HighPart, FILE_BEGIN)
	ReadFile (fil->Phan, buf, cnt, &trn, 0)
;	fail db_lst ("Reading") if fail
	reply trn
  end

  func	bi_clo
	fil : *biTfil
  is	CloseHandle (fil->Phan)
	fine
  end
