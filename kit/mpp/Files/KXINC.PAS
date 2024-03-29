{$nolist}
    {
     This software is furnished under a license and may be used or copied
     only in accordance with the terms of such license.

     Copyright (c) 1984, 1986 by Digital Equipment Corporation.
     All rights reserved.
     }
{$list}

    { KXINC.PAS -- KX definition include file }

type
    $kx_unit = 0..1;

    {
     Read data from the KXT
     }
    [external($kxrdd)]
    function kx_read_data (var buffer : universal;
			   length : unsigned;
			   var ret_length : unsigned;
			   controler : char := 'A';
			   unit : $kx_unit := 0;
			   reply : structure_desc_ptr := nil;
			   seq_num : unsigned := 0 ) : unsigned; external;


    {
     Write data to the KXT
     }
    [external($kxwrd)]
    function kx_write_data (var buffer : universal;
			    length : unsigned;
			    var ret_length : unsigned;
			    controler : char := 'A';
			    unit : $kx_unit := 0;
			    reply : structure_desc_ptr := nil;
			    seq_num : unsigned := 0 ) : unsigned; external;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          