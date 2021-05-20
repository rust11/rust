.;Edit Level 0
.;
.;                   COPYRIGHT (c) 1983, 1986 BY
.;             DIGITAL EQUIPMENT CORPORATION, MAYNARD, MASS.
.;
.; THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED AND  COPIED
.; ONLY  IN  ACCORDANCE  WITH  THE  TERMS  OF  SUCH  LICENSE AND WITH THE
.; INCLUSION OF THE ABOVE COPYRIGHT NOTICE.  THIS SOFTWARE OR  ANY  OTHER
.; COPIES  THEREOF MAY NOT BE PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY
.; OTHER PERSON.  NO TITLE TO AND OWNERSHIP OF  THE  SOFTWARE  IS  HEREBY
.; TRANSFERRED.
.;
.; THE INFORMATION IN THIS SOFTWARE IS SUBJECT TO CHANGE  WITHOUT  NOTICE
.; AND  SHOULD  NOT  BE  CONSTRUED  AS  A COMMITMENT BY DIGITAL EQUIPMENT
.; CORPORATION.
.;
.; DIGITAL ASSUMES NO RESPONSIBILITY FOR THE USE OR  RELIABILITY  OF  ITS

.; SOFTWARE ON EQUIPMENT WHICH IS NOT SUPPLIED BY DIGITAL.
.;
.;********************************************************
.; 	Initialiazation code
.;********************************************************
.;
	.ENABLE LOWERCASE
	.ENABLE SUBSTITUTION
	.ENABLE GLOBAL
	.ENABLE QUIET
	.DISABLE PREFIX,SUFFIX
	$SET TT QUIET
.;
.;	Set ESCAPE Sequences for hard copy dev.
.;
	.SETS BLACK	""
	.SETS NEWSCR	""
	.SETS CLEAR 	""
	.SETS ANSI	""
	.SETS WHITE	""
	.SETS JUMP	""
	.SETS HOME 	""
	.SETS CLEAR 	""
	.SETS BS 	""
	.SETS BOTTOM	""
	.SETS BEGIN	""
	.SETS NEG	""
	.SETS OFF	""
	.SETS SCROLL	""
	.SETS UNSCRL	""
	.SETS BIGU	""
	.SETS BIGB	""
	.SETS NOWRAP	""
	.SETS REVER 	""
	.SETS STARS "********************************************************"
	.SETS	BELL	""
	.SETS VER "MPP23"
	.SETS VERS "V2.3"
	.SETF VT100
	.TESTFILE SY:TERMID.SAV
	.IF <FILERR> EQ <SUCCES> .GOTO 5
	.SETS ERRTYP ": Running TERMID.SAV"
	.GOTO CRASH

.5:	$RUN SY:TERMID
	.IF <EXSTAT> EQ 1 .SETT VT100
	.IFF VT100 .GOTO 10
.;
.;	Set ESCAPE Sequences for VT-100
.;
	.SETS ANSI	"<"
	.SETS WHITE	"[?5h"
	.SETS JUMP	"[?4l"
	.SETS HOME 	"[H"
	.SETS CLEAR 	"[2J"
	.SETS BS 	""
	.SETS NEG	"[7m"
	.SETS OFF	"[m"
	.SETS BOTTOM	"[24;1H"
	.SETS BEGIN	"[4;1H"
	.SETS END	"[22;1H"
	.SETS SCROLL	"[4;22r"
	.SETS UNSCRL	"[1;24r"
	.SETS BIGU	"#3"
	.SETS BIGB	"#4"
	.SETS BLACK	"[?5l"
	.SETS NEWSCR	"[r"
	.SETS CLEAR 	"[2J"
	.SETS REVER 	"[7m"
	.SETS STARS ""
.10:	.SETS RTC "ready to continue"
	.SETS READY RTC

.START:	; 'ANSI''WHITE''JUMP''HOME''CLEAR''SCROLL'
	.SETS HEADER "MicroPower Installation Verification"
	.GOSUB HEADER
	;
	; 	Welcome to MicroPower/Pascal-RT (MP/P-RT) Version 'VERS'
	;
	;	MP/P-RT is installed  on  your  working disk  and your
	;	system  is  booted.   The  Installation   Verification
	;	Procedure, which consists of building and running  the
	;	test program, now  begins.  At the  completion  of the
	;	build procedure, you will  be  instructed  to run  the
	;	test program (CARS3).
        ;       	
	;	You may exit this  installation verification procedure
	;	at  any  time   by  answering  NO   to  the  following
	;	instruction:
	;
	;	"Press the RETURN key when ready to continue."
	;	
	.GOSUB CONTIN
	.GOSUB GETDAT
.NCHEC:
	.SETS HEADER "Building Test Program"
	.GOSUB HEADER
	;
	;
	;	The test program  build procedure  is done in TWO steps.
	;
	;	First  the kernel  for your  target processor  is built.
	;	Next,  the  test program is  compiled and  added to  the
	;	kernel. 
	;        
	;	Your  target processor  may be  one of  four types.  The
	;	next frame will ask you for the type of target processor
	;	for which you will build the kernel.
	;	
	;	
	.GOSUB CONTIN
.TAR:
	.GOSUB HEADER
	;	
	;	Indicate the target processor for which you will build
	;	the kernel by typing the corresponding number.
	;	
	;	   'REVER'1.'OFF'  Any LSI-11 microcomputer (unmapped)
	;	
	;	   'REVER'2.'OFF'  FALCON
	;	
	;	   'REVER'3.'OFF'  FALCON-PLUS
	;	
	;	   'REVER'4.'OFF'  KXT11-CA (standalone)
	;	
	;	   'REVER'5.'OFF'  CMR21
	;	
	;	The next frame will ask you to confirm your choice.
	;
	.SETN TNUM 0
	.ASKN TNUM 	Enter the correct number (1-5) and press the RETURN key.
	.IF TNUM EQ 1 .GOTO TAR1
	.IF TNUM EQ 2 .GOTO TAR2
	.IF TNUM EQ 3 .GOTO TAR3
	.IF TNUM EQ 4 .GOTO TAR4
	.IF TNUM EQ 5 .GOTO TAR5
	.GOTO TAR
.TAR1:	.;
	.GOSUB HEADER
	;	
	;	
	;	You have indicated that your target is an LSI-11 microcomputer.
	;	LSI-11 microcomputers include the following:  LSI-11, LSI-11/2,
	;	LSI-11/23, LSI-11/23-PLUS, and LSI-11/73.
	;	
	;	Please confirm your choice by answering the following question.
	;	Answer YES  to indicate confirmation.  Answer  NO  to return to
	;	the previous frame.
	;	
	;	Is your target an LSI-11 ?
	;	
	;	
	.ASK ANSWER  	Enter YES or NO and press the RETURN key.
	.IFT ANSWER .GOTO 15
	.IFF ANSWER .GOTO TAR
.TAR2:	.;
	.GOSUB HEADER
	;	
	;	
	;	You have indicated that  your target is a FALCON.  The  FALCON
	;	is a  dual-height  board with a  T-11 processor,  memory,  two
	;	asynchronous lines and a parallel I/O interface.
	;	
	;	Please confirm your choice by answering the following question.
	;	Answer YES  to indicate confirmation.  Answer  NO  to return to
	;	the previous frame.
	;	
	;	Is your target a FALCON ?
	;	
	;	
	.ASK ANSWER  	Enter YES or NO and press the RETURN key.
	.IFT ANSWER .GOTO 15
	.IFF ANSWER .GOTO TAR
.TAR3:	.;
	.GOSUB HEADER
	;	
	;	
	;	You have indicated  that your  target  is a  FALCON-PLUS.  The
	;	FALCON-PLUS, like the FALCON,  is a  dual-height  board with a
	;	T-11 processor, memory, two asynchronous lines and  a parallel
	;	I/O interface.  The FALCON-PLUS  has more  RAM memory than the
	;	FALCON.
	;	
	;	Please confirm your choice by answering the following question.
	;	Answer YES  to indicate confirmation.  Answer  NO  to return to
	;	the previous frame.
	;	
	;	Is your target a FALCON-PLUS ?
	;	
	;	
	.ASK ANSWER  	Enter YES or NO and press the RETURN key.
	.IFT ANSWER .GOTO 15
	.IFF ANSWER .GOTO TAR
.TAR4:	.;
	.GOSUB HEADER
	;	
	;	
	;	You  have  indicated  that  your  target  is a  KXT11-CA.  The
	;	KXT11-CA is a quad-height board with a T-11 processor, memory,
	;	three synchronous/asynchronous lines, a parallel I/O interface
	;	and a two-channel DMA controller.
	;	
	;	Please confirm your choice by answering the following question.
	;	Answer YES  to indicate confirmation.  Answer  NO  to return to
	;	the previous frame.
	;	
	;	Is your target a KXT11-CA ?
	;	
	;	
	.ASK ANSWER  	Enter YES or NO and press the RETURN key.
	.IFT ANSWER .GOTO 15
	.IFF ANSWER .GOTO TAR
.TAR5:	.;
	.GOSUB HEADER
	;	
	;	
	;	You  have  indicated  that  your  target  is a  CMR21.  The
	;	CMR21 is a ruggedized system with a T-11 processor, memory,
	;	three synchronous/asynchronous lines.
	;	
	;	Please confirm your choice by answering the following question.
	;	Answer YES  to indicate confirmation.  Answer  NO  to return to
	;	the previous frame.
	;	
	;	Is your target a CMR21 ?
	;	
	;	
	.ASK ANSWER  	Enter YES or NO and press the RETURN key.
	.IFT ANSWER .GOTO 15
	.IFF ANSWER .GOTO TAR
.15:	.;
	.GOSUB HEADER
	;
	;
	;	The test program is now being built. 
	;	The file will be called DK:CARS3.MIM.
	;
	;
	;	This will take about 7 minutes.
	;
	$ASSIGN DK TMP
	.IF TNUM EQ 1 $@LB:KRDUNM
	.IF TNUM EQ 2 $@LB:KRDFAL
	.IF TNUM EQ 3 $@LB:KRDFPL
	.IF TNUM EQ 4 $@LB:KRDKTC
	.IF TNUM EQ 5 $@LB:KRDCMR
	.IF <EXSTAT> EQ 1 .GOTO NOERR
	.; Handle test program build error
	.SETS ERRTYP ": Error building the test program"
	.GOTO CRASH	
.NOERR:	.;
	.SETS HEADER "Concluding Verification"
	.GOSUB HEADER
	;
	;
	;	Your  next  step is to  load the test program  (DK:CARS3.MIM)
	;	into the target hardware.
	;	
	;	The next two frames contain commands that you type and  system
	;	messages that appear when  running the  test  program.  Before
	;	continuing, be prepared to make note of the commands you  will
	;	be required to enter.
	;	
	.GOSUB CONTIN
	.SETS HEADER "Concluding Verification"
	.GOSUB HEADER
	;	
	;	You will see the message "Rebooting working disk......"  Press
	;	RETURN in response to the "Startup file?" prompt. You will see
	;	"RT-11 Extended Memory Monitor", and other system information.
	;	At the system prompt, enter the following sequence of commands:
	;	
	;	.run lb:pasdbg
	;	PASDBG>load cars3
	;	;PASDBG-I-BOTWARN, STARTING PRIMARY BOOT LOAD, PLEASE WAIT...
	;	;PASDBG-I-BOTLD, PRIMARY BOOT LOADED, GETTING CLOSER...
	;	PASDBG>go
	;	
	;	where capital letters denote computer output and lower-case
	;	letters represent your input.
	;	(NOTE THE ABOVE COMMANDS BEFORE CONTINUING.)
	.GOSUB CONTIN
	.SETS HEADER "Concluding Verification"
	.GOSUB HEADER
	;
	;	On entering "go" at the PASDBG> prompt, you will see either
	;
	;	   a) [TARGET EXECUTION RESUMED-TYPE <CR> TO HALT]
	;
	;	if you have a terminal attached to the target, or
	;
	;	   b) MEMORY_FAULT EXCEPTION, BUS ERROR
	;
	;	if you do not have a terminal attached to the target.
	;	
	;	Both  messages  signify  successful  Verification.  Any  other    
	;	message  indicates  that the  hardware has  not  been  set  up
	;	correctly.  If  this happens, check your hardware, restart the
	;	debugger by  typing "run lb:pasdbg", and try to downline  load
	;	the test program into the target again.
	.GOSUB CONTIN
	.SETS	HEADER "Confirm Hardware"
	.GOSUB	HEADER
	;
	;
	;	Before down-line loading  the test program,  confirm that
	;	your hardware  is set up as described  in the next frame.
	;	The Installation Verification Procedure will fail if your
	;	hardware is not set up according to the following diagram.
	;	
	;
	.GOSUB CONTIN
	.IF TNUM NE 1 .GOTO 20
	.SETS TNAM "LSI-11     "
	.SETS TCSR "176500"
	.SETS TVEC "300"
	.GOTO 50
.20:	.IF TNUM NE 2 .GOTO 30
	.SETS TNAM "FALCON     "
	.SETS TCSR "176540"
	.SETS TVEC "120"
	.GOTO 50
.30:	.IF TNUM NE 3 .GOTO 40
	.SETS TNAM "FALCON-PLUS"
	.SETS TCSR "176540"
	.SETS TVEC "120"
	.GOTO 50
.40:	.IF TNUM NE 4 .GOTO 50
	.SETS TNAM "KXT11-CA   "
	.SETS TCSR "175700"
	.SETS TVEC "140"
.50:	.;
	.GOSUB HEADER
	; 	_____________________                   _________________
	; 	|    HOST SYSTEM    |   serial lines    |   Optional    |
	; 	|* any PDP-11 with  |   to terminals    |TARGET terminal|
	; 	|  memory management|_______    / \     | VT52 or VT100 |
	; 	|  (e.g., 11/23)    |       |<-    \    -----------------
	; 	|* 128 KB memory    | csr=177560    -------------->|
	; 	|* line clock       | vector=60         csr='TCSR' |
	; 	--------------------- ______|__________ vector='TVEC' |
	; 	csr=176500      |     | HOST console  | ___________|_________
	; 	vector=300      |     | terminal      | |   TARGET SYSTEM   |
	; 	                |     | (e.g., VT100) | |                   |
	;	HOST-TARGET     |     ----------------- |* 'TNAM'      |
	; 	serial line --->|           csr=177560  |                   |
	; 	                ------------vector=60---|* 32 KB RAM        |
	;	MAKE SURE THAT:                         ---------------------
	;     * Host/Target link has same     * Serial lines are hooked up
	;       baud rates on both ends         to DL11 interfaces on HOST and
	; 	                                TARGET
	;	'BOTTOM'	 Press the RETURN key to continue. 'BOTTOM'
	.ASK ANSWER
	.GOSUB HEADER
	.IF TNUM NE 2 .GOTO 60
	;	
	;	
	;	Ensure that your FALCON has the KXT11-A2 Macro-ODT ROM
	;	option installed and that the  start/restart addresses
	;	are set to  172000/172004.  For  detailed  information
	;	concerning the  configuration  of the FALCON,  consult
	;	the MicroPower/Pascal-RT Installation Guide.
	;	
	.GOSUB CONTIN
	.GOTO 70
.60:	.IF TNUM NE 3 .GOTO 70
	;	
	;	
	;	Ensure that your  FALCON-PLUS has the  KXT11-A5 Macro-ODT
	;	ROM option installed and that the start/restart addresses
	;	are  set  to   172000/172004.  For  detailed  information
	;	concerning the  configuration of the FALCON,  consult the
	;	MicroPower/Pascal-RT Installation Guide.
	;	
	.GOSUB CONTIN
.70:	.SETS HEADER "Concluding Verification"
	.GOSUB HEADER
	;	
	;	
	;	The verification procedure will now terminate to allow  you
	;	to make the necessary changes to the  hardware and load the
	;	test program into the target.
	;	
	.GOSUB CONTIN
.DONE:
	.; Check if being run via MPVFY.COM
	.TESTFILE SY:MPPINS.COM
	.IF <FILERR> NE <SUCCES> .GOTO DONE1
	.SETS INSPEC "SY:STARTX.COM"
	.GOSUB DELETE
	.OPEN SY:DEL.TMP
	.DATA DEL/NOQ SY:DEL.TMP
	.DATA DEL/NOQ SY:MPPINS.COM
	.DATA BOOT SY:
	.CLOSE
	.OPEN SY:STARTX.COM
	.DATA SET TT QUIET,TAB,NOCRLF,WIDTH=80
	.IFT VT100 .DATA SET EDIT KEX
	.IFT VT100 .DATA SET TT SCOPE
	.DATA MOUNT LD0 'VER'.DSK
	.DATA ASSIGN LD0 LB
	.DATA ASSIGN SY TMP
	.DATA LOAD LD:
	.DATA TYPE LB:USER.TXT
	.DATA SET TT NOQUIET
	.DATA IND DATIME
	.CLOSE
	;'CLEAR''BLACK''NEWSCR'
	;	
	;	
	;	
	;	Rebooting working disk......
	;	
	$@SY:DEL.TMP
.DONE1:	.EXIT
.;
.;	Clear the Screen and Display Heading
.;
.HEADER:
	.IFT VT100 .GOTO HEAD1
	;'STARS'
	;  'HEADER'
	;'STARS'
	.RETURN
.HEAD1:
	;'HOME''CLEAR''SCROLL'
	;'BIGU'  'HEADER'
	;'BIGB'  'HEADER''BOTTOM'
	;'BEGIN''OFF'
	.RETURN


.;Do the CONTINUE? prompt. If REPEAT is true on exit, the user
.;wants to continue after answering no to CONTINUE?
.;
.; INPUT: READY= When to press return. See below
.;
.CONTIN:
	.SETF REPEAT
	;
	.ASK [<TRUE>] CONT		Press the RETURN key when 'READY'.
	.IFT CONT .RETURN
.CON10:
	.SETT REPEAT
	.ASK CONT		Do you want to continue with this verification?
	.IFT <DEFAUL> .GOTO CON10
	.IFT CONT .RETURN
	.GOTO DONE
.GETDAT:
	.SETS HEADER "Enter Today''s Date"
	.IF <DATE> NE "         " .RETURN
	.GOSUB HEADER
	;
	;	Please enter today''s date as follows:
	;
	;	DD-MMM-YY
	;
	;          where DD =  day of the month
	;               MMM =  first three letters of the month 
	;                YY =  last two numbers of the year
	;
	;		For example:   31-JUL-86
	;	
	.ASKS DAT		Enter date, then press the RETURN key.
	$DATE 'DAT'
	.IF <EXSTAT> EQ <SUCCES> .RETURN
	;
	;'BELL'	Wrong format for date.
	.GOSUB CONTIN
	.GOTO GETDAT
.;***********************************************************************
.;		COMMON PROCEDURES
.;***********************************************************************
.RENAME:
	$RENAME/NOLOG 'INSPEC' 'OUSPEC'
	.IF <EXSTAT> LE 1 .RETURN
	;
	;	An error occurred while renaming 'INSPEC' to 'OUSPEC'.
	;
	.ASK RETRY         Do you want to try again?
	.IFT RETRY .GOTO RENAME
	.SETS ERRTYP ": renaming 'INSPEC' to 'OUSPEC'"
	.GOTO CRASH
.DELETE:
	$DELETE/NOQ 'INSPEC'
	.IF <EXSTAT> LE 1 .RETURN
	;
	;	An error occurred while deleting 'INSPEC'. 
	;
	.ASK RETRY         Do you want to try again?
	.IFT RETRY .GOTO DELETE

	.SETS ERRTYP ": deleting 'INSPEC'"
	.GOTO CRASH
.COPY:
	$COPY/PREDEL/NOLOG/SYS 'INSPEC' 'OUSPEC'
	.IF <EXSTAT> LE 1 .RETURN
	;
	;	An error occurred while copying 'INSPEC' to 'OUSPEC'.
	;
	.ASK RETRY         Do you want to try again?
	.IFT RETRY .GOTO COPY
	.SETS ERRTYP ": copying 'INSPEC' to 'OUSPEC'"
	.GOTO CRASH
.UNPROT:
	$UNPROTECT/NOLOG/SYS 'INSPEC'
	.IF <EXSTAT> EQ <SUCCES> .RETURN
	;	
	;	An error occurred while unprotecting 'INSPEC'.
	;
	.ASK RETRY         Do you want to try again?
	.IFT RETRY .GOTO UNPROT
	.SETS ERRTYP ": unprotecting 'INSPEC'"
	.GOTO CRASH
.BOOT:
	$BOOT 'INSPEC'
	.IF <EXSTAT> EQ <SUCCES> .RETURN
	;
	;	An error occurred while bootstrapping 'INSPEC'.
	;
	.ASK RETRY         Do you want to try again?
	.IFT RETRY .GOTO BOOT
	.SETS ERRTYP ": bootstrapping 'INSPEC'"
	.GOTO CRASH
.CRASH:
	.SETS HEADER "Verification Error"
	.GOSUB HEADER
	;
	;  'BELL'
	;  Error'ERRTYP'
	;
	;	
	;	
	;	An error occured during Installation Verification.  When  this
	;	procedure terminates, please reboot  your  distribution  media
	;	and follow the  instructions to  recreate  your  working disk.
	;	If  this error  occurs  again, try to perform the installation
	;	with the duplicate software provided  in  your  kit.   If  the 
	;	problem persists,  contact  the  Customer Support Center (CSC)
	;	for your area.
	.EXIT
                                                                                                                                                                                                                              