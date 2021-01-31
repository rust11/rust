VUS: - RUST VUP.SAV replacement for RT-11 DUP.SAV

VUP

  Performs device operations. Replaces DUP.

  CSI       DCL                   CSI       DCL
  ---       ---                   ---       ---
  /B[:ret]  /BADBLOCKS            /C[:k]    CREATE
  /D        /RESTORE              /E:n      /END/TRUNCATION
  /F        /FILES                /G        /IGNORE
  /G:n      /START                /H        /VERIFY
  /I        COPY/DEVICE           /K        DIR/BAD
  /L        /LOG                  /N:n      /SEGMENTS/SIZE
  /O        BOOT                  /Q        /FOREIGN
  /R[:ret]  /REPLACE              /S        SQUEEZE
  /T:n      /END/EXTENSION        /U        COPY/BOOT
  /V[:onl]  /VOLUMEID             /W        /WAIT
  /X        /NOBOOT               /Y        /NOQUERY
  /Z        INITIALIZE            /Z:n      /EXTRA
  /Z:3      /RT11X

  o /B and /S not implemented.
  o For more information use HELP BOOT, COPY/BOOT/DEVICE, INIT & SQUEEZE.

