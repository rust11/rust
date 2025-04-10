{ ADSUB.PAS	- Edit Level 1 }
[system(micropower)] Module Set_Analog_Mode;

{$NOLIST}
{
 THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED OR COPIED
 ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE.

 COPYRIGHT (c) 1983, 1986 BY DIGITAL EQUIPMENT CORPORATION. ALL RIGHTS
   RESERVED.
}
{$LIST}
 %INCLUDE 'LB:IOPKTS'

 CONST
     external_event = 16;		{ Initiated by an external event }
     real_time_clock = 32;		{ Initiated by a real-time clock }
     convrt_imed = 0;			{ Start A/D conversion immediately}
     DA$NORMAL	= 1;			{ Successful D/A write }
     DA$INVPARAM = -1;			{ Invalid parameter for D/A write }
     ab_dac_addr = %O'170440';		{ Standard buffer address for D/A
					  output buffers for AAV11-C }
   { ab_dac_addr = %O'170404';		{ Standard buffer address for D/A
					  output buffers for AXV11-C }
     ab_dac_nchan = 4;			{ Number of output channels for
					  AAV11-C }
   { ab_dac_nchan = 2;			{ Number of output channels for
					  AXV11-C }

TYPE
  ad_gain = (
    ad_gain_1,
    ad_gain_2,
    ad_gain_4,
    ad_gain_8 );

  mpx_addr = 0..15;	{ Channel number }

  ad_csr = PACKED RECORD
    start		: BOOLEAN;
			{ Initiates an A/D conversion }

    filler_1		: [BIT(1)] BOOLEAN;

    gain_sel		: [BIT(2)] ad_gain;
			{ Selects gain for the analog input }

    ext_trig		: BOOLEAN;
			{ Enables an external trigger to initiate an A/D
			  conversion }

    rtc_trig		: BOOLEAN;
			{ Enables a real_time clock (KWV11-C) to initiate an
			  A/D conversion }

    done_int_enable	: BOOLEAN;
			{ Enables an interrupt on done_flag }

    done_flag		: BOOLEAN;
			{ Set on completion of A/D conversion and reset when
			  the Data Buffer Register is read - READONLY BIT}

    addr		: [BIT(4)] mpx_addr;
			{ Select one of sixteen analog input channels }

    filler_2		: [BIT(2)] BOOLEAN;

    err_int_enable	: BOOLEAN;
			{ Enables interrupt when error_flag is set }

    error_flag		: BOOLEAN;
			{ When set, it indicates one of the following errors
			  has occurred:

			    1.	an external start or a clock start occurred
				during multiplexer settling time;

			    2.	an A/D start occurred while an A/D conversion
				was in progress;

			    3.	a start of any type occurred while done_flag
				was set. }

  END;		{ ad_csr }

   ad_chan_desc = PACKED RECORD
     chan_num	:	[BIT(12)] mpx_addr;
     gain_sel	:	[BIT(4)] ad_gain;
   END;
 
   ad_control_type = RECORD
     num_chan	:	INTEGER;
     chan_ctrl	:	ARRAY [1..16] OF ad_chan_desc;
   END;
 
   ad_control_ptr = ^ ad_control_type;

   dac_chan = 0..3;


{$LIST}
[Global($ADSET)]
  PROCEDURE Set_analog_mode(
    VAR buffer   : ad_control_type;
	trigger	  : INTEGER;
	count	  : INTEGER := 0;
    VAR ad_desc	  : STRUCTURE_DESC;
        reply	  : STRUCTURE_DESC_PTR);

 VAR
  x : IO$REQ;

 BEGIN
   x.oper := IF$SET_CHAR;
   x.dep_mod := [];
   x.ind_mod := [];
   x.config_word := trigger;
   x.rec_count := count;
   IF reply <> nil THEN x.reply_sem := reply^.id else x.reply_sem.index := 0;
   SEND (
 	ref_data	:= buffer,
 	ref_length	:= 34,
 	val_data	:= x,
 	val_length	:= size(x),
 	desc		:= ad_desc );
 END;

[Global($ADSIG)]
 PROCEDURE Read_analog_signal(
    VAR buffer	  : ARRAY[first..last : INTEGER] OF INTEGER;
    VAR ad_desc	  : STRUCTURE_DESC;
        reply	  : STRUCTURE_DESC_PTR);

 {   Where:
 
       buffer	The array of integers that the counter is copied to  after
 	 	each interrupt.
 
       reply	Indicates  the  queue  semaphore  that  the  final  status
 		message is sent to when the I/O request is completed.  The
 		message consists of  a  zy_reply  record.  The status word
 		contains  the  final  status  of  the request.  The values
 		returned in the final status are  IO$SUCCESS,  IO$STOPPED,
 		IO$OVERFLOW or IO$OVERRUN.
 }

  VAR
    number  : INTEGER;
    x	    : IO$REQ;

  BEGIN
   x.oper := IF$READ_LOGICAL;
   x.dep_mod := [];
   x.ind_mod := [];
   IF reply <> nil THEN x.reply_sem := reply^.id else x.reply_sem.index := 0;
   number := last-first+1;
   SEND (
 	ref_data	:= buffer,
 	ref_length	:= 2 * number,
 	val_data	:= x,
 	val_length	:= size(x),
 	desc		:= ad_desc );
 END;

{ WRDAW.PAS }

{ This procedure interfaces with the digital to analog converters
  (AAV11-C and AXV11-C).  This procedure writes one or more values
  from a buffer to one or more D/A channels. }

[ GLOBAL($WRDAW) ] PROCEDURE Write_analog_wait(
        VAR channels	: ARRAY [chan1..num_chan  : dac_chan] OF INTEGER;
	VAR buffer	: ARRAY [val1..num_values : dac_chan] OF INTEGER;
	VAR state	: unsigned );

  VAR
    da_buffer	: [AT(ab_dac_addr)] ARRAY[1..ab_dac_nchan] OF INTEGER;
    index		: INTEGER;
    index1		: INTEGER;

  BEGIN		{ Write_analog_wait }

    state := DA$NORMAL;

	{ Validate parameters }

    index1 := chan1;

    IF ((num_chan - chan1) <= num_chan) AND ((num_values - val1) <= num_chan)

      THEN
	FOR index := val1 TO num_values DO
	  BEGIN
	    IF channels[index] <= num_chan
	      THEN
		da_buffer [channels [index1] ]::UNIVERSAL
		  := buffer[index]::UNIVERSAL
	      ELSE state := DA$INVPARAM;
	    index1 := index1 + 1;
	  END

      ELSE
	state := DA$INVPARAM;

  END;		{ Write_analog_wait }

END.
{ End of ADSUB.PAS }
                                                                                                                                                                                                                                                          