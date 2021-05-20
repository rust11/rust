{$NOLIST}
{
 This software is furnished under a license and may be used or copied
 only in accordance with the terms of such license.

 Copyright (c) 1982, 1986 By Digital Equipment Corporation.
 All rights reserved.
}

(*
  This file contains the declarations of the I/O system interfaces
  the device drivers/system processes.

  Author  ERS

  Edit history:

	RSR	8-JAN-86	Add IT$XD to type IO$TYPE_DISK for
				extended disk driver. 
 *)


{$LIST}

type

  { Class codes }

  io$class = (
    id$disk,			{ DC$DSK - Disk class devices }
    id$tape,			{ DC$TAP - Tape class devices }
    id$comm,			{ DC$COM - Communication devices }
    id$card,			{ DC$CRD - Card reader devices }
    id$terminal,		{ DC$TER - Terminal interface devices }
    id$line_pr,			{ DC$LPT - Line printer devices }
    id$real_time,		{ DC$RLT - Real-time devices }
    id$protocol,  		{ DC$PRL - Protocol device }
    id$system );		{ DC$SSV - System Service }


  io$type_disk = (
    it$rx02,			{ DK$DY2 - RX02 }
    it$tu58,			{ DK$DD	 - TU58 }
    it$rl02, 			{ DK$DL	 - RL02 }
    it$mscp,			{ DK$DU  - MSCP }
    it$vm, 			{ DK$VM  - Virtual Memory }
    it$xd );			{ DK$XD  - Extended Disk }

  io$type_tape = (
    it$tmscp );			{ MT$MU  - TMSCP }

  io$type_comm = (
    it$dpv,			{ CM$DPV - DPV11 Synchronous }
    it$ethernet,		{ CM$ETH - DEQNA Ethernet }
    it$xs_kxt, 			{ CM$XS  - KXT11C Synchronous }
    it$kx_kxt,			{ CM$KXK - KXT11C two port ram, arb side }
    it$kk_kxt );		{ CM$KKK - KXT11C two port ram, KXT side }

  io$type_terminal = (
    it$dl,			{ TT$DL	 - DLV11 }
    it$dle,			{ TT$DLE - DLV11-E }
    it$dlf,			{ TT$DLF - DLV11-F }
    it$dlt,			{ TT$DLT - DLART }
    it$dm,			{ TT$DM  - KXT Multiprotocol, no modem }
    it$dmm,			{ TT$DMM - KXT Multip., all modem lines }
    it$dh,			{ TT$DH  - DHV11 }
    it$dz );			{ TT$DZ  - DZV11 }
  io$type_real_time = (
    it$drv11,			{ RT$DRV - DRV11 }
    it$drv11j,			{ RT$DRJ - DRV11-J }
    it$fal,			{ RT$FAL - SBC-11/21 8255 PIO Interface }
    it$kwv11c,			{ RT$KWV - KWV11-C Real-time clock }
    it$adv11c,			{ RT$ADV - ADV11-C Analog to digital converter }
    it$axv11c,			{ RT$ADX - AXV11-C Analog to digital converter }
    it$ykp_kxt,			{ RT$YKP - KXT11-C Parallel Port }
    it$ykt_kxt,			{ RT$YKT - KXT11-C Timer }
    it$qd_kxt,			{ RT$QDK - KXT11-C DMA channel (QD) }
    it$drv11b,			{ RT$DRB - DRV11-B }
    it$ieq );			{ RT$IEQ - IEEE driver }

  io$type_protocol = (
    it$ddcmp );			{ PR$CDM - Communications using DDCMP model }

  io$type_system = (
    it$net_control,		{ SS$NSC - Network Services Control }
    it$net_link,		{ SS$NLL - Network Logical Link }
    it$ancillary_control,	{ SS$ACP - Ancillary Control Process }
    it$directory_file,		{ SS$DFL - Directory file }
    it$disk_file );		{ SS$DSK - Disk file (non file structured) }
  io$function = (
    if$read_physical,		{ IF$RDP - Read physical }
    if$read_logical,		{ IF$RDL - Read logical }
    if$rsvd2,			{ IF$RDV - Read virtual (Not implemented) }
    if$write_physical,		{ IF$WTP - Write physical }
    if$write_logical,		{ IF$WTL - Write logical }
    if$rsvd5,			{ IF$WTV - Write virtual (Not implemented) }
    if$set_char,		{ IF$SET - Set characteristics }
    if$get_char,		{ IF$GET - Get characteristics }
    if$dev_dep_01,		{	 Device Dependent Functions }
    if$dev_dep_02,
    if$dev_dep_03,
    if$dev_dep_04,
    if$dev_dep_05,
    if$dev_dep_06,
    if$dev_dep_07,
    if$dev_dep_08,
    if$lookup,			{ IF$LOK - Lookup (open) }
    if$enter,			{ IF$ENT - Enter  (open) }
    if$rename,			{ IF$REN - Rename }
    if$delete,			{ IF$DEL - Delete }
    if$close,			{ IF$CLS - Close }
    if$purge,			{ IF$PRG - Purge }
    if$protect,			{ IF$PRO - Protect file }
    if$unprotect );		{ IF$UNP - Unprotect file }
    
const

  { it$mscp }
  if$bypass_only = if$dev_dep_01;  { IF$ONY - Bypass only commands }
  if$bypass      = if$dev_dep_02;  { IF$BYP - Bypass function }
  if$init        = if$dev_dep_03;  { IF$INI - Init function }

  { id$tmscp }
  if$reposition  = if$dev_dep_04;  { IF$REP - Reposition tape }
  if$tape_mark   = if$dev_dep_05;  { IF$MRK - Write tape mark }
  if$rewind      = if$dev_dep_06;  { IF$RWD - Rewind tape }

  { id$comm, it$drv11j }
  if$enable = if$dev_dep_01;	{ IF$ENA - Enable line/portal }
  if$disable = if$dev_dep_02;	{ IF$DSA - Disable line/portal }
  if$stop = if$dev_dep_03;	{ IF$STP - Stop requests }

  { id$terminal }
  if$setmodem = if$dev_dep_04;	{ IF$SMD - Set modem semaphore }

  { id$adv11c }
  if$setadmode = if$dev_dep_01;	{ IF$MOD - Set A/D operating mode }

type

  io$pseudo_fun = (
    ip$read_physical,	{ Read physical }
    ip$read_logical,	{ Read logical }
    ip$write_physical,	{ Write physical }
    ip$write_logical,	{ Write logical }
    ip$set_char,	{ Set characteristics }
    ip$get_char,	{ Get characteristics }
    ip$set_modem_sem,	{ Set modem semaphore }
    ip$open,		{ Lookup/Enter request }
    ip$set_ad_mode,	{ Set A/D operating mode }
    ip$reposition,	{ Reposition tape }
    ip$kwstart,		{ Start real-time clock }
    ip$maxfuncode );	{ Maximum function code (catch all) }

  io$fundepbits = (
    fd$bit0,
    fd$bit1,
    fd$bit2,
    fd$bit3,
    fd$bit4,
    fd$bit5,
    fd$bit6);

const
  { read modifiers }
  fd$minmax = fd$bit1;		{ FM$MIN - Min/Max read  (id$terminal) }

  { write modifiers }
  fd$indirect = fd$bit0;	{ FM$IRP - Indirect reference pointer }

  fd$more_to_come = fd$bit0;	{ FM$MTC - More to come (it$net_link) }
  fd$interrupt_data = fd$bit1;	{ FM$SID - Send Interrupt Data (it$net_link) }

  fd$write_format = fd$bit0;	{ FM$WFM - Format Device (it$rx02) }
  fd$format_single = fd$bit1;	{ FM$WSD - Format single density (it$rx02) }

  { Enable modifiers }
  fd$promiscuous = fd$bit0;	{ FM$ANY - Promiscuous mode (it$ethernet) }

  fd$no_timing_req = fd$bit0;	{ FM$NTR - No timing required (it$ddcmp) }

  { stop modifiers }
  fd$stop_reads = fd$bit0;	{ FM$KRR - Stop Read requests }
  fd$stop_writes = fd$bit1;	{ FM$KWR - Stop Write requests }
type

  io$funindbits = (
    fi$simple_reply,		{ FM$BSM - Reply to binary semaphore }
    fi$data_chk,		{ FM$DCK - Read after write requested }
    fi$noretry);		{ FM$INH - Retry after error inhibited }

  io$bits = (
    st$bit0,
    st$bit1,
    st$bit2,
    st$bit3,
    st$bit4,
    st$bit5,
    st$bit6,
    st$bit7,
    st$bit8,
    st$bit9,
    st$bit10,
    st$bit11,
    st$bit12,
    st$bit13,
    st$bit14,
    st$bit15);

  io$device_addr = packed record
      case io$function of
	   if$read_physical,
	   if$write_physical :
		( sector : 0..255;
		  track : 0..255;
		  cylinder : unsigned );
	   if$read_logical,
	   if$write_logical :
		( block_num : long_integer );
  end;
  io$req = packed record
      oper : [bit(6)] io$function;
      dep_mod : packed set of io$fundepbits;
      ind_mod : packed set of io$funindbits;
      unit_num : 0..255;
      reserved_1 : 0..255;
      sequence : unsigned;
      pid : structure_id;
      reply_sem	: structure_id;
      case io$pseudo_fun of
	ip$read_physical,
	ip$read_logical,
	ip$write_physical,
	ip$write_logical:
		( dev_addr : io$device_addr;
		  min_length : unsigned );
	ip$set_modem_sem:
		( signal_sem : structure_id );
	ip$set_char:
		( reserved_2 : unsigned;
		  word_1 : packed set of io$bits;
		  word_2 : packed set of io$bits;
		  word_3 : packed set of io$bits );
	ip$open :
		( buffer_size : integer );
	ip$set_ad_mode :
		( config_word : unsigned;
		  rec_count : integer );
	ip$reposition :
		( modifier : unsigned;
		  object_count : long_integer;
		  mark_count : long_integer );
	ip$kwstart :
		( kw_config : unsigned;
		  kw_count : unsigned;
		  st_signal : structure_id );
	ip$maxfuncode :
	        ( function_data : array[1..5] of unsigned );
 end;	{ io$req }

  io$req_pkt = packed record
      link : ^io$req_pkt;
      aux_link : ^io$req_pkt;
      priority : 0..255;
      val_len : [bit(6)] 0..63;
      ref2 : boolean;
      ref1 : boolean;
      pkt : io$req;
      buffer_ptr : physical_address;
      buf_len : unsigned;
  end;
  io$reply = packed record
      oper : [bit(6)] io$function;
      dep_mod : packed set of io$fundepbits;
      ind_mod : packed set of io$funindbits;
      unit_num : 0..255;
      reserved_1 : 0..255;
      sequence : unsigned;
      status : unsigned;
      act_length : unsigned;
      err_code : unsigned;
      reply_sem : structure_id;
      case io$pseudo_fun of
	ip$set_char,
	ip$get_char :
	  ( class : [bit(8)] io$class; 
	    typ : 0..255;
	    case io$class of
	      id$disk : 
		( blocks : long_integer;
		  sectors : 0..255;
		  tracks : 0..255;
		  cylinders : unsigned );
	      id$comm :
		( comm_info : packed array [1..6] of byte_range );
	      id$terminal : 
		( word_1  : packed set of io$bits;
		  word_2  : packed set of io$bits;
		  word_3  : packed set of io$bits );
	      id$real_time : 
	        ( subtype : 0..255;
	          filler_2 : 0..255 ); );
	ip$open :
		( buffer_size : integer;
		  device_sem : structure_id );
	ip$maxfuncode : 
	  ( function_data : array[1..5] of unsigned );
    end;  { io$reply }

  io$reply_pkt = packed record
      link : ^io$reply_pkt;
      aux_link : ^io$reply_pkt;
      priority : 0..255;
      val_len : [bit(6)] 0..63;
      ref2 : boolean;
      ref1 : boolean;
      pkt : io$reply;
  end;
{ end IOPKTS.PAS }
                                                                              