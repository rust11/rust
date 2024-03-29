{ ADINC.PAS	- Edit Level 1 }

{$NOLIST}
{
 THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED OR COPIED
 ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE.

 COPYRIGHT (c) 1983, 1986 BY DIGITAL EQUIPMENT CORPORATION. ALL RIGHTS
   RESERVED.
}
{$LIST}

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

[External($ADSET)]
  PROCEDURE Set_analog_mode
   ( VAR buffer   : ad_control_type;
	 trigger  : INTEGER;
	 count	  : INTEGER := 0;
     VAR ad_desc  : STRUCTURE_DESC;
     VAR reply	  : STRUCTURE_DESC:=0);EXTERNAL;

[External($ADSIG)]
 PROCEDURE Read_analog_signal
   ( VAR buffer	  : ARRAY[first..last : INTEGER] OF INTEGER;
     VAR ad_desc  : STRUCTURE_DESC;
     VAR reply	  : STRUCTURE_DESC:=0);EXTERNAL;

[External($WRDAW)]
 PROCEDURE Write_analog_wait
      ( VAR channels	: ARRAY [chan1..num_chan  : dac_chan] OF INTEGER;
	VAR buffer	: ARRAY [val1..num_values : dac_chan] OF INTEGER;
	VAR state	: unsigned );EXTERNAL;

{ End of ADINC.PAS }
                                                                                                                                                                                                                                                                                                                                            