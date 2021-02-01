header	rwdef - raw I/O definitions

	Vms  ?= &vms		; harden VMS existential

;If Vms
;header rmdefv
;	include <fab.h>
;	include <rab.h>
;	include <xab.h>
;
;	rmTfab	:= struct FAB
;	rmTrab	:= struct RAB
;	rmTfhc	:= struct XABFHC
;	rm_fab	: () * rmTfab extern
;	rm_rab	: () * rmTrab extern
;	rm_fhc	: () * rmTfhc extern
; end header
;End

data	rwTfil - file plex

  type	rwTfil
  is	Vmod : short		; mode/status flags
	Vchr : short		; characteristics
	Vctl : short		; control flags
	Vsta : int		; operation status code
	Vcod : int		; local operation status code
	Vval : int		; local operation status value
	Pspc : * char		; file specification (user only)
	Vlen : long		; file size in bytes
	Vpos : long		; current read/write position (dos/unix)
   If Vms			;
	Pfab : * rmTfab		; file access block
	Prab : * rmTrab		; record access block
   End				;
	Pbuf : * char		; transfer buffer
	Vadr : long		; current file address
  end

data	Vmod - open/create mode

	rwCRE_	:= BIT(0)	; write file		O_WRONLY
	rwUPD_	:= BIT(1)	; read/write file	O_RDWR
;	rwIMM_	:= BIT(2)	; immediate		O_NOWAIT
;	rwAPP_	:= BIT(3)	; append		O_APPEND
;	rwTRU_	:= BIT(4)	; truncate file		O_TRUNC
;	rwEXC_	:= BIT(5)	; exclusive access	O_EXCL
;	rwCIF_	:= BIT(6)	; create if file does not exist
	rwTMP_	:= BIT(7)	; temporary file - delete on close
;	rwTEN_	:= BIT(8)	; use tentative name, rename on close
;	rwFIT_	:= BIT(9)	; allocate final file size
	rwBIN_	:= BIT(10)	; binary file (no carriage control)
	rwUFO_	:= BIT(11)	; user file open
;	rwREP_	:= BIT(12)	; report messages to terminal

data	Vctl - contol flags

	rwOPN_	:= BIT(0)	; some file is open
	rwNEW_	:= BIT(1)	; a new file is open (create, cif)
	rwDYN_	:= BIT(2)	; deallocate file block on close/purge
	rwLEN_	:= BIT(3)	; Vlen valid (file length is known)
	rwPOS_	:= BIT(4)	; Vpos valid
	rwERR_	:= BIT(6)	; error seen
	rwEOF_	:= BIT(7)	; eof seen
	rwMOD_	:= BIT(8)	; buffer is modified

data	Vchr - characteristics

	rwDEV_	:= BIT(1)	; device or spooled
	rwDIR_	:= BIT(2)	; directory file
	rwTER_	:= BIT(3)	; terminal
	rwMBX_	:= BIT(4)	; mailbox like device
;	rwSIP_	:= BIT(4)	; standard input
;	rwSOP_	:= BIT(5)	; standard output
;	rwSER_	:= BIT(6)	; standard report
	rwNET_	:= BIT(7)	; network device/file

data	routines

	rw_alc	: () * rwTfil extern	; allocate file block
	rw_dlc	: () void		; deallocate file block
	rw_opn	: () * rwTfil extern	; open
	rw_cre	: () * rwTfil extern	; create
	rw_rea	: () int extern		; read
	rw_wri	: () int extern		; write
	rw_clo	: () int extern		; close
	rw_prg	: () int extern 	; purge
					; rwget.c

	rw_buf	: (*rwTfil)		; setup buffering
	rw_see	: (*rwTfil, long)	; seek
	rw_get	: (*rwTfil, *void, size) size; get
	rw_put	: (*rwTfil, *void, size) int ; put

end header
end file
file	file.h - (open) constants

;	Standard constants

	O_RDONLY := 00000
	O_WRONLY := 00001
	O_RDWR	 := 00002

;	BSD Unix 4.2

	O_NDELAY := 00004
	O_NOWAIT := 00004
	O_APPEND := 00010
	O_CREAT	 := 01000
	O_TRUNC	 := 02000
	O_EXCL	 := 04000
file	stat.h - stat/fstat Unix 

#ifndef __STAT
	__STAT := 1
  type	off_t : long unsigned
  type	ino_t : short unsigned
  type	dev_t : * char
  type	stat_t
	st_dev 	 : dev_t		; pointer to physical device name
	st_ino 	 : [3] ino_t		; 3-word i-number (fid)
	st_mode	 : short unsigned	; mode: protection, etc 
	st_nlink : int			; number of links - unix-only
	st_uid	 : int unsigned		; user Id
	st_gid	 : int unsigned		; group Id
	st_rdev	 : dev_t		; redirection device name?
	st_size	 : off_t		; file size in bytes
	st_atime : long unsigned	; last access time (same as last modification)
	st_mtime : long unsigned	; last modification time
	st_ctime : long unsigned	; file creation time
    #ifdef vms				;
	st_fab_rfm : char		; record format
	st_fab_rat : char		; record attributes
	st_fab_fsz : char		; fixed header size
	st_fab_rms : long unsigned	; record size
    #endif
  end

data	st_mode - file mode flags

	S_IFMT	 := 0170000	; type of file
	S_IMULT	 := 0010000	; multiplexed
	S_IFCHR	 := 0020000	; character special
	S_IFMPC	 := 0030000	; multiplexed character special
	S_IFDIR	 := 0040000	; directory
	S_IFBLK	 := 0060000	; block special
	S_IFMPB	 := 0070000	; multiplexed block special
	S_IFREG	 := 0100000	; regular
	S_ISUID	 := 0004000	; set user id on execution
	S_ISGID	 := 0002000	; set group id on execution
	S_ISVTX	 := 0001000	; save swapped text even after use
	S_IREAD	 := 0000400	; read permission, owner
	S_IWRITE := 0000200	; write permission owner
	S_IEXEC  := 0000100	; execute/search permission, owner
#endif
file	fidef.d - file definitions

;	BUF	Buffer I/O
;	LIN	Stream line
;	CHA	Stream character
;	RAW	Stream passall
;	UFO	User file open

#vms	include fabdef
#vms	include rabdef

  type	fiTblk
	fiLbfs	:= 512		; buffer size
#vms	fiLfns	:= 64		; filename size
#pdp	fiLfns	:= 16		; filename size
	fiLrcs	:= 134		; record size

  type	fiTplx
  is	Vflg : int 		; file flags
	Vcod : int		; error code
	Pbuf : * char		; buffer base address
	Vsiz : int		; buffer size
	Vblk : long		; block number
	Pnxt : * char		; next character
	Vcnt : int		; bytes in buffer
				;
	Pspc : * char		; filename
	Valc : long		; allocate size
	Vlen : long		; actual file length
	Vffb : short		; first free byte
	Vmod : short		; record format, access mode flags
	Vrsz : short		; record size (fixed)
	Vdev : short		; device flags
	Vf00 : int		;
	Vf01 : int
	Vf02 : int
	Vf03 : int
	Vchn : short		; channel number
#pdp	Vvar : char unsigned	; variable record state
#pdp	Vodd : char		; variable odd record size flag
#pdp	Vrbc : short		; variable record byte count
#vms	Pfab : fab$		; fab
#vms	Prab : rab$t		;
  end

  enum	fiTerr
  is	fiNOR			; normal - no error
	fiEOF			; end of file
	fiERR			; i/o error
	fiOVR			; record buffer overflow
	fiFNO			; no file open
	fiFIL			; missing file block
	fiBUF			; missing buffer
	fiFNF			; file not found
	fiFUL			; device full
	fiDEV			; invalid device
	fiBSY			; device is busy
	fiPRT			; file protection
	fiWEF			; write end of file
	fiFNM			; directory name
	fiOPN			; open file error
	fiCRE			; enter
	fiEXS			; file already exists
	fiLCK			; file is locked
	fiCON			; connect file error
	fiDIS			; disconnect file error
	fiREA			; read error
	fiWRI			; write error
	fiCLO			; close error
	fiCHN			; channel assignment error
	fiREN			; rename error
	fiDEL			; delete error
	fiIEC			; invalid error code
  end

  bits	fiTflg
  is	fiOPN_			; file is open
	fiDIS_			; this is the display
	fiCON_			; this is the console
	fiCRE_			; file was created - create-if
	fiIPT_			; input file
	fiOPT_			; output file
	fiEOF_			; first end of file
	fiERR_			; error seen
  end

;	fidel$		;delete on close
;	fipar$		;parse only
;	fiext$		;extended open
;
;	fiufo$		user-file open
;	fichn$		channel setup
;	fieva$		eva packet follows
;	fiper$		create with permanent name
;
;	fi.fnm		file name
;	fi.def		default name
;	fi.rsl		result name
;	fi.siz		output file size
;	fi.uic		file uic
;	fi.prt		file protection
;	fi.dat		file date
;	fi.tim		file time

  bits	fiTdev
  is	fiDEV_			;device, spooled, foreign
	fiCON_			;console - process terminal
	fiTER_			;terminal
	fiTAP_			;magtape
	fiREM_			;remote device
	fiMBX_			;mailbox
	fiDIR_			;has directory
	fiFOR_			;mounted foreign
  end

  bits	fiTmod			; high byte has flags
  is	[8]  fiBIN_		; binary file
	[14] fiREP_		; report errors	
	[15] fiEXT_		; extended file open (unused)
  end

  enum	fiTvar			; variable record control
  is	fiCNT			; count required
	fiDAT			; in data
	fiTER			; at terminator
  end
