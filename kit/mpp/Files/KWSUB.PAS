{ KWSUB.PAS	- Edit Level 1 }

[system(micropower)] Module RTC_routines;

{
 THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED OR COPIED
 ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE.

 COPYRIGHT (c) 1985, 1986 BY DIGITAL EQUIPMENT CORPORATION. ALL
   RIGHTS RESERVED.
}

{$NOLIST}
%INCLUDE 'MICROPOWER$LIB:IOPKTS'
{$LIST}

 TYPE
   kw_mode = (
     kwv_md_single_interval,		{ run for a single interval }
     kwv_md_repeated_interval,		{ runs for repeated intervals }
     kwv_md_external_event,		{ monitor external events }
     kwv_md_external_event_zero_base );	{ monitor external events and zero the
					  clock after each event }
   kw_rate = (
     kwv_stop,				{ stop the clock }
     kwv_1MHz,				{ 1000000 Hz }
     kwv_100kHz,			{  100000 Hz }
     kwv_10kHz,				{   10000 Hz }
     kwv_1kHz,				{    1000 Hz }
     kwv_100Hz,				{     100 Hz }
     kwv_ST1,				{ Schmitt Trigger 1 determines the
					  clock frequency }
     kwv_line );			{ Line frequency 50/60 Hz }

   kw_csr = PACKED RECORD
     go:	[POS(0), BIT] BOOLEAN;
		{ Starts the clock }

     mode:	[POS(1), BIT(2)] kw_mode;
		{ Selects mode of clock operation }

     rate:	[POS(3), BIT(3)] kw_rate;
		{ Specifies the clock rate or counting
		  source for the counter }

     int_ovf:	[POS(6), BIT(1)] BOOLEAN;
		{ Specifies interrupt on overflow }

     ovf_flag:	[POS(7), BIT(1)] BOOLEAN;
		{ If int_ovf is set, setting this bit generates an interrupt.
		  This bit must be cleared after the interrupt has been
		  serviced to enable further overflow interrupts. }

     maint_st1:	[POS(8), BIT(1)] BOOLEAN;
		{ Maintenance bit, setting this bit simulates the firing of
		  ST1 }

     maint_st2:	[POS(9), BIT(1)] BOOLEAN;
		{ Maintenance bit, setting this bit simulates the firing of
		  ST2 }

     maint_osc:	[POS(10), BIT(1)] BOOLEAN;
		{ Maintenance bit, Setting this bit simulates one cycle of the
		  internal crystal oscillator used to increment the clock
		  counter.  This bit is used with maint_dio. }

     maint_dio:	[POS(11), BIT(1)] BOOLEAN;
		{ Maintenance bit, setting this bit inhibits the internal
		  crystal oscillator from incrementing the clock counter.
		  This bit is used with maint_osc }

     ovr_flag:	[POS(12), BIT(1)] BOOLEAN;
		{ When set, indicates that the clock is being asked to operate
		  at a rate higher that is compatible with the software.  This
		  bit must be cleared before a subsequent overrun interrupt
		  can occur. }

     st2_go:	[POS(13), BIT(1)] BOOLEAN;
		{ When set, the assertion of st2_flag sets the go bit and
		  clears this bit. }

     int_st2:	[POS(14), BIT(1)] BOOLEAN;
		{ When set, the assertion of st2_flag (Schmitt trigger 2)
		  causes an interrupt. }

     st2_flag:	[POS(15), BIT(1)] BOOLEAN;
		{ See int_st2.  Must be cleared by software to enable further
		  Schmitt trigger 2 interrupts. }

   END;

   kwv_buffer_preset = INTEGER;
		{ In single_interval or repeated_interval mode, this register
		  is used to load the number of clock counts before the
		  counter overflows.  In the external_event modes, this
		  register is used to load the current count from the counter.
		  Reading this register, indirectly reads the counter. }

   kwv_register_set = PACKED RECORD
     csr :	kw_csr;
     buffer :	kwv_buffer_preset
   END;

   fill1 = 0..127;

   fill2 = 0..3;

   kw_control = PACKED RECORD
     kw_signal	:	[POS(0), BIT(1)] BOOLEAN;
			{ This bit field is set to one when a binary or
			  counting semaphore is to be signaled after each
			  clock interrupt.  This mode is used when the
			  clock is being used to trigger A/D conversions.
			  This field is valid only with the Start Real-Time
			  Clock request. }

     kw_mode	:	[POS(1), BIT(2)] kw_mode;
			{ This bit field is used to specify the clock modes of
			  operation. }

     kw_rate	:	[POS(3), BIT(3)] kw_rate;
			{ This bit field is used to specify the clock rate or
			  source of clock count signals. }
 
     kw_fill_1  :	[POS(6), BIT(7)] FILL1;
			{ This field is padding }

     kw_ext_go	:	[POS(13), BIT(1)] BOOLEAN;
			{ This bit field specifies when set that the clock is
			  to be started by an external event (Schmitt trigger
			  2).  If this field is set to zero, the device
			  handler will start the clock immediately. }

     kw_fill_2	:	[POS(14), BIT(2)] FILL2;
			{ This field is padding }

   END;


   kw_data = PACKED RECORD
     kw_clock_control : kw_control;
     kw_count : INTEGER;
   END;

   kw_base_type =
      ( rtc_continuous,		{ Time of event }
	rtc_zero_base );	{ Elapsed time since previous event }

   kw_start_type =
      ( immediate,		{ The realtime clock is started
				  immediately }
	event );		{ The realtime clock is started
				  by an external event on Schmitt
				  trigger 2 }

VAR
  x : IO$REQ;
  y : IO$REPLY;
  rt_reply_desc : STRUCTURE_DESC;
  proc_id : STRUCTURE_DESC;
  control : kw_control;

[INITIALIZE] PROCEDURE KW_initialize;

  BEGIN
    CHANGE_PRIORITY (247);	{ Make priority lower than KWDRV
    				  initialization priority so that the real
    				  time clock's queue semaphore gets created
    				  before we try to access it. }


{* Invalidate structure descriptors so that they can be reused on a
   restart. *}

    rt_reply_desc.id.index := 0;

   { Create queue semaphore for real-time clock replies. }

    IF NOT CREATE_QUEUE_SEMAPHORE (
			desc	:= rt_reply_desc )

      THEN STOP;			{ Can't process if no memory resources
					  are available. }
  END;
[GLOBAL ($KWSTRT)] PROCEDURE Start_rtclock(
	source	: kw_rate;
	counts	: INTEGER;
	single	: BOOLEAN;
	start	: kw_start_type;
	signals	: BOOLEAN;
   	timer	: STRUCTURE_DESC_PTR:=nil;
   VAR  kw_desc : STRUCTURE_DESC;
   VAR	state	: unsigned );

{   Where:

	source	The source of the counts:  kwv_stop is  an  illegal  value;
		kwv_1MHz through kwv_100Hz are clock ticks at the respective
		rates, kwv_line is clock ticks at the line frequence (50 or
		60  Hz)  and  kwv_ST1 is counts of events logged on Schmitt
		Trigger 1.

	counts	The number of ticks at the specified frequency.

	single	Indicates whether the clock runs for a single  interval or
		for repeated intervals.

	start	Indicates whether the clock is to be  started  immediately
		or triggered by an external event on Schmitt trigger 2.

	signals	Indicates  whether  a binary (or counting) semaphore is to
		be signaled at the end of each interval or not.

	timer	Indicates the binary or counting semaphore that is  to  be
		signaled at the end of each interval.

	state	The  status  word contains the status of the request.  The
		possible   values   returned   are   IE$NORMAL,   IE$STOP,
		IE$OVERFLOW or IE$OVERRUN.
}

BEGIN
  x.oper := IF$ENABLE;
  x.dep_mod := [];
  x.ind_mod := [];
  INIT_PROCESS_DESC (			{ Get current process ID }
  	desc := proc_id );
  x.pid := proc_id.id;
  x.st_signal := timer^.id;
  x.reply_sem := rt_reply_desc.id;
  WITH control DO
    BEGIN
      kw_signal := signals;
      IF single
	THEN kw_mode := kwv_md_single_interval
	ELSE kw_mode := kwv_md_repeated_interval;
      kw_rate := source;
      kw_ext_go := (start = event);
    END;
  x.kw_config := control::unsigned;
  x.kw_count := counts::unsigned;
  SEND (
	val_data	:= x,
	val_length	:= size ( x ) , 
	desc		:= kw_desc );

  RECEIVE (
	val_data	:= y,
	val_length	:= size ( y ) , 
	desc		:= rt_reply_desc );

  state := y.status;

END;


[GLOBAL ($KWSTOP)] PROCEDURE Stop_rtclock(
	VAR kw_desc : STRUCTURE_DESC);

BEGIN
  x.oper := IF$DISABLE ;
  x.dep_mod := [];
  x.ind_mod := [];
  proc_id.id.index := 0;		{ Invalidate for reuse }
  INIT_PROCESS_DESC (			{ Get current process ID }
  	desc := proc_id );
  x.reply_sem := rt_reply_desc.id;
  x.pid := proc_id.id;

  SEND (
	val_data	:= x,
	val_length	:= size ( x ) , 
	desc		:= kw_desc );

  RECEIVE (
	val_data	:= y,
	val_length	:= size ( y ) , 
	desc		:= rt_reply_desc );

END;

{ This module contains the procedure Read_counts_signal.  This procedure
  interfaces with the programmable read-time clock (KWV11-C) handler, KWDRV.
  This procedure provides an asynchronous interface to read a block of counts
  via the programmable real-time clock. }

[GLOBAL ($KWRDS)] PROCEDURE Read_counts_signal(
    VAR buffer	: ARRAY [first..last : INTEGER] OF INTEGER;
	number	: INTEGER;
	source	: kw_rate;
	base	: kw_base_type;
	start	: kw_start_type;
    VAR kw_desc : STRUCTURE_DESC;
	reply	: STRUCTURE_DESC_PTR:=nil);

{   Where:

	buffer	The array of integers that the counter is copied to  after
	 	each interrupt.

	number	The number of elements to be copied to array buffer.

	source	The source of the counts:  kwv_stop is  an  illegal  value;
		kwv_1MHz through kwv_100Hz are clock ticks at the respective
		rates, kwv_line is clock ticks at the line frequence (50 or
		60  Hz)  and  kwv_ST1 is counts of events logged on Schmitt
		Trigger 1.

	base	The value rtc_continuous specifies that the count  at  any
		event  is  continuous  from  the  first  event.  The value
		rtc_zero_base specifies that  the  count  resets  to  zero
		after each event.

	start	Indicates whether the clock is to be  started  immediately
		or triggered by an external event on Schmitt trigger 2.

	reply	Indicates  the  queue  semaphore  that  the  final  status
		message is sent to when the I/O request is completed.  The
		message consists of  a  kwv_reply  record.  The status word
		contains  the  final  status  of  the request.  The values
		returned in the final status are  IO$SUCCESS,  IO$STOPPED,
		IO$OVERFLOW or IO$OVERRUN.
}

BEGIN
  x.oper := IF$READ_PHYSICAL;
  x.dep_mod := [];
  x.ind_mod := [];

{* Invalidate structure descriptors so that they can be reused on a
   restart. *}

  proc_id.id.index := 0;

  INIT_PROCESS_DESC (			{ Get current process ID }
  	desc := proc_id );
  x.pid := proc_id.id;
  IF reply <> nil THEN x.reply_sem := reply^.id;
  WITH control DO
    BEGIN
      IF base = rtc_continuous
	THEN kw_mode := kwv_md_external_event
	ELSE kw_mode := kwv_md_external_event_zero_base;
      kw_rate := source;
      kw_ext_go := (start = event);
    END;
x.kw_config := control::unsigned ;
x.kw_count := number::unsigned ;
  SEND (
	ref_data	:= buffer,
	ref_length	:= 2 * number,
	val_data	:= x,
	val_length	:= size ( x ) , 
	desc		:= kw_desc );
END;

{ This module contains the procedure Read_counts_wait.  This procedure
  interfaces with the programmable read-time clock (KWV11-C) handler, KWDRV.
  This procedure provides a synchronous interface to read a block of counts
  via the programmable real-time clock. }

[GLOBAL ($KWRDW)] PROCEDURE Read_counts_wait(
    VAR buffer	: ARRAY [first..last : INTEGER] OF INTEGER;
	number	: INTEGER;
	source	: kw_rate;
	base	: kw_base_type;
	start	: kw_start_type;
    VAR kw_desc : STRUCTURE_DESC;
    VAR state	: unsigned );

{   Where:

	buffer	The array of integers that the counter is copied to  after
	 	each interrupt.

	number	The number of elements to be copied to array buffer.

	source	The source of the counts:  kwv_stop is  an  illegal  value;
		kwv_1MHz through kwv_100Hz are clock ticks at the respective
		rates, kwv_line is clock ticks at the line frequence (50 or
		60  Hz)  and  kwv_ST1 is counts of events logged on Schmitt
		Trigger 1.

	base	The value rtc_continuous specifies that the count  at  any
		event  is  continuous  from  the  first  event.  The value
		rtc_zero_base specifies that  the  count  resets  to  zero
		after each event.

	start	Indicates whether the clock is to be  started  immediately
		or triggered by an external event on Schmitt trigger 2.

	state	Indicates the status of the procedure call.  The following
		status  may  be  indicated:   success,  invalid parameter,
		busy, or overrun.
}

BEGIN
  x.oper := IF$READ_PHYSICAL;
  x.dep_mod := [];
  x.ind_mod := [];

{* Invalidate structure descriptors so that they can be reused on a
   restart. *}

  proc_id.id.index := 0;

  INIT_PROCESS_DESC (			{ Get current process ID }
  	desc := proc_id );
  x.pid := proc_id.id;
  x.reply_sem := rt_reply_desc.id;
  WITH control DO
    BEGIN
      IF base = rtc_continuous
	THEN kw_mode := kwv_md_external_event
	ELSE kw_mode := kwv_md_external_event_zero_base;
      kw_rate := source;
      kw_ext_go := (start = event);
    END;
x.kw_config := control::unsigned ;
x.kw_count := number::unsigned ;
  SEND (
	ref_data	:= buffer,
	ref_length	:= 2 * number,
	val_data	:= x,
	val_length	:= size ( x ) , 
	desc		:= kw_desc );
  RECEIVE (
	val_data	:= y,
	val_length	:= size ( y ) , 
	desc		:= rt_reply_desc );
  state := y.status;
END;

END.
                                                                                                                                                                                                                                                                                                                                                              