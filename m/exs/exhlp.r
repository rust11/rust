file	exhlp - expat help command
include	rid:rider


  init	cuAhlp : [] * char
  is   "PDP-11 file exchange program EXPAT.SAV V1.0"
       " "
       "COPY path path	 Copy files    /ASCII/LOG/QUERY"
       "DIRECTORY path	 List files    /BRIEF/FULL/LIST/OUTPUT=path/PAUSE"
       "TYPE path	 Display files /LOG/PAUSE/QUERY"
       "Date options:   /BEFORE:date/DATE:d"

       "EXIT		 Exit EXPAT"
       "HELP		 Display this help"
	<>
  end
  func	cm_hlp
  is	dcl : * dcTdcl

  end

  func	hm_cop
  is	hu_dis (haAcop)
  end
      2,  "/BE*FORE",	dc_fld, &ctl.Abef, 32,	dcSPC|dcASS_
      2,  "/DA*TE",	dc_fld, &ctl.Adat, 32,	dcSPC|dcASS_
      2,  "/NE*WFILES",	dc_set, &ctl.Qnew, 1,	0
      2,  "/SI*NCE",	dc_fld, &ctl.Asin, 32,	dcSPC|dcASS_
;
      2,  "/EX*CLUDE",	dc_fld, &ctl.Aexc, 32,	dcSPC|dcASS_
      2,  "/LO*G",	dc_set, &ctl.Qlog, 1,	0
      2,  "/PA*GE",	dc_set, &ctl.Qpag, 1,	0
      2,  "/NOPA*GE",	dc_set, &ctl.Qnpg, 1,	0
      2,  "/QU*ERY",	dc_set, &ctl.Qque, 1,	0
      2,  "/NOQU*ERY",	dc_set, &ctl.Qnqu, 1,	0
      2,  <>,		<>, <>, 	   0,	dcRET_
  /BEFORE=date
  /DATE=date
  /NEWFILES
  /SINCE=date

  /EXCLUDE=files
  /LOG
  /[NO]PAGE
  /[NO]QUERY


     1,	"CO*PY",	dc_act, <>,	   0,	dcNST_
      2,  "/AS*CII",	dc_set, &ctl.Qasc, 1,	0
      2,  "/SE*TDATE",	dc_set, &ctl.Qdat, 1,	0
      2,  "/SE*VENBIT",	dc_set, &ctl.Q7bt, 1,	0

     1,	"DE*LETE",	dc_act, <>,	   0, 	dcNST_

     1,	"DI*RECTORY",	dc_act, <>,	   0, 	dcNST_
      2,  "/BR*IEF",	dc_set, &ctl.Qbrf, 1,	0
      2,  "/FU*LL",	dc_set, &ctl.Qful, 1,	0
      2,  "/LI*ST",	dc_set, &ctl.Qlst, 1,	0
      2,  "/OC*TAL",	dc_set, &ctl.Qoct, 1,	0
      2,  "/OU*TPUT",	dc_fld, Idst.Aspc, 32,	dcSPC|dcASS_
      2,  "/EX*ECUTE",	dc_fld, &ctl.Aexe, 64,	dcSPC|dcASS_
      2,  "/XX*DP",	dc_set, &ctl.Qxdp, 1,	0

     1,	"PR*INT",	dc_act, <>,	   0, 	dcNST_
      2,  "/SE*VENBIT",	dc_set, &ctl.Q7bt, 1,	0

;    1,	"RE*NAME",	dc_act, <>,	   0,	dcNST_

     1,	"TO*UCH",	dc_act, <>,	   0, 	dcNST_
     1,	"TY*PE",	dc_act, <>,	   0, 	dcNST_
      2,  "/SE*VENBIT",	dc_set, &ctl.Q7bt, 1,	0

EXIT
  Returns to the system.

HELP
  Displays this help information.

COPY in-files out-files

  Copies files.

  /ASCII
     Elides non-ascii 7-bit codes from the output.
  /NOREPLACE
     Does not replace existing files.
  /SETDATE[=date]
     Specifies the date for output files. The default is to use the
     input file date.
  /SEVENBIT
     Elides all non-seven


DELETE files
  Deletes files.

DIRECTORY [path]
  Lists files in a directory.

  o Lists files in the current directory by default.

  /BRIEF
    Lists only the names of files.
  /FULL
    Lists
  /LISTS
    Displays only file names, one per line.
  /OUTPUT=file
    Writes the directory listing to the specified file.
  /XXDP
    Displays information about XXDP files.

MOVE in-file out-file

RENAME old-name new-name
  Renames files.
TOUCH file
  Set the creation date of the specified file to the system date.
TYPE
  Displays the file at the terminal.

  /PAGE
    Pauses every 24 lines and waits for 

                                                                                                                                                                                                                                                                                                                                                                                                                                   