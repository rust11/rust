{ YFDRVP.PAS	-	Edit Level 0

	Subroutine Package for the FALCON (SBC-11/21) Parallel I/O
		device interface for non-interrupt usage.



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


 Module name: YFDRVP.PAS

 System: Micro-PAX/Pascal

 Author: EGP		Creation date: 25 Sep 81

 Modified:

 13-Jan-82/EGP		Fix copyright

 12-Dec-82/JPR		Change values of a_input and c_input to fit
			production board


 Functional Description:

	This module defines Pascal procedures to set the operating mode,
	read, and write to the FALCON (SBC-11/21) on-board 8255 PIO.
	The 8255 is supported in Mode 0 (non-interrupt) ONLY. In this
	mode, there are two 8-bit data ports (A & B), and a third dual
	4-bit port, port C. The lower half of port C is permanently
	connected as an input. The upper half of port C, and ports A & B
	can be used as either input or output, depending on wire-wrap
	jumpers on the FALCON board.

	To set the mode, use SET_PIO_MODE( mode_num);
		where mode_num is of type mode_sel.
	To write data, use WRITE_PIO (port_num, value);
		where port_num selects the port to which value is written.
	To read data, use var := READ_PIO (port_num);
		which reads the specified port and returns the value.
}
[SYSTEM (MicroPower)] Module YFDRVP;

Const
	mode_set = %O'201';
	a_input = 16;
	c_input = 8;
	b_input = 2;
Type
	port_sel = (port_a, port_b, port_c_low, port_c_high);
	mode_sel = (Ainput_Binput_Cinput, Ainput_Binput_Coutput,
		    Ainput_Boutput_Cinput, Ainput_Boutput_Coutput,
		    Aoutput_Binput_Cinput, Aoutput_Binput_Coutput,
		    Aoutput_Boutput_Cinput, Aoutput_Boutput_Coutput);
Var
{	pio_cntrl : [AT (%O'176206'), VOLATILE, BYTE] Byte;
	pio_portc : [AT (%O'176204'), VOLATILE, BYTE] Byte;
	pio_portb : [AT (%O'176202'), VOLATILE, BYTE] Byte;
	pio_porta : [AT (%O'176200'), VOLATILE, BYTE] Byte;
}
	pio_cntrl : [AT (%O'176206'), VOLATILE] Integer;
	pio_portc : [AT (%O'176204'), VOLATILE] Integer;
	pio_portb : [AT (%O'176202'), VOLATILE] Integer;
	pio_porta : [AT (%O'176200'), VOLATILE] Integer;

[GLOBAL ( $YFSPM )] Procedure SET_PIO_MODE (mode : mode_sel);
Begin
{ Eight modes of operation, all without interrupts, are supported:
	(Because of PC etch, Port C low 4-bits is ALWAYS input)
	0: Port A input, Port B input, Port C high input
	1: Port A input, Port B input, Port C high output
	2: Port A input, Port B output, Port C high input
	3: Port A input, Port B output, Port C high output
	4: Port A output, Port B input, Port C high input
	5: Port A output, Port B input, Port C high output
	6: Port A output, Port B output, Port C high input
	7: Port A output, Port B output, Port C high output	}
 Case mode Of
 Ainput_Binput_Cinput:   pio_cntrl := mode_set + a_input + b_input + c_input;
 Ainput_Binput_Coutput:  pio_cntrl := mode_set + a_input + b_input;
 Ainput_Boutput_Cinput:  pio_cntrl := mode_set + a_input + c_input;
 Ainput_Boutput_Coutput: pio_cntrl := mode_set + a_input;
 Aoutput_Binput_Cinput:  pio_cntrl := mode_set + b_input + c_input;
 Aoutput_Binput_Coutput: pio_cntrl := mode_set + b_input;
 Aoutput_Boutput_Cinput: pio_cntrl := mode_set + c_input;
 Aoutput_Boutput_Coutput:pio_cntrl := mode_set;
 End;
End;

[GLOBAL ( $YFRD )] Function READ_PIO (port : port_sel) : Integer;
Begin
 Case port Of
 port_a:	READ_PIO := UAND (pio_porta, %O'377');
 port_b:	READ_PIO := UAND (pio_portb, %O'377');
 port_c_low:	READ_PIO := UAND (pio_portc, %O'17');
 port_c_high:	READ_PIO := UAND (pio_portc, %O'360') DIV 16;
 End;
End;

[GLOBAL ( $YFWRT )] Procedure WRITE_PIO (port : port_sel; outdat : Integer);
Begin
 Case port Of
 port_a:	pio_porta := outdat;
 port_b:	pio_portb := outdat;
 port_c_low:	pio_portc := outdat;
 port_c_high:	pio_portc := UAND (outdat, %O'17') * 16;
 End;
End;

End. { of YFDRVP }
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               