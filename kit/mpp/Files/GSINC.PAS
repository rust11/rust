{module GSINC;}
{$nolist}
{
 This software is furnished under a license and may be used or copied
 only in accordance with the terms of such license.

 Copyright (c) 1985, 1986 by Digital Equipment Corporation.
 All rights reserved.
}
{$list}

{ This is the include file for the declarations of the procedures for doing
   Get and Set Characteristics defined in the module GETSET.PAS }

[External($GS001)]
Function Get_File_Characteristics(
		var filevar : universal;
		var stsblok : universal;
		    stsleng : integer;
		var refblok : universal := 0;
		    refleng : integer := 0
			) : boolean; EXTERNAL;
[External($GS002)]
Function Set_File_Characteristics(
		var filevar : universal;
		var stsblok : universal;
		    stsleng : integer;
		var refblok : universal := 0;
		    refleng : integer := 0
			) : boolean; EXTERNAL;
[External($GS003)]
Function Set_Line_Mode_and_Echo(
		var filevar : universal;
		    on      : boolean
			) : boolean; EXTERNAL;
[External($GS004)]
Function Get_Desc_Characteristics(
		var descrpt : queue_semaphore_desc;
		    unitnum : integer;
		var stsblok : universal;
		    stsleng : integer;
		var refblok : universal := 0;
		    refleng : integer := 0
			) : boolean; EXTERNAL;
[External($GS005)]
Function Set_Desc_Characteristics(
		var descrpt : queue_semaphore_desc;
		    unitnum : integer;
		var stsblok : universal;
		    stsleng : integer;
		var refblok : universal := 0;
		    refleng : integer := 0
			) : boolean; EXTERNAL;
[External($GS006)]
Procedure Set_AutoEmpty(
		var filevar : universal;
		    on      : boolean
			); EXTERNAL;
[External($GS007)]
Function Set_Line_Mode(
		var filevar : universal;
		    on      : boolean
			) : boolean; EXTERNAL;
[External($GS008)]
Function Set_Echo(
		var filevar : universal;
		    on      : boolean
			) : boolean; EXTERNAL;

{end. Module GSINC}
                                                                                                                                              