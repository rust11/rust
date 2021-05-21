RT-11 MicroPowerPascal (MPP)

The distribution kit was recovered from five RX02's. I've transferred the
files to an RL02 disk image and to a directory (/FILES). 

I got the distribution from a customer back in the 1980s to help fix up some
bug. He also sent me a sixth disk with the debug materials. That sixth disk
had a copy of PASCAL.SAV, which was missing from the distribution kit. So, 
I've copied it to the kit and the disk.

I've included MPP documents that I found on the web back around 2012. They
include some RT-11 Software Reports with MPP entries.

I ran up PASCAL.SAV and PASDBG under my emulator and system. They failed with
a message telling me I had no clock. In fact, the programs tested for a
clock by counting ticks between I/O operations, and my emulator was too fast
for them. The problem does not seem to be present under SimH (which throttles
the clock), but if it does crop up let me know (because I found the patch
address).

The contents of this folder:

\FILES
README.TXT
MPPRL2.DSK
AA-M388A-TC_IntroToMicroPowerPascal_Jan82.pdf
micropower_pascal_mpprsxvms_messagesmanual_v15.pdf
micropower_pascal_runtime_service_manual_v15.pdf
micropower_pascal_system_users_guide_v15 (1).pdf
8208_AD-C740C-30_rtSwDisp.pdf
8209_AD-C740C-31_rtSwDisp.pdf
8211_AD-C740C-33_rtSwDisp.pdf

The /FILES subdirectory and MPPRL2.DSK contain the following:

ACPPFX.MAC   ADINC .PAS   ADPFX .MAC   ADSUB .PAS   ARBVFY.COM
ARBVFY.PAS   CARS2 .PAS   CARS3 .PAS   CFDCMR.MAC   CFDFAL.MAC
CFDFPL.MAC   CFDKJJ.MAC   CFDKJU.MAC   CFDKTC.MAC   CFDMAP.MAC
CFDUNM.MAC   CLKLIB.PAS   COMM  .SML   COMPLX.PAS   COMU  .SML
COPBOT.PAS   COPYB .SAV   CSPFX .MAC   DATTIM.PAS   DDBOTM.BOT
DDBOTU.BOT   DDPFX .MAC   DLBOTM.BOT   DLBOTU.BOT   DLPFX .MAC
DMA   .PAS   DRAM  .PAS   DRVM  .OBJ   DRVU  .OBJ   DUBOTM.BOT
DUBOTU.BOT   DUPFX .MAC   DYBOTM.BOT   DYBOTU.BOT   DYPFX .MAC
ESCODE.PAS   EXC   .PAS   FILSYS.OBJ   FSINCL.PAS   FSPAS .PAS
GETPUT.PAS   GETSET.PAS   GSINC .PAS   INSX  .COM   INTDIR.OBJ
INTDIR.PAS   IOPKTS.PAS   IOPVFY.COM   IOPVFY.PAS   KKINC .PAS
KKPFX .MAC   KKRWD .PAS   KRDCMR.COM   KRDFAL.COM   KRDFPL.COM
KRDKTC.COM   KRDUNM.COM   KWINC .PAS   KWPFX .MAC   KWSUB .PAS
KXINC .PAS   KXJSHR.PAS   KXPFX .MAC   KXRWD .PAS   KXTLO .PAS
LIBEIS.OBJ   LIBFIS.OBJ   LIBFPP.OBJ   LIBNHD.OBJ   LIBSUP.OBJ
LIBUSR.OBJ   LOGNAM.PAS   MERGE .SAV   MIB   .SAV   MISC  .PAS
MPBLD .COM   MPP   .SAV   MPVFY .COM   MUINC .PAS   MUPFX .MAC
MUSUB .PAS   MUTEX .PAS   NSPPFX.MAC   PASCAL.SAV   PASDBG.COM
PASDBG.HLP   PASDBG.MES   PASDBG.SAV   PAT50 .COM   PAXM  .OBJ
PAXU  .OBJ   PCBM  .PAS   PCBU  .PAS   PPVFY .COM   PREDFL.DOC
PREDFL.PAS   QDINC .PAS   QDPFX .MAC   QNPFX .MAC   RELOC .SAV
SQUEEZ.PAS   SUPEIS.OBJ   SUPFPP.OBJ   TD    .COM   TD    .MAC
TDBOTC.BOT   TDBOTM.BOT   TDBOTU.BOT   TDPRO .MAC   TDRT  .MAC
TDX   .PRO   TIMER .PAS   TTPFX .MAC   TTPFXC.MAC   TTPFXF.MAC
TTPFXK.MAC   UPDATE.TXT   USER  .TXT   VMPFX .MAC   VT100 .PAS
VT1INC.PAS   XADRV .MAC   XAPFX .MAC   XDDRV .PAS   XEINC .PAS
XEPFX .MAC   XESUB .PAS   XLDRVK.OBJ   XLDRVM.OBJ   XLDRVU.OBJ
XLPFX .MAC   XLPFXD.MAC   XLPFXF.MAC   XLPFXK.MAC   XPPFX .MAC
XSPFX .MAC   YADRV .PAS   YAPFX .PAS   YBPFX .MAC   YFDRVI.PAS
YFDRVP.PAS   YFPFX .MAC   YK    .PAS   YKINC .PAS   YKPFX .MAC
 150 Files, 4906 Blocks
