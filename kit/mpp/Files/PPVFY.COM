.;
.; This software is furnished under a license and may be used or copied
.; only in accordance with the terms of such license.
.;
.; Copyright (c) 1984, 1986 by Digital Equipment Corporation.
.; All rights reserved.
.;
.; Module name: PPVFY.COM
.;
.; Author -- RW  Creation date: 28-NOV-83
.;
.; Modified
.;   ERS 7-Feb-85  Update for V2.0
.;
	.enable quiet
	.enable substitution
.;
.; If P1 is "VERIFY" then just do it...
.;
	.sett pp$int
	.sets ans "VERIFY"
	.if P1 = ans .setf pp$int
.;
.; Now start asking questions
.;
.q$1:	.ask pp$lhe 1. Do you want the long form of the dialogue
	.iff pp$lhe .goto q$2
;
; This procedure will create the arbiter and KXT11-C programs that
; compose the Peripheral Processor application example and verification
; system.  It will optionally load the programs with PASDBG.  Command
; files are generated that will facilitate operation of these programs
; and other peripheral applications.  You may then execute these command
; procedures at a later time.  Default answers to questions are indicated
; by parenthesis.
;
.;
.; Check if the .mim files are already there, and if so ask
.; if he just wants to load them.
.;
.q$2:	.setf pp$lon
	.testfile arbvfy.mim
	.if <filerr> <> <succes> .goto q$3
	.testfile arbvfy.dbg
	.if <filerr> <> <succes> .goto q$3
	.testfile iopvfy.mim
	.if <filerr> <> <succes> .goto q$3
	.testfile iopvfy.dbg
	.if <filerr> <> <succes> .goto q$3
	.iff pp$lhe .goto q$2a
;
; The Peripheral Processor application programs already exist.
; Do you simply want to load and run them, or do you want
; to recreate them?
;
.q$2a:	.ask pp$lon 2. Do you just want to load and run the programs
.;
.q$3:	.iff pp$lhe .goto q$3a
;
; This procedure will leave several files in your directory if you
; so desire, or will delete them after they have been used.  These
; files are:
;
;   ARB.COM	-- Sets the PASDBG port to the arbiter line.
;   IOP.COM	-- Sets the PASDBG port to the KXT11-C line.
;
.q$3a:	.ask pp$kee 3. Do you want to keep the files
	.ift pp$lon .goto q$5
.;
.q$4:	.iff pp$lhe .goto q$4a
;
; The building of the verification programs will take several minutes.
; You may want to build them now, and load and run them at some other
; time.  Or there may be some other reason (for exampl, the need to
; configure the hardware lines to the target system) why you may not
; wish to load and run the programs now.  If you answer Y to this
; question the programs will be built, loaded, and run.  If you answer
; N (the default) the programs will only be built.
;
.q$4a:	.ask pp$loa 4. Do you want to load and run the programs
	.iff pp$loa .goto q$7
.;
.q$5:	.sett pp$loa
	.testfile arb.com
	.if <filerr> <> <succes> .goto q$5b
	.testfile iop.com
	.if <filerr> <> <succes> .goto q$5b
	.goto q$6e
.q$5b:	.iff pp$lhe .goto q$5a
;
; This procedure needs to know the terminal ports connected to
; the arbiter and KXT11-C lines.  Each of these lines are specified
; by CSR and VECTOR address.  These values are not checked for
; correctness, so be careful when entering them.
;
.q$5a:	.testfile arb.com
	.if <filerr> = <succes> .goto q$6a
	.asks [6:6:"176520"] pp$arc 5. Enter the arbiter port CSR address
	.asks [3:3:"320"] pp$arv 5a. Enter the arbiter port VECTOR address
	.open arb.com
	.data ! ARB.COM -- Sets the td driver to the arbiter line
	.data !
	.data UNLOAD TD
	.data REMOVE TD
	.data SET TD CSR 'pp$arc'
	.data SET TD VECTOR 'pp$arv'
	.data INSTALL TD
	.data LOAD TD
	.close
.;
.q$6a:	.testfile iop.com
	.if <filerr> = <succes> .goto q$6e
	.asks [6:6:"176500"] pp$ioc 6. Enter the KXT11-C port CSR address
	.asks [3:3:"300"] pp$iov 6a. Enter the KXT11-C port VECTOR address
	.open iop.com
	.data ! IOP.COM -- Sets the td driver to the KXT11-C line
	.data !
	.data UNLOAD TD
	.data REMOVE TD
	.data SET TD CSR 'pp$ioc'
	.data SET TD VECTOR 'pp$iov'
	.data INSTALL TD
	.data LOAD TD
	.close
.;
.q$6e:	.ift pp$lon .goto q$9
.;
.q$7:	.iff pp$int .goto q$7a
;
; The arbiter application will now be built
;
.q$7a:	$SET TT QUIET
	$@LB:ARBVFY
	$SET TT NOQUIET
	$DELETE/NOQ ARBKRN.*
.;
.q$8:	.iff pp$int .goto q$8a
;
; The KXT11-C application will now be built
;
.q$8a:	$SET TT QUIET
	$@LB:IOPVFY
	$SET TT NOQUIET
	$DELETE/NOQ IOPKRN.*
	.iff pp$int .stop
	.iff pp$loa .stop
.;
.q$9:	.iff pp$lhe .goto q$9a
;
; The programs will now be loaded into the targets and run.
; Any errors that occur here mean that there is some problem
; in the configuration of your hardware, or perhaps miskeying
; of the terminal ports above.  Should this step fail refer to
; your documentation for help.
;
.q$9a:
;
; The KXT11-C will now be loaded
;
	$SET TT QUIET
	$@IOP
	$SET TT NOQUIET
	.open ioplod.com
	.data run lb:pasdbg
	.data load iopvfy
	.data go/exit
	.data ^C
	.close
	$@ioplod
	delete/noq ioplod.com
	.iff pp$kee delete/noq iop.com
;
; The Arbiter will now be loaded
;
	$SET TT QUIET
	$@ARB
	$SET TT NOQUIET
	.open arblod.com
	.data run lb:pasdbg
	.data load arbvfy
	.data go/exit
	.data ^C
	.close
	$@arblod
	delete/noq arblod.com
	.iff pp$kee delete/noq arb.com
;
; The Peripheral Processor application should now be running
;
	.stop
                                                                                                                                                                                                                                                                                                                                                                