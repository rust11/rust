[system(micropower), init_priority(250), priority(175), 
		privileged, data_space(1000)] 
	program $xddrv;

(*

                  COPYRIGHT (c) 1986 BY
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

*)

{
Author	RSR	8-Jan-86

	RSR	10-Feb-86	Allow 65536 block logical partitions.
				Change unsigned variables to long_integer.

Edit History
}

{
The XD driver permits MicroPower/Pascal to do perform file-structured 
I/O to disk devices with 
greater than 65536 blocks. It does this by partitioning the 
physical disk unit into multiple partitions. Each physical disk
unit is treated as a single controller with one or more logical units.
}
{$NOLIST}
 %include 'LB:exc'
 %include 'LB:iopkts' 
 %include 'LB:gsinc'
{$LIST}

  const

{Define the maximum number of disk blocks per partition.}
{NOTE: Must not exceed 65536.}
    max_unit_size = 65536;
{Define the minimum number of disk blocks per partition.}
    min_unit_size = 100;
{Define the number of physical disk units which are to be partitioned.}
    no_devices = 1;

  type
    foo =
      record
        low, hi: unsigned
      end;
    io$req_pkt_ptr = ^io$req_pkt;
    io$reply_pkt_ptr = ^io$reply_pkt;
    c_array = array [1..no_devices] of
        record
          device_name: name_str;
          unit_number: byte_range;
          xd_name: name_str;
        end;
    status_values = array[1..8] of integer;

    var
      i : integer;
      calc_no_units : byte_range;
      calc_no_blocks_last_unit : long_integer;
      disk_size: long_integer;
      desc_get, desc_put: structure_desc;
      exc_status_1: exc_status;
      stsblok_1: status_values;
      control_array : c_array;

  procedure procedure_z1(desc_get: structure_desc;
             desc_put: structure_desc;
             put_unit: byte_range;
             no_units: byte_range;
             no_blocks_last_unit: long_integer);

    label
      99;

    var
      reply_desc: structure_desc;
      req_pkt_ptr: io$req_pkt_ptr;
      reply_pkt_ptr: io$reply_pkt_ptr;
      b_temp: boolean;
      last_block_to_access: long_integer;

    procedure error(exc_code: exc_codes);

      begin
        with reply_pkt_ptr^.pkt do
          begin
            status := exc_code;
	    act_length := 0;
            if reply_sem.index <> 0
              then
                begin
                  if fi$simple_reply in ind_mod
                    then
                      signal(desc := reply_desc)
                    else
                      put_packet(desc := reply_desc, 
				packet_ptr := reply_pkt_ptr::queue_ptr);
                end;
          end; {with}
      end; {error}

    begin {procedure_z1}
      while true do
        begin

          get_packet(desc := desc_get, 
			packet_ptr := req_pkt_ptr::queue_ptr);
          reply_pkt_ptr := req_pkt_ptr::io$reply_pkt_ptr;
	  reply_desc.id := req_pkt_ptr^.pkt.reply_sem;

          if req_pkt_ptr^.pkt.unit_num > (no_units - 1)
            then
              begin
              error(exc_code := es$nxu);
	      goto 99;
	      end;

          case req_pkt_ptr^.pkt.oper of

            if$read_logical, if$write_logical:
              begin
                with req_pkt_ptr^.pkt do
                  begin
                    if unit_num = (no_units - 1)
                      then
                        b_temp := dev_addr.block_num > (no_blocks_last_unit -1)
                      else
                        b_temp := dev_addr.block_num > (max_unit_size - 1);
                    if b_temp
                      then
			begin
                        error(exc_code := es$ibn);
			goto 99;
			end;

                    last_block_to_access := dev_addr.block_num +
                       (req_pkt_ptr^.buf_len + 511) div 512 - 1;

                    if unit_num = (no_units - 1)
                      then
                        b_temp := last_block_to_access > (no_blocks_last_unit - 1)
                      else
                        b_temp := last_block_to_access > (max_unit_size - 1);
                    if b_temp
                      then
			begin
                        error(exc_code := es$ivl);
			goto 99;
			end;

                    dev_addr.block_num := dev_addr.block_num + unit_num *
                                          max_unit_size;
                    unit_num := put_unit;
                    put_packet(desc := desc_put, 
				packet_ptr := req_pkt_ptr:: queue_ptr);
                  end; {with}
              end; {if$read_logical, if$write_logical}

            if$get_char:
              begin
                with reply_pkt_ptr^.pkt do
                  begin
                    class := id$disk;
                    typ := ord(it$xd);
		    act_length := 0;
		    status := es$nor;
                    if unit_num = (no_units - 1)
                      then
                        blocks := no_blocks_last_unit
                      else
                        blocks := max_unit_size;
                    if reply_sem.index <> 0
                      then if fi$simple_reply in ind_mod
                        then
                          signal(desc := reply_desc)
                        else
                          put_packet(desc := reply_desc, 
					packet_ptr := reply_pkt_ptr::queue_ptr);
                  end; {with}
              end; {if$get_char}

            otherwise
	      begin
              error(exc_code := es$ifn);
	      {goto 99;}
	      end;

            end; {case}

        99: {awful, but true}

        end; {while true do ...}
    end; {procedure_z1}
process process_z1(desc_get: structure_desc;
             desc_put: structure_desc;
             put_unit: byte_range;
             no_units: byte_range;
             no_blocks_last_unit: long_integer);

 begin {process_z1}
  procedure_z1(desc_get := desc_get, 
		desc_put := desc_put, 
		put_unit := put_unit,
		no_units := no_units,
		no_blocks_last_unit := no_blocks_last_unit); 
 end; {process_z1}
  [initialize] procedure init_xddrv;

    var
      i : integer;

	 procedure partition_one_physical_unit(
		var device_name_x : [readonly] name_str;
		unit_number_x : byte_range;
		var xd_name_x : [readonly] name_str;
		index : integer);

	 begin
	 with control_array[index] do
		begin
		device_name := device_name_x;
		unit_number := unit_number_x;
		xd_name := xd_name_x;
		end;
	 end; {partition_one_physical_unit}

    begin

{Procedure partition_one_physical_unit is invoked no_devices times.}

	partition_one_physical_unit(
	device_name_x := '$DUA  ',
	unit_number_x := 0,
	xd_name_x := '$XDA  ',
	index := 1);


{

Note: For each additional call to partition_one_physical_unit,
      increase data_space attribute by 456 (dynamic process
      stack and impure area).

	partition_one_physical_unit(

Request queue semaphore name associated with physical disk device.

	device_name_x := '$DUA  ',

Unit number of physical disk device.

	unit_number_x := 1,

Request queue semaphore name associated with partition.
Should be of the form '$XDc  '.

	xd_name_x := '$XDB  ',

Ordinal in range 1,2,...,no_devices.

	index := 2);

}

      for i := 1 to no_devices do
        with control_array[i] do
          begin
            if not create_queue_semaphore({desc := desc_get, }
					name := xd_name)
              then
                report(exc_code := es$nmk,
			 exc_type := [resource]);

          end; {with ... do}
    end; {init_xddrv}

    begin {$xddrv}

      for i := 1 to no_devices do
        with control_array[i] do
          begin
	    init_structure_desc(desc := desc_get,
				name := xd_name);
            init_structure_desc(desc := desc_put, 
				name := device_name,
				status := exc_status_1);
            if exc_status_1.exc_code <> es$nor
              then
                report(exc_code := exc_status_1.exc_code,
			 exc_type := exc_status_1.exc_type);
            if not get_desc_characteristics(descrpt := desc_put, 
					unitnum := unit_number, 
					stsblok := stsblok_1,
                                        stsleng := 6)
              then
                report(exc_code := es$ist,
			 exc_type := [system_service]);

            disk_size::foo.low := stsblok_1[2];
            disk_size::foo.hi := stsblok_1[3];

            calc_no_blocks_last_unit := disk_size mod max_unit_size;
            if calc_no_blocks_last_unit = 0
              then
                calc_no_blocks_last_unit := max_unit_size;
            calc_no_units := short((disk_size + max_unit_size - 1) 
				div max_unit_size );
            if calc_no_blocks_last_unit < min_unit_size
              then
                begin
                  calc_no_units := calc_no_units - 1;
                  calc_no_blocks_last_unit := max_unit_size;
                end;

	    if i <> no_devices
             then process_z1(desc_get := desc_get, 
			desc_put := desc_put, 
			put_unit := unit_number, 
			no_units := calc_no_units, 
			no_blocks_last_unit := calc_no_blocks_last_unit) 
	     else procedure_z1(desc_get := desc_get, 
			desc_put := desc_put, 
			put_unit := unit_number, 
			no_units := calc_no_units, 
			no_blocks_last_unit := calc_no_blocks_last_unit);

          end; {with ... do}

  end. {$xddrv}
                   