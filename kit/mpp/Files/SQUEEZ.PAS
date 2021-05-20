    [System(Micropower)] Module squeeze (input, output);

    {
     Edit Level 0

     Copyright (c) 1985, 1986
     by DIGITAL EQUIPMENT CORPORATION,
     Maynard, Massachusetts.
     All Rights Reserved.

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


     Module name: SQUEEZ.PAS

     System: MicroPower/Pascal

     Author: ERS  Creation date: 29-Jan-85

     Modified:

     Functional Description:

     This procedure performs a squeeze of a RT-11 structured disk.

     BUILD NOTE:
     This procedure uses plenty of heap (DATA_SPACE Approximatly 5200 bytes)
     This requires the module GETSET.PAS
     }
    %include 'LB:iopkts.pas'

    %include 'LB:exc.pas'
    %include 'LB:gsinc.pas'
    [global ($squez)]
    procedure squeeze_directory
	(var strng : [readonly] packed array [l..u:integer] of char;
	 var status : exc_status := 0);

    const
	(*
	 * size of the read/write buffer
	 * must be a multiple of 512.
	 *)
	BUFFER_SIZE = 2048;

	MAX_BAD_FILES = 10 { # of .BAD files allowed };

	DIR_OFFSET = 4; {  2 * segment # + Starting block of RT-11 directories }

	{ Directory status bits }
	TENTATIVE_FILE = %O'400';
	EMPTY_FILE = %O'1000';
	PERMANENT_FILE = %O'2000';
	END_OF_SEGMENT = %O'4000';
	PROT_PERMANENT_FILE = %O'102000';

    label
	50, 99;

    type
	data_buffer_type = packed array [1..BUFFER_SIZE] of char;

	entry = record
		    status,
		    name1,
		    name2,
		    exten,
		    length,
		    active,
		    date    : unsigned;
		end;
	dseg = record
		   total_segments : integer;
		   next_segment : integer;
		   highest_seg_in_use : integer;
		   extra_bytes_per_entry : integer;
		   files_start_block : unsigned;
		   entries : array [1..72] of entry;
		   end_status : integer;
		   junk : array [1..2] of integer;
	       end;

	file_entry = record
			 rt_entry : entry;
			 start_block : unsigned;
		     end;

	bad_entry = record
			start_block : unsigned;
			size : unsigned;
		    end;

	bad_table_type = record
			     count : 0..MAX_BAD_FILES { # of .BAD files };
			     save_index : 1..MAX_BAD_FILES { saved current index };
			     table : array [1..MAX_BAD_FILES] of bad_entry;
			 end;

    const
	END_ENTRY = entry ( END_OF_SEGMENT, 0, 0, 0, 0, 0, 0);
	EMPTY_ENTRY = entry ( EMPTY_FILE,
			     %O'325', { name = ' EMPTYFIL' }
			     %O'63471',
			     %O'23364',
			     0, { dummy length }
			     0, { dummy channel word }
			     0 { dummy date } );

	BAD_FILE_ENTRY = entry ( PERMANENT_FILE,
				%O'23364', { name = 'FILE  BAD' }
				%O'17500',
				%O'6254',
				0, { dummy length }
				0, { dummy channel word }
				0 { dummy date } );

    var
	device_sdb : queue_semaphore_desc;
	unit : integer;
	device_size : unsigned;

	reply : structure_desc;

	data_buffer : ^ data_buffer_type;
	segment_buffer1, in_seg : ^dseg;
	in_seg_valid : boolean;

	bad_table : bad_table_type;

	current_segment : integer;
	current_index : integer;
	current_free_size : unsigned;
	current_start_block : unsigned;

	this_entry : file_entry;
	cop_status : unsigned;

	error_status : exc_status;
	created_sem, allocated_bufs : boolean;
	(*
	 * convert a I/O error to exc_status
	 *)
	function status_convert (code : unsigned) : exc_status;
	type
	    exception_code_type = packed record
					     c : [pos(0), bit(11)] 0..2047;
					     t : [pos(11), bit(5)] 0..31;
					 end;
	var
	    temp_code : exception_code_type;
	  begin
	    status_convert.exc_code := ES$NOR;
	    status_convert.exc_type := [];
	    if code <> ES$NOR
	      then
		begin
		  temp_code := code :: exception_code_type;
		  status_convert.exc_type := [(temp_code.t - 1)::exceptions];
	  	  status_convert.exc_code := code;
		end;
	  end;



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
	 *
	 *)
	function doio (operation : io$function;
		       block_number : unsigned;
		       length : unsigned;
		       var buffer : universal) : exc_status;
	var
	    io_request : io$req;
	    io_reply : io$reply;

	  begin
	    with io_request do
	      begin
		oper := operation;
		dep_mod := [];
		ind_mod := [];
		unit_num := unit;
		sequence := 24+23;
		reply_sem := reply.id;
		dev_addr.block_num := block_number;
	      end;
	    send (ref_data := buffer,
		  ref_length := length,
		  priority := 20,
		  val_data := io_request,
		  val_length := size(io$req),
		  desc := device_sdb);
	    receive (val_data := io_reply,
		     val_length := size(io_reply),
		     desc := reply);
	    doio := status_convert (io_reply.status);
	  end;
	(*
	 * read from the disk
	 *)
	function disk_read (block_number : unsigned;
			    length : unsigned;
			    var buffer : universal) : exc_status;
	  begin
	    disk_read := doio (if$read_logical, block_number, length, buffer);
	  end;


	(*
	 * write to the disk
	 *)
	function disk_write (block_number : unsigned;
			     length : unsigned;
			     var buffer : universal) : exc_status;
	  begin
	    disk_write := doio (if$write_logical, block_number, length, buffer);
	  end;


	(*
	 * read a directory segment
	 *)
	function read_segment (seg_number : integer;
			       var buffer : universal) : exc_status;
	var
	    block_number : unsigned;
	  begin
	    block_number := seg_number * 2 + DIR_OFFSET;
	    read_segment := disk_read (block_number,1024,buffer);
	  end;


	(*
	 * write a directory segment
	 *)
	function write_segment (seg_number : integer;
				var buffer : universal) : exc_status;
	var
	    block_number : unsigned;
	  begin
	    block_number := seg_number * 2 + DIR_OFFSET;
	    write_segment := disk_write (block_number,1024,buffer);
	  end;
	(*
	 * get some device information (size,sdb,unit)
	 *)
	procedure get_device_info;

	type
	    ret_rec = packed record
				 class : [bit(8)] io$class;
				 typ : 0..255;
				 start_block : unsigned;
				 high_block : unsigned;
				 file_size : unsigned;
				 unit : integer;
				 device_sdb : structure_id;
			     end;
	var
	    f : text;
	    ret_info : ret_rec;
	    ok : boolean;
	    i : integer;

	  begin
	    f :: integer := 0;
	    open(f, strng, history := old,
		 status := error_status);
	    if error_status.exc_code <> ES$NOR
	      then error_exit(error_status);
	      { exc_status (SOFT_IO,ES$NFS)  non file structured }
	    error_status.exc_type := [soft_io];
	    error_status.exc_code := es$nfs;
	    ok := get_file_characteristics(f, ret_info, size(ret_info));
	    purge(f);
	    if ok
	      then
		begin
		  if ((ret_info.class = id$system) and
		      (ret_info.typ = ord(it$disk_file) ))
		    then
		      begin
			device_sdb.id := ret_info.device_sdb;
			unit := ret_info.unit;
			device_size := ret_info.file_size;
		      end
		    else error_exit (error_status);
		end
	      else error_exit (error_status);
	  end;
	(*
	 * Check that this is an RT-11 directory
	 * (Make sure system id is DECRT11A)
	 *)
	procedure check_directory;
	type
	    dbuf = packed record
			      bad_block : array [0..64] of unsigned;
			      reserved : array[65..232] of unsigned;
			      home_info : array[0..22] of integer;
			  end;
	var
	    bufptr : ^dbuf;
	  begin
	    new (bufptr);
	    error_status := disk_read(1, 512, bufptr^);

	    { exc_status (SOFT_IO, ES$IDR)  invalid directory }
	    error_status.exc_type := [soft_io];
	    error_status.exc_code := es$idr;

	    if ( (bufptr^.home_info[15] <> %O'42504') or
		(bufptr^.home_info[16] <> %O'51103') or
		(bufptr^.home_info[17] <> %O'30524'))
	      then error_exit(error_status);
	    dispose(bufptr);
	  end;
	(*
	 * Re-link the directory so that the logical and
	 * physical segments are the same.
	 *)
	procedure relink;
	var
	    seg_table : array [1..31] of integer;
	    current_seg, next_seg : integer;
	    segment_buffer2 : ^dseg;
	    temp : integer;

	  begin
	    for temp := 1 to 31 do seg_table[temp] := 0;
	    new (segment_buffer2);
	    current_seg := 1;
	    error_status := read_segment (current_seg, segment_buffer1^);
	    next_seg := segment_buffer1^.next_segment;
	    while next_seg <> 0 do
	      begin
		(*
		 * Check if we have moved this segment,
		 * if so, find the correct next_segment
		 * in the seg_table
		 *)
		if seg_table[next_seg] <> 0
		  then
		    begin
		      while seg_table[next_seg] <> 0 do
			begin
			  temp := seg_table[next_seg];
			  seg_table[next_seg] := 0;
			  next_seg := temp;
			end;
		      segment_buffer1^.next_segment := next_seg;
		      error_status := write_segment (current_seg,
						     segment_buffer1^);
		    end;
		current_seg := current_seg + 1;
		if current_seg <> next_seg
		  then
		    begin
		      (*
		       * Swap directory segments, saving
		       * the next_seg in seg_table
		       *)
		      seg_table[current_seg] := next_seg;
		      segment_buffer1^.next_segment := current_seg;
		      temp := current_seg - 1;
		      error_status := write_segment (temp,
						     segment_buffer1^);
		      error_status := read_segment (next_seg,
						    segment_buffer1^);
		      error_status := read_segment (current_seg,
						    segment_buffer2^);
		      error_status := write_segment (current_seg,
						     segment_buffer1^);
		      error_status := write_segment (next_seg,
						     segment_buffer2^);
		    end
		  else error_status := read_segment (current_seg,
						     segment_buffer1^);
		next_seg := segment_buffer1^.next_segment;
	      end;
	    dispose (segment_buffer2);
	  end;
	(*
	 * Get next entry from in_seg and
	 * return it to the caller
	 * key variables:
	 *   in_seg_valid  (boolean)
	 *)
	function get_next_entry : file_entry;
	var
	    g_segment : [static]integer;
	    g_file_start_block : [static]unsigned;
	    g_entry_index : [static]integer;
	    temp : unsigned;

	  begin
	    if not in_seg_valid
	      then
		begin
		  g_segment := 1;
		  g_entry_index := 1;
		  error_status := read_segment(g_segment,in_seg^);
		  g_file_start_block := in_seg^.files_start_block;
		  in_seg_valid := true;
		end;
	      { a great RT11 'feature' %&*#!! }
	    if g_entry_index <= 72
	      then temp := in_seg^.entries[g_entry_index].status
	      else temp := in_seg^.end_status;
	    if ( (temp = END_OF_SEGMENT) and
		(in_seg^.next_segment = 0) )
	      then
		begin
		  get_next_entry.rt_entry.status := 0;
		  in_seg_valid := false;
		end;
	    if ( (temp = END_OF_SEGMENT) and
		(in_seg^.next_segment <> 0) )
	      then
		begin
		  get_next_entry.rt_entry.status := END_OF_SEGMENT;
		  g_segment := in_seg^.next_segment;
		  g_entry_index := 1;
		  error_status := read_segment(g_segment,in_seg^);
		  g_file_start_block := in_seg^.files_start_block;
		end;
	    if (temp <> END_OF_SEGMENT)
	      then
		begin
		  get_next_entry.rt_entry := in_seg^.entries[g_entry_index];
		  get_next_entry.start_block := g_file_start_block;
		  g_file_start_block := (g_file_start_block +
					 in_seg^.entries[g_entry_index].length);
		  g_entry_index := g_entry_index + 1;
		end;
	  end;
	(*
	 * Create the .BAD file table
	 *)
	procedure find_bad_files;

	var
	    bad_table_index : integer;
	    next_file : file_entry;
	  begin
	    bad_table.count := 0 { no bad files yet };
	    bad_table.save_index := 1; { setup to start at 1st entry }
	    bad_table_index := 1 { start at first bad_entry };
	    in_seg_valid := false { force read of segment };
	    next_file := get_next_entry;
	    while next_file.rt_entry.status <> 0 { End of directory } do
	      begin
		if ((next_file.rt_entry.status = PERMANENT_FILE) or
		    (next_file.rt_entry.status = PROT_PERMANENT_FILE))
		  then
		    if (next_file.rt_entry.exten = %O'6254' { RAD50 BAD } )
		      then
			  if bad_table.count < MAX_BAD_FILES
			    then
				begin
				  bad_table.count := bad_table.count + 1;
				  bad_table.table[bad_table_index].start_block := next_file.start_block;
				  bad_table.table[bad_table_index].size := next_file.rt_entry.length;
				  bad_table_index := bad_table_index + 1;
				end
			    else
				begin
				  {** should be too many bad blocks }
				  { exc_status (SOFT_IO,ES$DIO) }
				  error_status.exc_type := [soft_io];
				  error_status.exc_code := es$dio;
				  error_exit (error_status);
				end;
		next_file := get_next_entry;
	      end;
	  end;
	(*
	 * Copy the file starting at 'from_block' to
	 * area starting at 'to_block'.  'size' is the file's
	 * size.
	 *)
	procedure move_file (from_block : unsigned;
			     to_block : unsigned;
			     size : unsigned);
	var
	    actual_length : unsigned;
	  begin
	      repeat
		if size >= (BUFFER_SIZE div 512)
		  then actual_length := BUFFER_SIZE
		  else actual_length := size * 512;
		if from_block <> to_block
		  then
		    begin
		      error_status := disk_read (from_block,
						 actual_length,
						 data_buffer^);
		      error_status := disk_write (to_block,
						  actual_length,
						  data_buffer^);
		    end;
		size := size - (actual_length div 512);
		from_block := from_block + (actual_length div 512);
		to_block := to_block + (actual_length div 512);
	      until size = 0;
	  end;
	(*
	 * Re-init the in-memory directory segment
	 *)
	procedure build_segment;
	  begin
	    current_segment := current_segment + 1;
	    current_index := 1;
	    with segment_buffer1^ do
	      begin
		next_segment := 0;
		highest_seg_in_use := current_segment;
		files_start_block := current_start_block;
		end_status := END_OF_SEGMENT;
	      end;
	  end;
	(*
	 * Add the file described by which_entry
	 * to the directory segment segment_buffer1
	 * possibly writing out the current segment.
	 *)
	procedure add_entry (which_entry : entry);
	  begin
	    if  (current_free_size < which_entry.length)
	      then
		begin
		  error_status.exc_type := [SOFT_IO];
		  error_status.exc_code := ES$DCF { device full };
		  error_exit (error_status);
		end;
	    with segment_buffer1^ do
	      begin
		if (current_index = 73)
		  then
		    begin
		      (*
		       * update the link for the next segment,
		       * and write this segment out.
		       *)
		      next_segment := current_segment + 1;
		      error_status := write_segment (current_segment,
						     segment_buffer1^);
		      (*
		       * now fix segment 1's highest_seg_in_use
		       *)
		      error_status := read_segment (1,
						    segment_buffer1^);
		      highest_seg_in_use := current_segment + 1;
		      error_status := write_segment (1,
						     segment_buffer1^);
		      build_segment;
		    end;
		entries[current_index] := which_entry;
		current_index := current_index + 1;
	      end;
	  end;
	(*
	 * Insert the next FILE.BAD into the directory.
	 * if needed, place an empty of appropriate length
	 * before it, to align to the proper location.
	 *)
	procedure process_bad_block;
	var
	    local_entry : entry;
	  begin
	    with bad_table do
	      begin
		if current_start_block <> table[save_index].start_block
		  then
		    begin
		      local_entry := EMPTY_ENTRY;
		      local_entry.length := (table[save_index].start_block -
					     current_start_block);
		      add_entry (local_entry);
		      current_start_block := (current_start_block +
					      local_entry.length);
		      current_free_size := (current_free_size -
					    local_entry.length);
		    end;
		local_entry := BAD_FILE_ENTRY;
		local_entry.length := table[save_index].size;
		add_entry (local_entry);
		current_start_block := (current_start_block +
					local_entry.length);
		current_free_size := (current_free_size -
				      local_entry.length);
		save_index := save_index + 1;
		count := count - 1;
	      end;
	  end;
      begin
	created_sem := false;
	allocated_bufs := false;

	get_device_info;
	created_sem := create_queue_semaphore(desc:=reply);
	check_directory;

	new (in_seg);
	new (data_buffer);
	new (segment_buffer1);
	allocated_bufs := true;

	relink;
	find_bad_files;

	(*
	 * Build a prototype directory segment
	 * from 1st segment
	 *)
	error_status := read_segment (1,in_seg^) { get segment # 1 };
	segment_buffer1^ := in_seg^;

	current_segment := 0;
	current_start_block := ((segment_buffer1^.total_segments * 2) +
				DIR_OFFSET + 2);
	current_free_size := (device_size -
			      ((segment_buffer1^.total_segments * 2) +
			       DIR_OFFSET + 2));
	build_segment;

	in_seg_valid := false; { force scan at start of directory }
	this_entry := get_next_entry;
50:
	while this_entry.rt_entry.status <> 0 { End of directory } do
	  begin
	    cop_status := this_entry.rt_entry.status;
	    (*
	     * if the file is a real file (permanent)
	     *    and if it is not a .BAD file
	     * then squeeze it...
	     *)
	    if ( ((cop_status = PERMANENT_FILE) or
		  (cop_status = PROT_PERMANENT_FILE)) and
		(this_entry.rt_entry.exten <> %O'6254' { .BAD in Rad50 }))
	      then
		begin
		  (*
		   * See if this file encroaches on
		   * a .BAD file
		   *)
		  if bad_table.count <> 0
		    then
		      if (bad_table.table[bad_table.save_index].start_block <
			  (current_start_block + this_entry.rt_entry.length) )
			then
			    begin
			      process_bad_block;
			      goto 50;
			    end;

		  add_entry (this_entry.rt_entry);
		  move_file (this_entry.start_block,
			     current_start_block,
			     this_entry.rt_entry.length);
		  current_start_block := (current_start_block +
					  this_entry.rt_entry.length);
		  current_free_size := (current_free_size -
					this_entry.rt_entry.length);
		end;
	    this_entry := get_next_entry;
	  end;

	(*
	 * Now perform final cleanup
	 *  Finish dumping .BAD table
	 *  Dump a final empty entry
	 *  Dump an END_OF_SEGMENT if needed
	 *  and write out last segment
	 *)
	while bad_table.count <> 0 do process_bad_block;

	this_entry.rt_entry := EMPTY_ENTRY;
	this_entry.rt_entry.length := current_free_size;
	add_entry (this_entry.rt_entry);

	if current_index <> 73
	  then add_entry (END_ENTRY);

	error_status := write_segment (current_segment,
				       segment_buffer1^);

	error_status.exc_code := ES$NOR;
	error_status.exc_type := [];
	error_exit (error_status);
99:
	if created_sem
	  then destroy (desc := reply);
	if allocated_bufs
	  then
	    begin
	      dispose (segment_buffer1);
	      dispose (in_seg);
	      dispose (data_buffer);
	    end;
      end;
end.
                                                                                                           