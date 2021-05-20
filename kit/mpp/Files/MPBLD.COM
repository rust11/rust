.; Edit Level 3
.;
.;                   Copyright (c) 1984, 1986 by
.;             Digital Equipment Corporation, Maynard
.;              Massachusetts.  All rights reserved.
.;
.; This software is furnished under a license and may be used and  copied
.; only  in  accordance  with  the  terms  of  such  license and with the
.; inclusion of the above copyright notice.  This software or  any  other
.; copies  thereof may not be provided or otherwise made available to any
.; other person.  No title to and ownership of  the  software  is  hereby
.; transferred.
.;
.; The information in this software is subject to change  without  notice
.; and  should  not  be  construed  as  a commitment by Digital Equipment
.; Corporation.
.;
.; DIGITAL assumes no responsibility for the use or  reliability  of  its
.; software on equipment that is not supplied by DIGITAL.
.;
.;
.; MPBLD MicroPower/Pascal-RT command file generator.
.; Author:	Eric R. Schott  DEC
.; Modified:	ERS 26-Sep-83 added kxt11-c questions
.;		ERS 8-Aug-84  Updated for V2.0
	.disable suffix,prefix,octal
	.enable substitution,timeout,quiet,global
.;
.;	Strings
.;
.;		CFGFIL = configuration file
.;		KRNFIL = Kernel and driver MIM, DBG, and STB files
.;		KRNDEV = Device for kernel MIM, DBG, and STB files
.;		APPFIL = Final application MIM and DBG files
.;		COMFIL = Indirect command file
.;		SMLFIL = System macro library (COMU.SML or COMM.SML)
.;		PAXFIL = System library (PAXU.OBJ or PAXM.OBJ)
.;		DRVFIL = Driver library (DRVU.OBJ or DRVM.OBJ)
.;		CMODE  = Code type (EIS,NHD,FIS,FPP)
.;		AUXnnn = List of auxillary files (shared library build)
.;
.;
.;	Logicals
.;
.;		APPBLD = True for build an application
.;		CFGOBJ = True for configuration OBJ file
.;		KRNBLD = True for kernel build
.;		KRNMAP = True for kernel reloc map
.;		MAPPED = True for  mapped system
.;			 False for unmapped system
.;		DEBUG  = True for Pasdbg support
.;			 False for no Pasdbg support
.;		ROM    = True for ROM/RAM images
.;			 False for RAM only
.;		OPTMZ  = True for kernel optimization
.;		SHRBLD = True for build a shared library
.;		SUPLIB = True for shared library is supervisor library
.;	
.;	Numeric
.;
.;		OPTOUT = Optimization output file channel number (0 or 1)
.;		AUXOUT = Auxillary output file channel number (0 or 2)
.;		AUXCNT = # of auxillary files in AUXnnn
	.sets vers "V2.3"	.; current version string
	.sett appbld 		.; assume application build
	.setf ls2		.; not an LSI-11/2
	.setf rom		.; assume RAM system
	.sets mapstr ""		.; no reloc map file name
	.sets appfil ""		.; null application name
	.sets addstr ""		.; Compiler, Merge, Reloc switch "/D" or ""
	.sets cmode  "NHD"	.; Code type for compiler, libraries
	.setn optout 0		.; optimize auxillary file #
	.setn auxout 0		.; Auxillary file #
	.setf optmz		.; no kernel optimization
	.setf shrbld		.; do not build a shared library
	.setf suplib		.; not a supervisor library
	.setf $ldiag		.; no long dialog
	.setf $map		.; no reloc map
	.setf $id		.; no I&D space
.;
	;
	;MicroPower/Pascal-RT 'vers' Build Command Procedure Generator
	;
	;Type "?" for help at any question.
	.sett $deflt		.; allow default answer
	.sets $dfans "NO"	.; default answer
	.sets $ques "Do you want the long form of dialog [no] ?"
	.setn $hlp 1
	.gosub askl
	.setl $ldiag $ans
.;
	.sets $dfans "YES"
	.setn $hlp 2
	.sets $ques "Do you wish to build a kernel [yes] ?"
	.gosub askl
	.setl krnbld $ans
.1:
	.setf $deflt
	.sets $ques "Kernel memory image file name ?"
	.setn $hlp 3
	.iff krnbld .sets $ques "Input memory image file name ?"
	.iff krnbld .setn $hlp 51
	.gosub asks
	.sets $infil $anstr
	.if $infil ne "" .goto 1A
	;
	;?MPBLD-W-No kernel memory image file specified
	.goto 1
.;
.1A:	.setf sw$obj	.; allow no switches
	.setf sw$lst
	.setf sw$mac
	.setf sw$map
	.setf sw$lbr
	.setf sw$id
	.gosub prsfil
	.ift $err .goto 1
	.sets krnfil $name
	.sets krndev $dev
	.sets appfil $dev+$name
	.sets cfgfil $dev+$name+".MAC"
	.sets comfil $dev+$name+".COM"
	.iff krnbld .goto 4
.;
.2:
	.setf $deflt
	.sets $ques "System config file spec ["+cfgfil+"] ?"
	.setn $hlp 4
	.gosub asks
	.sets $infil $anstr
	.sett $deflt
	.sets $dfans cfgfil
	.sett sw$obj		.; allow /OBJ
	.sett sw$map		.; allow /MAP
	.setf sw$lst
	.setf sw$mac
	.setf sw$lbr
	.setf sw$id
	.gosub prsfil
	.ift $err .goto 2
	.setl krnmap $map
	.iff $obj .and .if $ext eq "" .sets $ext ".MAC"
	.setl cfgobj $obj
	.setn $hlp 5
	.iff $obj .gosub editfl
	.sets cfgfil $dev+$name+$ext
.;
	.sett $deflt		.; allow default answer
	.sets $dfans "NO"	.; default answer
	.sets $ques "Do you wish to build only the kernel/drivers [no] ?"
	.setn $hlp 6
	.gosub askl
	.setl appbld ^$ans	.; NOT $ans
	.iff appbld .goto 6
.;
.;
.4:.;
.5:
	.setf $deflt
	.sets $ques "Application memory image file name ?"
	.setn $hlp 8
	.gosub asks
	.sets $infil $anstr
	.if $infil ne "" .goto 5A
	;
	;?MPBLD-W-No Application memory image file specified
	.goto 5
.5A:	.setf sw$obj		.; allow no switches
	.setf sw$lst
	.setf sw$mac
	.setf sw$map
	.setf sw$lbr
	.setf sw$id
	.gosub prsfil
	.ift $err .goto 5
	.sets appfil $dev+$name
	.sets comfil $dev+$name+".COM"
.;
.6:
	.setf $deflt
	.sets $ques "Output command file spec ["+comfil+"] ?"
	.setn $hlp 9
	.gosub asks
	.sets $infil $anstr
	.sett $deflt
	.sets $dfans comfil
	.setf sw$obj		.; allow no switches
	.setf sw$lst
	.setf sw$mac
	.setf sw$map
	.setf sw$lbr
	.setf sw$id
	.gosub prsfil
	.ift $err .goto 6
	.if $ext eq "" .sets $ext ".COM"
	.sets comfil $dev+$name+$ext
.;
	.sets tmp1 "U"
	.sets $dfans "NO"
	.sets $ques "Mapped image [no] ?"
	.setn $hlp 10
	.gosub askl
	.setl mapped $ans
.;
	.ift mapped .sets tmp1 "M"
	.ift mapped .sets cmode "EIS"
	.sets smlfil "LB:COM"+tmp1+".SML/M"
	.sets paxfil "LB:PAX"+tmp1+".OBJ"
	.sets drvfil "LB:DRV"+tmp1+".OBJ"
.;
	.sets $dfans "YES"
	.sets $ques "Debug support required [yes] ?"
	.setn $hlp 11
	.gosub askl
	.setl debug $ans
	.ift debug .sets addstr "/D"
.;
	.iff krnbld .goto 7
	.sett $deflt
	.sets $dfans "NO"
	.sets $ques "Optimize the kernel [no] ?"
	.setn $hlp 40
	.gosub askl
	.setl optmz $ans
.;
.7:	.setn rambas 0
	.setn rombas 0
	.sets $dfans "NO"
	.sets $ques "Does this system contain any ROM [no] ?"
	.setn $hlp 12
	.iff debug .gosub askl
	.iff debug .setl rom $ans
	.iff krnbld .or .iff rom .or .ift mapped .goto 8
	.sett $deflt
	.sets $dfans "0"
	.sets $ques "What is the base of ROM (octal address) [0] ?"
	.setn $hlp 50
	.sets adtyp "ROM"
	.gosub ncvrt
	.enable octal
	.setn rombas rtnum
	.disable octal
.;
	.setf $deflt
	.sets $ques "What is the base of RAM (octal address) ?"
	.setn $hlp 13
	.sets adtyp "RAM"
	.gosub ncvrt
	.enable octal
	.setn rambas rtnum
	.disable octal
.;
.8:
	.iff appbld .goto 9A
	.sett $deflt
	.sets $dfans cmode
	.sets $ques "Instruction set hardware {NHD,FPP,EIS,FIS} ["+cmode+"] ?"
	.setn $hlp 14
	.gosub asks
	.sets str $anstr
	.setn n 0
	.if str ne "NHD" .and .if str ne "FPP" .inc n
	.if str ne "EIS" .and .if str ne "FIS" .inc n
	.if n ne 2 .goto 9
	;
	;MPBLD-W-Invalid reply; Please enter NHD,FPP,EIS, or FIS
	.goto 8
.;
.9:	.sets cmode str
	.sets $dfans "NO"
	.sets $ques "LSI-11/2 mode on compilations [no] ?"
	.setn $hlp 15
	.setf tm00 
	.if cmode eq "EIS" .or .if cmode eq "FIS" .sett tm00
	.ift tm00 .and .ift rom .and .iff mapped .gosub askl
	.ift tm00 .and .ift rom .and .iff mapped .setl ls2 $ans
.;
	.sett $deflt
	.sets $dfans "NO"
	.sets $ques "Build a shared library [no] ?"
	.setn $hlp 18
	.gosub askl
	.setl shrbld $ans
	.iff mapped .or .iff shrbld .goto 9A
.;
	.sets $ques "Supervisor Mode Library [no] ?"
	.setn $hlp 19
	.gosub askl
	.setl suplib $ans
.;
.9A:	.open 'comfil'
	.sets kopt ""
	.sets kopts ""
	.iff optmz .goto 10A
	.inc optout
	.open #'optout' DK:MPBLD.TMP
	.sett opt1st
	.sets kopt "TMP:"+krnfil+".KAU"
	.sets kopts ","+kopt
.;
.10A:	.data #'optout' !
	.data #'optout' ! MicroPower/Pascal 'vers' Build Command Procedure
	.parse appfil ":" a b
	.data #'optout' ! Application: 'b'  Generated : '<date>' '<time>' by You
	.data #'optout' !
	.data #'optout' ! Command file name:	'comfil'
	.sets a "No"
	.ift krnbld .sets a "Yes"
	.data #'optout' ! Kernel build:		'a'
	.sets a "No"
	.ift appbld .sets a "Yes"
	.data #'optout' ! Application build:	'a'
	.sets a "No"
	.ift optmz .sets a "Yes"
	.data #'optout' ! Optimize kernel:	'a'
	.sets a "No"
	.ift debug .sets a "Yes"
	.data #'optout' ! Debug support:	'a'
	.iff appbld .goto 10B
	.data #'optout' ! Code type:		'cmode'
	.sets a "None"
	.ift shrbld .sets a "User Mode"
	.ift suplib .sets a "Supervisor Mode"
	.data #'optout' ! Shared library:	'a'
.10B:	.sets a "Ram"
	.ift rom .sets a "Rom/Ram"
	.sets b "Unmapped"
	.ift mapped .sets b "Mapped"
	.data #'optout' ! 'b' 'a' application
	.data #'optout' !
	.data #'optout' SET ERROR WARNING
	.data #'optout' !
	.iff krnbld .goto 20
.;
	.data ! Build kernel and create memory image
	.data !
	.ift cfgobj .goto 10
	.sets $infil cfgfil
	.gosub prsfil
	.data R MACRO
	.data TMP:'$name'='$dev''$name''$ext','smlfil'
	.data ^C
.;
.10:	.data RUN LB:MERGE
	.sets a $dev+$name+$ext+addstr+kopts
	.iff cfgobj .sets a "TMP:"+$name+addstr+kopts
	.data TMP:'krnfil'.KMO='a','paxfil''addstr'
	.data ^C
	.sets relx ""		.; reloc switch
	.ift mapped .sets relx "/R:100000"
	.iff mapped .and .ift rom .sets relx "/O:"+"'rombas'"+"/R:"+"'rambas'"
	.ift krnmap .sets mapstr krndev+krnfil
	.data RUN LB:RELOC
	.data TMP:'krnfil','mapstr','krndev''krnfil'=TMP:'krnfil'.KMO'relx'
	.ift debug .data ,,TMP:'krnfil'.DST=TMP:'krnfil'.KMO/D'relx'
	.data ^C
	.data RUN LB:MIB
	.ift debug .data 'krndev''krnfil',,'krndev''krnfil'=TMP:'krnfil',,TMP:'krnfil'.DST/K/S
	.iff debug .data 'krndev''krnfil'=TMP:'krnfil'/K/S
	.data ^C
	.ift optmz .data DEL/NOQUERY 'kopt'
	.ift debug .data DEL/NOQUERY TMP:'krnfil'.DST
	.data DEL/NOQUERY TMP:'krnfil'.(KMO,PIM)
	.iff cfgobj .data DEL/NOQUERY TMP:'$name'.OBJ
	.data !
.;		
.;	Device driver query
.;
.20:	.sets krnfil krndev+krnfil
	.ift krnbld .goto 26
	.data ! Create application memory image
	.data !
	.if appfil eq krnfil .goto 26
	.data COPY/PREDELETE 'krnfil'.MIM 'appfil'.MIM
	.data COPY/PREDELETE 'krnfil'.STB 'appfil'.STB
	.ift debug .data COPY/PREDELETE 'krnfil'.DBG 'appfil'.DBG
	.sets krnfil appfil
	.data !
.;
.26:	.sett first
	;
	;Beginning system process section
.21:
	.setf $deflt
	.sets $ques "Driver prefix file spec ?"
	.iff krnbld .sets $ques "Additional driver prefix file spec ?"
	.setn $hlp 16
	.gosub asks
	.sets $infil $anstr
	.if $infil eq "" .goto 25
	.setf $map
	.sets mapstr ""
	.sett sw$obj		.; allow /OBJ
	.setf sw$lst
	.setf sw$mac
	.setf sw$map
	.setf sw$lbr
	.setf sw$id
	.gosub prsfil
	.ift $err .goto 21
	.ift $obj .goto 24
	.if $ext eq "" .sets $ext ".MAC"
.;
	.close
	.ift optmz .close #'optout'
	.setn $hlp 17
	.gosub editfl
	.opena 'comfil'
	.ift optmz .opena #'optout' DK:MPBLD.TMP
.24:	.iff first .goto 24B
	.setf first
	.iff optmz .goto 24A
	.data #'optout' ! Build device drivers
	.data #'optout' !
	.data ! Install device drivers
	.data !
	.goto 24B
.24A:	.data ! Build and install device drivers
	.data !
.;
.24B:	.sets device "TMP:"+$name
	.sets mrgobj $dev+$name+$ext		.; assume user OBJ file
	.ift $obj .goto 23
	.sets mrgobj device
	.data #'optout' R MACRO
	.data #'optout' 'mrgobj'='$dev''$name''$ext','smlfil'
	.data #'optout' ^C
.;
.23:	.iff optmz .goto 23A
.;
.; Build with kernel optimization
	.data #'optout' RUN LB:MERGE
	.ift opt1st .data #'optout' 'device',,'kopt'='mrgobj','drvfil'
	.iff opt1st .data #'optout' 'device',,'kopt'='mrgobj','kopt','drvfil'
	.data #'optout' ^C
	.setf opt1st
	.data RUN LB:MERGE
	.data 'device'='device'.MOB,'krnfil'.STB
	.data ^C
	.goto 23B
.;
.; Build with no kernel optimization
.23A:	.data RUN LB:MERGE
	.data 'device'='mrgobj','drvfil','krnfil'.STB
	.data ^C
.;
.23B:	.ift $map .sets mapstr ","+$dev+$name
	.data RUN LB:RELOC
	.ift mapped .data 'device''mapstr'='device'/O:40000/R:60000
	.iff mapped .data 'device''mapstr'='device','krnfil'
	.data ^C
	.data RUN LB:MIB
	.data 'krnfil'='device','krnfil'/S
	.data ^C
	.data DEL/NOQUERY 'device'.(MOB,PIM)
	.iff $obj .data #'optout' DEL/NOQUERY 'device'.OBJ
	.ift optmz .data #'optout' !
	.data !
	.goto 21
.;
.25:	.iff appbld .goto done
	;
	;
	;User Process Build Phase
	.iff krnbld .goto 27
	.data ! Create application memory image
	.data !
	.if appfil eq krnfil .goto 27
	.data COPY/PREDELETE 'krnfil'.MIM 'appfil'.MIM
	.data COPY/PREDELETE 'krnfil'.STB 'appfil'.STB
	.ift debug .data COPY/PREDELETE 'krnfil'.DBG 'appfil'.DBG
	.data !
.;
.27: 	.iff shrbld .goto slend
.;
.;	Shared library query
.;
	;
	;Beginning Shared Library Build Phase
	.setf $map			.; no map file
	.setn auxout 2
	.open #'auxout' DK:MPBLD1.TMP
	.setn auxopt auxout
	.ift optmz .setn auxopt 3
	.ift optmz .open #'auxopt' DK:MPBLD2.TMP
	.setn auxcnt 0	.; no aux files
	.gosub intmrg
.;
.s15:
	.setf $deflt
	.sets $ques "Additional Module or Library ?"
	.setn $hlp 20
	.gosub asks
	.sets $infil $anstr
	.if $infil eq "" .goto s80
	.sett sw$obj	.; allow /OBJ
	.sett sw$lst	.; /LIST
	.sett sw$mac	.; /MAC
	.sett sw$map	.; /MAP
	.sett sw$lbr	.; /LIBR
	.setf sw$id
	.gosub prsfil
	.ift $err .goto s15
	.gosub admrg		.; add file to merge & delete strings
.;
	.ift $obj .or .ift $lbr .goto s15
	.sets lis ""
	.ift $lis .sets lis ","+$dev+$name
	.ift $mac .goto s34
.;
	.sets modsw cmode
	.ift ls2 .sets modsw cmode+":LS2"
	.data #'auxopt' R MPP
	.data #'auxopt' TMP:'$name''lis'='$dev''$name''$ext''addstr'/I:'modsw'
	.goto s15
.;
.s34:	.data #'auxopt' R MACRO
	.data #'auxopt' TMP:'$name''lis'='$dev''$name''$ext','smlfil'
	.data #'auxopt' ^C
	.goto s15
.;
.s80:	.sets tmp1 "LB:FILSYS.OBJ,LB:LIB'cmode'.OBJ"
	.ift suplib .sets tmp1 "LB:FILSYS.OBJ,LB:SUP'cmode'.OBJ"
	.sets tmp2 "TMP:SHRLIB"
	.ift optmz .goto s80a
.; Shared library build without kernel optimization
	.inc mrgcnt
	.sets mrg'mrgcnt' "TMP:SHRLIB.AUX"
	.inc mrgcnt
	.sets mrg'mrgcnt' tmp1+","+appfil+".STB"
	.data #'auxout' RUN LB:MERGE
	.setn tmpout auxout		.; file to output merge line to
	.sets outstr tmp2		.; merge output file
	.gosub dmpmrg			.; output merge line
	.goto s80b
.;
.; Here for shared library build with kernel optimization
.s80a:	.inc mrgcnt
	.sets mrg'mrgcnt' tmp1+","+kopt
	.data #'auxopt' RUN LB:MERGE
	.setn tmpout auxopt		.; file to output merge line to
	.sets outstr tmp2+",,"+kopt	.; merge output file
	.gosub dmpmrg			.; output merge line
	.data #'auxout' RUN LB:MERGE
	.data #'auxout' 'tmp2'='tmp2'.MOB'addstr','appfil'.STB
	.data #'auxout' ^C
.;
.s80b:	.data #'auxout' RUN LB:RELOC
	.sets mapstr ""			.; no map string
	.ift $map .sets mapstr tmp2
	.sets relx "/J"			.; assume user library
	.ift suplib .sets relx "/M"	.; supervisor library
	.sets tmp1 ""
	.iff mapped .sets tmp1 ","+appfil
	.data #'auxout' 'tmp2','mapstr','tmp2'.STB='tmp2''addstr''tmp1''relx'
	.data #'auxout' ^C
	.data #'auxout' RUN LB:MIB
	.ift debug .data #'auxout' 'appfil',,'appfil'='tmp2','appfil','tmp2'.STB/S
	.iff debug .data #'auxout' 'appfil'='tmp2','appfil'/S
	.data #'auxout' ^C
	.data #'auxout' DEL/NOQUERY 'tmp2'.(MOB,PIM)
	.iff optmz .data #'auxout' DEL/NOQUERY 'tmp2'.AUX
	.setn tmpout auxopt
	.gosub dmpdel		.; dump deletes 
	.ift optmz .data #'auxopt' !
	.data #'auxout' !
	.ift optmz .close #'auxopt'
.slend:
.;
.;	User process query
.;
	;
	;Beginning User Process Section
	.sett first
	.iff krnbld .setf first
	.sett usrtxt			.; output user text
.30:
	.setf $map		.; no map
	.setf $id		.; not I&D
	.setf $deflt
	.sets $dfans appfil+".PAS"
	.sets $ques "User process file spec"
	.ift first .sets $ques $ques+" ["+$dfans+"]"
	.sets $ques $ques+" ?"
	.setn $hlp 24
	.gosub asks
	.sets $infil $anstr
	.ift first .sett $deflt
	.iff first .and .if $infil eq "" .goto 50
	.sett sw$obj		.; allow /OBJ
	.sett sw$lst		.; /LIST
	.sett sw$mac		.; /MAC
	.sett sw$map		.; /MAP
	.setf sw$lbr
	.ift mapped .sett sw$id	.; /ID (if mapped)
	.gosub prsfil
	.ift $err .goto 30
	.setf first
	.sets proces $dev+$name
	.gosub intmrg		.; init merge/delete strings
	.gosub admrg		.; add name to merge/dele strings
	.goto 33
.;
.31:
	.setf $deflt
	.sets $ques "Additional module or library ?"
	.setn $hlp 25
	.gosub asks
	.sets $infil $anstr
	.if $infil eq "" .goto 34
	.sett sw$obj		.; allow /OBJ
	.sett sw$lst		.; /LIST
	.sett sw$mac		.; /MAC
	.sett sw$map		.; /MAP
	.sett sw$lbr		.; /LIBR
	.ift mapped .sett sw$id	.; /ID (if mapped)
	.gosub prsfil
	.ift $err .goto 31
	.gosub admrg		.; add name to merge/delete strings

.33:	.iff usrtxt .goto 30A
	.setf usrtxt
	.iff shrbld .and .iff optmz .data #'optout' ! Build and install User processes
	.ift shrbld .or .ift optmz .data #'optout' ! Build User processes
	.ift optmz .data #'optout' !
	.ift shrbld .data #'auxout' ! Install user processes
	.ift shrbld .data #'auxout' !
	.iff shrbld .and .ift optmz .data ! Install user processes
	.iff shrbld .and .ift optmz .data !
	.iff optmz .data !
.;
.30A:	.ift $obj .or .ift $lbr .goto 31
	.sets lis ""
	.ift $lis .sets lis ","+$dev+$name
	.ift $mac .goto 32
.;
	.sets modsw cmode
	.ift ls2 .sets modsw cmode+":LS2"
	.data #'optout' R MPP
	.data #'optout' TMP:'$name''lis'='$dev''$name''$ext''addstr'/I:'modsw'
	.goto 31
.;
.32:	.data #'optout' R MACRO
	.data #'optout' TMP:'$name''lis'='$dev''$name''$ext','smlfil'
	.data #'optout' ^C
	.goto 31
.;
.34:	.setf drvpro			.; not a driver process
	.sett $deflt
	.sets $dfans "NO"
	.sets $ques "Is this process a device handler [no] ?"
	.setn $hlp 27
	.ift mapped .gosub askl
	.ift mapped .setl drvpro $ans
.;
	.setf useshr			.; don't use shared library
	.iff shrbld .goto 34A		.; if no shared library...
	.sett $deflt
	.sets $dfans "YES"
	.sets $ques "Build this process with the shared library [yes] ?"
	.setn $hlp 28
	.gosub askl
	.setl useshr $ans
	.ift drvpro .and .ift useshr ;
	.ift drvpro .and .ift useshr ;?MPBLD-W-Driver may not execute properly with Shared Library
.;
.34A:	.sets $infil proces
	.gosub prsfil
	.sets tmp2 "TMP:"+$name
	.iff useshr .goto 35B
	.iff optmz .goto 35A
.; optimize the kernel and build with shared library
	.iff opt1st .inc mrgcnt
	.iff opt1st .sets mrg'mrgcnt' kopt
	.data #'optout' RUN LB:MERGE
	.setn tmpout optout			.; output file to dump to
	.sets outstr ",,"+kopt			.; merge output string
	.gosub dmpmrg
	.iff opt1st .dec mrgcnt		.; remove kopt from string
	.setf opt1st
.;
.; Build with shared library
.35A:	.inc auxcnt
	.sets aux'auxcnt' tmp2+".AUX"
	.data #'optout' RUN LB:MERGE
	.setn tmpout optout
	.sets outstr tmp2+",,"+tmp2
	.gosub dmpmrg
	.sets relx "/J"			.; assume user library
	.ift suplib .sets relx "/M"	.; supervisor library
	.data #'auxout' RUN LB:MERGE
	.data #'auxout' 'tmp2'='tmp2'.MOB'addstr'//
	.data #'auxout' TMP:SHRLIB.STB'relx'
	.data #'auxout' //
	.data #'auxout' ^C
	.goto 36
.;
.; Kernel optimize and no shared library
.35B:	.iff optmz .goto 35C
	.inc mrgcnt
	.sets mrg'mrgcnt' "LB:FILSYS.OBJ,LB:LIB'cmode'.OBJ"
	.ift shrbld .goto 35BB
	.iff opt1st .inc mrgcnt
	.iff opt1st .sets mrg'mrgcnt' kopt
	.setf opt1st
	.data #'optout' RUN LB:MERGE
	.setn tmpout optout			.; output file to dump to
	.sets outstr tmp2+",,"+kopt		.; merge output string
	.gosub dmpmrg
	.goto 35BBB
.;
.35BB:	.data #'optout' RUN LB:MERGE
	.setn tmpout optout
	.sets outstr tmp2+",,"+tmp2
	.gosub dmpmrg
	.data #'optout' RUN LB:MERGE
	.sets a ""
	.iff opt1st .sets a ","+kopt
	.setf opt1st
	.data #'optout' ,,'kopt'='tmp2'.AUX'a'
	.data #'optout' ^C
	.data #'optout' DEL/NOQUERY 'tmp2'.AUX
.;
.35BBB:	.data RUN LB:MERGE
	.data 'tmp2'='tmp2'.MOB'addstr','appfil'.STB
	.data ^C	
	.goto 36
.;
.; no shared library and no kernel optimize
.35C:	.data RUN LB:MERGE
	.inc mrgcnt
	.sets mrg'mrgcnt' "LB:FILSYS.OBJ,LB:LIB'cmode'.OBJ,'appfil'.STB"
	.setn tmpout 0			.; use output file
	.sets outstr tmp2
	.gosub dmpmrg
.;
.36:	.sets relx ""			.; no reloc switch
	.ift mapped .and .ift rom .sets relx "/X"
	.ift mapped .and .ift drvpro .sets relx "/O:40000/R:60000"
	.ift $id .and .iff drvpro .sets relx relx+"/I"
	.ift $id .and .ift drvpro ;
	.ift $id .and .ift drvpro ;?MPBLD-W-/ID ignored with driver
	.sets symfil ""			.; no process symbol table file
	.ift debug .sets symfil ","+tmp2+".PST"
	.sets mapstr ""			.; no reloc map
	.ift debug .sets mapstr ","
	.ift $map .sets mapstr ","+$dev+$name
	.sets tmp3 ""		.; application input mim file
	.iff mapped .sets tmp3 ","+appfil
	.data #'auxout' RUN LB:RELOC
	.data #'auxout' 'tmp2''mapstr''symfil'='tmp2''tmp3''addstr''relx'
	.data #'auxout' ^C
	.data #'auxout' RUN LB:MIB
	.ift debug .data #'auxout' 'appfil',,'appfil'='tmp2','appfil''symfil'/S
	.iff debug .data #'auxout' 'appfil'='tmp2','appfil'/S
	.data #'auxout' ^C
	.ift debug .data #'auxout' DEL/NOQUERY 'tmp2'.PST
	.data #'auxout' DEL/NOQUERY 'tmp2'.(MOB,PIM)
	.setn tmpout optout
	.gosub dmpdel		.; dump delete of merge's
	.ift optmz .and .ift useshr .data #'optout' DEL/NOQUERY 'tmp2'.AUX
	.ift optmz .or .ift useshr .data #'optout' !
	.data #'auxout' !
	.goto 30
.;
.intmrg:
	.setn mrgcnt 0
	.setn delcnt 0
	.return
.;
.;
.admrg:
	.ift $obj .or .ift $lbr .goto ad1
	.inc mrgcnt
	.sets mrg'mrgcnt' "TMP:"+$name+".OBJ"+addstr
	.inc delcnt
	.sets del'delcnt' "TMP:"+$name+".OBJ"
	.return
.;
.ad1:	.inc mrgcnt
	.sets mrg'mrgcnt' $dev+$name+$ext+addstr
	.return
.;
.;
.dmpmrg:
	.setn cnt 1
	.setn dmtmc mrgcnt
	.sets tmp3 "mrg"+"'cnt'"
	.sets tmp3 'tmp3'
	.data #'tmpout' 'outstr'='tmp3'//
	.goto d6
.d3:
	.inc cnt
	.sets tmp3 "mrg"+"'cnt'"
	.sets tmp3 'tmp3'
	.data #'tmpout' 'tmp3'
.d6:	.dec dmtmc
	.if dmtmc ne 0 .goto d3
	.data #'tmpout' //
	.data #'tmpout' ^C
	.return
.;
.;
.dmpdel:
	.if delcnt eq 0 .return
	.sets tmp1 "del"+"'delcnt'"
	.sets tmp1 'tmp1'
	.data #'tmpout' DEL/NOQUERY 'tmp1'
	.dec delcnt
	.goto dmpdel
.;
.;	Install bootstrap
.;
.50:
	.ift debug .or .ift rom .goto done
	.sett $deflt
	.sets $dfans "YES"
	.sets $ques "Include bootstrap [yes] ?"
	.setn $hlp 33
	.gosub askl
	.iff $ans .goto done
	.setf $deflt
	.sets $ques "Bootstrap device {DD,DY,DL,DU} ?"
	.setn $hlp 34
	.gosub asks
	.setn n 0
	.if $anstr ne "DD" .and .if $anstr ne "DY" .inc n
	.if $anstr ne "DL" .and .if $anstr ne "DU" .inc n
	.if n ne 2 .goto 52
	;
	;?MPBLD-W-Invalid boot device; Enter DD,DY,DL, or DU
	.goto 50
.52:	.sets boot $anstr
	.data #'auxout' ! Install bootstrap
	.data #'auxout' !
	.data #'auxout' RUN LB:MIB
	.data #'auxout' 'appfil'=,'appfil'/S/B
	.sets addstr "U"
	.ift mapped .sets addstr "M"
	.data #'auxout' LB:'boot'BOT'addstr'
	.data #'auxout' ^C
	.data #'auxout' !
.done:	.iff shrbld .goto 100
.;
.; complete shared library build
.;
	.if auxcnt eq 0 .goto noref
	.data #'auxout' DEL/NOQUERY TMP:SHRLIB.STB
	.iff optmz .data ! Build and install shared library
	.ift optmz .data ! Install shared library
	.data !
	.ift optmz .goto 655A	.; if optimizing kernel and shared build
	.data RUN LB:MERGE
	.setn cnt 1
	.setn savcnt auxcnt
	.sets tmp3 "AUX"+"'cnt'"
	.sets tmp3 'tmp3'
	.data ,,TMP:SHRLIB='tmp3'//
	.goto 677
.666:
	.sets tmp3 "AUX"+"'cnt'"
	.sets tmp3 'tmp3'
	.data 'tmp3'
.677:	.inc cnt
	.dec auxcnt
	.if auxcnt ne 0 .goto 666
	.data //
	.data ^C
.;
	.setn cnt 1
.655:
	.sets tmp3 "AUX"+"'cnt'"
	.sets tmp3 'tmp3'
	.data #'optout' DEL/NOQUERY 'tmp3'
	.inc cnt
	.dec savcnt
	.if savcnt ne 0 .goto 655
.;
.; Combine share library aux file with command file
.;
.655A:	.close #'auxout'
	.openr #'auxout' DK:MPBLD1.TMP
.93:
	.read #'auxout' inlin
	.ift <eof> .goto 95
	.data 'inlin'
	.goto 93
.95:	.close #'auxout'
.;
.100:	.close 
	.iff optmz .goto 100A
	.ift opt1st ;
	.ift opt1st ;MPBLD-W-Invalid optimized kernel build
	.iff shrbld .goto 100C
.;
.; shared build and kernel optimization
.;
	.openr #'auxopt' DK:MPBLD2.TMP
.100B:
	.read #'auxopt' inlin
	.ift <eof> .goto 100D
	.data #'optout' 'inlin'
	.goto 100B
.100D:	.close #'auxopt'
.;
.; kernel optimazation cleanup (Append command file to optout)
.;
.100C:	.openr 'comfil'
.100E:
	.read inlin
	.ift <eof> .goto 100F
	.data #'optout' 'inlin'
	.goto 100E
.;
.100F:	.close
	.close #'optout'
	$DELETE 'comfil'
	$COPY DK:MPBLD.TMP 'comfil'
	$DELETE DK:MPBLD.TMP
.100A:
	.ift shrbld $DELETE DK:MPBLD1.TMP
	.ift shrbld .and .ift optmz $DELETE DK:MPBLD2.TMP
	;
	;?MPBLD-I-Command procedure generated - 'comfil'
	.exit
.noref:	;
	;?MPBLD-F-Invalid shared library build
	.exit
.;**********************************************************
.;	Edit a file 
.;**********************************************************
.editfl:
	.setf libdev
	.sets t1 ""
	.if $dev eq "LB:" .sett libdev
	.ift libdev .sets t1 "/OUTPUT:DK:"+$name+$ext
	.sett $deflt		.; allow default answer
	.sets $dfans "NO"	.; default answer
	.sets $ques "Do you wish to modify "+$dev+$name+$ext+" [no] ?"
	.gosub askl
	.iff $ans .goto edit2
.edit1:
	$EDIT't1' '$dev''$name''$ext'
	.sett $deflt
	.sets $dfans "YES"
	.sets $ques "Satisfied with edit [yes] ?"
	.setn $hlp 35
	.gosub askl
	.iff $ans .goto edit1
	.ift libdev .testfile DK:'$name''$ext'
	.ift libdev .and .if <filerr> ne <succes> .goto edit2
	.ift libdev .sets $dev "DK:"
.edit2:	.return
.;**********************************************************
.; Read in an octal number
.;**********************************************************
.ncvrt:
	.gosub asks
	.onerr baddr
	.test $anstr
	.if <strlen> eq 0 .goto baddr
	.test $anstr "9"
	.if <strlen> ne 0 .goto baddr
	.test $anstr "8"
	.if <strlen> ne 0 .goto baddr
	.enable octal
	.setn rtnum '$anstr'
	.disable octal
	.onerr
	.return

.baddr:	;
	;?MPBLD-W-Invalid 'adtyp' address
	.onerr
	.goto ncvrt
.;**********************************************************
.; Ask a Yes/No (True/False) question
.;
.; Inputs:
.;	$ldiag	= Boolean Long dialog is selected
.;	$deflt	= Boolean Allow a default answer
.;	$dfans	= Default answer string
.;	$ques	= Question string
.;	$hlp	= numeric help text #
.;
.; Outputs:
.;	$ans	= user's answer (BOOLEAN)
.;
.; If user type ? as an answer, the help text is printed.
.; If long dialog is selected, the help text is printed before
.; asking the question.
.; If the user does not respond Yes or no, the question
.; is asked again
.;**********************************************************

.askl:
	.setf $help
.askl1:
	.ift $help .or .ift $ldiag .gosub help
	;
	.disable lowercase
	.ift $deflt .asks [::$dfans] str '$ques'
	.iff $deflt .asks str '$ques'
	.enable lowercase
	.parse str " " str jnk
	.if str eq "" .sets str jnk
	.sets str1 str[1:1]   .; get first character
	.setn n 0
	.if str1 eq "?" .sett $help
	.if str1 ne "?" .inc n
	.if str1 eq "Y" .sett $ans
	.if str1 ne "Y" .inc n
	.if str1 eq "N" .setf $ans
	.if str1 ne "N" .inc n
	.if n eq 3 .goto askl2
	.ift $help .goto askl1
	.return
.askl2:	;
	;?MPBLD-W-Invalid reply; Please respond Yes or No
	.goto askl1
.;**********************************************************
.; Ask a string question
.;
.; Inputs:
.;	$ldiag	= Boolean Long dialog is selected
.;	$deflt	= Boolean Allow a default answer
.;	$dfans	= Default answer string
.;	$ques	= Question string
.;	$hlp	= numeric help text #
.;
.; Outputs:
.;	$anstr	= user's answer string
.;
.; If user type ? as an answer, the help text is printed.
.; If long dialog is selected, the help text is printed before
.; asking the question.
.; Leading spaces on user's answer are stripped
.;**********************************************************

.asks:
	.setf $help
.asks1:
	.ift $help .or .ift $ldiag .gosub help
	;
	.disable lowercase
	.ift $deflt .asks [::$dfans] str '$ques'
	.iff $deflt .asks str '$ques'
	.enable lowercase
	.parse str " " str jnk
	.if str eq "" .sets str jnk
	.if str eq "?" .sett $help
	.ift $help .goto asks1
	.sets $anstr str
	.return
.;**********************************************************
.;      File Spec parser
.;
.; Inputs:	$infil  string of filename
.;		$deflt	True if a default is allowed
.;		$dfans	Default answer
.;		sw$obj	allow /OBJ
.;		sw$lst	/LIST
.;		sw$mac	/MAC
.;		sw$map	/MAP
.;		sw$lbr	/LIBR
.;		sw$id	/ID (I & D)
.; Outputs :	$dev	device specification
.;		$name	name portion
.;		$ext	extension
.;		$obj	True if /OBJ switch
.;		$lis	True if /LIST switch
.;		$lbr	True if /LIBR
.;		$mac    True if /MAC switch
.;		$err	True if an error in parsing
.;		$id     True if /ID switch (not cleared on entry)
.;		$map    True if /MAP switch (not cleared on entry)
.;
.;**********************************************************

.prsfil:
	.setf $obj
	.setf $lis
	.setf $mac
	.setf $lbr
	.setf $err
	.parse $infil "/" xxfile swtch1
	.iff $deflt .goto p0
	.parse $dfans ":" dfdev dfnam
	.if xxfile eq "" .sets xxfile $dfans

.p0:	.parse xxfile ":" $dev $name 
	.; *'xxfile'*  *'$dev'*   *'$name'*
	.test xxfile ":"
	.; '<strlen>'
	.;dump
	.if <strlen> eq 0 .sets $dev "DK"
	.if <strlen> ne 0 .and .if $name eq "" .and .ift $deflt .sets $name dfnam
	.test $dev
	.iff <rad50> .goto badchr
	.if <strlen> gt 3 .goto baddev
	.sets $dev $dev+":"
	.if $name eq "" .sets $name xxfile
	.parse $name "." $name $ext
	.test $name
	.iff <rad50> .goto badchr
	.if <strlen> gt 6 .or .if <strlen> lt 1 .goto badnam
	.test $ext
	.iff <rad50> .goto badchr
	.if <strlen> gt 3 .goto badext
	.if $ext ne "" .sets $ext "."+$ext
	.if $ext eq ".OBJ" .sett $obj
	.if $ext eq ".MAC" .sett $mac
	.if $ext eq ".OLB" .sett $lbr
.p2:
	.if swtch1 eq "" .goto p4
	.parse swtch1  "/" swtch1 swtch2
	.setn check 0
	.sets swtch "/"+swtch1
.;
	.test swtch "/O"	.; /O [ BJECT ]
	.if <strlen> ne 0 .and .ift sw$obj .sett $obj
	.if <strlen> eq 0 .or .iff sw$obj .inc check
.;
	.test swtch "/LIS"	.; /LIS [ TING ]
	.if <strlen> ne 0 .and .ift sw$lst .sett $lis
	.if <strlen> eq 0 .or .iff sw$lst .inc check
.;
	.test swtch "/MAP"	.; /MAP
	.if <strlen> ne 0 .and .ift sw$map .sett $map
	.if <strlen> eq 0 .or .iff sw$map .inc check
.;
	.test swtch "/MAC"	.; /MAC [ RO ]
	.if <strlen> ne 0 .and .ift sw$mac .sett $mac
	.if <strlen> eq 0 .or .iff sw$mac .inc check
.;
	.test swtch "/LIB"	.; /LIB [ RARY ]
	.if <strlen> ne 0 .and .ift sw$lbr .sett $lbr
	.if <strlen> eq 0 .or .iff sw$lbr .inc check
.;
	.test swtch "/LB"	.; /LB [ R ]
	.if <strlen> ne 0 .and .ift sw$lbr .sett $lbr
	.if <strlen> eq 0 .or .iff sw$lbr .inc check
.;
	.test swtch "/ID"	.; /ID [ SPACE ]
	.if <strlen> ne 0 .and .ift sw$id .sett $id
	.if <strlen> eq 0 .or .iff sw$id .inc check
.;
	.if check eq 7 .goto p3
	.sets swtch1 swtch2
	.goto p2
.;
.p3:	.sets errs "Invalid switch - "+swtch
	.goto p5
.;
.p4:	.ift $obj .and .ift $lis .goto p7
	.ift $obj .and .ift $lbr .goto p7
	.ift $obj .and .ift $mac .goto p7
	.ift $lbr .and .ift $mac .goto p7
	.ift $lbr .and .ift $lis .goto p7
	.return
.;
.badnam:.sets errs "Invalid file name"
	.goto p5
.baddev:.sets errs "Invalid device spec"
	.goto p5
.badext:.sets errs "Invalid extension"
	.goto p5
.badchr:.sets errs "Invalid character in "+$infil
	.goto p5
.p7:	.sets errs "Conflicting switches"
.p5:	;
	;?MPBLD-W-'errs'
	.sett $err
	.return
.;**********************************************************
.;**********************************************************
.help:
	.setf $help
	.sets hlplab "HLP"+"'$hlp'"
	;
	.if $hlp gt 17 .goto help1
	.goto 'hlplab'
.HLP1:	.;
;     Answer yes to  get  an  explanation  displayed  before  each
;     question   in   the   dialog.  Alternatively,  you  can  get
;     explanations of selected questions by responding with ? to a
;     given question.
	.return
.HLP2:	.;
;     Indicate whether you want to create a new kernel image  file
;     (yes),  or  want  to begin the build cycle with an existing,
;     previously created kernel/driver or application image  (no).
;     A  no  response implies that a new application image will be
;     built, based on an  existing  kernel  or  application  image
;     file.  (If  the  existing input file contains an application
;     image, this allows you to add to existing processes.)
	.return
.HLP3:	.;
;     Specify a file name for  the  new  kernel  .MIM  file.  Your
;     response  names  the  new kernel/driver image, symbol (.STB)
;     and debug (.DBG) files to be created in the build cycle.  Do
;     not  specify a file type; directory or device information is
;     optional. (You will be asked for the name of the application
;     MIM file in a later question.)
	.return
.HLP4:	.;
;     Specify  the  system  configuration  file  to  be  used  for
;     building the kernel image; for example,  LB:CFDMAP.MAC.  The
;     default file type is MAC; that is, source input is expected.   
;     Use  the  /OBJ  option, if appropriate, to indicate that the
;     input is an object file.  Use the /MAP option to  produce  a
;     relocation  map  of  the  kernel  (useful  for MACRO process
;     debugging).
	.return
.HLP5:	.;
;     Indicate whether you want to edit the config file.   If  you
;     answer  yes,  you will automatically enter the editor with a
;     copy of the file as input.  When you exit the editor, unless
;     the input file is from LB:, output of the editing session is
;     placed on the same device as the input file.   If  input  is
;     from LB:, the output file will be placed on DK:, the default
;     device.  If you answer no, the config file is used as is.
	.return
.HLP6:	.;
;     Indicate whether you want to create the  kernel  image  file
;     only,  or  want  to  create  the application image file also
;     (complete build cycle). If an  application  image  is  being
;     built,  the  kernel/driver  image  will  be  copied from the
;     kernel MIM file to the application MIM file before the  user
;     processes and shared library, if any, are installed.
	.return
.HLP8:	.;
;     Specify a file name for the application  .MIM  output  file.
;     (The  name  applies to the application .DBG file, if any, as
;     well.) Do not specify  a  file  type;  directory  or  device
;     information  is  optional. On completion of the build cycle,
;     the application MIM file will contain a copy of  the  kernel
;     MIM  file contents plus the processes and shared library, if
;     any, installed in the user-process build phase.
	.return
.HLP9:	.;
;     Supply  a  specification  for  the  ''intermediate''   command
;     procedure  (.COM)  file that  MPBLD  will generate to invoke
;     and control the  actual  build cycle.  Following  the  MPBLD
;     dialog  you  can  execute  the  generated  command  file  to
;     initiate the build cycle.
	.return
.HLP10:	.;
;     Indicate whether the kernel and/or application images are to
;     be built in mapped or unmapped form.  A yes response implies
;     that  the  target-system   configuration   includes   memory
;     management  (mapping) hardware, e.g., the KT-11 option on an
;     LSI-11/23  processor.    The   response   must   match   the
;     specification for the MMU=YES/NO  parameter of the PROCESSOR
;     macro in the system configuration file.
	.RETURN
.HLP11:	.;
;     Indicate  if  the  kernel  and/or application is to be built
;     with PASDBG symbolic debugging support.  If your response is
;     no, no debug-symbol (.DBG) files are created or used in  the
;     build cycle.  Your response must match the specification for
;     the DEBUG=YES/NO parameter in the SYSTEM configuration macro,
;     which determines whether  the  Debug Service Module (DSM) is
;     included in the kernel.
	.RETURN
.HLP12:	.;
;     Indicate whether the kernel  and/or  application  is  to  be
;     built for a ROM target environment or for a RAM-only target.
;     Your   response   must   agree   with   the    target-memory
;     configuration   described   in  the  MEMORY  macros  of  the
;     configuration file used to build the kernel.   The  response
;     is used to determine certain build-utility command options.
	.RETURN
.HLP13:	.;
;     Specify the base  address  of  the  first  (low  order)  RAM
;     segment in the target memory configuration.  This value will
;     be used to relocate the  kernel's  initial  read/write  data
;     section at the proper physical address.
	.RETURN
.HLP14:	.;
;     Specify the instruction-set option to be used for  compiling
;     any  PASCAL  user program. Your response determines the type
;     of OTS library used to merge a PASCAL process,  in  addition
;     to supplying the compilation option.
	.RETURN
.HLP15:	.;
;     Indicate whether the /I:LS2 option is to be used  for PASCAL
;     compilations.  Answer yes only if the target is an LSI-11 or
;     LSI-11/2.
	.RETURN
.HLP16:	.;
;     Specify a prefix module file for a  DIGITAL-supplied  system
;     process (e.g., a device driver) to be built and installed in
;     the  kernel  MIM  file.  The  system-process  prefix  files,
;     supplied in LB, include:
;
;       ACPPFX.MAC - Ancillary Control Process
;       DDPFX.MAC  - TU58       
;       DLPFX.MAC  - RL01/RL02
;       DUPFX.MAC  - MSCP-class disk
;       DYPFX.MAC  - RX02
;       KKPFX.MAC  - Interface to Q-Bus arbiter
;       KXPFX.MAC  - KXT11-C slave interface
;       NSPPFX.MAC - Network Services Process
;       QNPFX.MAC  - DEQNA Ethernet Driver
;       TTPFX.MAC  - Terminal Driver (debug)
;       YFPFX.MAC  - FALCON PIO port
;
;     A source file (MAC) is  assumed  unless  you  use  the  /OBJ
;     option  to indicate that the input is an object file. A null
;     response - <CR> only  -  signifies  'no  more  drivers'  and
;     terminates the prefix-file question loop.
	.RETURN
.HELP1:
	.goto 'hlplab'
.HLP17:	.;
;     Indicate whether you want to edit the prefix file.   If  you
;     answer  yes,  you will automatically enter the editor with a
;     copy of the file as input.  When you exit the editor, unless
;     the input file is from LB:, output of the editing session is
;     placed on the same device as the input file.   If  input  is
;     from LB:, the output file will be placed on DK:, the default
;     device.  If you answer no, the prefix file is used as is.
	.RETURN
.HLP18:	.;
;     Indicate whether a shared library  containing  the  required
;     PASCAL OTS modules and optionally any user specified modules
;     should be included in the application build.
	.RETURN
.HLP19:	.;
;     Indicate  whether  the  shared  library  should  execute  in
;     supervisor  mode  or user mode. Supervisor mode is available
;     only on J-11 based processors.
	.RETURN
.HLP20:	.;
;     Specify a module or  library  to  be  added  to  the  shared
;     library;  a  PASCAL source module is assumed (.PAS default).
;     /MAC may  be appended for a macro source module, /OBJ for an
;     object  module,  /LIB  for an object library file, and /LIST
;     and /MAP are valid where applicable.
	.RETURN
.HLP24:	.;
;     Supply a specification for  a  user-written  static  process
;     file  (PASCAL  program or MACRO module containing the DFSPC$
;     macro). The default file type is .PAS  unless  the  /MAC  or
;     /OBJ  option  is used. The /IDS option may be used with J-11
;     based  targets  to  obtain  Instruction   and   Data   space
;     separation in the static process. The /LIST and /MAP options
;     are applicable; /LIST produces  a  compilation  or  assembly
;     listing  (.LST)  file  and  /MAP  produces  a relocation map
;     (.MAP) file for the process. A null response - <CR>  only  -
;     signifies  'no more processes,' terminating the user process
;     question loop.
	.RETURN
.HLP25:	.;
;     Here you  may  specify  an  additional  source,  object,  or
;     library  module  to  be merged with the static process file.
;     The default file type is .PAS unless the /MAC, /OBJ, or /LIB
;     option  is  used.  The  /LIST option may be used on a source
;     file to produce a compilation  or  assembly  listing  (.LST)
;     file.   A   null   response   signifies  "no  more  inputs",
;     terminating the single-question loop.
	.RETURN
.HLP27:	.;
;     Indicate whether the process needs to be built  with  driver
;     mapping.  This is necessary for any process that establishes
;     an interrupt service  routine  (CONNECT_INTERRUPT  or  CINT$
;     primitive)  in  a mapped environment. A yes response implies
;     that the DRIVER  attribute  was  specified  in  the  PROGRAM
;     heading or PT$DRV was specified in the DFSPC$ macro.
	.RETURN
.HLP28:	.;
;     Indicate whether this user process is to be built  with  the
;     shared library.
	.RETURN
.HLP33:	.;
;     Indicate whether you  want  a  bootstrap  installed  in  the
;     application MIM file.  Request a bootstrap only if the image
;     is to be loaded from a target-system boot device.
	.RETURN
.HLP34:	.;
;     Specify the  type  of  device  that  will  be  employed  for
;     booting.
	.RETURN
.HLP35:	.;
;     Here you have the option of repeating the  editing  session.
;     (The  question  is  asked in case you terminated the initial
;     editing session with a QUIT command.) If you answer yes, the
;     dialog continues.  If you answer no, you will be returned to
;     the editor with the original file as input.
	.return
.HLP40:	.;
;     Indicate whether or not the kernel should  be  automatically
;     optimized  to  include  only  the  primitives  used  by  the
;     application. If optimize is selected, the CONFIGURATION file
;     SYSTEM   macro   should  specify  OPTIMIZE  =  YES  and  the
;     PRIMITIVES macro should not be used.
	.return
.HLP50:	.;
;     Specify the base  address  of  the  first  (low  order)  ROM
;     segment  in the target memory configuration. This value will
;     be used to relocate  the  kernel's  initial  read-only  code
;     section  at  the proper physical address. Zero is the proper
;     value for most target configurations (exception: CMR21).
.HLP51:	.;
;     Specify a file name for the existing kernel  or  application
;     .MIM  file.  Your  response  names the existing input image,
;     symbol (.STB) and debug (.DBG) files to be used in  building
;     the  new  application  image.  Do  not  specify a file type;
;     directory or device information is optional.  (You  will  be
;     asked  for  the name of the output application MIM file in a
;     later question.)

	.return
                                                                                                                                                                                                                                                                                                                                                                                                                            