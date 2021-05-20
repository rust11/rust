{ Module: YK.PAS	edit level 1 }

{
                   COPYRIGHT (c) 1982, 1986 BY
              DIGITAL EQUIPMENT CORPORATION, MAYNARD
               MASSACHUSETTS.  ALL RIGHTS RESERVED.


  THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED AND  COPIED
  ONLY  IN  ACCORDANCE  WITH  THE  TERMS  OF  SUCH  LICENSE AND WITH THE
  INCLUSION OF THE ABOVE COPYRIGHT NOTICE.  THIS SOFTWARE OR  ANY  OTHER
  COPIES  THEREOF MAY NOT BE PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY
  OTHER PERSON.  NO TITLE TO AND OWNERSHIP OF  THE  SOFTWARE  IS  HEREBY
  TRANSFERRED.


  THE INFORMATION IN THIS SOFTWARE IS SUBJECT TO CHANGE  WITHOUT  NOTICE
  AND  SHOULD  NOT  BE  CONSTRUED  AS  A COMMITMENT BY DIGITAL EQUIPMENT
  CORPORATION.


  DIGITAL ASSUMES NO RESPONSIBILITY FOR THE USE OR  RELIABILITY  OF  ITS
  SOFTWARE ON EQUIPMENT THAT IS NOT SUPPLIED BY DIGITAL.
}

[SYSTEM(MICROPOWER)] MODULE $YK ;

{ The following section contains a function that reads data from a Parallel
  Port, via the YK handler.  It returns a standard I/O error code for the
  value of the function, and the actual number of bytes read in the
  VAR parameter `length' (length NOT returned if user semaphore chosen). }

{$NOLIST}
%INCLUDE 'LB:ESCODE.PAS'	{ get exception code defs }
{$LIST}
%INCLUDE 'LB:YKINC.PAS'	{ get YK driver and packet defs } 

VAR
    $ykrd_reply : STRUCTURE_DESC ;	{ read reply sem desc. }

[INITIALIZE] PROCEDURE YK_READ_INIT ;

BEGIN
IF CREATE_QUEUE_SEMAPHORE (DESC := $ykrd_reply) THEN
    BEGIN
    END ;
END ;


[global($ykprd)] FUNCTION YK_PORT_READ ;  { parameters defined by YKINC.PAS}

VAR
    request_packet : YK_PORT_RQST ;
    reply_packet : YK_REPLY ;

BEGIN
    WITH request_packet DO
	BEGIN
	oper := read_physical ;
	ind_mods := [] ;
	IF match_rst = false THEN
	    funct_mods := []
	ELSE
	    funct_mods := [reset_pat] ;

	unit_num := port_num ;
	seqnc := seq_num ;

	IF reply = NIL THEN
	    reply_sem := $ykrd_reply.id
	ELSE
	    reply_sem := reply^ .id ;

	END ;

    SEND ( NAME := '$YKA  ' ,	{ Now send the request to the driver }
         VAL_DATA := request_packet,
	 VAL_LENGTH := SIZE (YK_PORT_RQST),
	 REF_DATA := buffer ,
         REF_LENGTH := byte_count );

    IF reply = NIL THEN  	{ If User didn't specify semaphore, then
				     this function will wait for reply }
	BEGIN
	RECEIVE ( DESC := $ykrd_reply ,
	        VAL_DATA := reply_packet,
	        VAL_LENGTH := SIZE (YK_REPLY)) ;
	YK_PORT_READ := reply_packet.status ;
	byte_count := reply_packet.act_length ; { The VAR param `byte_count' 
						is set to the actual length}
	END
    ELSE
	YK_PORT_READ := ES$NOR ;

END;
{ The following section contains a function that writes data to a Parallel Port,
  via the YK handler.  It returns a standard I/O error code for the
  value of the function, and the actual number of bytes written in the
  VAR parameter `length' (length NOT returned if user semaphore chosen). }

VAR
    $ykwr_reply : STRUCTURE_DESC ;	{ write reply sem desc. }


[INITIALIZE] PROCEDURE YK_WRITE_INIT ;

BEGIN
    IF CREATE_QUEUE_SEMAPHORE (DESC := $ykwr_reply) THEN
        BEGIN
        END ;
END ;


[global($ykpwr)] FUNCTION YK_PORT_WRITE ;  { parameters defined by YKINC.PAS}

VAR
    request_packet : YK_PORT_RQST ;
    reply_packet : YK_REPLY ;

BEGIN
    WITH request_packet DO
	BEGIN
	oper := write_physical ;
	ind_mods := [] ;
	IF match_rst = false THEN
	    funct_mods := []
	ELSE
	    funct_mods := [reset_pat] ;

	unit_num := port_num ;
	seqnc := seq_num ;

	IF reply = NIL THEN
	    reply_sem := $ykwr_reply.id
	ELSE
	    reply_sem := reply^ .id ;

	END ;

    SEND ( NAME := '$YKA  ' ,	{ Now send the request to the driver }
         VAL_DATA := request_packet,
	 VAL_LENGTH := SIZE (YK_PORT_RQST),
	 REF_DATA := buffer ,
         REF_LENGTH := byte_count );

    IF reply = NIL THEN  { If User didn't specify semaphore, then
				     this function will wait for reply }
	BEGIN
	RECEIVE ( DESC := $ykwr_reply ,
	        VAL_DATA := reply_packet,
	        VAL_LENGTH := SIZE (YK_REPLY)) ;
	YK_PORT_WRITE := reply_packet.status ;
	byte_count := reply_packet.act_length ; { The VAR param `byte_count' 
						is set to the actual length}
	END
    ELSE
	YK_PORT_WRITE := ES$NOR ;

END;
{ The following section contains a function that sets the pattern mode on a
  Parallel Port, via the YK handler.  It returns a standard I/O error code for
  the value of the function, and the actual number of bytes read in the
  VAR parameter `length' (length NOT returned if user semaphore chosen).
  Data will only be read if the `wait till match mode' is chosen. }

VAR
    $ykpa_reply : STRUCTURE_DESC ;	{ pattern reply sem desc. }


[INITIALIZE] PROCEDURE YK_PAT_INIT ;

BEGIN
IF CREATE_QUEUE_SEMAPHORE (DESC := $ykpa_reply) THEN
    BEGIN
    END ;
END ;


[global($ykspa)] FUNCTION YK_SET_PATTERN ;  { parameters defined by YKINC.PAS}

VAR
    request_packet : YK_PATTERN_RQST ;
    reply_packet   : YK_REPLY ;

BEGIN
    WITH request_packet DO
	BEGIN
	oper := SET_PATTERN ;
	ind_mods := [] ;
	funct_mods := mode ;
	unit_num := port_num ;
	seqnc := seq_num ;

	IF reply = NIL THEN
	    reply_sem := $ykpa_reply.id
	ELSE
	    reply_sem := reply^ .id ;

	Polarity := patp ;
	transitions := patt ;
	mask := patm ;
	END ;

    IF Pt_buf <> NIL THEN
	SEND ( NAME := '$YKA  ' ,	{ Now send the request to the driver }
	    VAL_DATA := request_packet,
	    VAL_LENGTH := SIZE (YK_PATTERN_RQST),
	    REF_DATA := pt_buf^ ,
	    REF_LENGTH := 2 )    { set to 2 in case ports are linked. YK
	    			   will read the correct number of bytes
	    			   in both cases }
    ELSE
	SEND ( NAME := '$YKA  ', 
	    VAL_DATA := request_packet,
	    VAL_LENGTH := SIZE (YK_PATTERN_RQST) ) ;

    IF reply = NIL THEN  { If User didn't specify semaphore, then
				     this function will wait for reply }
	BEGIN
	RECEIVE ( DESC := $ykpa_reply ,
	        VAL_DATA := reply_packet,
	        VAL_LENGTH := SIZE (YK_REPLY)) ;
	YK_SET_PATTERN := reply_packet.status ;
	END
    ELSE
	YK_SET_PATTERN := ES$NOR ;

END;
{ The following section contains functions that service the Timer/Counters,
  via the YK handler.  It returns a standard I/O error code for the
  value of the function. }

VAR
    $ykti_reply : STRUCTURE_DESC ;	{ timer reply sem desc. }


[INITIALIZE] PROCEDURE YK_TIMER_INIT ;

BEGIN
IF CREATE_QUEUE_SEMAPHORE(DESC:=$ykti_reply) THEN
    BEGIN
    END ;
END ;


[global($yktms)] FUNCTION YK_SET_TIMER ;  { parameters defined by YKINC.PAS}

VAR
    request_packet : YK_TIMER_RQST ;
    reply_packet   : YK_REPLY ;

BEGIN
    WITH request_packet DO
	BEGIN
	oper := set_timer ;
	ind_mods := [] ;
	funct_mods := mode ;
	unit_num := timer_num ;
	timer_constant := timer_value ;
	IF bin_sem = NIL THEN
	    timer_signal_sem := no_sem
	ELSE
	    timer_signal_sem := bin_sem^ .id ;
	
	IF reply = NIL THEN
	    reply_sem := $ykti_reply.id
	ELSE
	    reply_sem := reply^ .id ;

	END ;

    SEND ( NAME := '$YKA  ' ,	{ Now send the request to the driver }
         VAL_DATA := request_packet,
	 VAL_LENGTH := SIZE (YK_TIMER_RQST) ) ;

    IF reply = NIL THEN  { If User didn't specify semaphore, then
				  this function will wait for reply }
	BEGIN
	RECEIVE ( DESC := $ykti_reply ,
	        VAL_DATA := reply_packet,
	        VAL_LENGTH := SIZE (YK_REPLY)) ;
	YK_SET_TIMER := reply_packet.status ;
	END
    ELSE
	YK_SET_TIMER := ES$NOR ;

END;


[global($yktmr)] FUNCTION YK_READ_TIMER ;  { parameters defined by YKINC.PAS}

VAR
    request_packet : YK_TIMER_RQST ;
    reply_packet   : YK_REPLY ;

BEGIN
    WITH request_packet DO
	BEGIN
	oper := read_timer ;
	ind_mods := [] ;
	unit_num := timer_num ;

	IF reply = NIL THEN
	    reply_sem := $ykti_reply.id
	ELSE
	    reply_sem := reply^ .id ;

	END ;

    IF pt_time <> NIL THEN
	SEND ( NAME := '$YKA  ' ,	{ Now send the request to the driver }
	    VAL_DATA := request_packet,
	    VAL_LENGTH := SIZE (YK_TIMER_RQST),
	    REF_DATA := pt_time ^ ,
	    REF_LENGTH := 2 )    
    ELSE
	SEND ( NAME := '$YKA  ', 
	    VAL_DATA := request_packet,
	    VAL_LENGTH := SIZE (YK_TIMER_RQST) ) ;

    IF reply = NIL THEN { If User didn't specify semaphore, then
				  this function will wait for reply }
	BEGIN
	RECEIVE ( DESC := $ykti_reply ,
	        VAL_DATA := reply_packet,
	        VAL_LENGTH := SIZE (YK_REPLY)) ;
	YK_READ_TIMER := reply_packet.status ;
	END
    ELSE
	YK_READ_TIMER := ES$NOR ;

END;

{  This functions clears (disables from further interupts) a timer }
[global($yktmc)] FUNCTION YK_CLEAR_TIMER ;  { parameters defined by YKINC.PAS}

VAR
    request_packet : YK_TIMER_RQST ;
    reply_packet   : YK_REPLY ;

BEGIN
    WITH request_packet DO
	BEGIN
	oper := clear_timer ;
	ind_mods := [] ;
	unit_num := timer_num ;

	IF reply = NIL THEN
	    reply_sem := $ykti_reply.id
	ELSE
	    reply_sem := reply^ .id ;

	END ;

    SEND ( NAME := '$YKA  ' ,	{ Now send the request to the driver }
         VAL_DATA := request_packet,
	 VAL_LENGTH := SIZE (YK_TIMER_RQST) ) ;

    IF reply = NIL THEN  { If User didn't specify semaphore, then
				     this function will wait for reply }
	BEGIN
	RECEIVE ( DESC := $ykti_reply ,
	        VAL_DATA := reply_packet,
	        VAL_LENGTH := SIZE (YK_REPLY)) ;
	YK_CLEAR_TIMER := reply_packet.status ;
	END
    ELSE
	YK_CLEAR_TIMER := ES$NOR ;

END;

END.
                                                                                                           