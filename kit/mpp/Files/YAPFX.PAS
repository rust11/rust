MODULE YAPFX;
{
 YAPFX.PAS	- Edit Level 1

 This software is furnished under a license and may be used or copied
 only in accordance with the terms of such license.

 Copyright (c) 1982, 1986 by DIGITAL EQUIPMENT CORPORATION.
 All rights reserved.
}

const
   std_proc_prio = 175;		{ Standard process priority }
   std_int_prio = 4;		{ and interrupt priority }

var
   stdprio : [global] integer;		 { Driver process priority }
   drprio : [global] integer;            { Interrupt priority }
   csr : [global] unsigned;		 { CSR address }
   vector_reqa : [global(REQA)] unsigned;  {vector address, A request}
   vector_reqb : [global(REQB)] unsigned;  {vector address, B request}
   maintenance : [global(MAINT)] boolean;

   { Declared in YADRV 
}

const
   std_proc_prio = 175;		{ Standard process priority }
   std_int_prio = 4;		{ and interrupt priority }

var
   stdprio : [global] integer;		 { Driver process priority }
   drprio : [global] integer;            { Interrupt priority }
   

{
 Note that the interrupt vector addresses below are not the default
  addresses specified for the DRV-11.  The default vector addresses
  are 300 and 304.  The default addresses conflict with some other
  devices more commonly used.  Change the following addresses to 300
  and 304 if your hardware configuration requires it.
 }

   vector_reqa := %o'340';
   vector_reqb := %o'344';
   version := 'V02.00';	
   maintenance := false;		 {Not maintenance mode}
end   { procedure initcsr };
end.
