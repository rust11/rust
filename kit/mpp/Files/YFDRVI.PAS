{ YFDRVI.PAS	-	Edit Level 0 }

{
 THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED OR COPIED
 ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE.

 COPYRIGHT (c) 1982, 1986 BY DIGITAL EQUIPMENT CORPORATION. ALL
   RIGHTS RESERVED.
}




{	Include File for the Subroutine Package for the FALCON (SBC-11/21)
	Parallel I/O device interface for non-interrupt usage.


 Module name: YFDRVI.PAS

 System: Micro-PAX/Pascal

 Author: EGP		Creation date: 25 Sep 81

 Modified:

 13-Jan-82/EGP		Fix copyright

 Functional Description:

	Include file for the YFDRVP.PAS module. Defines types and
	external interfaces necessary to use the FALCON (SBC-11/21)
	8255 PIO interface procedures and functions.

	To set the mode, use SET_PIO_MODE( mode_num);
		where mode_num is of type mode_sel.
	To write data, use WRITE_PIO (port_num, value);
		where port_num selects the port to which value is written.
	To read data, use var := READ_PIO (port_num);
		which reads the specified port and returns the value.
}
Type
	port_sel = (port_a, port_b, port_c_low, port_c_high);
	mode_sel = (Ainput_Binput_Cinput, Ainput_Binput_Coutput,
		    Ainput_Boutput_Cinput, Ainput_Boutput_Coutput,
		    Aoutput_Binput_Cinput, Aoutput_Binput_Coutput,
		    Aoutput_Boutput_Cinput, Aoutput_Boutput_Coutput);

[EXTERNAL ( $YFSPM )] Procedure SET_PIO_MODE (mode : mode_sel); External;

[EXTERNAL ( $YFRD )] Function READ_PIO (port : port_sel) : Integer; External;

[EXTERNAL ( $YFWRT )] Procedure WRITE_PIO (port : port_sel;
					   outdat : Integer); External;

{ End of YFDRVI.PAS }
                                                                                                                                                                                                                                                                                                                                                                                                                                                  