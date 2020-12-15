F:\P\RTS\

RUST/SJ source directory
RUST/SJ provides an extended RT-11/SJ environment

RUST.SAV     RUST/SJ - the monitor boot and system bootable/executable
RTX.TSK      RUST/RTX - RUST virtualized under RSX-11M

The monitor is copied to the top of memory during boot
Usually this requires a lot of position independent coding
(read: a lot of position indepenent hacking)
RUST (and RTX) solve the problem by linking as relocatable images
the secondary bootstrap reads and applies the image relocation information
thus, for the most part, RUST need not worry about relocation


