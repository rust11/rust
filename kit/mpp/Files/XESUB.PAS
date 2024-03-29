[system(micropower)] Module XE_routines;
{ XESUB.PAS

  THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED OR COPIED
  ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE.
 
  COPYRIGHT (c) 1984, 1986 BY DIGITAL EQUIPMENT CORPORATION.
 		ALL RIGHTS RESERVED.
}
%INCLUDE 'LB:IOPKTS'

CONST

{ THE FOLLOWING FUNCTION CODES ARE IMPLEMENTED: }

	IO$WTL = %O'4';			{ WRITE LOGICAL BLOCK }
	IO$WLE = %O'30';		{ WRITE WITH EOI ON LAST BYTE }
	IO$CMD = %O'31';		{ WRITE IEEE REMOTE MESSAGES }
	IO$RDL = %O'1';			{ READ LOGICAL BLOCK }
	IO$SPS = %O'32';		{ PERFORM SERIAL POLL WHILE SRQ IS SET }
	IO$SPO = %O'33';		{ PERFORM SERIAL POLL OVER ALL DEVICES }
	IO$PPO = %O'34';		{ ISSUE PARALLEL POLL }
	IO$LPP = %O'35';		{ LOAD PARALLEL POLL REGISTER }
	IO$PPC = %O'36';		{ PARALLEL POLL CONFIGURE }
	IO$AUX = %O'37';		{ ISSUE AUXILARY COMMAND }
	IO$RSV = %O'40';		{ REQUEST SERVICE }
	IO$STS = %O'6';			{ SET STATE }
	IO$STO = %O'41';		{ SET TIME OUT DURATION }
	IO$SNS = %O'7';			{ SENSE MODE }
	IO$GTC = %O'42';		{ GET CONTROL (GOTO CACS) }
	IO$GTS = %O'43';		{ GO TO STANDBY }
	IO$PCT = %O'44';		{ PASS CONTROL }
	IO$SEM = %O'45';		{ SET EVENT MASK }
	IO$REV = %O'46';		{ RECOGNIZE EVENT }
	IO$RES = %O'47';		{ RECOGNIZE EVENT POLL }

{ Subfunction Modifiers }

	TF$LIS = %O'10000';	{ LEAVE IN STATE }
				{ IF THE UNIT IS C-I-C, THE DRIVER
				  WILL SET THE UNIT TO THE STATE
				  REQUIRED TO PROCESS THE REQUEST.
				  IT WILL ALSO ADDRESS THE UNIT AS
				  LISTENER OR TALKER IF REQUIRED.
				  AFTER THE REQUEST THE DRIVER WILL
				  RESET THE UNIT TO THE ORIGINAL STATE.
				  IF THIS MODIFIER IS SPECIFIED, THE
				  UNIT WILL NOT BE RESET TO THE ORIGINAL
				  STATE. }

	TF$SRQ = %O'20000';	{ THIS MODIFIER IS APPLICABLE TO DATA
				  TRANSFER REQUESTS. IF SET THEN THE DATA 
				  TRANSFER WILL BE TERMINATED IF A SERVICE
				  REQUEST OCCURS. }

	TF$EAD = %O'20000';	{ THIS MODIFIER IS APPLICABLE TO SERIAL
				  POLL REQUESTS.  IT SPECIFIES THAT EXTENDED
				  ADDRESSING IS TO NE USED IN ADDRESSING
				  THE DEVICES AS TALKER IN THE SERIAL POLL. }
	TF$TCS = %O'40000';	{ TAKE CONTROL SYNCHRONOUSLY }

{ Software Flags in I.STS }

	F$NPIP = 1;		{ If set NPR request in progress }
	F$COIP = 2;		{ Command output in progress }
	F$DRLS = %O'10';		{ Driver ACDS holdoff release pending }
	F$URLS = %O'20';		{ User ACDS holdoff release pending }
	F$LON  = %O'40';		{ Set if LON was generated by IORLB }
	F$TON  = %O'100';		{ Set if TON was generated by IOWLB }
	F$WLE  = %O'200';		{ IO.WLE request in progress }
	F$REV  = %O'400';		{ IO.REV request in progress }
	F$IELO = %O'1000';		{ I.E lockout during fork processes }
	F$PPIP = %O'2000';		{ Parallel poll configure in progress }
	F$RPBC = %O'4000';		{ Return processed byte count by time-out }
	F$TADS = %O'10000';		{ Previously addressed as talker }
	F$MA   = %O'20000';		{ Set if MA interrupts occur between QIOs }
	F$EVP  = %O'40000';		{ Event recognization is pending }

{ Define flags used to signal controller state }

	C$CIDS = 1;		{ Controller idle state }
	C$CACS = 2;		{ Controller active state }
	C$CSBS = 3;		{ Controller standby state }

{ Define flags used with the IO.STS function }

	comm_mc = 1;		{ Master Clear }
	comm_ssr = 2;		{ Send Software Reset }
	comm_syc = 4;		{ Set System Controller Bit in CSR }
	comm_clr = %O'10';	{ Clear System Controller Bit }
	comm_cac = %O'20';	{ Set Controller to CACS }
	comm_spa = %O'40';	{ Set Primary Address }

 { Mask works used with IO.SEM function }

	E$SRQ =	%O'000001';	{ Event on service request }
	E$ADL = %O'000002';	{ Event when addressed as listener }
	E$ADT = %O'000004';	{ Event when addressed as talker }
	E$DAD = %O'000010';	{ Event when deaddressed }
	E$AEL = %O'000020';	{ Event when addressed as extended
					listener }
	E$AET = %O'000040';	{ Event when addressed as extended
					talker }
	E$DCL = %O'000100';	{ Event on device clear }
	E$DTG = %O'000200';	{ Event on device trigger }
	E$RLC = %O'000400';	{ Event on remote/local change }
	E$RCC = %O'001000';	{ Event on received control }
	E$PPC = %O'002000';	{ Event on parallel poll configure }
	E$PPU = %O'004000';	{ Event on parallel poll unconfigure }
	E$IFC = %O'010000';	{ Event on interface clear }

{Codes used in DP.STS]

	ES$SIO = %O'034000';	{ Soft I/O Error }
	ES$HIO = %O'030000';	{ Hard I/O Error }
	ES$NOR = %O'000000';	{ Normal Completion }

{Codes used in DP.ERR}

	IE_BAD = -2;		{ Bad Parameter }
	IE_BLA = -9;		{ Bad Listener Address }
	IE_BMC = -8;		{ Bad Match Character }
	IE_BTA = -7;		{ Bad Talker Address }
	IE_ERR = -4;		{ Error Interrupt }
	IE_FCL = -10;		{ Data Transfer Termination - IFC }
	IE_FUN = -1;		{ Invalid IEEE Function }
	IE_ICR = -6;		{ Invalid REV Function }
	IE_SRQ = -5;		{ Data Transfer Termination - SRQ }
	IE_STE = -3;		{ Controller State Error }
	IE_SUC = 1;		{ Successful Completion }

TYPE
  ieq_address = PACKED RECORD
	     prim_addr,
	     sec_addr : [BYTE] BYTE_RANGE;
	   END;

  ser_poll_buf = PACKED RECORD
	     addr : ieq_address;
	     status : INTEGER;
	   END;
  pp_buffer = packed record
		l_addrs : [byte] byte_range;
		cfg_byte : [byte] byte_range;
	      end;
  funct_code = 0..%O'7777';
  subfunct_bits = 0..15;
  config_word = PACKED RECORD
		  l_addr : [BYTE] byte_range;
		  c_byte : [BYTE] byte_range;
		END;
  io_req =  PACKED RECORD
	     oper : INTEGER; { operation  }
	     unit_num,                { unit number   }
	     filler_1 : BYTE_RANGE;         { reserved      }
	     sequence : INTEGER;      { user specified sequence number}
	     pid, reply_sem : STRUCTURE_ID;
	     CASE funct_code OF
		  IO$WTL,
		  IO$WLE,
		  IO$CMD,
		  IO$SPO,
		  IO$SNS,
		  IO$GTC,
		  IO$GTS,
		  IO$REV,
		  IO$RES :
			(filler1, filler2 : INTEGER);
		  IO$PPO :
			(p_stat, filler3 : INTEGER);
		  IO$PPC :
			 (par_buff : PACKED ARRAY[1..8] of pp_buffer);
		  IO$RDL :
			(match_char : char;
			 filler : BYTE_RANGE;
			 match_length : INTEGER);
		  IO$AUX :
			(aux_command, fill_aux : INTEGER);
		  IO$RSV :
			(stat_byte, fill_rsv1 : BYTE_RANGE;
			 fill_rsv2 : INTEGER);
		  IO$STS :
			(cmd_mask, fill_sts : BYTE_RANGE;
			 primary_addr : INTEGER);
		  IO$PCT :
			(talk_addr, fill_pct : INTEGER);
		  IO$SEM :
			(event_mask, fill_sem : INTEGER);
	   END;

  io_reply = PACKED RECORD
	     oper : INTEGER; { operation  }
	     unit_num,                { unit number   }
	     filler_1 : [byte] BYTE_RANGE;         { reserved      }
	     sequence : INTEGER;      { user specified sequence number}
	     status,
	     act_length,
	     err_code : INTEGER;
	     reserved : ARRAY [1..3] OF INTEGER;
	     fun_dep_dat : ARRAY [1..8] OF INTEGER;
	   END;

  bit_on = 0..7;
  sec_val = 0..31;

  con_word = PACKED RECORD
	con_sts  : [POS(0), BIT(8)] byte_range;
	con_addr : [POS(8), BIT(3)] bit_on;
	sec_fun  : [POS(11), BIT(5)] sec_val;
      END;

[Global($xeset)]
 FUNCTION set_state(comm, unit : INTEGER;
	  VAR unit_desc : STRUCTURE_DESC;
	  address : INTEGER): BOOLEAN;

VAR
  reply : STRUCTURE_ID;
  io_request : io_req;

BEGIN
  reply.index := 0;
  WITH io_request DO
    BEGIN
	oper := IO$STS;
	reply_sem := reply;
	cmd_mask := comm;
	fill_sts := 0;
	primary_addr := address;
	unit_num := unit;
    END;
    SEND(PRIORITY := 20,
	 VAL_DATA := io_request,
	 VAL_LENGTH := 34,
	 DESC := unit_desc);
   set_state := TRUE;
END;

[Global($xemsk)]
PROCEDURE set_int_mask(unit : INTEGER;
	VAR unit_desc : STRUCTURE_DESC;
	mask : INTEGER);

VAR
  reply : STRUCTURE_ID;
  io_request : io_req;

BEGIN
  reply.index := 0;
  WITH io_request DO
    BEGIN
	oper := IO$SEM;
	reply_sem := reply;
	event_mask := mask;
	unit_num := unit;
    END;
    SEND(PRIORITY := 20,
	 VAL_DATA := io_request,
	 VAL_LENGTH := 34,
	 DESC := unit_desc);
END;

[Global($xewrt)]
PROCEDURE write_ieq(unit : INTEGER;
		VAR unit_desc : STRUCTURE_DESC;
		VAR buffer : PACKED ARRAY[first..last: INTEGER] OF CHAR;
		leng : INTEGER;
		reply : STRUCTURE_DESC_PTR:=nil);

VAR
  buf_len : INTEGER;
  io_request : io_req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := IO$WTL;
	IF reply <> nil THEN reply_sem := reply^.id;
	unit_num := unit;
    END;
    buf_len := leng;
    SEND(PRIORITY := 20,
	 VAL_DATA := io_request,
	 VAL_LENGTH := 22,
	 DESC := unit_desc,
	 REF_DATA := buffer,
	 REF_LENGTH := buf_len);
END;

[Global($xeeoi)]
PROCEDURE write_eoi_ieq(unit : INTEGER;
		VAR unit_desc : STRUCTURE_DESC;
		VAR buffer : PACKED ARRAY[first..last: INTEGER] OF CHAR;
		leng : INTEGER;
		reply : STRUCTURE_DESC_PTR:=nil);

VAR
  buf_len : INTEGER;
  io_request : io_req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := IO$WLE;
	IF reply <> nil THEN reply_sem := reply^.id;
	unit_num := unit;
    END;
    buf_len := leng;
    SEND(PRIORITY := 20,
	 VAL_DATA := io_request,
	 VAL_LENGTH := 22,
	 DESC := unit_desc,
	 REF_DATA := buffer,
	 REF_LENGTH := buf_len);
END;

[Global($xerea)]
PROCEDURE read_ieq(unit : INTEGER;
		VAR unit_desc : STRUCTURE_DESC;
		VAR buffer : PACKED ARRAY[first..last: INTEGER] of CHAR;
		leng, mlength : INTEGER;
		chr : char;
		reply : STRUCTURE_DESC_PTR:=nil);

VAR
  buf_len : INTEGER;
  io_request : io_req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := IO$RDL;
	IF reply <> nil THEN reply_sem := reply^.id;
	unit_num := unit;
	match_char := chr;
	match_length := mlength;
    END;
    buf_len := leng;
    SEND(PRIORITY := 20,
	 VAL_DATA := io_request,
	 VAL_LENGTH := 22,
	 DESC := unit_desc,
	 REF_DATA := buffer,
	 REF_LENGTH := buf_len);
END;

[Global($xecom)]
PROCEDURE ieq_command(unit : INTEGER;
		VAR unit_desc : STRUCTURE_DESC;
		VAR comm : ARRAY[first..last : INTEGER] of BYTE_RANGE;
		reply : STRUCTURE_DESC_PTR:=nil);

VAR
  io_request : io_req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := IO$CMD;
	IF reply <> nil THEN reply_sem := reply^.id;
	unit_num := unit;
    END;
    SEND(PRIORITY := 20,
	 VAL_DATA := io_request,
	 VAL_LENGTH := 22,
	 DESC := unit_desc,
	 REF_DATA := comm,
	 REF_LENGTH := last-first+1);
END;

[Global($xeaux)]
PROCEDURE ieq_aux_command(unit : INTEGER;
		VAR unit_desc : STRUCTURE_DESC;
		aux_comm : INTEGER;
		reply : STRUCTURE_DESC_PTR:=nil);

VAR
  io_request : io_req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := IO$AUX;
	IF reply <> nil THEN reply_sem := reply^.id;
	unit_num := unit;
	aux_command := aux_comm;
    END;
    SEND(PRIORITY := 20,
	 VAL_DATA := io_request,
	 VAL_LENGTH := 34,
	 DESC := unit_desc);
END;

[Global($xevnt)]
PROCEDURE rec_ieq_event(unit : INTEGER;
		VAR unit_desc : STRUCTURE_DESC;
		reply : STRUCTURE_DESC_PTR:=nil);

VAR
  io_request : io_req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := IO$REV;
	IF reply <> nil THEN reply_sem := reply^.id;
	unit_num := unit;
    END;
    SEND(PRIORITY := 20,
	 VAL_DATA := io_request,
	 VAL_LENGTH := 34,
	 DESC := unit_desc);
END;

[Global($xegts)]
PROCEDURE ieq_control_gts(unit : INTEGER;
		VAR unit_desc : STRUCTURE_DESC;
		reply : STRUCTURE_DESC_PTR:=nil);

VAR
  io_request : io_req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := IO$GTS;
	IF reply <> nil THEN reply_sem := reply^.id;
	unit_num := unit;
    END;
    SEND(PRIORITY := 20,
	 VAL_DATA := io_request,
	 VAL_LENGTH := 34,
	 DESC := unit_desc);
END;

[Global($xepas)]
PROCEDURE ieq_pass_control(unit : INTEGER;
		VAR unit_desc : STRUCTURE_DESC;
		t_addr : INTEGER;
		reply : STRUCTURE_DESC_PTR:=nil);

VAR
  io_request : io_req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := IO$PCT;
	IF reply <> nil THEN reply_sem := reply^.id;
	unit_num := unit;
	talk_addr := t_addr;
    END;
    SEND(PRIORITY := 20,
	 VAL_DATA := io_request,
	 VAL_LENGTH := 34,
	 DESC := unit_desc);
END;

[Global($xereq)]
PROCEDURE ieq_req_service(unit : INTEGER;
		VAR unit_desc : STRUCTURE_DESC;
		stat : INTEGER);

VAR
  io_request : io_req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := IO$RSV;
	unit_num := unit;
	stat_byte := stat;
    END;
    SEND(PRIORITY := 20,
	 VAL_DATA := io_request,
	 VAL_LENGTH := 34,
	 DESC := unit_desc);
END;

[Global($xeser)]
PROCEDURE ieq_serial(unit : INTEGER;
		VAR unit_desc : STRUCTURE_DESC;
		len : INTEGER;
		VAR buff : ARRAY[first..last : INTEGER] OF ser_poll_buf;
		reply : STRUCTURE_DESC_PTR:=nil);

VAR
  io_request : io_req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := IO$SPS;
	unit_num := unit;
	IF reply <> nil THEN reply_sem := reply^.id;
    END;
    SEND(PRIORITY := 20,
	 VAL_DATA := io_request,
	 VAL_LENGTH := 22,
	 DESC := unit_desc,
	 REF_DATA := buff,
	 REF_LENGTH := last-first+1);
END;

[Global($xepar)]
PROCEDURE ieq_parallel_config(unit : INTEGER;
		VAR unit_desc : STRUCTURE_DESC;
		VAR buff : ARRAY[first..last : INTEGER] of pp_buffer;
		reply : STRUCTURE_DESC_PTR:=nil);

VAR
  I : INTEGER;
  io_request : io_req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := IO$PPC;
	unit_num := unit;
	FOR I := first to last DO
	  par_buff[I] := buff[I];
	IF reply <> nil THEN reply_sem := reply^.id;
    END;
    SEND(PRIORITY := 20,
	 VAL_DATA := io_request,
	 VAL_LENGTH := 34,
	 DESC := unit_desc);
END;

[Global($xelod)]
PROCEDURE ieq_parallel_load(unit : INTEGER;
		VAR unit_desc : STRUCTURE_DESC;
		stat :INTEGER);

VAR
  io_request : io_req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := IO$LPP;
	unit_num := unit;
	stat_byte := stat;
    END;
    SEND(PRIORITY := 20,
	 VAL_DATA := io_request,
	 VAL_LENGTH := 34,
	 DESC := unit_desc);
END;

[Global($xepol)]
PROCEDURE ieq_parallel_poll(unit : INTEGER;
		VAR unit_desc : STRUCTURE_DESC;
		reply : STRUCTURE_DESC_PTR:=nil);

VAR
  io_request : io_req;

BEGIN
  WITH io_request DO
    BEGIN
	oper := IO$PPO;
	unit_num := unit;
	IF reply <> nil THEN reply_sem := reply^.id;
    END;
    SEND(PRIORITY := 20,
	 VAL_DATA := io_request,
	 VAL_LENGTH := 34,
	 DESC := unit_desc);
END;

END.
{End of XESUB}
                                                                                                                                     