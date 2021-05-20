    [system(MicroPower), data_space(2000), priority(248),
     stack_size(500), privileged]
    program drv11;

    {
     YADRV.PAS - Edit Level 1

     Copyright (c) 1982, 1986 by
     DIGITAL EQUIPMENT CORPORATION, Maynard
     Massachusetts.  All rights reserved.

     This software is furnished under a license and may be used and  copied
     only  in  accordance  with  the  terms  of  such  license and with the
     inclusion of the above copyright notice.  This software or  any  other
     copies  thereof may not be provided or otherwise made available to any
     other person.  No title to and ownership of  the  software  is  hereby
     transferred.

     The information in this software is subject to change  without  notice
     and  should  not  be  construed  as  a commitment by DIGITAL EQUIPMENT
     CORPORATION.

     DIGITAL assumes no responsibility for the use or  reliability  of  its
     software on equipment that is not supplied by DIGITAL.
     }
    {
     Module: YADRV.PAS ( DRV11 device driver )
     Note: Requires (includes) GETPUT.PAS, IOPKTS.PAS
     YAPFX.PAS must be separately compiled and merged
     with YADRV to build a DRV11 driver process.

     Author: JAS

     Definition of Function:

     This driver process provides 16 bit block mode input and output
     for the DRV11 device. It will control one such device whose
     CSR and vector are defined by the InitCSR procedure
     supplied in the YAPFX module and called from the driver
     initialization procedure.

     The DRV11 is a single unit,  bi-directional, 16-bit binary
     transfer device with separate read/write interrupt enables.
     A typical device configuration for the first module is as follows:

     CSR       167770
     OUTBUF    167772       Write Interrupt(REQ A) Vector = 300
     INBUF     167774       Read Interrupt (REQ B) Vector = 304

     Input:

     Request messages are sent to the DRV11 driver in the standard
     driver request format using the SEND directive.  Only the function
     code, function code modifiers, transfer length, user buffer and
     reply semaphore fields are used.  There are no device dependent
     function modifiers. The transfer count is specified in bytes
     although the device transfers 16 bits at a time; thus, for
     expected operation the byte count should be even. If not, it is
     rounded down to an even number of bytes --e.g., a 3 byte request
     results in the transfer of 1 word, a 7 byte request in 3 words, etc.
     Note that the include file IOPKTS.PAS defines the IO$REQuest record
     for "internal" usage, i.e., by the driver process (GET/PUT packet
     formats). IOPKTS.PAS also defines the appopriate "external" definitions
     of the request packet for users of the driver (SEND/RECEIVE formats
     without packet header).
     Output:

     Upon completion of the user's request, or if an error was made
     in the input request, a queue packet is sent to the user's
     reply semaphore (if one was specified)--if a binary or counting
     semaphore was specified, it is signalled.  The reply packet
     contains the number of bytes transferred (always 0 or the number
     specified in the request), the status code (always normal or
     illegal command), and the information in the original request
     packet. Data is returned directly to or removed from the
     user's buffer ( address ) specified in the request packet.
     Note that the IOPKTS.PAS include file defines the IO$REPLY record.

     Process organization:

     The static process starts at priority 248 and
     then creates two dynamic processes, as follows:
     DRV11_IO         ( NAME := 'DRARDR', PRIORITY := 249 )
     DRV11_IO         ( NAME := 'DRAWRT', PRIORITY := 249 )

     When a request is received the Dispatcher validates the function.
     If an illegal function is detected, and a reply queue semaphore had
     been given, a reply packet is returned to the requestor with an
     illegal function (IS$FUN) status. If a binary or counting semaphore
     had been specified for replys, that sempahore will be signalled and
     packet deleted.
     If a valid read or write request is received, the Dispatcher
     sends the request packet on to either the YAARDR or YAAWRT process
     as appropriate.

     The YAARDR (reader) process, through cooperation with the interrupt
     handling of the kernel which signals the $YAARI binary semaphore each
     time a word  of data is available in the device register, effects the
     transfer of  data from the device data register into the user's buffer.
     When the transfer is complete (as specified by the byte count) the reader
     process sends an IO$REPLY back to the requestor and then returns
     to wait on its input queue. The YAAWRT (writer) process acts in similar
     fashion, using the $YAAWI semaphore, to transfer the specified number
     of words from the user's buffer to the output device.
     }
    %INCLUDE 'LB:IOPKTS'
    %INCLUDE 'LB:GETPUT'  { Defines map_par1_addr, put_word and get_word }
const
    max_buf_size = 256;        { Formal--limit ignored by driver }

    {
     Define Dummy error codes
     }
    es$nor = 0;
    es$ifn = %O'34006';


type

    drv11_csr = packed record
			   forcea:  [pos(0)] boolean; {simulates interrupt}
			   forceb:  [pos(1)] boolean; {simulates interrupt}
			   intenb:  [pos(5)] boolean;
			   intena:  [pos(6)] boolean;
			   reqa:    [pos(7)] boolean;
			   reqb:    [pos(15)] boolean;
			   outbuf:  [pos(16),word] unsigned;
			   inbuf:   [pos(32),word,volatile] unsigned;
		       end;

    io_req_ptr = ^io$req_pkt;
    io_reply_ptr = ^io$reply_pkt;

var
    inbuf_ptr : ^integer;
    outbuf_ptr : ^integer;
    req_ptr : io_req_ptr;
    reply_ptr : io_reply_ptr;
    stop_driver : boolean;

    {
     NOTE: This is the unresolved global from YAPFX which
     "pulls in" the driver from the appropriate library
     }
    version : [global($YAVER)] packed array [1..6] of char;

    {
     Following defined in the YAPFX module and
     initialized by InitCSR call
     }
    csr : [external] ^drv11_csr;
    drprio : [external, readonly] integer;
    stdprio : [external, readonly] integer;
    vector_reqa : [external (reqa)] unsigned;
    vector_reqb : [external (reqb)] unsigned;
    maintenance : [external (maint)] boolean;

    procedure reply_to_requestor (request_ptr : io_req_ptr;
				  return_code : unsigned);
    var
	reply_desc: semaphore_desc;
	reply_ptr: io_reply_ptr;

      begin
	reply_ptr := request_ptr :: io_reply_ptr;
	reply_desc.id := request_ptr^.pkt.reply_sem;
	if (reply_desc.id.index = 0) { if no reply }
	  then deallocate_packet (packet_ptr := reply_ptr :: queue_ptr)
	  else
	    begin
	      { Use the same packet for reply }
	      reply_ptr^.pkt.status := return_code;
	      if fi$simple_reply in request_ptr^.pkt.ind_mod
		then
		  begin
		    signal (desc := reply_desc);
		    deallocate_packet (packet_ptr := reply_ptr :: queue_ptr);
		  end
		else put_packet (desc := reply_desc,
				 packet_ptr := reply_ptr :: queue_ptr);
	    end
      end { reply_to_requestor };
    [stack_size (200), context (MMU)]
    process drv11_io (io_mode:char);

	{
	 This process code is used with by both the YAARDR (reader) process
	 and the YAAWRT (writer) process. On creation of each of the processes
	 local variables (separate copies for each process) are initialized
	 for both the name of the interrupt binary semaphore, INT_NAME, and
	 the name of the request queue semaphore, QUE_NAME. The IO_MODE parameter
	 ( 'R' for reader, 'W' for writer ) determines whether a "reader" or
	 a "writer" process is being created.

	 The process waits on read or write requests from the Dispatcher which are
	 sent to QUE_NAME. It will process each request in entirety before
	 going on to the next request (queued in the meantime, if any).
	 When the specified number of words have been transferred, a reply
	 packet will be sent back to the requestor (if reply-semaphore given).
	 }

    var
	request : io_req_ptr;
	index, byte_count, word_count: integer;
	buf_par1_addr : physical_address;
	que_name : PACKED ARRAY[1..6] OF char;
	int_name : PACKED ARRAY[1..6] OF char;
	int_desc : semaphore_desc;
	reading : boolean;
	int_vector : unsigned;

      begin     {Following process specialization is only done once}
	{ after the reader/writer process is created and started.}

	que_name := '$YAA Q';
	que_name[5] := io_mode;
	if io_mode = 'R'
	  then
	    begin
	      reading := true;
	      int_name := '$YAAIB' ;   {DRV11 Interrupt REQ B}
	      int_vector := vector_reqb;
	    end
	  else
	    begin
	      reading := false;
	      int_name := '$YAAIA' ;   {DRV11 Interrupt REQ A}
	      int_vector := vector_reqa;
	    end;

	init_structure_desc (desc := int_desc, name := int_name);
	{
	 NOTE: Already created by name.
	 This sets up descriptor for
	 more efficient access.
	 }

	connect_semaphore (vector := int_vector,
			   ps   := drprio,
			   desc := int_desc);

	change_priority (stdprio);  { Lower to standard priority for DRV11 }

	while not stop_driver do    { Head of request processing loop }
	  begin
	    get_packet (name := que_name,
			packet_ptr := request :: queue_ptr);

	    byte_count := request^.buf_len;
	    map_par1_addr (request^.buffer_ptr, buf_par1_addr);

	    word_count :=  byte_count div 2;  { Note: integer division }

	    for index := 1 to word_count DO
	      begin
		if reading
		  then
		    begin
		      wait (desc := int_desc); { for interrupt }
		      get_word (inbuf_ptr^,  buf_par1_addr);
		      {
		       Move word from the device register to the user buffer.
		       NOTE: With loopback can now let the "writer" go ahead.
		       }
		      if maintenance
			then
			  begin
			    {
			     Must toggle to force interrupt--set REQA;
			     for debug only with loopback cable.
			     }
			    csr^.forcea := false;
			    csr^.forcea := true;
			  end;
		    end
		  else    {Writing}
		    begin
		      put_word( outbuf_ptr^,  buf_par1_addr );
		      {
		       Move word from the user buffer to the device register.
		       NOTE: With loopback this means the INBUF is new, too,
		       Therefore, force an INPUT interrupt.
		       }
		      if maintenance
			then
			  begin
			    csr^.forceb := false;
			    csr^.forceb := true;
			  end;

		      wait (desc := int_desc);
		    end;
		  { Here when OUTPUT done }
	      end;
	    { Completed the request; "signal" a reply. }

	    reply_to_requestor (request, es$nor);
	  end { Request processing loop };

      end { Process DRV11_IO };
    {
     The [INITIALIZE] procedure for the driver process creates the
     following semaphores:
     $YAA    Queue semaphore for all driver requests.
     $YAARQ  Queue semaphore for reads.
     $YAAWQ  Queue semaphore for writes.
     $YAARI  Binary semaphore signalled by read ISR.
     $YAAWI  Binary semaphore signalled by write ISR.
     }
    [initialize]
    procedure initdrv11;
      begin
	if not create_queue_semaphore ( name :='$YAA  ')
	or not create_queue_semaphore ( name := '$YAARQ')   {Read request}
	or not create_queue_semaphore ( name := '$YAAWQ')    {Write request}
	or not create_binary_semaphore ( name := '$YAAIA')   {Interrupt A}
	or not create_binary_semaphore ( name := '$YAAIB')   {Interrupt B}
	  then stop_driver := true
	  else stop_driver := false;
      end;


    PROCEDURE initcsr;EXTERNAL;     {Defined in YAPFX module}
  begin   { Static process Note: PRIORITY = 248 }

    initcsr;  { Sets up CSR and VECTOR addresses }

    inbuf_ptr::unsigned  :=  csr::unsigned + 4 ;  {Address computations}
    outbuf_ptr::unsigned :=  csr::unsigned + 2 ;

    if (version <> 'V02.00') or stop_driver
      then stop_driver := true
      else  { OK to proceed }
	begin
	  {
	   Create the reader and writer processes
	   }
	  drv11_io( name := 'YAARDR', priority := 249, io_mode := 'R' );
	  drv11_io( name := 'YAAWRT', priority := 249, io_mode := 'W' );

	  csr^.intenb := true;            {Enable (REQB)input interrupts}
	  csr^.intena := true;            {Enable (REQA)output interrupts}
	  change_priority (stdprio);
	end;

    while not stop_driver do        { Head of request processing loop }
      begin
	get_packet( name := '$YAA  ', packet_ptr := req_ptr :: queue_ptr);

	  case req_ptr^.pkt.oper of
	    if$read_physical,
	    if$read_logical:
			    put_packet( name := '$YAARQ',
				       packet_ptr := req_ptr::queue_ptr );
	    if$write_physical,
	    if$write_logical:
			     put_packet( name := '$YAAWQ',
					packet_ptr := req_ptr::queue_ptr );
	    if$set_char:
			{
			 Used to shut down the driver--
			 i.e., return structure space and
			 terminate all YA driver processes.
			 }
			stop_driver := TRUE;
	    if$get_char:
			  begin
			    reply_ptr := req_ptr :: io_reply_ptr;
			    reply_ptr^.pkt.class := id$real_time;
			    reply_ptr^.pkt.typ := ord(it$drv11);
			    reply_to_requestor (req_ptr, es$nor);
			  end;
	    otherwise
		     reply_to_requestor (req_ptr, es$ifn);
	  end;

      end;

    {
     Here if stop_driver = true, resulting from error
     in initialization or explicit stop request.
     }

    stop (name := 'YAARDR' );
    stop (name := 'YAAWRT' );
    destroy (name := '$YAA  ' );
    destroy (name := '$YAARQ' );
    destroy (name := '$YAAWQ' );
    destroy (name := '$YAAIA' );
    destroy (name := '$YAAIB' );

    {
     Falling through here with no dependent processes will
     terminate the Dispatcher static process and recovers
     its PCB space.
     }
  END.

                                                                                                                                                                                                                                                                                                                                                                             