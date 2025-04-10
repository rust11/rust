[system(micropower)] Module Get_and_Set_Characteristics;

{
 THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED OR COPIED
 ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE.

 COPYRIGHT (c) 1985, 1986 BY DIGITAL EQUIPMENT CORPORATION. ALL RIGHTS RESERVED.
}

{Assumes:
	Internal file descriptor block (FDB) has the following definitions
		FD.STA =   2	     The file status word
		FD.CHN =  40 (octal) The unit number
		FD.DVC =  62 (octal) The queue semaphore desc

	For the terminal driver
		C.LINE = 100 (octal) The line mode bit
		C.ECHO = 200 (octal) The echo bit
}

Type
    status_values = array [1..8] of integer;
    file_variable = record
			filler   : integer;
			filstats : integer;
			filler_1 : array [3..16] of integer;
			unitnumb : integer;
			filler_2 : array [18..25] of integer;
			driver_q : queue_semaphore_desc;
		    end;
    file_pointer = ^file_variable;
    request_packet = packed record
			fun : integer;
			uni : integer;
			seq : integer;
			pdb : structure_id;
			sem : structure_id;
			val : status_values;
		    end;
    reply_packet = packed record
			fun : integer;
			uni : integer;
			seq : integer;
			sts : integer;
			aln : integer;
			err : integer;
			xtr : array [1..3] of integer;
			val : status_values;
		    end;

[Global($GS004)]
Function Get_Desc_Characteristics(
		var descrpt : queue_semaphore_desc;
		    unitnum : integer;
		var stsblok : status_values;
		    stsleng : integer;
		var refblok : universal := 0;
		    refleng : integer := 0
			) : boolean;
    var
	rep : queue_semaphore_desc;
	dp  : request_packet;
	rp  : reply_packet;
	i   : integer;
	siz : integer;
    begin
	if create_queue_semaphore(desc := rep) then
	    begin
		dp.sem := rep.id;
		dp.fun := 7;
		dp.uni := unitnum;
		siz := size(dp);
		if refleng <> 0 then siz := siz - 6;
		send (val_data := dp, val_length := siz, desc := descrpt,
		      ref_data := refblok, ref_length := refleng);
		receive(val_data := rp, val_length := size(rp), desc := rep);
		destroy(desc := rep);
		if rp.sts = 0 then
		    begin
			siz := stsleng div 2;
			for i := 1 to siz do stsblok[i] := rp.val[i];
			Get_Desc_Characteristics := True;
		    end
		  else Get_Desc_Characteristics := False;
	    end
	  else Get_Desc_Characteristics := False;
    end;

[Global($GS005)]
Function Set_Desc_Characteristics(
		var descrpt : queue_semaphore_desc;
		    unitnum : integer;
		var stsblok : status_values;
		    stsleng : integer;
		var refblok : universal := 0;
		    refleng : integer := 0
			) : boolean;
    var
	rep : queue_semaphore_desc;
	dp  : request_packet;
	rp  : reply_packet;
	i   : integer;
	siz : integer;
    begin
	if create_queue_semaphore(desc := rep) then
	    begin
		siz := stsleng div 2;
		for i := 1 to siz do dp.val[i] := stsblok[i];
		dp.sem := rep.id;
		dp.fun := 6;
		dp.uni := unitnum;
		siz := size(dp);
		if refleng <> 0 then siz := siz - 6;
		send (val_data := dp, val_length := siz, desc := descrpt,
		      ref_data := refblok, ref_length := refleng);
		receive(val_data := rp, val_length := size(rp), desc := rep);
		destroy(desc := rep);
		if rp.sts = 0
		  then Set_Desc_Characteristics := True
		  else Set_Desc_Characteristics := False;
	    end
	  else Set_Desc_Characteristics := False;
    end;

[Global($GS001)]
Function Get_File_Characteristics(
		var filevar : file_pointer;
		var stsblok : status_values;
		    stsleng : integer;
		var refblok : universal := 0;
		    refleng : integer := 0
			) : boolean;
    begin
	Get_File_Characteristics := Get_Desc_Characteristics(
					filevar^.driver_q,
					filevar^.unitnumb,
					stsblok,
					stsleng,
					refblok,
					refleng );
    end;

[Global($GS002)]
Function Set_File_Characteristics(
		var filevar : file_pointer;
		var stsblok : status_values;
		    stsleng : integer;
		var refblok : universal := 0;
		    refleng : integer := 0
			) : boolean;
    begin
	Set_File_Characteristics := Set_Desc_Characteristics(
					filevar^.driver_q,
					filevar^.unitnumb,
					stsblok,
					stsleng,
					refblok,
					refleng );
    end;
Function Set_or_Clear_Bits(var filevar : file_pointer;
			       on      : boolean;
			       bis,bic : unsigned) : boolean;
    var
	sts : status_values;
    begin
	if Get_File_Characteristics(filevar,sts,size(sts)) then
	    begin
		if on
		  then sts[2] := uor(sts[2],bis)
		  else sts[2] := uand(sts[2],bic); 
		Set_or_Clear_Bits := Set_File_Characteristics(filevar,sts,size(sts));
	    end
	  else Set_or_Clear_Bits := False;
    end;

[Global($GS003)]
Function Set_Line_Mode_and_Echo(var filevar:file_pointer; on:boolean) : boolean;
    begin
	Set_Line_Mode_and_Echo := Set_or_Clear_Bits(filevar,on,%o'300',%o'177477');
    end;

[Global($GS007)]
Function Set_Line_Mode(var filevar:file_pointer; on:boolean) : boolean;
    begin
	Set_Line_Mode := Set_or_Clear_Bits(filevar,on,%o'100',%o'177677');
    end;

[Global($GS008)]
Function Set_Echo(var filevar:file_pointer; on:boolean) : boolean;
    begin
	Set_Echo := Set_or_Clear_Bits(filevar,on,%o'200',%o'177577');
    end;

[Global($GS006)]
Procedure Set_AutoEmpty(var filevar:file_pointer; on:boolean);
    begin
	if on
	  then filevar^.filstats := uor(filevar^.filstats,%O'10000')
	  else filevar^.filstats := uand(filevar^.filstats,%O'167777');
    end;
end.
                                                                                                                                                                             