{
  Module: GETPUT.PAS - Edit Level 1
}

{$NOLIST}
{
 This software is furnished under a license and may be used or copied
 only in accordance with the terms of such license.

 Copyright (c) 1982, 1986 by DIGITAL EQUIPMENT CORPORATION.
 All rights reserved.
}
{$LIST}

    {
     These procedures are provided as a service for device drivers written in
     MicroPower/Pascal.  The map_par1_addr procedure is provided to convert the
     mapped addresses to a for usable by the GET_x and PUT_x procedures.  The
     GET_x procedures are for input.  The specified byte or word is copied to
     the location designated by the PAR 1 address, and the address is
     incremented to the next location (byte or word).  The PUT_x procedures
     are for output.  A byte or word is copied from a location indicated by
     the PAR 1 address to the specified byte or word.
    }


    {
     This procedure converts a standard "PHYSICAL_ADDRESS", i.e. a virtual
     address and a PAR value to a PAR 1 address and PAR value that can be
     used by the GET_x and PUT_x procedures.  The "PHYSICAL_ADDRESS" is
     that returned in the "RET_INFO" argument of a RECEIVE procedure call.
     }

    [external ($MPAR1)]
    procedure map_par1_addr (    x : physical_address;
			     var y : physical_address ); external;
    {
     Because of their similarities, the following procedures are discussed as a
     group.  The procedure name indicates whether a byte or a word is to be
     moved.  The procedure name prefix indicates the direction of the move.  A
     GET_x procedure is for input from a device to a buffer.  A PUT_x procedure
     is for output to a device from a buffer.  In all procedures, the
     physical_address is updated after the move so that it points to the
     next element in the buffer.

     Assumptions:

     1.  The process is executing in USER mode and opposed to KERNEL or
     SUPERVISOR mode.
     2.  The process is mapped to the I/O page.
     }


    [external ($PUTBT)]
    procedure put_byte ( var x : byte_range;
			 var y : physical_address ); external;

    [external ($PUTWD)]
    procedure put_word ( var x : integer;
			 var y : physical_address); external;

    [external ($GETBT)]
    procedure get_byte ( x : byte_range;
		         var y : physical_address); external;

    [external ($GETWD)]
    PROCEDURE get_word ( x : integer;
		         var y : physical_address ); external;

 { End of GETPUT.PAS }
                                            