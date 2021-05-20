{
 THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED OR COPIED
 ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE.

 COPYRIGHT (c) 1982, 1986 BY DIGITAL EQUIPMENT CORPORATION.
		ALL RIGHTS RESERVED.
}
{  QDINC.PAS -- DMA user interface routine definitions

     Modified:
      
	23-Apr-86 RLP KXJ support. Add dma$adrtype_option field to dma$address.

 This file defines the MicroPower/Pascal user's interface
 to the QD DMA handler.  Six routines are provided:

	$DMA_TRANSFER -- performs dma transfer.
	$DMA_SEARCH -- performs dma search.
	$DMA_SEARCH_TRANSFER -- performs transfer while searching.
	$DMA_ALLOCATE -- allocates a dma channel.
	$DMA_DEALLOC -- deallocates a dma channel.
	$DMA_GET_STATUS -- gets the status of the dma unit.

 All necessary data structures are defined here.
}
TYPE

  DMA$ADDR_SPACE = (DMA$IBUS, DMA$QBUS);	{ local or qbus space }

  DMA$INCR_OPTION = (DMA$UP, DMA$DOWN, DMA$NOINC); { incriment up, down, or not at all }

{Allow only wait_0 state}
  DMA$WAIT_OPTION = (DMA$WAIT_0);

  DMA$REQ_OPTION = (DMA$NOWFR, DMA$WFR);	{ wait for request line active }

  DMA$IO_OPTION = (DMA$NOIO, DMA$IO);		{ access I/O addresses }

  DMA$BYTE_OPTION = (DMA$NOBYTE, DMA$BYTE);	{ byte mode to/from this address }

 {For the unmapped case, local addresses are always physical so there's no
  need to set this bit. If it is set in that case, the address is left the same}
  DMA$ADRTYP_OPTION = (DMA$VIRTUAL, DMA$PHYSICAL); {physical - no need to 
						convert; virtual - means must 
						be converted. }

  DMA$ADDRESS = PACKED RECORD			{ to or from dma address }
	LOW: [POS(00),WORD] UNSIGNED;		{ low portion of 22bit address }
	HIGH: [POS(16),BIT(6)] 0..63;		{ high portion of 22bit address }
	ADRTYP: [POS(22),BIT(1)] DMA$ADRTYP_OPTION; { physical or virtual }
	IO: [POS(24),BIT(1)] DMA$IO_OPTION;	{ IO mode or not }
	WS: [POS(25),BIT(2)] DMA$WAIT_OPTION;	{ number of wait states to add }
	INC: [POS(27),BIT(2)] DMA$INCR_OPTION;	{ UP or DOWN or NOINC }
	WFR: [POS(29),BIT(1)] DMA$REQ_OPTION;	{ wait for request ? }
	BM: [POS(30),BIT(1)] DMA$BYTE_OPTION;	{ byte mode ?}
	SPACE: [POS(31),BIT(1)] DMA$ADDR_SPACE	{ IBUS OR QBUS }
  END;

  DMA$BYTE_COUNT = UNSIGNED;			{ number of bytes to transfer }

  DMA$UNIT_NUMBER = 0..1;			{ 0 == chanel A, 1 == chanel B }

  DMA$SEM_POINTER = ^ SEMAPHORE_DESC;		{ pointer to sem desc }

  DMA$DEVICE_REGS = PACKED RECORD		{ Device registers }
    caoff_b_1 : unsigned;
    caoff_b_0 : unsigned;
    baoff_b_1 : unsigned;
    baoff_b_0 : unsigned;
    caoff_a_1 : unsigned;
    caoff_a_0 : unsigned;
    baoff_a_1 : unsigned;
    baoff_a_0 : unsigned;
    catag_b_1 : unsigned;
    catag_b_0 : unsigned;
    batag_b_1 : unsigned;
    batag_b_0 : unsigned;
    catag_a_1 : unsigned;
    catag_a_0 : unsigned;
    batag_a_1 : unsigned;
    batag_a_0 : unsigned;
    chaino_1  : unsigned;
    chaino_0  : unsigned;
    chaint_1  : unsigned;
    chaint_0  : unsigned;
    isr_1     : unsigned;
    isr_0     : unsigned;
    stat_1    : unsigned;
    stat_0    : unsigned;
    coc_1     : unsigned;
    coc_0     : unsigned;
    boc_1     : unsigned;
    boc_0     : unsigned;
    mmr       : unsigned;
    junk      : [WORD(7)] unsigned;
    pat_1     : unsigned;
    pat_0     : unsigned;
    msk_1     : unsigned;
    msk_0     : unsigned;
    cmr_l_1   : unsigned;
    cmr_l_0   : unsigned;
    cmr_h_1   : unsigned;
    cmr_h_0   : unsigned;
    inv_1     : unsigned;
    inv_0     : unsigned;
  END;

CONST
{
 These constants are used to initialize variables of
 type DMA$ADDRESS.
}
  DMA$NORM_IBUS_ADDRESS = DMA$ADDRESS ( 0, 0, DMA$VIRTUAL, DMA$NOIO, 
			DMA$WAIT_0, DMA$UP, DMA$NOWFR, DMA$NOBYTE, DMA$IBUS );
  DMA$NORM_QBUS_ADDRESS = DMA$ADDRESS ( 0, 0, DMA$PHYSICAL, DMA$NOIO, 
			DMA$WAIT_0, DMA$UP, DMA$NOWFR, DMA$NOBYTE, DMA$QBUS );
{ And a constant for the size of the register file }

  DMA$REGBUF_SIZE = 92;


{  Definitions for QD handler request and reply }
TYPE

  BYTE = 0..255;

  FUNCT_CODE = ( READ_FUNCTION, INVAL1, INVAL2, WRITE_FUNCTION,

                 INVAL3, INVAL4, INVAL5, QD_GET_STATUS, ALLOCATE, DEALLOCATE );

  FUN_IND_BITS = (SIMPLE_REPLY, DATA_CHK, NORETRY);

  FUN_DEP_BITS = (FM$TSO, FM$TTS, BIT2, BIT3, BIT4, BIT5, BIT6);

  IO_REQ = PACKED RECORD
    OPER : [POS(0), BIT(6)] FUNCT_CODE;
    DEP_MOD : [POS(6), BIT(7)] PACKED SET OF FUN_DEP_BITS;
    IND_MOD : [POS(13), BIT(3)] PACKED SET OF FUN_IND_BITS;
    UNIT_NUM : [POS(16), BYTE] DMA$UNIT_NUMBER;
    FILLER_1 : [POS(24), BYTE] BYTE;
    SEQUENCE : [POS(32), WORD] INTEGER;
    PID : STRUCTURE_ID;
    REPLY_SEM : STRUCTURE_ID;
    DEV_ADR : DMA$ADDRESS;
    SLEN, PAT, MSK : [WORD] UNSIGNED;
    dev_adr2 : dma$address;
    length : dma$byte_count;
  END;
  
  IO_REPLY = PACKED RECORD
    OPER : [POS(0), BIT(6)] FUNCT_CODE;
    DEP_MOD : [POS(6), BIT(7)] PACKED SET OF FUN_DEP_BITS;
    IND_MOD : [POS(13), BIT(3)] PACKED SET OF FUN_IND_BITS;
    UNIT_NUM,
    FILLER_1 : BYTE;
    SEQUENCE : INTEGER;
    STATUS : UNSIGNED;
    ACTUAL_LENGTH,
    ERR_CODE : INTEGER;
  END;

  DMA$ALT_ADDRESS = PACKED RECORD		{ to or from dma address }
	LOW: [POS(00), WORD] UNSIGNED;		{ low portion of 22bit address }
	HIGH: [POS(16), BIT(6)] 0..63;		{ high portion of 22bit address }
	ADRTYP: [POS(22), BIT(1)] 0..1;		{ address type (virtual or
						  physical) }
	NOT_USE: [POS(23), BIT(1)] 0..1;	{ unused }
	REST: [POS(24),BYTE] 0..255;		{ rest of the stuff }
  END;

  DMA$ALT2_ADDRESS = RECORD			{ to or from dma address }
	LOW: UNSIGNED;				{ low portion of 22bit address }
	HIGH: UNSIGNED;				{ high word }
  END;
  
  BUF_POINTER = ^ UNIVERSAL;


{  Definitions of Support Functions }

[EXTERNAL($TRVPH)] FUNCTION $tran_virt_phys (
{
 Convert a virtual address to a physical address
}
 virt_addr : unsigned			{ virtual address to be translated }
 ): long_integer; EXTERNAL;

[EXTERNAL($DMATR)] FUNCTION $DMA_TRANSFER (
{
 This function transfers data from one place to another.
 Control returns to the user after the transfer, unless 
 the reply field is specified; Otherwise control is returned
 immediatly and the semaphore is signaled appropriatly
 by the handler.
}
	SOURCE: DMA$ADDRESS;			{ from address (either Q-BUS or II) }
	DEST: DMA$ADDRESS;			{ to address (either Q-BUS or II) }
	COUNT: DMA$BYTE_COUNT;			{ byte count }
	UNIT: DMA$UNIT_NUMBER := 0;		{ **OPTIONAL** unit number }
	REPLY: DMA$SEM_POINTER := NIL		{ **OPTIONAL** pointer to semaphore descriptor }
	) :DMA$BYTE_COUNT ; EXTERNAL ;

[EXTERNAL($DMAST)] FUNCTION $DMA_SEARCH_TRANSFER (
{
 This function causes data to be transfered from one place
 to another until either a search value is matched or
 the byte count expires.  Other options are same as
 dma_transfer. The number of bytes transfered is returned.
 If the reply field is specified, the function returns 0
 immediatly, and the bytes tranfered is returned in the
 reply message.
}
	SOURCE: DMA$ADDRESS;			{ from address (either Q-BUS or II) }
	DEST: DMA$ADDRESS;			{ to address (either Q-BUS or II) }
	COUNT: DMA$BYTE_COUNT;			{ byte count }
	VAL: UNSIGNED;				{ search value }
	MASK: UNSIGNED := 0 ;			{ **OPTIONAL** search mask }
	UNIT: DMA$UNIT_NUMBER := 0;		{ **OPTIONAL** unit number }
	REPLY: DMA$SEM_POINTER := NIL		{ **OPTIONAL** pointer to semaphore descriptor }
	) : DMA$BYTE_COUNT ; EXTERNAL ;

[EXTERNAL($DMASR)] FUNCTION $DMA_SEARCH (
{
 This function searches the source area.  The search terminates either
 when the search descriptor is matched or when the byte count
 expires.  The number of bytes searched is returned.
}
	SOURCE: DMA$ADDRESS;			{ from address (either Q-BUS or II) }
	COUNT: DMA$BYTE_COUNT;			{ byte count }
	VAL: UNSIGNED;				{ search value }
	MASK: UNSIGNED := 0 ;			{ **OPTIONAL** search mask }
	UNIT: DMA$UNIT_NUMBER := 0;		{ **OPTIONAL** unit number }
	REPLY: DMA$SEM_POINTER := NIL		{ **OPTIONAL** pointer to semaphore descriptor }
	) : DMA$BYTE_COUNT ; EXTERNAL ;

[EXTERNAL($DMAAL)] FUNCTION $DMA_ALLOCATE (
{
 This function allocates the unit specified for
 exclusive use of this process.
}
	UNIT: DMA$UNIT_NUMBER := 0):BOOLEAN ; EXTERNAL ;	{ **OPTIONAL** unit number }

[EXTERNAL($DMADL)] FUNCTION $DMA_DEALLOCATE (
{
 This function reverses the effect of a previous
 $dma_allocate call.
}
	UNIT: DMA$UNIT_NUMBER := 0):BOOLEAN ; EXTERNAL ;	{ **OPTIONAL** unit number }

[EXTERNAL($DMAGS)] FUNCTION $DMA_GET_STATUS (
{
 This function returns status information from
 the dma device into a user supplied buffer.
}
	UNIT: DMA$UNIT_NUMBER := 0;
	VAR REGBUF: DMA$DEVICE_REGS;
	REGBUF_SIZE: INTEGER := DMA$REGBUF_SIZE;
	REPLY: DMA$SEM_POINTER := NIL
	):BOOLEAN ; EXTERNAL ;
                                                                                                                                                                                                                                                                                                                                                               