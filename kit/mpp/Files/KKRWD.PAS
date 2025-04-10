    [system(MicroPower)] module kkrwd;

    {$nolist}
    {
     This software is furnished under a license and may be used or copied
     only in accordance with the terms of such license.

     Copyright (c) 1984, 1986 by Digital Equipment Corporation.
     All rights reserved.
     }

    %include 'LB:iopkts.pas'
    %include 'LB:exc.pas'
    {$list}

    %include 'LB:kkinc.pas'
    {
     Common function which performs
     kk_read and kk_write
     }
    function kk_io (funct : io$function;
		    var buffer : universal;
		    length : unsigned;
		    var ret_length : unsigned;
		    unit : $kk_unit := 0;
		    reply : structure_desc_ptr := nil;
		    seq_num : unsigned := 0 ) : unsigned;

    var
	reply_semaphore : queue_semaphore_desc;
	request_packet : io$req;
	reply_packet : io$reply;
	use_my_semaphore : boolean;

    label
	99;

      begin
	kk_io := es$nor;

	use_my_semaphore := reply = nil ;
	if use_my_semaphore
	  then
	    if not create_queue_semaphore (desc := reply_semaphore)
	      then
		  begin
		    report (exc_info := 0, 
			    exc_type := [RESOURCE], 
			    exc_code := ES$NMK);
		    goto 99
		  end;
	with request_packet do
	  begin
	    oper := funct;  { function }
	    dep_mod := [];   { and nothing here }
	    ind_mod := [];   { retry when KXT ready }
	    sequence := seq_num ;  { fill in user's sequence number }
	    unit_num := unit;   { Fill in the Unit number}
	    if use_my_semaphore   { Fill in the proper reply sem}
	      then reply_sem := reply_semaphore.id
	      else reply_sem := reply^.id;
	  end;

	send (name := '$KKA  ',
	      val_data := request_packet,
	      val_length := size(io$req),
	      ref_data := buffer,
	      ref_length := length);

	if use_my_semaphore
	  then  { If necessary wait for a reply }
	    begin
	      receive (desc := reply_semaphore, { get the reply }
		       val_data := reply_packet,
		       val_length := size(reply_packet) );

	      kk_io := reply_packet.status ;
	      ret_length := reply_packet.act_length ;
	      destroy (desc := reply_semaphore);
	    end;
99:
      end;
    [global($kkrdd)]
    function kk_read_data;
      begin
	kk_read_data := kk_io (if$read_logical,
			       buffer,
			       length,
			       ret_length,
			       unit,
			       reply,
			       seq_num);
      end;


    [global($kkwrd)]
    function kk_write_data;
      begin
	kk_write_data := kk_io (if$write_logical,
				buffer,
				length,
				ret_length,
				unit,
				reply,
				seq_num);
      end;

end.
                                                                                                                                                                                                                                                                                                                                                                                                                                                                            