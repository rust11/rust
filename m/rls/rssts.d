header	rssts - RSX status codes

;  type	rsTsts
;  is
;
;	RSX I/O status & error codes
;
;	is.%%%	status
;	IS%%%.	success
;	IE%%%.	error
;
; i/o status area
;
;	is.cod	byte,0		; i/o status code
;	is.qua	byte		; i/o status qualifier
;	is.val			; i/o status related value
;	is.bbs			; 
;
; IOSB - success codes
;
	ispnd := 0		; pending
	issuc := 1		; success
	isrdd := 2		; dy - read deleted datamark
	istmo := 2		; tt - request timed out
;
	isCRN := 06401		; tt - cr terminator
	isESC := 015401		; tt - escape terminator
	isCC. := 01401		; tt - ctlr/c terminator
	isESQ := 0115401	; tt - escape sequence terminator
	isPES := 0100001	; tt - partial escape sequence terminator
	isEOT := 02001		; tt - eot terminator - block mode
	isTAB := 04401		; tt - tab terminator - block mode
;
; IOSB - I/O error codes	
;				;  system standard codes
	ieBAD := -1		; bad parameter
	ieIFC := -2		; invalid function code
	ieDNR := -3		; device not ready
	ieVER := -4		; unrecoverable error
	ieONP := -5		; invalid subfunction
	ieSPC := -6		; invalid address space
	ieDNA := -7		; device not attached
	ieDAA := -8		; device already attached
	ieDUN := -9		; device not attachable
	ieEOF := -10		; eof detected
	ieEOV := -11		; eov detected
	ieWLK := -12		; write-locked device
	ieDAO := -13		; data overrun
	ieSRE := -14		; send/receive error
	ieABO := -15		; operation aborted
	iePRI := -16		; privilege violation
	ieRSU := -17		; noshare resource in use
	ieOVR := -18		; invalid read overlay request
	ieBYT := -19		; odd-byte buffer address
	ieBLK := -20		; invalid block number
	ieMOD := -21		; invalid udc/ics/icr module
	ieCON := -22		; UDC connect error
;				;  file primitive codes
	ieNOD := -23		; no dynamic pool space
	ieDFU := -24		; device full
	ieIFU := -25		; index device full
	ieNSF := -26		; no such file
	ieLCK := -27		; locked from read/write access
	ieHFU := -28		; file header full
	ieWAC := -29		; accessed for write
	ieCKS := -30		; file header checksum failure
	ieWAT := -31		; attribute control list format error
	ieRER := -32		; file processor device read error
	ieWER := -33		; file processor device write error
	ieALN := -34		; file already processed on lun
	ieSNC := -35		; file id, file number check
	ieSQC := -36		; file id, file sequence check
	ieNLN := -37		; no file accessed on lun
	ieCLO := -38		; file not properly closed
;				;  file control services codes
	ieNBF := -39		; open - no buffer space for file
	ieRBG := -40		; invalid record size
	ieNBK := -41		; file exceeds space allocated - no blocks
	ieILL := -42		; invalid operation on fdb
	ieBTP := -43		; bad record type
	ieRAC := -44		; invalid record access bits set
	ieRAT := -45		; invalid record attributes bits set
	ieRCN := -46		; invalid record number - too large
;				;  unused
	ieC47 := -47		; error 47
;				;  file control services codes
	ie2DV := -48		; rename - 2 different devices
	ieFEX := -49		; rename - new file name already exists
	ieBDR := -50		; bad directory file
	ieRNM := -51		; can't rename old file system
	ieBDI := -52		; bad directory syntax
	ieFOP := -53		; file already open
	ieBNM := -54		; bad file name
	ieBDV := -55		; bad device name
;				;  system standard codes
	ieBBE := -56		; bad block error
;				;  file primitive codes
	ieDUP := -57		; enter - duplicate entry in directory
;				;  system standard codes
	ieSTK := -58		; not enough stack space (fcs/fcp)
	ieFHE := -59		; fatal hardware error
;				;  file control services codes
	ieNFI := -60		; file id not specified
	ieISQ := -61		; invalid sequential operation
;				;  system standard codes
	ieEOT := -62		; eot detected
;				;  file primitive codes
	ieBVR := -63		; bad version number
	ieBHD := -64		; bad file header
;				;  standard system codes
	ieOFL := -65		; device offline
	ieBCC := -66		; block check error
;				;  unused
	ieC67 := -67		; error code 67
;				;  network acp codes
	ieNNN := -68		; no such node
	ieNFW := -69		; path lost to partner
	ieBLB := -70		; bad logical buffer
	ieTMM := -71		; too many outstanding messages
	ieNDR := -72		; no dynamic space available
	ieCNR := -73		; connection rejected
	ieTMO := -74		; timeout on request
;				;  file primitive codes
	ieEXP := -75		; file expiration date not reached
	ieBTF := -76		; bad tape format
;				;  file control codes
	ieNNC := -77		; not ansii D format byte count
;				;  network acp codes
	ieNNL := -78		; not a network lun
;				;  ics/icr error codes
	ieNLK := -79		; task not linked to specified ics/icr interrupts
;;	ieNST := -80		; task not installed - duplicate code
;				;  network acp codes
;;	ieAST := -80		; no ast specified in connect - same as DSW -80.
;				;  ics/icr error codes
;				;  compromise
	ieNST := -80		; no task or ast
;				;  ics/icr error codes
	ieFLN := -81		; device offline when offline request issued
;				;  tty error codes
	ieIES := -82		; invalid escape sequence
	iePES := -83		; partial escape sequence
;				;  file primitive codes
	ieALC := -84		; allocation failure
	ieULK := -85		; unlock error
;
	ieERS := -86		; errors
;
; DSW - directive success codes
;
	isCLR := 0		; event flag was clear
	isSET := 2		; event flag was set
	isSPD := 2		; task was suspended
;
; DSW - directive error codes
;
	ieUPN := -1		; insufficient dynamic storage
	ieINS := -2		; specified task not installed
	iePTS := -3		; partition to small for task
	ieUNS := -4		; insufficient dynamic storage for send
	ieUNL := -5		; unassigned lun
	ieHWR := -6		; device handler not installed
	ieACT := -7		; device not active
	ieITS := -8		; directive inconsistant with task state
	ieFIX := -9		; task already fixed/unfixed
	ieCKP := -10		; task not checkpointable
	ieTCH := -11		; task is checkpointable
;
	ieRBS := -15		; receive buffer is too small
;sic]	iePRI := -16		; privilege violation - same as I/O code
;sic]	ieRSU := -17		; noshare resource in use - same as I/O code
	ieNSW := -18		; no swap space
	ieILV := -19		; invalid vector
;
	ieAST := -80		; directive issued/not issued from ast
	ieMAP := -81		; illegal mapping specified
;		-82		; 
	ieIOP := -83		; window has I/O in progress
	ieALG := -84		; alignment error
	ieWOV := -85		; address window overflow
	ieNVR := -86		; invalid region id
	ieNVW := -87		; invalid address window id
	ieITP := -88		; invalid ti parameter
	ieIBS := -89		; invalid send buffer size - gt 255.
	ieLNL := -90		; lun locked in use
	ieIUI := -91		; invalid uic
	ieIDU := -92		; invalid device or unit
	ieITI := -93		; invalid time parameters
	iePNS := -94		; partition/region not in system
	ieIPR := -95		; invalid priority - gt 250.
	ieILU := -96		; invalid lun
	ieIEF := -97		; invalid event flag - gt 64.
	ieADP := -98		; dpb outside user space
	ieSDP := -99		; dic or dpb size invalid
;
; DSW - directive success codes
;
	isCLR := 0		; event flag was clear
	isSET := 2		; event flag was set
	isSPD := 2		; task was suspended

end header
