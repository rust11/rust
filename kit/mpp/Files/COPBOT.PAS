    [System(Micropower), Data_space(6000), Stack_size(1000), Priority(20)]
    program copy_boot (input, output);

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


     Module name: COPBOT.PAS
     System: MicroPower/Pascal
     Author: ERS  Creation date: 25-Jan-85
     Modified:

     Functional Description:

     This program performs a stand-alone copy boot.

     This program must be built with the following modules:
      GETSET.PAS
      INTDIR.PAS

     The application mim file needs
     terminal driver
     ACP
     any required disk device driver
     This program and its modules
     }
    %include 'LB:iopkts.pas'

    %include 'LB:exc.pas'
    %include 'LB:fsincl.pas'
    %include 'LB:gsinc.pas'
type

    block = packed array[0..255] of unsigned;
    name_string = packed array [1..40] of char;

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
    input_file, output_file, device_file : file of block;
    inputname, outputname : name_string;
    outputdevice : packed array [1..6] of char;
    error_status : exc_status;
    error : boolean;
    index, current_index : integer;
    c : char;
    ret_info : ret_rec;

    function check_directory_structured(var file_variable:universal) : boolean;
      begin
	check_directory_structured := false;
	if get_file_characteristics(file_variable, ret_info, size(ret_info))
	  then
	    begin
	      if ((ret_info.class = id$system) and
	          (ret_info.typ = ord(it$directory_file) ))
		then check_directory_structured := true
		else writeln('Non directory structured access');
	    end
	  else writeln('Get characteristics failed');
      end;







    procedure report_error(err_cod : unsigned);
      begin
	if err_cod = es$fnf
	  then writeln('File not found')
	  else
	    if err_cod = es$ids
	      then writeln('Invalid device spec or device not found')
	      else
		  if err_cod = es$ifs
		    then writeln('Invalid file spec')
		    else writeln('Unknown error ', oct(err_cod) );
      end;
    procedure get_file_name(var inputname : name_string; infil : boolean);
    var
	current_position : integer;
	error : boolean;
	c : char;

      begin
	error := true;
	while error do
	  begin
	    current_position := 1;
	    if infil
	      then write('Input ')
	      else write('Output ');
	    write('mim file name (dev:name.ext) -> ');

	    while not eoln(input) do
	      begin
		read(c);
		if (c <> ' ')
		  then
		    begin
		      inputname[current_position] := c;
		      current_position := current_position + 1;
		    end;
	      end;
	    readln;
	    if current_position = 1
	      then writeln('No file name entered')
	      else
		begin
		  inputname[current_position] := chr(0);
		  error := false;
		end;
	  end;
      end;
  begin
    writeln;
    writeln('MicroPower/Pascal stand alone Copy Boot program');
    writeln;
    writeln('This program copies a MIM file from the input device');
    writeln('to the output device, and performs the COPYB operation');
    writeln('on the output device');
    writeln;
    (*
     * Pick up the input device and file name
     *)
    error := true;
    while error do
      begin
	get_file_name(inputname,true);
	open(input_file, inputname, history:=old, buffersize:=512,
	     overlapped:=enable, status:=error_status );
	if error_status.exc_code = es$nor
	  then
	    if check_directory_structured(input_file)
	      then error := false
	      else purge(input_file)
	  else report_error(error_status.exc_code);
      end;
    reset(input_file);
    (*
     * Pick up the output device and file name
     *)
    error := true;
    while error do
      begin
	get_file_name(outputname,false);

        for index := 1 to 6 do outputdevice[index] := chr(0);
	current_index := 1;
	index := 1;
	c := outputname[index];
	while (c <> ':') and (c <> chr(0)) and (current_index <= 6) do
	  begin
	    outputdevice[current_index] := c;
	    current_index := current_index + 1;
	    index := index + 1;
	    c := outputname[index];
	  end;
	if c <> chr(0)
	  then
	    begin
	      outputdevice[current_index] := c;

	      write('Do you wish to initialize ',
		    outputdevice : current_index, '? ');
	      readln(c);
	      if (c = 'y') or (c = 'Y')
		then init_directory(outputdevice {, status := error_status } );

	      open(output_file, outputname, history:=new, buffersize:=512,
		   overlapped:=enable, status:=error_status );
	      if error_status.exc_code = es$nor
		then
		  if check_directory_structured(output_file)
		    then error := false
		    else purge(output_file)
		else report_error(error_status.exc_code);
	    end
	  else writeln('No device specified');
      end;
    rewrite(output_file);
    while not eof(input_file) do
      begin
	output_file^ := input_file^;
	get(input_file);
	put(output_file);
      end;
    close(input_file);
    close(output_file);

    open(output_file, outputname, history:=old,
	 buffersize:=512, overlapped:=disable );
    reset(output_file);

    open (device_file, outputdevice, history:=new,
	  buffersize:=512);
    rewrite(device_file);

    error := get_file_characteristics(output_file, ret_info, size(ret_info));

    device_file^ := output_file^;
    (*
     * word 43 = # of additional blocks in boot
     * word 44 = next logical block in boot
     * word 45 = CSR
     * word 46 = ascii device name
     * word 47 = PAX in Rad50
     *)
    if (output_file^[0] = %O'240') and (output_file^[47] = %O'62100')
      then
	begin
	  device_file^[44] := ret_info.start_block + 1;
	  put(device_file);
	  close(device_file);
	  close(output_file);
	  writeln('Copy boot completed successfully');
	end
      else writeln('File not bootable');

    writeln('Copy boot exiting');
  end.
                                                                                                                                                                                                                                            