
{
 This software is furnished under a license and may be used or copied
 only in accordance with the terms of such license.

 Copyright (C) 1984, 1986 by Digital Equipment Corporation.
 All rights reserved.
}

(*
 * This is the include file for the declarations
 * of the VT100 video procedures defined in the
 * module VT100.
 *)

type
  character_two = packed array [1..2] of char;
  character_three = packed array [1..3] of char;

  [external ( $vt100 )] procedure cursor (p : integer; term : char); external;
  [external ( $vt101 )] procedure up (p : integer); external;
  [external ( $vt102 )] procedure down (p : integer); external;
  [external ( $vt103 )] procedure right (p : integer); external;
  [external ( $vt104 )] procedure left (p : integer); external;
  [external ( $vt105 )] procedure plot (r,c : integer); external;
  [external ( $vt106 )] procedure index; external;
  [external ( $vt107 )] procedure nextline; external;
  [external ( $vt108 )] procedure reverseindex; external;
  [external ( $vt109 )] procedure save; external;
  [external ( $vt110 )] procedure restore; external;
  [external ( $vt111 )] procedure doublehightop; external;
  [external ( $vt112 )] procedure doublehighbot; external;
  [external ( $vt113 )] procedure singlewide; external;
  [external ( $vt114 )] procedure doublewide; external;
  [external ( $vt115 )] procedure alloff; external;
  [external ( $vt116 )] procedure boldon; external;
  [external ( $vt117 )] procedure underon; external;
  [external ( $vt118 )] procedure blinkon; external;
  [external ( $vt119 )] procedure reverseon; external;
  [external ( $vt120 )] procedure eraseright; external;
  [external ( $vt121 )] procedure eraseleft; external;
  [external ( $vt122 )] procedure eraseline; external;
  [external ( $vt123 )] procedure erasedown; external;
  [external ( $vt124 )] procedure eraseup; external;
  [external ( $vt125 )] procedure erasescreen; external;
  [external ( $vt126 )] procedure scroll (t,b : integer); external;
  [external ( $vt127 )] procedure graphic; external;
  [external ( $vt128 )] procedure ascii; external;

  (* VT1INC *)
                                                                                                                                                                                                                                                                                                                                                                                                           