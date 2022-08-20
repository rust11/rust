file	EXPAT - expatriate file exchange program

;	---------------------------
;	EXPAT file exchange utility
;	---------------------------
;
;	EXPAT (from "expatriate") is a file housekeeping utility for PDP-11
;	file systems that runs under RT-11 compatible systems and Windows.
;	The current release is a preliminary minimal version designed to
;	import files from RT-11 and XXDP disk media.
;
;	Host	Input File Systems	Output
;	----	------------------	------
;	RT-11	RT-11 XXDP  		RT-11
;	RUST11	RT-11 XXDP  		RT-11
;	Windows RT-11 XXDP Windows 	Windows
;
;	Unlike most file exchange apps, EXPAT requires no special commands
;	to access non-native file structures. Instead, EXPAT detects file
;	system structures automatically. Assuming an XXDP volume is mounted
;	on DL1:, the command below will automatically detect the XXDP file
;	structure.
;
;	EXPAT> COPY DL1:HSAAGB.SYS SY:
;
;	Sub-directory notation is used to access RT-11 .DSK container files.
;	For example, the command below accesses the logical disk "XXDP23.DSK"
;	on the system disk and detects its XXDP volume structure.
;
;	EXPAT> DIR SY:\XXDP23\*.CCC	
;
;	Windows and RUST/SJ can combine their sub-directory notation with
;	EXPAT specifications. 
;
;	Features:
;	--------
;
;	o Runs under RT-11, RUST and Windows
;	o Runs under RSX using RUST/RTX
;	o Supports RT-11, RUST, XXDP
;	o Supports Windows directories when running under Windows
;	  or when using V11 to run RUST under Windows.
;
;	o Supports disk-like and container file volumes
;	o Automatically recognizes volume file structures
;	o Uses subdirectory notation to specify .DSK container files
;	o Supports 32-bit I/O and RT-11 disk partitions
;	  DECUS-C effectively limits block sizes to 2^21 blocks (2,097,152)
;	  RT-11 32-bit I/O is used where available (MSCP etc)
;	o Wildcard file, but not wildcard sub-directories
;	o Single input and output file specifications
;	o EXPAT on Windows has a line recall facility
;
;	Restrictions
;
;	o RT-11 EXPAT doesn't sort directories; Windows does 
;
;	General usage
;	-------------
;	EXPAT does away the MOUNT command that file exchange utilities
;	usually require to access a disk volume, with two features:
;	auto-detection and the use of sub-directory notation to access
;	container files.
;
;	EXPAT> dir rl1:*.*		! accesses the device "DL1:"
;	EXPAT> dir dl1:\mydisk\*.*	! accesses "DL1:MYDISK.DSK"
;
;	Under RUST, RUST-on-RSX and Windows, container files are 
;	specified as the last sub-directory:
;
;	EXPAT> dir \disks\xxdp\xxdl82\	! => "DK:\DISKS\XXDP\XXDL82.DSK"
;	EXPAT> dir [1,54]\xxdl82\	! => "[1,54]XXDL82.DSK"
data	EXPAT implementation

;	--------------------
;	EXPAT implementation
;	--------------------
;
;	EXPAT is developed simultaneously for the PDP-11 and Windows using
;	the C front-end language Rider/C and an extensive shared library.
;	The C compiler I use for the PDP-11 is DECUS-C, which lacks full
;	function prototypes and other features. Rider/C irons out these
;	differences.
;
;	EXPAT runs under any RT-11 or Windows system. It can also run under
;	RSX using RUST/RTX (an RT-11 environment that runs on RSX).
;
;	The sources for EXPAT itself are fairly short because most of the
;	functionality resides in libraries.
;
;	--------------
;	User Interface
;	--------------
;	The EXPAT user interface is driven by a DEC-style DCL interpreter.
;	The function below is all that is required to initiate the DCL 
;	interpreter.
;
;	  func	start
;	  is	dcl : * dcTdcl			; DCL control object
;		im_ini ("EXPAT")		; image init for messages
;		dcl = ctl.Pdcl = dc_alc ()	; allocate DCL object
;		dc_eng (dcl, cuAdcl, "EXPAT> ")	; pass control to DCL
;	  end
;
;	The equivalent C-code output by Rider/C follows. Note that <start()>
;	is called by a library <main ()> routine.
;
;	start()
;	{ dcTdcl *dcl;
;	  im_ini ("EXPAT");
;	  co_ctc (coENB);
;	  cu_ini ();
;	  dcl = ctl.Pdcl = dc_alc ();
;	  dcl->Venv |= dcCLI_|dcCLS_;
;	  dc_eng (dcl, cuAdcl, "EXPAT> ");
;	} 
;
;	The DCL interpreter is table-driven, as shown in this excerpt:
;
;	  init	cuAdcl : [] dcTitm
;	; level symbol		task	P1	  V1  	type|flags
;	  is
;	     1,	"EX*IT",	dc_exi, <>,	   0, 	dcEOL_
;	     1,	"HE*LP",	dc_hlp, cuAhlp,	   0, 	dcEOL_
;	  
;	     1,	"CO*PY",	dc_act, <>,	   0,	dcNST_
;	      2,  <>,		dc_fld, Isrc.Aspc, 32,	dcSPC
;	      2,  <>,		dc_fld, Idst.Aspc, 32,	dcSPC
;	      2,  <>,		cu_cop, <>, 	   0, 	dcEOL_
;
;	     1,	"DI*RECTORY",	dc_act, <>,	   0, 	dcNST_
;	      2,  <>,		dc_fld, Isrc.Aspc, 32,	dcSPC|dcOPT_
;	      2,  <>,		cu_dir, <>, 	   0, 	dcEOL_
;	      2,  "BR*IEF",	dc_set, &ctl.Qbrf, 1,	dcOPT_
;	     0,	 <>,		<>,	<>,	   0, 	0
;	  end
;
;	Container file notation
;	-----------------------
;	
;
;	Directory and file operations
;	-----------------------------
;	All directory and file operations are implemented by "VF", a 
;	long-planned Virtual File system that was finally implemented in
;	parallel with EXPAT.
;
;	VF handles the following tasks:
;
;	o Automated file system detection
;	o Scanning directories
;	o File open, close, read, write, rename, delete, etc.
;
;	VF currently handles XXDP, RT-11 and Windows file systems. DOS11,
;	RSX and (early) VMS are in preparation.
;
;	VF hides the specific details of each of the file systems.
;
;	o File specifications are ascii strings.
;	  (PDP-11 6.3 Rad50 specs are hidden)
;	o Device and file locations are long 32-bit byte values.
;	o Device and file lengths are long 32-bit byte values.
;	 (PDP-11 block numbers and 16-bit block number limits are hidden)
;	 (DECUS-C does not support unsigned longs, effectively limiting
;	  longs to a 31-bit range arithmetically. However, that still
;	  handles the largest disks available to PDP-11s).
;
;	Essentially, VF conforms to standard 32-bit C I/O practice.
;
;	------------
;	VF interface
;	------------
;	Using VF is also relatively simple. The Rider/C excerpt below 
;	implements a bare-bones directory function.
;
;	  func	cu_dir
;		dcl : * dcTdcl
;	  is	obj : * vfTobj = &Isrc		; VF object
;		ent : * vfTent			; VF directory entry
;		fine if !vf_acc (obj)		; access directory
;		fine if !vf_scn (obj)		; scan the directory
;		ent = &obj->Pscn->Ient		; entry
;	        while vf_nxt (obj) ne		; get next entry
;		   PUT("%s\n", ent->Anam)	; output file name
;	        end
;		fine
;	  end
;
;	The equivalent C code reads as:
;
;	cu_dir(dcl)
;	  dcTdcl *dcl;
;	{ vfTobj *obj;
;	  vfTent *ent;
;	  obj = &Isrc;
;	  vf_alc (obj);
;	  if (!vf_acc (obj)) return 1;
;	  if (!vf_scn (obj)) return 1;
;	  ent = &obj->Pscn->Ient;
;	  while (vf_nxt (obj) != 0) {
;	    printf("%s\n", ent->Anam);
;	  } 
;	  return 1;
;	} 
;
;	File export
;	-----------
;	File import is relatively easy. I have written file import software
;	for DOS11, XXDP, RT-11, RSX and VMS in the past.
;
;	File export can be more complex. 
;
;	RT-11:
;	I already have a Rider/C library that fully manages RT-11 disk
;	volumes.
;
;	DOS11/XXDP:
;	The XXDP file system is largely derived from the DOS11 file
;	system. The export functionality is relatively simple.
;
;	RSX/VMS:
;	VMS is largely an extension of the RSX file system. I've already
;	have a file import utility for RSX/VMS which will act as a 
;	template for VF import. Export will be more complex, particularly
;	since RSX/VMS use an ornate system of file record types.
;
;	Windows:
;	Windows support for EXPAT exists only when EXPORT runs under
;	Windows, where I can use native Windows system calls for all
;	functionality.
