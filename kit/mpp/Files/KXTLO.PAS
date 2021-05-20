    [system(micropower)] module kxtload;

    {
     Edit Level 0

     Copyright (c) 1984, 1986 by DIGITAL EQUIPMENT CORPORATION,
     Maynard, Massachusetts.  All Rights Reserved.

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


     Module name: KXTLO.PAS

     System: MicroPower/Pascal

     Author: SH

     Modified:
      6-Feb-85 ERS  Bug fixes (multi-segment mim files, I&D space, skip boot)
     23-Apr-86 RSR  Add KXJ_LOAD.
     Functional Description:

     Load a KXT11-CA or KXJ11-CA over the Q-Bus

     This procedure reads in a MIM file and commands the KXT/KXJ 
     native firmware to DMA each block into it's local memory. When 
     the entire MIM file has been loaded into the KXT/KXJ's memory, 
     the Q-Bus Odt commands are issued to the KXT/KXJ that cause it 
     to start the application. (A jump to the address in location 24 octal).
     For a KXT, only unmapped applications can be loaded. For a KXJ,
     both unmapped and mapped applications can be loaded.

     User Interface

     The user gains access to this load procedure by including the
     definition file MISC.PAS, found the kit area, in their PASCAL
     source, and merging this file with their source module at build
     time.

     The only restriction that applies to the user program is that
     it must be DEVICE, DRIVER, or PRIVLEDGED mapped.  This procedure
     must have access to the I/O page, to access the KXT11-CA control
     registers. (see mapping attributes, and this only applys
     to mapped systems)
     }
    %include 'LB:EXC.PAS'
{**********************************************************************
**********************************************************************}

    %include 'LB:MISC.PAS'	

{**********************************************************************
**********************************************************************}
type
	iop_type = (kxt_iop,kxj_iop);

procedure iop_load(kxt_addr : unsigned;
		    var mimf : [readonly]packed array[l..u:integer] of char;
		    var status : exc_status := 0;
 		    iop_select:iop_type); forward;

[global($kxtlo)]
 procedure kxt_load;
  begin
  iop_load(kxt_addr,
	   mimf,
	   status,
           kxt_iop);
  end;

[global($kxjlo)]
 procedure kxj_load;
 begin
 iop_load(kxj_addr,
          mimf,
	  status,
	  kxj_iop);
 end;

    procedure iop_load;
	(*
	 * KXT Control
	 *
	 * The kxt is controlled via a 4 word CSR area on the
	 * KXT, that is being processed by the KXT's native
	 * firmware.  The 4 words contain COMMAND, STATUS,
	 * GEN2, and GEN3 (Where GEN = General Purpose)
	 *)

    const
	KXT_CMD_DMA = %O'2';  { dma load }
	KXT_CMD_INIT= %O'4';  { re-initialize }
	CMD_INIT_WAIT = %O'6'; { Enter wait state, (reg 3 value, init parameter) }
	KXT_CMD_ODT = %O'10';  { Enter ODT }
	KXT_ODT_GOE = %O'10';  { Go and Exit ODT mode }
	IOP_CMD_WHAT = %O'2000'; { What are you command - illegal command on the
				  KXT, returns a 1 in TPR3 for the KXJ}

    type
	state_code = (kxt_state_iso,  { - init or serial ODT }
		      kxt_state_ast,  { - auto self test }
		      kxt_state_qct,  { - qbus controlled test }
		      kxt_state_odt,  { - qbus ODT mode  }
		      kxt_state_wfc,  { - wait for command }
		      kxt_state_t58,  { - loading from tu58 }
		      kxt_state_nu1,  { - not used }
		      kxt_state_eac  { - executing application } );

	kxt_stat_reg = packed record
				  state : [pos(0),bit(3)] state_code; { state }
				  stk_err : [pos(3),bit] boolean; { stack error flag }
				  odt_halt : [pos(4),bit] boolean; { enter odt on halt }
				  fatal_err : [pos(5),bit] boolean; { fatal error flag }
				  nu_by_prog : [pos(6),bit(7)] 0..1; { not used }
				  dma_err : [pos(14),bit] boolean; { dma load error flag }
				  cmd_err : [pos(15),bit] boolean; { command error flag }
			      end;

    type
	kxt_cntr_area = packed record
				   cmd : unsigned;  { Command Register }
				   stat : kxt_stat_reg; { Status Register }
				   gen2 : unsigned;  { General Sys Control Reg 2 }
				   gen3 : unsigned;  { General Sys Control Reg 3 }
			       end;

	kxt_cntr_pt = ^kxt_cntr_area;
	(*
	 * DMA control block
	 * When the tag value and address of a DMA control
	 * block is written in general registers 2 and 3 ,
	 * and then a DMA command is given to a KXT control
	 * area, the arbitor causes a DMA operation.  The
	 * operation performed is defined by a DMA control block
	 * which is made up of the following:
	 *
	 * Reload control
	 * is a single word where each bit in it selects
	 * a different parameter to be loaded.  The DMA controller
	 * begins with the most significant bit and works toward the
	 * least.  At each bit, if it's set then the associated
	 * parameter gets loaded from the list of parameters following
	 * the reload word.  This programs only needs to load a single
	 * combination of parameters which is ARA TAG, ARA OFFSET,
	 * ARB TAG, ARB OFFSET, WORD COUNT, CHANNEL STATUS LOW, and
	 * finally CHANNEL STATUS HIGH.
	 *)

    const
	RELOAD_VAL = %O'1602';

    type
	tag_value = packed record
			       nused1: [pos(0),bit] 0..1; { not used }
			       waits : [pos(1),bit(2)] 0..3; { wait state code }
			       nused2: [pos(3),bit(5)] 0..1; { not used }
			       highad: [pos(8),bit(6)] 0..%O'77'; { address 16-21 }
			       io_sel: [pos(14),bit(1)] 0..1; { I/O page select }
			       qb_sel: [pos(15),bit(1)] 0..1; { qbus select }
			   end;
	(*
	 * Channel control low
	 * set to a value that causes the DMA to do a
	 * transfer from ARB to ARA (flip bit), and to
	 * transfer continuously until finished.
	 *)
    const
	CC_LOW = %O'60';

	(*
	 * Channel control high
	 * set to a value that causes the DMA to proceed
	 * according to the `transfer type' selection, and
	 * ignores the hardware request input
	 *)
	CC_HIGH = %O'30';

    type
	dma_cntr_blk = packed record
				  reload : unsigned;  { reload specification }
				  ara_tag : tag_value; { ara tag value }
				  ara_ofst : unsigned; { ara offset (kxt address)}
				  arb_tag : tag_value; { arb tag value }
				  arb_ofst : unsigned; { arb offset (qbus address)}
				  opcount : unsigned;  { word transfer count }
				  chan_high : unsigned; { Channel control high }
				  chan_low : unsigned; { Channel control low }
			      end;
    label
	99;

    type
	block = packed array [0..255] of unsigned;

    var
	open_file : boolean;
	mim_file : file of block;

	segtab_buf  : ^block;
	next_segtab_block : unsigned; { next segment buf block number }

	text_buf : ^block;  { Buffer for Text areas }
	next_text_block : unsigned; { next text buf block number }

	kxt_cntr : kxt_cntr_pt;
	start_address : unsigned; { start address on KXT }
	error_status : exc_status;
	(*
	 * Abort this procedure, filling in the return status
	 *)
	procedure error_exit (error_status : exc_status);
	type
	    pain_full = ^ exc_status;
	var
	    i : integer;
	  begin
	    i::pain_full := address (status);
	    if i <> 0
	      then status := error_status
	      else
		if error_status.exc_code <> ES$NOR
		  then report (exc_type := error_status.exc_type,
			       exc_code := error_status.exc_code,
			       exc_info := 0, exc_info_size := 0);
	    goto 99;
	  end;
	(*
	 * convert a virtual address to a physical address
	 *)
	function tran_virt_phys (virt_addr : unsigned) : long_integer;
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
	    get_config (clock_freq := dummy1,
			config := config_info);
	    long_addr := 0;
	    if config_info.mmu
	      then
		begin
		  long_addr := info.address.par_value;
		  long_addr := long_addr * 64;
		  info.address.address := info.address.address MOD 8192;
		  long_addr := long_addr + info.address.address;
		end
	      else long_addr := virt_addr;
	    tran_virt_phys := long_addr;
	  end;
	(*
	 * Convert physical address to a tag value
	 *)
	function get_tag_value (phys_addr : long_integer) : tag_value;
	type
	    foo_rec = record
			  low : unsigned;
			  high : unsigned;
		      end;
	var
	    foo : foo_rec;
	    temp : unsigned;
	  begin
	    foo := phys_addr :: foo_rec;
	    temp := foo.high * 256;
	    get_tag_value := temp :: tag_value;
	  end;



	(*
	 * Send a command to the kxt
	 * wait until it is complete
	 *)
	procedure send_command (command : unsigned);
	  begin
	    kxt_cntr^.cmd := command;
	    while kxt_cntr^.cmd <> 0 do ;
	  end;




	(*
	 * Start the kxt
	 *)
	procedure start_kxt;
	  begin
	    send_command (KXT_CMD_ODT);
	    kxt_cntr^.gen3 := start_address;
	    kxt_cntr^.cmd := KXT_ODT_GOE;
	  end;

	(*
	 * Verify that the KXT is available
	 * and open the .MIM file
	 *)
	procedure verify_and_open;
	var
	    i : integer;
	    b_temp : boolean;
	    iop_select_temp : iop_type;
	  begin
	    mim_file :: integer := 0;
	    open (mim_file, mimf, buffersize := 512,
		  access_method := direct, status := error_status);
	    if error_status.exc_code <> ES$NOR
	      then error_exit(error_status);
	    reset (mim_file);
	    open_file := true;
	    read (mim_file, segtab_buf^);
	    if (segtab_buf^[0] =  %o'240')   { does file contain a bootstrap? }
	      then  { skip over the boot }
		begin
		  next_segtab_block := segtab_buf^[43] + 2;
		  find (mim_file, next_segtab_block);
		  read (mim_file, segtab_buf^);
		  next_segtab_block := next_segtab_block + 1
		end
	      else next_segtab_block := 2;
	    next_text_block := next_segtab_block + 1; { 1st text block }

	    { make sure 1st word block contain RAD50 "MIM" }
	    {if (segtab_buf^[0] = %O'51265') and (uand(segtab_buf^[1],1) = 0)}
	    iop_select_temp := iop_select;
	    case iop_select of
	     kxt_iop : b_temp:= 
			  ((segtab_buf^[0] = %O'51265') and 
				(uand(segtab_buf^[1],1) = 0));
	     kxj_iop : begin
			b_temp := (segtab_buf^[0] = %O'51265');
			if (uand(segtab_buf^[1],1) = 0) 
			 then iop_select_temp := kxt_iop;
			end;
	     end;
	     if b_temp
	      then
		begin
		  { Now verify that the KXT is in the correct state }
		  kxt_cntr^.gen3 := cmd_init_wait;
		  send_command (KXT_CMD_INIT);
		  while (kxt_cntr^.stat.state <> kxt_state_wfc) do ;
		end
	      else
		begin
		  error_status.exc_type := [HARD_IO];
		  error_status.exc_code := ES$FOR; { file format error }
		  error_exit(error_status);
		end;

	{Check for correct IOP type}
		send_command (IOP_CMD_WHAT);
		{Check IOP type - b_temp false if not a match}
		case iop_select of
		   kxt_iop: b_temp := kxt_cntr^.stat.cmd_err; { should
				get a command error on the KXT}
		   kxj_iop: b_temp := (not kxt_cntr^.stat.cmd_err) and
				(kxt_cntr^.gen2 = 1);	{ should be no error
					and type of 1 returned in TPR3}
		   end;
		if not b_temp then
		  begin
		    error_status.exc_type := [HARD_IO];
		    error_status.exc_code := ES$IVM; { invalid mode - wrong
						      IOP type}
		    error_exit(error_status);
		  end
		  else iop_select := iop_select_temp;
	  end;
	(*
	 * Down Load the MIM file
	 * cycles through the mim file that has been opened
	 * and sends DMA commands to the KXT for each segment.
	 *)
	procedure down_load_kxt;
	type
	    foo_rec = record
			  low : unsigned;
			  high : unsigned;
		      end;
	var
	    seg_address : unsigned;
	    seg_size : unsigned;
	    segtab_index : integer;
	    byte_count : integer;
	    this_len : unsigned;
	    saved_buffer_addr, buffer_addr : long_integer;
	    buffer_tag : tag_value;
	    kxt_dma : dma_cntr_blk; { DMA control block }
	    dma_cntr_tag : tag_value; { tag value of kxt_dma }
	    dma_cntr_ofst : unsigned; { offset value of kxt_dma }
	    dummy : unsigned;
	  begin
	    (*
	     * get physical address DMA control block
	     *)
	    dummy := (address(kxt_dma)) :: unsigned;
	    buffer_addr := tran_virt_phys (virt_addr := dummy);
	    dma_cntr_tag := get_tag_value (buffer_addr);
	    dma_cntr_tag.qb_sel := 1;
	    with buffer_addr::foo_rec do dma_cntr_ofst := low;
	    (*
	     * get physical address of internal buffer
	     *)
	    dummy := text_buf :: unsigned;
	    saved_buffer_addr := tran_virt_phys (virt_addr := dummy);

	    segtab_index := 5;
	    seg_address := segtab_buf^[segtab_index];
	    segtab_index := segtab_index + 1;
	    seg_size := segtab_buf^[segtab_index];
	    segtab_index := segtab_index + 1;

	    byte_count := 0;
	    while (seg_address <> %O'177777') do
	      begin
		while (seg_size <> 0) do
		  begin
		    if byte_count = 0
		      then
			begin
			  find (mim_file,next_text_block);
			  read (mim_file,text_buf^);
			  next_text_block := next_text_block + 1;
			  byte_count := 512;
			end;
		    if (seg_size >= byte_count)
		      then this_len := byte_count
		      else this_len := seg_size;

		    buffer_addr := saved_buffer_addr + 512 - byte_count;
		    buffer_tag := get_tag_value (buffer_addr);
		    buffer_tag.qb_sel := 1;

		    with kxt_dma do
		    (*
		     * setup DMA control block
		     *)
		      begin
			reload := RELOAD_VAL;
			ara_tag := tag_value(0,0,0,0,0,0);
			ara_ofst := seg_address;
			arb_tag := buffer_tag;
			with buffer_addr::foo_rec do arb_ofst := low;
			opcount := this_len div 2;
			chan_high := CC_HIGH;
			chan_low := CC_LOW;
		      end;
		    kxt_cntr^.gen2 := dma_cntr_ofst;
		    kxt_cntr^.gen3 := dma_cntr_tag :: unsigned;
		    send_command (KXT_CMD_DMA);

		    if (seg_address = 0)
		      then start_address := text_buf^[10];
		    seg_size := seg_size - this_len;
		    seg_address := seg_address + this_len;
		    byte_count := byte_count - this_len;
		  end;

		seg_address := segtab_buf^[segtab_index];
		segtab_index := segtab_index + 1;
		if (segtab_index = 256)
		  then
		    begin
		      find (mim_file, next_segtab_block);
		      read (mim_file, segtab_buf^);
		      segtab_index := 0;
		    end;
		seg_size := segtab_buf^[segtab_index];
		segtab_index := segtab_index + 1;
	      end;
	  end;
	(*
	 * Down Load the MIM file
	 * cycles through the mim file that has been opened
	 * and sends DMA commands to the KXJ for each segment.
	 *)
	procedure down_load_kxj;
	type
	    foo_rec = record
			  low : unsigned;
			  high : unsigned;
		      end;
	var
	    seg_address : long_integer;
	    seg_size : long_integer;
	    segtab_index : integer;
	    byte_count : integer;
	    this_len : unsigned;
	    saved_buffer_addr, buffer_addr : long_integer;
	    buffer_tag : tag_value;
	    kxt_dma : dma_cntr_blk; { DMA control block }
	    dma_cntr_tag : tag_value; { tag value of kxt_dma }
	    dma_cntr_ofst : unsigned; { offset value of kxt_dma }
	    dummy : unsigned;
	  begin
	    (*
	     * get physical address DMA control block
	     *)
	    dummy := (address(kxt_dma)) :: unsigned;
	    buffer_addr := tran_virt_phys (virt_addr := dummy);
	    dma_cntr_tag := get_tag_value (buffer_addr);
	    dma_cntr_tag.qb_sel := 1;
	    with buffer_addr::foo_rec do dma_cntr_ofst := low;
	    (*
	     * get physical address of internal buffer
	     *)
	    dummy := text_buf :: unsigned;
	    saved_buffer_addr := tran_virt_phys (virt_addr := dummy);

	    segtab_index := 5;
	    seg_address := segtab_buf^[segtab_index];
	    seg_address := seg_address * 64;
	    segtab_index := segtab_index + 1;
	    seg_size := segtab_buf^[segtab_index];
	    seg_size := seg_size * 64;
	    segtab_index := segtab_index + 1;

	    byte_count := 0;
	    while (seg_address <> %O'17777700') do
	      begin
		while (seg_size <> 0) do
		  begin
		    if byte_count = 0
		      then
			begin
			  find (mim_file,next_text_block);
			  read (mim_file,text_buf^);
			  next_text_block := next_text_block + 1;
			  byte_count := 512;
			end;
		    if (seg_size >= byte_count)
		      then this_len := byte_count
		      else this_len := ushort(seg_size);

		    buffer_addr := saved_buffer_addr + 512 - byte_count;
		    buffer_tag := get_tag_value (buffer_addr);
		    buffer_tag.qb_sel := 1;

		    with kxt_dma do
		    (*
		     * setup DMA control block
		     *)
		      begin
			reload := RELOAD_VAL;
			ara_tag := get_tag_value(seg_address);
			with seg_address::foo_rec do ara_ofst := low;
			arb_tag := buffer_tag;
			with buffer_addr::foo_rec do arb_ofst := low;
			opcount := this_len div 2;
			chan_high := CC_HIGH;
			chan_low := CC_LOW;
		      end;
		    kxt_cntr^.gen2 := dma_cntr_ofst;
		    kxt_cntr^.gen3 := dma_cntr_tag :: unsigned;
		    send_command (KXT_CMD_DMA);

		    if (seg_address = 0)
		      then start_address := text_buf^[10];
		    seg_size := seg_size - this_len;
		    seg_address := seg_address + this_len;
		    byte_count := byte_count - this_len;
		  end;

		seg_address := segtab_buf^[segtab_index];
		seg_address := seg_address * 64;
		segtab_index := segtab_index + 1;
		if (segtab_index = 256)
		  then
		    begin
		      find (mim_file, next_segtab_block);
		      read (mim_file, segtab_buf^);
		      segtab_index := 0;
		    end;
		seg_size := segtab_buf^[segtab_index];
		seg_size := seg_size * 64;
		segtab_index := segtab_index + 1;
	      end;
	  end;
      begin
	error_status.exc_type := [SOFT_IO];
	error_status.exc_code := ES$NOR;
	open_file := false;
	new (segtab_buf);
	new (text_buf);

	start_address := 0;
	kxt_cntr := kxt_addr :: kxt_cntr_pt;

	verify_and_open;
	case iop_select of
	 kxt_iop : down_load_kxt;
	 kxj_iop : down_load_kxj;
	 end;
	start_kxt;
	error_exit(error_status);
99:
	if open_file
	  then close (mim_file);
	dispose (segtab_buf);
	dispose (text_buf);
      end;
end.
                                                                                                                                                                                                                                                                                                                       