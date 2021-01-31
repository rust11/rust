IPS: - RUST file IMPORT utility for RSX and VMS disks

IMPORT was written rather quickly after our VAX/730 crashed,
because all our source files were located on VMS disks,
including the backups. 


IMPORT> help

Read files from RT-11, RSX and VMS disks

COPY files dev:          Copy files to device
DIRECTORY[/SIZE] [files] List directory
HELP                     List commands
MAKE log directory       Make Directory
MOUNT log directory      Mount Directory
SET item                 Set COPY control flags
 [NO]EXCLUDE             Do (not) exclude files with filetypes
 [NO]HEADER              Do (not) copy F11 file header
 [NO]LOG                 Do (not) log copy operations
 [NO]QUERY               Do (not) confirm copy operations
 [NO]MULTIVOLUME         Do (not) use multiple output volumes
 [NO]REPLACE             Do (not) replace existing files
SHOW                     Display volume and settings
TYPE files               Display files at terminal
USE dev:[dir]            Specify device and/or directory

Specify device and directory with the USE command.
Specify COPY options with the SET command.
Check COPY options with the SHOW command.

