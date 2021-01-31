KPS: - RUST KEYPAD editor

KEYPAD.SAV is the default RUST text file editor

o Compatible subset of the RT-11 KED editor
o Supports RT-11 and RSX-11 text files
o Supports a very limited HTML mode

The current implementation will be too slow for large files
on systems with slow disks.

KEYPAD has been tested internally only. It must have bugs
for an experienced user (I'm a novice).


KEYPAD [out-file]=[in-file]

  The RUST editor.

  In-File
    Input file specification.
  Out-file
    Output file specification.
    Defaults to the in-file name unless /Create specified.

  DCL             CSI     Operation
  ---             ---     --------
  /ALLOCATE=n     /A:n    Reserves space for the output file.
  /INSPECT        /I      Does not open an output file.
  /CREATE         /C      Creates a new file.

  .r keypad
  *myfile.txtinformation use HELP DIFFER/BINARY.
  ...screen commands...
  *^C?

  o See the main HELP KEYPAD article for more information.

	

