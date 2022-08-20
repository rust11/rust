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
  /BEFORE=date
  /DATE=date
  /NEWFILES
  /SINCE=date
  /EXCLUDE=files
  /LOG
  /QUERY
  /NOQUERY


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

