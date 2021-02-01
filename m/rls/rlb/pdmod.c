/* file -  pdmod - pod memory support */
/* header pddef - pod definitions */
#ifndef _RIDER_H_pddef
#define _RIDER_H_pddef 1
#define pdUND  0
#define pdUBB  1
#define pdSBB  2
#define pdUBW  3
#define pdSBW  4
#define pdUBL  5
#define pdSBL  6
#define pdUBQ  7
#define pdSBQ  8
#define pdFBL  9
#define pdFBQ  10
#define pdSTR  11
#define pdVEC  12
#define pdLST  13
#define pdTbyt struct pdTbyt_t 
struct pdTbyt_t
{ char Vtag ;
  char Vval ;
   };
#define pdTwrd struct pdTwrd_t 
struct pdTwrd_t
{ char Vtag ;
  short Vval ;
   };
#define pdTlng struct pdTlng_t 
struct pdTlng_t
{ char Vtag ;
  long Vval ;
   };
#define pdTqua struct pdTqua_t 
struct pdTqua_t
{ char Vtag ;
  long Aval [2];
   };
Datum;
ByteDatum | WordDatum | LongDatum | QuadDatum | VaryDatum;
ShapeFileHeader;
sbyte oxff;
sbyte 0xef;
word;
long ShapeMagic;
long ShapeVersion;
... items;
ShapeItem;
sbyte Category;
InvalidCat=0;
Extension=128++;
...;
AllCatsAreBytes;
Datum ElementSize;
Cat SHPCAT_ALLCATSBYTES;
FileSizeItem;
Datum ElementSize;
Cat SHPCAT_FILESIZE;
Frm Datum;
Datum filesize;
PlexDefinition;
Datum ElementSize;
Cat SHPCAT_FORM;
Frm Plex;
NewCat n;
NewFrm n;
Datum ElementCount;
Plex Type1;
Plex Type2;
...;
Plex Typen;
PlexDenotation;
Datum ElementSize;
Cat SHPCAT_FORMNAME;
RefCat n;
Text "name";
Text "comment";
Datum ElementCount;
Text Name1;
Text Name2;
...;
Text Namen;
#define  xxTnum  int
#define xxTstr  char
#define xxThdr struct xxThdr_t 
struct xxThdr_t
{  };
xxTnum Vcat ;
#define xxDEF  1
#define xxTdef struct xxTdef_t 
struct xxTdef_t
{ xxThdr Shdr ;
  xxTnum Vidt ;
  xxTnum Vcnt ;
  xxTnum Aelm [1];
   };
#define xxNAM  2
#define xxTnam struct xxTnam_t 
struct xxTnam_t
{ xxThdr Shdr ;
  xxTnum Vidt ;
  xxTstr *Pnam ;
  xxTnum Vcnt ;
  xxTstr *Aelm [1];
   };
xxTdef xxIdef  =  {
  0,
  xxDEF,
  };
