{
 THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED OR COPIED
 ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE.

 COPYRIGHT (c) 1982, 1986 BY DIGITAL EQUIPMENT CORPORATION.
		ALL RIGHTS RESERVED.
}

{ YKINC.PAS  -  YK handler's include file }

{  The Requests to the YK driver are defined by the following: }

CONST

    No_sem = STRUCTURE_ID (0, 0) ;  { Null Semaphore }


TYPE

  YK$FUNCTION = (
    READ_PHYSICAL,		{ IF$RDP - Read physical }
    NA_1 ,			{ not used }
    NA_2 ,			{ not used }
    WRITE_PHYSICAL ,		{ IF$WTP - Write physical }
    NA_3 ,
    NA_4 ,			{ not used }
    NA_5 ,
    YK_GET_STATUS ,		{ Get Status }
    SET_PATTERN ,		{ Set Pattern }
    DMA_READ ,			{ Set DMA read mode }
    DMA_WRITE ,			{ Set DMA write mode }
    DMA_COMPLETE ,		{ End of DMA mode }
    SET_TIMER ,			{ Set Timer }
    CLEAR_TIMER ,		{ Clear Timer }
    READ_TIMER ) ;		{ Read Timer }

  FUNC_INDEP_BITS = (SIMP_REPLY, DATA_CHECK, NO_RETRY);

  UNIT_NUMBER = (
    PORT_A ,			{ Port A }
    PORT_B ,			{ Port B }
    PORT_C ,			{ Port C }
    TIMER_1 ,			{ Timer 1 }
    TIMER_2 ,			{ Timer 2 }
    TIMER_3 ) ;			{ Timer 3 }

  Port_mods = (			{ Port's Function Modifiers }
    nu_1 ,			{ - not used }
    nu_2 ,			{ - not used }
    reset_pat ) ;		{ - reset pattern at end }
  Port_mod_entry = PACKED SET OF Port_mods ;

  Pattern_mods = (		{ Pattern Function Modifiers }
    nu_3 ,			{ - not used }
    nu_4 ,			{ - not used }
    pat_reset ,			{ - reset pattern at end }
    and_mode ,			{ - AND pattern mode }
    or_mode ,			{ - OR pattern mode }
    wait_match ) ;		{ - Wait till match mode }
  Pat_mod_entry = PACKED SET OF Pattern_mods ;

TYPE
  Timer_mods = (		{ Timer Function Modifiers }
    nu_5 ,			{ - not used }
    nu_6 ,			{ - not used }
    init_constant ,		{ - initialize timer constant }
    trigger ,			{ - trigger timer when setup }
    nu_7 ,			{ - not used }
    contin_cycle ) ;		{ - continuous cycle mode }
  Timer_mod_entry = PACKED SET OF Timer_mods ;

{  The data for a timer reads or pattern setting with the wait option,
   is sent via a pointer to it.  If omitted, the data will be returned
   in the `bufferless data' portion of the reply. }
   YKBUF_PT = ^ UNSIGNED ;
{  Request packets defined in terms of the above types }

  YK_PORT_RQST = PACKED RECORD
      oper	: [POS(0), BIT(6)] YK$FUNCTION ;
				{ I/O operation to be performed }

      funct_mods  : [POS(6), BIT(7)] Port_mod_entry ;
    				 { read/write function modifier bits }
      ind_mods	: [POS(13), BIT(3)] PACKED SET OF FUNC_INDEP_BITS;

      unit_num  : [POS(16), BIT(8)] UNIT_NUMBER  ; { Selects port }
      filler_1	: BYTE_RANGE;		  { Reserved by DEC. }
      seqnc	: UNSIGNED;		  { User's sequence number }
      pid  : STRUCTURE_ID ;		  { requestor's PDB }
      reply_sem	: STRUCTURE_ID ; 	  { Reply semaphore SDB }
      END;


  YK_PATTERN_RQST = PACKED RECORD
      oper	: [POS(0), BIT(6)] YK$FUNCTION ;
				{ I/O operation to be performed }

      funct_mods  : [POS(6), BIT(7)] pat_mod_entry ;
    				 { pattern function modifier bits }
      ind_mods	: [POS(13), BIT(3)] PACKED SET OF FUNC_INDEP_BITS;

      unit_num  : [POS(16), BIT(8)] UNIT_NUMBER  ; { Selects port }
      filler_1	: BYTE_RANGE;	{ Reserved for future use by DEC. }
      seqnc	: UNSIGNED;	{ A sequence number specified by the user to
				  identify a specific request. }
      pid  : STRUCTURE_ID ;	{ requestor's PDB }
      reply_sem	: STRUCTURE_ID ; { Reply semaphore SDB }
      polarity , not_us1,	 { Pattern Polarity }
      transitions , not_us2,	 { Pattern Transitions }
      mask , not_us3 : BYTE_RANGE; { Pattern Mask }
      END;


  YK_TIMER_RQST = PACKED RECORD
      oper	: [POS(0), BIT(6)] YK$FUNCTION ;
					  { I/O operation to be performed }

      funct_mods  : [POS(6), BIT(7)] Timer_mod_entry ;
    				 	  { timer function modifier bits }
      ind_mods	: [POS(13), BIT(3)] PACKED SET OF FUNC_INDEP_BITS;

      unit_num  : [POS(16), BIT(8)] UNIT_NUMBER  ; { Selects timer }
      filler_1	: BYTE_RANGE;		  { Reserved by DEC. }
      seqnc	: UNSIGNED;		  { User's sequence number }
      pid  : STRUCTURE_ID ;		  { requestor's PDB }
      reply_sem	: STRUCTURE_ID ; 	  { Reply semaphore SDB }
      timer_constant : UNSIGNED ;  	  { Timer's constant }
      timer_signal_sem : STRUCTURE_ID ;   { Continuous Cycle Signal Sem. }
      END;



{ REPLYS }

{  If the user specifies a semaphore, the YK handler sends a reply as
   defined below :  }

{  -  The status field (error codes) are the standard definitions, that 
      are made by the top level I/O packet defs, IODEF.PAS }

{  -  The reply packet, which includes the error codes defined above,
      is defined as: }
TYPE

   YK_REPLY = PACKED RECORD
      oper	: [POS(0), BIT(6)] YK$FUNCTION ;  { I/O operation performed }
      mod_bits  : [POS(6), BIT(10)] 0..9 ;        { function modifier bits }
      unit_num  : [POS(16), BIT(8)] UNIT_NUMBER ; { identifies port or timer}
      filler_1	: BYTE_RANGE;			  { Reserved by DEC. }
      seqnc	: UNSIGNED;			  { User's sequence number}
      status	: UNSIGNED;			  { Status code }
      act_length,				  { Actual number of bytes 
						    transfered }
      filler_2 ,filler_3 ,filler_4,		  { FILL GAP }
      in_buffer : UNSIGNED	 		  { Intra-packet Buffer }
      END ;
				{ NOTE:  the intra-packet buffer is used
					 to return data from pattern match
				 	 wait mode, or timer Read, ONLY
					 if a buffer is not specified. }

{     External Functions provided in library }


{ This function transfers data to an IOP buffer, from a Parallel Port }
[external($ykprd)] FUNCTION YK_PORT_READ (
  port_num		: UNIT_NUMBER ;		{ select port }
  VAR buffer		: UNIVERSAL ;		{ data buffer }
  VAR byte_count	: UNSIGNED;		{ number of bytes }
  reply		: STRUCTURE_DESC_PTR := NIL ;	{ user's reply sem, OPT }
  match_rst	: BOOLEAN := FALSE ;		{ reset pat match,  OPT }
  seq_num	: UNSIGNED := 0			{ sequence number,  OPT }
	     )  : UNSIGNED ; EXTERNAL ;	{ function returns io status }
  

{ This function transfers data from an IOP buffer, to Parallel Port}
[external($ykpwr)] FUNCTION YK_PORT_WRITE (
  port_num		: UNIT_NUMBER ;		{ select port }
  VAR buffer		: UNIVERSAL ;		{ data buffer }
  VAR byte_count	: UNSIGNED;		{ number of bytes }
  reply		: STRUCTURE_DESC_PTR := NIL ;	{ user's reply sem, OPT }
  match_rst	: BOOLEAN := FALSE ;		{ reset pat match,  OPT }
  seq_num	: UNSIGNED := 0			{ sequence number,  OPT }
	     )  : UNSIGNED ; EXTERNAL ;	{ function returns io status }
  

{ This function sets the pattern match mode on PIO port A or B }
[external($ykspa)] FUNCTION YK_SET_PATTERN (
  port_num	: UNIT_NUMBER ;			{ select port }
  mode 		: PAT_MOD_ENTRY ;		{ pattern modifiers }
  reply		: STRUCTURE_DESC_PTR := NIL ;	{ user's reply sem, OPT }
  patp ,					{ Pattern Polarity }
  patt ,					{ Pattern Transition }
  patm		: BYTE_RANGE ;			{ Pattern Mask }
  pt_buf   	: YKBUF_PT := NIL ;		{ Optional buffer pointer..
						  used only in wait mode }
  seq_num	: UNSIGNED := 0			{ sequence number,  OPT }
	     )  : UNSIGNED ; EXTERNAL ;	{ function returns io status }
  

[external($yktms)] FUNCTION YK_SET_TIMER (
  timer_num	: UNIT_NUMBER ;			{ select timer }
  timer_value	: UNSIGNED ;			{ time constant value }
  mode		: TIMER_MOD_ENTRY ;		{ timer's functions mods }
  reply		: STRUCTURE_DESC_PTR := NIL ;	{ user's reply sem, OPT }
  bin_sem	: STRUCTURE_DESC_PTR := NIL	{ Contin. cycle Sem., OPT }
	     )  : UNSIGNED ; EXTERNAL ;	{ function returns io status }
  
[external($yktmr)] FUNCTION YK_READ_TIMER (
  timer_num	: UNIT_NUMBER ;			{ select timer }
  pt_time	: YKBUF_PT := NIL ;		{ pt to time VAR, OPT }
  reply		: STRUCTURE_DESC_PTR := NIL	{ user's reply sem, OPT }
	     )  : UNSIGNED ; EXTERNAL ;	{ function returns io status }
  
[external($yktmc)] FUNCTION YK_CLEAR_TIMER (
  timer_num	: UNIT_NUMBER ;			{ select timer }
  reply		: STRUCTURE_DESC_PTR := NIL	{ user's reply sem, OPT }
	     )  : UNSIGNED ; EXTERNAL ;	{ function returns io status }
  
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    