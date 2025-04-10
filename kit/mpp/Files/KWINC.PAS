{ Module: KWINC.PAS	- Edit level 0 }
{$NOLIST}
{
 THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED OR COPIED
 ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE.

 COPYRIGHT (c) 1982, 1986 BY DIGITAL EQUIPMENT CORPORATION. ALL
   RIGHTS RESERVED.
}
{$LIST}
{ Specifies symbol definitions for the KWV11-C Real-Time Clock

  Modified: Dec-13-82 JPR  Add definition of kw_data}

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

[External ($KWSTRT)] PROCEDURE Start_rtclock(
	source	: kw_rate;
	counts	: INTEGER;
	single	: BOOLEAN;
	start	: kw_start_type;
	signals	: BOOLEAN;
   VAR  timer	: STRUCTURE_DESC:=0;
   VAR  kw_desc : STRUCTURE_DESC;
   VAR	state	: unsigned );External;

[External ($KWSTOP)] PROCEDURE Stop_rtclock(
	VAR kw_desc : STRUCTURE_DESC);External;

[External ($KWRDS)] PROCEDURE Read_counts_signal
  ( VAR buffer	: ARRAY [first..last : INTEGER] OF INTEGER;
	number	: INTEGER;
	source	: kw_rate;
	base	: kw_base_type;
	start	: kw_start_type;
    VAR kw_desc : STRUCTURE_DESC;
    VAR reply	: STRUCTURE_DESC:=0);External;

[External ($KWRDW)] PROCEDURE Read_counts_wait
  ( VAR buffer	: ARRAY [first..last : INTEGER] OF INTEGER;
	number	: INTEGER;
	source	: kw_rate;
	base	: kw_base_type;
	start	: kw_start_type;
    VAR kw_desc : STRUCTURE_DESC;
    VAR state	: unsigned );External;

{ end KWVINC.PAS }
                                                                                                                                                                                                                                                        