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

     Modified:
      
	23-Apr-86 RLP KXJ support. Add dma$adrtype_option field to dma$address.
		      Use send by value if both addresses are not standard
		      local addresses. Add translate virtual to physical address
		      function.
	13-Aug-86 RLP Make it easier for the user. Translate any virtual
		      address to physical, even if the special addressing bits 
		      are not defaulted.
	29-Oct-86 RLP Remove include of IOPKTS.PAS, QDINC.PAS has its own 
		      request and reply packet declarations.
}
[SYSTEM(MICROPOWER)] MODULE $DMA;

{$NOLIST}
%include 'LB:exc.pas'		{ get the exception processing stuff }
%include 'LB:misc.pas'		{ get the get_config definitions }
{$LIST}
%include 'LB:qdinc.pas'	{ get the QD definitions }

[GLOBAL($TRVPH)] FUNCTION $tran_virt_phys;
	(*
	 * convert a virtual address to a physical address
	 *)
{	function $tran_virt_phys (virt_addr : unsigned) : long_integer;}
	type
	    foo_rec = record
			  low : unsigned;
			  high : unsigned;
		      end;

	    foo_ptr = ^ foo_rec;
	var
	    q : queue_semaphore_desc;
	    buffer : array[1..2] of char;
	    length : integer;
	    info : info_block;
	    dummy1 : integer;
	    config_info : hardware_config;
	    long_addr : long_integer;
	    bar : foo_ptr;
	    ok : boolean;
	  begin
	    get_config (clock_freq := dummy1,
			config := config_info);
	    long_addr := 0;
	    if config_info.mmu
	      then
		begin
	          ok := create_queue_semaphore(desc:=q);
	          bar := virt_addr :: foo_ptr;
	          send (ref_data := bar^,
		        ref_length := 2,
		        desc := q);
	          receive (ref_data := buffer,
		           ref_length := 2,
		           ret_info := info,
		           desc := q);
  	          destroy (desc:=q);
		  long_addr := info.address.par_value;
		  long_addr := long_addr * 64;
		  info.address.address := info.address.address MOD 8192;
		  long_addr := long_addr + info.address.address;
		end
	      else long_addr := virt_addr;
	    $tran_virt_phys := long_addr;
	  end;

[GLOBAL($DMAAL)] FUNCTION $DMA_ALLOCATE ;
{
 This function allocates the unit specified
 for exclusive use of this process.  The parameter is:

	( UNIT: DMA$UNIT_NUMBER := 0) : BOOLEAN;
}

VAR
  reply_semaphore, driver_semaphore : QUEUE_SEMAPHORE_DESC;
  request_packet : IO_REQ;
  reply_packet : IO_REPLY;
  proc_id : PROCESS_DESC;

LABEL 99;

BEGIN
  {
  Initialize the process descriptor, the driver 
  queue semaphore descriptor.
  }
  $DMA_ALLOCATE := FALSE;

  INIT_PROCESS_DESC(DESC := proc_id);

  INIT_STRUCTURE_DESC( DESC := driver_semaphore, NAME := '$QDA  ');

  IF NOT CREATE_QUEUE_SEMAPHORE (DESC := reply_semaphore) THEN
    BEGIN
      REPORT(EXC_INFO := 0, EXC_INFO_SIZE := 0,
	     EXC_TYPE := [RESOURCE], EXC_CODE := ES$NMK );
      GOTO 99
    END;
  {
  Initialize the request packet and send it.
  }
  WITH request_packet DO
    BEGIN
      IND_MOD := [];			{ want a standard reply, no retry }
      DEP_MOD := [];			{ want FM$TTO action }
      SEQUENCE := 0;			{ dont care about this }
      PID := proc_id.ID;		{ give handler proc id of requestor}
      UNIT_NUM := UNIT;			{ Fill in the Unit number}
      OPER := ALLOCATE;			{ Indicate a get status function }
      REPLY_SEM := reply_semaphore.id;	{ And reply to me }
    END;

  SEND ( DESC := driver_semaphore,	{ Now send the request to the driver }
         VAL_DATA := request_packet,
	 VAL_LENGTH := SIZE(request_packet)-6);

  RECEIVE ( DESC := reply_semaphore,
            VAL_DATA := reply_packet,
            VAL_LENGTH := SIZE(reply_packet) );

  IF ( reply_packet.status = es$nor ) THEN  { report success }
    $DMA_ALLOCATE := TRUE;

  DESTROY (DESC := reply_semaphore);

99:
END;

[GLOBAL($DMADL)] FUNCTION $DMA_DEALLOCATE ;
{
 This function deallocates the unit specified
 from exclusive use of this process.  The parameter is defined as: 

	UNIT: DMA$UNIT_NUMBER := 0) : BOOLEAN;
}

VAR
  reply_semaphore, driver_semaphore : QUEUE_SEMAPHORE_DESC;
  request_packet : IO_REQ;
  reply_packet : IO_REPLY;
  proc_id : PROCESS_DESC;

LABEL 99;

BEGIN
  {
  Initialize the process descriptor, the driver 
  queue semaphore descriptor.
  }
  $DMA_DEALLOCATE := FALSE;

  INIT_PROCESS_DESC(DESC := proc_id);

  INIT_STRUCTURE_DESC( DESC := driver_semaphore, NAME := '$QDA  ');

  IF NOT CREATE_QUEUE_SEMAPHORE (DESC := reply_semaphore) THEN
    BEGIN
      REPORT(EXC_INFO := 0, EXC_INFO_SIZE := 0,
	     EXC_TYPE := [RESOURCE], EXC_CODE := ES$NMK );
      GOTO 99
    END;
  {
  Initialize the request packet and send it.
  }
  WITH request_packet DO
    BEGIN
      IND_MOD := [];			{ want a standard reply, no retry }
      DEP_MOD := [];			{ want FM$TTO action }
      SEQUENCE := 0;			{ dont care about this }
      PID := proc_id.ID;		{ give handler proc id of requestor}
      UNIT_NUM := UNIT;			{ Fill in the Unit number}
      OPER := DEALLOCATE;		{ Indicate a get status function }
      REPLY_SEM := reply_semaphore.id	{ And reply to me }
    END;

  SEND ( DESC := driver_semaphore,	{ Now send the request to the driver }
         VAL_DATA := request_packet,
	 VAL_LENGTH := SIZE(request_packet)-6);

  RECEIVE ( DESC := reply_semaphore,
            VAL_DATA := reply_packet,
            VAL_LENGTH := SIZE(reply_packet) );

  IF ( reply_packet.status = es$nor ) THEN  { report success }
    $DMA_DEALLOCATE := TRUE;

  DESTROY (DESC := reply_semaphore);

99:
END;

[GLOBAL($DMAGS)] FUNCTION $DMA_GET_STATUS ;
{
 This function returns status information from
 the dma device into a user supplied buffer.

       (UNIT: DMA$UNIT_NUMBER := 0;
	VAR REGBUF: DMA$DEVICE_REGS;
	REGBUF_SIZE: INTEGER := DMA$REGBUF_SIZE;
	REPLY: DMA$SEM_POINTER := NIL
	) : BOOLEAN;
}

VAR
  reply_semaphore, driver_semaphore : QUEUE_SEMAPHORE_DESC;
  request_packet : IO_REQ;
  reply_packet : IO_REPLY;
  proc_id : PROCESS_DESC;
  use_my_semaphore : BOOLEAN;

LABEL 99;

BEGIN
  {
  Initialize the process descriptor, the driver 
  queue semaphore descriptor, and if necessary,
  create a queue semaphore descriptor for replys.
  }
  $DMA_GET_STATUS := TRUE;

  INIT_PROCESS_DESC(DESC := proc_id);

  INIT_STRUCTURE_DESC( DESC := driver_semaphore, NAME := '$QDA  ');

  use_my_semaphore := REPLY = NIL;
  IF use_my_semaphore THEN
    IF NOT CREATE_QUEUE_SEMAPHORE (DESC := reply_semaphore) THEN
      BEGIN
	REPORT(EXC_INFO := 0, EXC_INFO_SIZE := 0,
               EXC_TYPE := [RESOURCE], EXC_CODE := ES$NMK );
        $DMA_GET_STATUS := FALSE;
        GOTO 99
      END;
  {
  Initialize the request packet and send it.
  }
  WITH request_packet DO
    BEGIN
      IND_MOD := [];			{ want a standard reply, no retry }
      DEP_MOD := [];			{ want FM$TTO action }
      SEQUENCE := 0;			{ dont care about this }
      PID := proc_id.ID;		{ give handler proc id of requestor}
      UNIT_NUM := UNIT;			{ Fill in the Unit number}
      OPER := QD_GET_STATUS;		{ Indicate a get status function }
      IF use_my_semaphore THEN		{ Fill in the proper reply sem}
        REPLY_SEM := reply_semaphore.id
      ELSE
        REPLY_SEM := REPLY^.id;
    END;

  SEND ( DESC := driver_semaphore,	{ Now send the request to the driver }
         VAL_DATA := request_packet,
	 VAL_LENGTH := SIZE(request_packet)-6,
	 REF_DATA := REGBUF,
         REF_LENGTH := REGBUF_SIZE );

  IF use_my_semaphore THEN		{ If necessary wait for a reply }
    BEGIN
      RECEIVE ( DESC := reply_semaphore, { get the reply }
	        VAL_DATA := reply_packet,
	        VAL_LENGTH := SIZE(reply_packet) );

      IF ( reply_packet.status <> es$nor ) THEN  { and report any errors }
	$DMA_GET_STATUS := FALSE;

      DESTROY (DESC := reply_semaphore)
    END;
99:
END;

[GLOBAL($DMASR)] FUNCTION $DMA_SEARCH ;
{
 This function just searches.
 Control returns to the user after the search completes, unless 
 the reply field is specified; Otherwise control is returned
 immediatly and the semaphore is signaled appropriatly
 by the handler.  The parameter list is:

      ( SOURCE: DMA$ADDRESS;			 from address (either Q-BUS or II) 
	COUNT: DMA$BYTE_COUNT;			 byte count 
        VAL: UNSIGNED;				 search value 
        MASK: UNSIGNED := 0;			 **OPTIONAL** search mask 
	UNIT: DMA$UNIT_NUMBER := 0;		 **OPTIONAL** unit number 
	REPLY: DMA$SEM_POINTER := NIL		 **OPTIONAL** pointer to semaphore descriptor 
	) : DMA$BYTE_COUNT; 
}

VAR
  reply_semaphore, driver_semaphore : QUEUE_SEMAPHORE_DESC;
  request_packet : IO_REQ;
  reply_packet : IO_REPLY;
  proc_id : PROCESS_DESC;
  source_is_buffer : BOOLEAN;
  use_my_semaphore : BOOLEAN;
  dummy_address : DMA$ADDRESS;
  dummy_word : UNSIGNED;	{Dummy word for temporary storage of high
				 16 bits of a dma$address record}

LABEL 99;

BEGIN
  $DMA_SEARCH := 0;

  {
  Initialize the process descriptor and the driver 
  queue semaphore descriptor.
  }
  INIT_PROCESS_DESC(DESC := proc_id);

  INIT_STRUCTURE_DESC( DESC := driver_semaphore, NAME := '$QDA  ');
  {
  Set up a Boolean for whether the source is just a local buffer
  address (meaning a virtual address and all special addressing bits 
  defaulted = clear)
  }
  source_is_buffer := ( 0 = SOURCE::DMA$ALT_ADDRESS.REST ) and 
	(source.adrtyp = dma$virtual);
  {
  Create the reply semaphore if necessary
  }
  use_my_semaphore := REPLY = NIL;
  IF use_my_semaphore THEN
    IF NOT CREATE_QUEUE_SEMAPHORE (DESC := reply_semaphore) THEN
      BEGIN
	REPORT(EXC_INFO := 0, EXC_INFO_SIZE := 0,
               EXC_TYPE := [RESOURCE], EXC_CODE := ES$NMK );
        GOTO 99
      END;
  {
  Initialize the request packet and send it.
  }
  WITH request_packet DO
    BEGIN
      IND_MOD := [];			{ want a standard reply, no retry }
      DEP_MOD := [FM$TSO];		{ want FM$TSO action }
      SEQUENCE := 0;			{ dont care about this }
      PID := proc_id.ID;		{ give handler proc id of requestor}
      UNIT_NUM := UNIT;			{ Fill in the Unit number}
      PAT := VAL;			{ Fill in the Search Value }
      MSK := MASK;			{ Fill in the Search Mask }
      OPER := READ_FUNCTION;		{ Making this a read function }
      SLEN := COUNT;			{ For this many chars }
      
 {
  If source has a virtual address, convert it to a physical address
  }
      if source.adrtyp = dma$virtual then
	begin
	  dummy_address::long_integer := $tran_virt_phys (virt_addr := 
					source.low);
  {
  Clear out all but the special addressing bits in source
  }
          dummy_word := uand (source::dma$alt2_address.high,
				      %o'177600');
  {
  Or the special addressing bits with the high 6 bits of the address
  }
    	  dev_adr::dma$alt2_address.high := uor (dummy_word,
				dummy_address.high);
	  dev_adr.low := dummy_address.low;
	end
	  else
            DEV_ADR := SOURCE;	{ then we want to just use source as is}

      IF use_my_semaphore THEN		{ Fill in the proper reply sem}
        REPLY_SEM := reply_semaphore.id
      ELSE
        REPLY_SEM := REPLY^.id;
    END;

  SEND ( DESC := driver_semaphore,	{ Now send the request to the driver }
         VAL_DATA := request_packet,
	 VAL_LENGTH := SIZE(request_packet)-6);

  IF use_my_semaphore THEN		{ If necessary wait for a reply }
    BEGIN
      RECEIVE ( DESC := reply_semaphore, { get the reply }
	        VAL_DATA := reply_packet,
	        VAL_LENGTH := SIZE(reply_packet) );

      IF ( reply_packet.status = es$nor ) THEN  { and report count }
        $DMA_SEARCH := reply_packet.actual_length;

      DESTROY (DESC := reply_semaphore)
    END;
99:
END;

[GLOBAL($DMAST)] FUNCTION $DMA_SEARCH_TRANSFER ;
{
 This function transfers data from one place to another while searching.
 Control returns to the user after the transfer, unless 
 the reply field is specified; Otherwise control is returned
 immediatly and the semaphore is signaled appropriatly
 by the handler.

	SOURCE: DMA$ADDRESS;			from address (either Q-BUS or II)
	DEST: DMA$ADDRESS;			to address (either Q-BUS or II)
	COUNT: DMA$BYTE_COUNT;			byte count
        VAL: UNSIGNED;				search value
        MASK: UNSIGNED := 0;			**OPTIONAL** search mask
	UNIT: DMA$UNIT_NUMBER := 0;		**OPTIONAL** unit number
	REPLY: DMA$SEM_POINTER := NIL		**OPTIONAL** pointer to semaphore descriptor
	) : DMA$BYTE_COUNT; 
}

VAR
  reply_semaphore, driver_semaphore : QUEUE_SEMAPHORE_DESC;
  request_packet : IO_REQ;
  reply_packet : IO_REPLY;
  proc_id : PROCESS_DESC;
  use_my_semaphore : BOOLEAN;
  source_is_buffer, dest_is_buffer : BOOLEAN;
  buffer_pointer : BUF_POINTER;
  dummy_address : DMA$ADDRESS;
  dummy_word : UNSIGNED;	{Dummy word for temporary storage of high
				 16 bits of a dma$address record}

LABEL 99;

BEGIN
  $DMA_SEARCH_TRANSFER := 0;

  {
  Initialize the process descriptor and the driver 
  queue semaphore descriptor.
  }
  INIT_PROCESS_DESC(DESC := proc_id);

  INIT_STRUCTURE_DESC( DESC := driver_semaphore, NAME := '$QDA  ');
  {
  Set up Booleans for whether source and destination are just local buffer
  addresses (meaning a virtual address and all special addressing bits 
  defaulted = clear)
  }
  source_is_buffer := ( 0 = SOURCE::DMA$ALT_ADDRESS.REST ) and 
	(source.adrtyp = dma$virtual);
  dest_is_buffer := ( 0 = DEST::DMA$ALT_ADDRESS.REST ) and
	(dest.adrtyp = dma$virtual);
  {
  Create the reply semaphore if necessary
  }
  use_my_semaphore := REPLY = NIL;
  IF use_my_semaphore THEN
    IF NOT CREATE_QUEUE_SEMAPHORE (DESC := reply_semaphore) THEN
      BEGIN
        REPORT(EXC_INFO := 0, EXC_INFO_SIZE := 0,
	       EXC_TYPE := [RESOURCE], EXC_CODE := ES$NMK );
        GOTO 99
      END;
  {
  Initialize the request packet and send it.
  }
  WITH request_packet DO
    BEGIN
      IND_MOD := [];			{ want a standard reply, no retry }
      DEP_MOD := [FM$TTS];		{ want FM$TTS action }
      SEQUENCE := 0;			{ dont care about this }
      PID := proc_id.ID;		{ give handler proc id of requestor}
      UNIT_NUM := UNIT;			{ Fill in the Unit number}
      PAT := VAL;			{ Fill in the Search Value }
      MSK := MASK;			{ Fill in the Search Mask }
      
      IF use_my_semaphore THEN		{ Fill in the proper reply sem}
        REPLY_SEM := reply_semaphore.id
      ELSE
        REPLY_SEM := REPLY^.id;

      IF dest_is_buffer THEN		{ If the destination is a virtual
					  address with all special addressing
					  bits defaulted }
        BEGIN
  {
  Pass the dest buffer address by reference
  }
	  buffer_pointer := DEST.LOW::BUF_POINTER;
	  OPER := READ_FUNCTION;
  {
  If source has a virtual address, convert it to a physical address
  }
	  if source.adrtyp = dma$virtual then
	    begin
	      dummy_address::long_integer := $tran_virt_phys (virt_addr := 
					source.low);
  {
  Clear out all but the special addressing bits in source
  }
	      dummy_word := uand (source::dma$alt2_address.high,
				      %o'177600');
  {
  Or the special addressing bits with the high 6 bits of the address
  }
	      dev_adr::dma$alt2_address.high := uor (dummy_word,
				dummy_address.high);
	      dev_adr.low := dummy_address.low;
	    end
	  else
            DEV_ADR := SOURCE;	{ then we want to just use source as is}
	END

      ELSE				{ Otherwise.....}
        BEGIN
  {
  If destination address is virtual, convert it to physical
  }
	  if dest.adrtyp = dma$virtual then
 	    begin
	      dummy_address::long_integer := $tran_virt_phys (virt_addr := 
					dest.low);
  {
  Clear out all but the special addressing bits in dest
  }
	      dummy_word := uand (dest::dma$alt2_address.high,
				      %o'177600');
  {
  Or the special addressing bits with the high 6 bits of the address
  }
	      dev_adr::dma$alt2_address.high := uor (dummy_word,
				dummy_address.high);
	      dev_adr.low := dummy_address.low;
	    end
	    else
	      DEV_ADR := DEST;		
	  OPER := WRITE_FUNCTION;
	  if source_is_buffer then
	    buffer_pointer := SOURCE.LOW::BUF_POINTER
	  else 
	    begin
	      length := count;
	      if source.adrtyp = dma$virtual then
 	        begin
	          dummy_address::long_integer := $tran_virt_phys (virt_addr := 
					source.low);
  {
  Clear out all but the special addressing bits in source
  }
		  dummy_word := uand (source::dma$alt2_address.high,
				      %o'177600');
  {
  Or the special addressing bits with the high 6 bits of the address
  }
		  dev_adr2::dma$alt2_address.high := uor (dummy_word,
				dummy_address.high);
	          dev_adr2.low := dummy_address.low;
	        end
	        else
	          dev_adr2 := source;	{ have a physical address - just fill 
					  it in and send by value }
           end;
	END;
    END;

  {
  If either address was passed as a virtual address with all special addressing
  bits defaulted, send by reference to pass one address as a virtual address to 
  the driver.
  }

  if (source_is_buffer or dest_is_buffer) then
    SEND ( DESC := driver_semaphore,	{ Now send the request to the driver }
         VAL_DATA := request_packet,
	 VAL_LENGTH := SIZE(request_packet)-6,
	 REF_DATA := buffer_pointer^,
         REF_LENGTH := COUNT )
  else
    send (desc := driver_semaphore,	{ Have 2 physical address with special
	  				  bits - just send by value}
	  val_data := request_packet,
	  val_length := size (request_packet));
	  
  IF use_my_semaphore THEN		{ If necessary wait for a reply }
    BEGIN
      RECEIVE ( DESC := reply_semaphore, { get the reply }
	        VAL_DATA := reply_packet,
	        VAL_LENGTH := SIZE(reply_packet) );

      IF ( reply_packet.status = es$nor ) THEN  { and report count }
        $DMA_SEARCH_TRANSFER := reply_packet.actual_length;

      DESTROY (DESC := reply_semaphore)
    END;
99:
END;

[GLOBAL($DMATR)] FUNCTION $DMA_TRANSFER ;
{
 This function transfers data from one place to another.
 Control returns to the user after the transfer, unless 
 the reply field is specified; Otherwise control is returned
 immediatly and the semaphore is signaled appropriatly
 by the handler.

	SOURCE: DMA$ADDRESS;			from address (either Q-BUS or II)
	DEST: DMA$ADDRESS;			to address (either Q-BUS or II)
	COUNT: DMA$BYTE_COUNT;			byte count
	UNIT: DMA$UNIT_NUMBER := 0;		**OPTIONAL** unit number
	REPLY: DMA$SEM_POINTER := NIL		**OPTIONAL** pointer to semaphore descriptor
	) : DMA$BYTE_COUNT;
}

VAR
  reply_semaphore, driver_semaphore : QUEUE_SEMAPHORE_DESC;
  request_packet : IO_REQ;
  reply_packet : IO_REPLY;
  proc_id : PROCESS_DESC;
  use_my_semaphore : BOOLEAN;
  source_is_buffer, dest_is_buffer : BOOLEAN;
  buffer_pointer : BUF_POINTER;
  dummy_address : DMA$ADDRESS;
  dummy_word : UNSIGNED;	{Dummy word for temporary storage of high
				 16 bits of a dma$address record}

LABEL 99;

BEGIN
  {
  Initialize the process descriptor and the driver 
  queue semaphore descriptor.
  }
  $DMA_TRANSFER := 0;

  INIT_PROCESS_DESC(DESC := proc_id);

  INIT_STRUCTURE_DESC( DESC := driver_semaphore, NAME := '$QDA  ');
  {
  Set up Booleans for whether source and destination are just local buffer
  addresses (meaning a virtual address and all special addressing bits 
  defaulted = clear)
  }
  source_is_buffer := ( 0 = SOURCE::DMA$ALT_ADDRESS.REST ) and 
	(source.adrtyp = dma$virtual);
  dest_is_buffer := ( 0 = DEST::DMA$ALT_ADDRESS.REST ) and
	(dest.adrtyp = dma$virtual);

  {
  Create the reply semaphore if necessary
  }
  use_my_semaphore := REPLY = NIL;
  IF use_my_semaphore THEN
    IF NOT CREATE_QUEUE_SEMAPHORE (DESC := reply_semaphore) THEN
      BEGIN
        REPORT(EXC_INFO := 0, EXC_INFO_SIZE := 0,
	       EXC_TYPE := [RESOURCE], EXC_CODE := ES$NMK );
        GOTO 99
      END;
  {
  Initialize the request packet and send it.
  }
  WITH request_packet DO
    BEGIN
      IND_MOD := [];			{ want a standard reply, no retry }
      DEP_MOD := [];			{ want FM$TTO action }
      SEQUENCE := 0;			{ dont care about this }
      PID := proc_id.ID;		{ give handler proc id of requestor}
      UNIT_NUM := UNIT;			{ Fill in the Unit number}
      
      IF use_my_semaphore THEN		{ Fill in the proper reply sem}
        REPLY_SEM := reply_semaphore.id
      ELSE
        REPLY_SEM := REPLY^.id;

      IF dest_is_buffer THEN		{ If the destination is a virtual
					  address with all special addressing
					  bits defaulted }
        BEGIN
  {
  Pass the dest buffer address by reference
  }
	  buffer_pointer := DEST.LOW::BUF_POINTER;
	  OPER := READ_FUNCTION;
  {
  If source has a virtual address, convert it to a physical address
  }
	  if source.adrtyp = dma$virtual then
	    begin
	      dummy_address::long_integer := $tran_virt_phys (virt_addr := 
					source.low);
  {
  Clear out all but the special addressing bits in source
  }
	      dummy_word := uand (source::dma$alt2_address.high,
				      %o'177600');
  {
  Or the special addressing bits with the high 6 bits of the address
  }
	      dev_adr::dma$alt2_address.high := uor (dummy_word,
				dummy_address.high);
	      dev_adr.low := dummy_address.low;
	    end
	  else
            DEV_ADR := SOURCE;	{ then we want to just use source as is}
	END

      ELSE				{ Otherwise.....}
        BEGIN
  {
  If destination address is virtual, convert it to physical
  }
	  if dest.adrtyp = dma$virtual then
 	    begin
	      dummy_address::long_integer := $tran_virt_phys (virt_addr := 
					dest.low);
  {
  Clear out all but the special addressing bits in dest
  }
	      dummy_word := uand (dest::dma$alt2_address.high,
				      %o'177600');
  {
  Or the special addressing bits with the high 6 bits of the address
  }
	      dev_adr::dma$alt2_address.high := uor (dummy_word,
				dummy_address.high);
	      dev_adr.low := dummy_address.low;
	    end
	    else
	      DEV_ADR := DEST;		
	  OPER := WRITE_FUNCTION;
	  if source_is_buffer then
	    buffer_pointer := SOURCE.LOW::BUF_POINTER
	  else 
	    begin
	      length := count;
	      if source.adrtyp = dma$virtual then
 	        begin
	          dummy_address::long_integer := $tran_virt_phys (virt_addr := 
					source.low);
  {
  Clear out all but the special addressing bits in dest
  }
		  dummy_word := uand (source::dma$alt2_address.high,
				      %o'177600');
  {
  Or the special addressing bits with the high 6 bits of the address
  }
		  dev_adr2::dma$alt2_address.high := uor (dummy_word,
				dummy_address.high);
	          dev_adr2.low := dummy_address.low;
	        end
	        else
	          dev_adr2 := source;	{ have a physical address - just fill 
					  it in and send by value }
           end;
	END;
    END;

  {
  If either address was passed as a virtual address with all special addressing
  bits defaulted, send by reference to pass one address as a virtual address to 
  the driver
  }

  if (source_is_buffer or dest_is_buffer) then

    SEND ( DESC := driver_semaphore,	{ Now send the request to the driver }
         VAL_DATA := request_packet,
	 VAL_LENGTH := SIZE(request_packet)-6,
	 REF_DATA := buffer_pointer^,
         REF_LENGTH := COUNT )
  else

  {
  Both addresses are physical, so send the packet by value only, so the driver
  knows it
  }

    send (desc := driver_semaphore,	{ Have 2 physical address with special
	  				  bits - just send by value}
	  val_data := request_packet,
	  val_length := size (request_packet));
	  

  IF use_my_semaphore THEN		{ If necessary wait for a reply }
    BEGIN
      RECEIVE ( DESC := reply_semaphore, { get the reply }
	        VAL_DATA := reply_packet,
	        VAL_LENGTH := SIZE(reply_packet) );

      IF ( reply_packet.status = es$nor ) THEN  { and report count }
        $DMA_TRANSFER := reply_packet.actual_length;

      DESTROY (DESC := reply_semaphore)
    END;
99:
END;
END.
                                                                                                           