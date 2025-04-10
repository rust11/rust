    [system(micropower)] module kxjshr;

    {
     Edit Level 0

     Copyright (c) 1986 by DIGITAL EQUIPMENT CORPORATION,
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


     Module name: KXJSHR.PAS

     System: MicroPower/Pascal

     Author: RLP		Creation Date: 23-APR-86

     Modified:
      2-Jun-86   RLP	Fix limit on shared memory size- should be 2000000(8)
     Functional Description:

     Enable or disable shared memory from a MPP application running on the
     KXJ side. These procedures enable and disable memory which is on a
     KXJ, making it visible on the QBUS.

     User Interface

     The user gains access to this load procedure by including the
     definition file MISC.PAS, found the kit area, in their PASCAL
     source, and merging this file with their source module at build
     time.

     The only restriction that applies to the user program is that
     it must be DEVICE, DRIVER, or PRIVILEGED mapped.  This procedure
     must have access to the I/O page, to access the KXJ11-CA local
     registers. (see mapping attributes, and this only applys
     to mapped systems)
     }
    %include 'LB:EXC.PAS'
{**********************************************************************
**********************************************************************}

    %include 'LB:MISC.PAS'	

{**********************************************************************
**********************************************************************}

    const
	enable_bit = %o'4';

    var
	kxjcsrf : [at(%o'177534')] unsigned;
	kxjcsrh : [at(%o'177536')] unsigned;
	kxjcsrj : [at(%o'177540')] unsigned;
	error_status : exc_status;
	(*
	 * Abort this procedure, filling in the return status
	 *)
	procedure error_exit (err_status : exc_status;
			      var return_status : exc_status := 0);
	type
	    pain_full = ^ exc_status;
	var
	    i : integer;
	  begin
	    i::pain_full := address (return_status);
	    if i <> 0
	      then return_status := err_status
	      else
		if err_status.exc_code <> ES$NOR
		  then report (exc_type := err_status.exc_type,
			       exc_code := err_status.exc_code,
			       exc_info := 0, exc_info_size := 0);
	  end;
[global($kxjes)]
procedure kxj_enable_shared;
{
		    (start : long_integer;
		    size : long_integer;
		    var status : exc_status := 0);
}
  var
     temp,temp1,temp2 : unsigned;
  begin
    error_status.exc_type := [SOFT_IO];
    error_status.exc_code := ES$NOR;
    if (start mod 8192 = 0) and (size mod 8192 = 0) and (size <= %o'2000000')
     then
      begin    
	kxjcsrf := ushort (start div 64);
	temp := ushort ((start + size - %o'20000') div 64);
	temp1 := ushort ((start + size - %o'20000') div %o'20000');
	temp2 := uand (%o'77', unot (temp1));
	kxjcsrh := temp + temp2;
	kxjcsrj := uor (kxjcsrj,enable_bit);
      end
    else error_status.exc_code := es$ilv;
    error_exit(err_status := error_status,
	       return_status := status);
  end;

[global($kxjds)]
 procedure kxj_disable_shared;
{
		    (var status : exc_status := 0);
}
 begin
    error_status.exc_type := [SOFT_IO];
    error_status.exc_code := ES$NOR;
    kxjcsrj := uand (kxjcsrj,unot(enable_bit));
    error_exit(err_status := error_status,
	       return_status := status);
  end;

end.
       