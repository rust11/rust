!	DRS:CHECK.COM -- Check SET operations
!
!	Driver build files apply SET operations to record
!	default settings in the DRIVER log block.
!
!	This command file is used to ensure that the driver
!	binary is the same before and after the SET operations.
!	The usual protocol is as follows, for driver has:xxx.sys
!
!	macro/link etc		! build driver
!	@drs:check 1 xxx	! check step 1
!	driver set xxx ...	! apply SET items
!	@drs:check 2 xxx	! check step 2
!
!	CHECK copies the files to temps (check.1 and check.2)
!	check.2 is truncated to remove the DRIVER log block
!	The files are compared with DIFFER/BINARY
!
goto step'p1'
!
stepcapture:
step1:	copy drb:'p2'.sys sy:check.1
!	display "?CHECK-I-Checking 'P2'"
	goto end
!
stepcompare:
step2:	copy drb:'p2'.sys sy:check.2
	set file sy:check.2/trunc=1
	differ/binary/nolog sy:check.1 sy:check.2
	if/warning then goto error
	goto end
error:	display "?CHECK-E-Driver changed: 'P2'"
end:
