DFS: - SRCDIF/BINDIF file differences utilities

SRCDIF compares text files with merged/changebar/parallel output
BINDIF list binary differences between files
SRCDIF and BINDIF are replacements for RT-11 SRCCOM and BINCOM

SRCDIF [out-file=]file1,file2

  Compares files. Replaces SRCCOM. See HELP DIFFERENCES.

  File1,File2
    Old and new files to compare
  Out-file
    Output file or device. Default is terminal.

  CSI     DCL                     CSI     DCL
  ---     ---                     ---     ---
  /A      /AUDIT                  /B      /BLANKLINES
  /C[:c]  /[NO]COMMENTS[=c]       /D      /CHANGEBAR
  /E      /EIGHTBIT               /F      /FORMFEEDS
  /G      /NOLOG                  /H[:v]  /VERIFY[=v]
  /I[:v]  /CASE[=EXA|GEN]         /K[:n]  /WINDOW[=n]
  /L[:n]  /MATCH[=n]              /M[:n]  /MERGED[=n]
  /N      /NONUMBERS              /O      /NOOUTPUT
  /P[:n]  /PARALLEL[=n]           /R      /EDITED
  /S      /NOSPACES               /T      /NOTRIM
  /V[:v]  /CHANGEBAR              /W[:n]  /WIDTH[=n]
  /X[:n]  /MAXIMUM                /Z      /SPACES/DEVICE, INIT & SQUEEZE.



BINDIF [out-file=]file1,file2

  Implements the DCL DIFFER/BINARY command. Replaces BINCOM.

  File1,File2
    Old and new files to compare
  Out-file
    Output file or device. Default is terminal.

  Switch          Operation
  ------          --------
  /B              Compares bytes. The default is words.
  /D              Compare devices.
  /E:n            Specifies the last block.
  /Q              Quiet
  /S:n            Specifies the first block.

  o For more information use HELP DIFFER/BINARY.