Primitive System;
Assuming maximum 256 types, and fixed data size_t for each type:;
sbyte type;
vary data;
Assuming maximum 256 types, and maximum 256 bytes of data,and variable data size_t:;
sbyte type;
sbyte size_t;
vary data;
Now, drop the 256 maximum on types, but instead make them;
variable size_t, preceded by a size_t indicator:;
puck type;
puck size_t;
vary data;
Thus, type=10 might take these forms:;
1, 10 (puck_1);
2, 0,10 (puck_2);
3, 0,0,10 (puck_3);
LHS/RHS Variability;
if ( the order of elements) {The system outlined above is fine, ;}
{ 
#if !, then we need to additional information so (fixed: (type , size_t, data>) we
  Assume (can select an appropriate interpreter for each object.) the uppercase version of a name is a token that;
  can dispatch a name (e.g. TYPE, SIZE, VARY).;
  Then we need a process by which we can associate a predefined;
  order with the data.;
  (1) Require (This is most obviously done with the initial (type ) element.) each segment begin with (type puck );
  (2) Use the type to drive the order of elements;
  Now, to achieve this we need to have a type definition facility.;
  We need to be able to define atomic, singular types, and;
  structured compound types.;
  Base -- Built-in basic types;
  Atom -- Simple Type Definitions;
  Defines the type of a singular datum, in terms of;
  a simple or base type.;
   "display_name"
  form (typeId );
  ident (value );
  Thus, a definition for latitude:;
   "lat"
  form long;
  ident (value internal );
  Thus, (type ), (form ) and (ident ) need to be base types, along;
  with (plex ), (count ) and (item ) below.;
  Plex -- Fixed Compound Type Definitions;
  A compound definition includes only known names;
  plex "display_name";
  ident (value internal );
  size_t (array of );
  array (idents of );
  Thus, the nominal definition of a plex is:;
   "plex"
  ident (PLEX );
  size_t 4;
  item TYPE;
  item IDENT;
  item SIZE;
  item ARRAY;
  Ana -- Variable Compound Types;
  Base, Atomic and Plex types are fine for fixed order objects,but do ! handle miscellaneous collections of objects.;
  In this case we want to have a variable number of elements,of unconstrained type. To do this we need to include the type;
  information about each element in the data storage area.;
  Thus each element, except the first, is preceded by a TypeIdent puck:;
   "plex"
  puck IDENT ident (PLEX );
  puck SIZE size_t 4;
  puck ITEM item TYPE;
  puck ITEM item IDENT;
  puck ITEM item SIZE;
  puck ITEM item ARRAY;
  We can write this more simply by using the '#' prefix operator:;
   "plex"
  sizeof(ident) (PLEX );
  sizeof(size_t) 4;
  sizeof(item) TYPE;
  sizeof(item) IDENT;
  sizeof(item) SIZE;
  sizeof(item) ARRAY;
  Form -- Type definitions;
  Puck -- Refined type specifier;
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
} 
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
Some typical data:;
 textId
subtype TEXT;
lang ENGLISH;
log ID_QUIT;
eqv "Quit";
 icon
/* code -  [64] bytes */
 IconId
log ID_QUIT;
icon 0xaabb00dd 0x...;
 OBJECT
subtype BOX;
lat 120.2;
lon 20.4;
textId ID_QUIT;
act "SYSTEM_SIGNAL_QUIT";
SoundsAmazing example;
Barlines;
 form
name "Barline";
ident n;
long "pos";
 barline
pos 100;
 barline
pos 120;
 barline
