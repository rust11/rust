header	xxdef - xxdp file structure
include rid:eldef

  type	xxTdos			; dos home block
  is	Vmfd : elTwrd		; first mfd block (non-zero)
	Vint : elTwrd		; interleave factor
	Vmap : elTwrd		; bitmap block 
	Amap : [253] elTwrd	; bitmap array, repeats Vmap, zero terminated
  end				; 960 blocks per bitmap, max 69 bitmaps

  type	xxTusr
  is	Vuic : elTwrd		; first: 0401, [1,1], second: zero
	Vufd : elTwrd		; first ufd block
	Vsiz : elTwrd		; directory entry word size
	Vf00 : elTwrd		; unused
  end

  type	xxTmfd			; 
  is	Vsuc : elTwrd		; logical block successor -- always zero
	Ausr : [63] xxTusr	; user array
	Af00 : [3] elTwrd	; unused
  end
 
 type	xxTxdp			; xxdp home block/mfd
  is	Vsuc : elTwrd		; always zero
	Vufd : elTwrd		; first ufd block #
	Vuct : elTwrd		; ufd count
	Vmap : elTwrd		; first map block #
	Vmct : elTwrd		; map count
	Vhom : elTwrd		; block number of self
	Vf00 : elTwrd		;
	Vtot : elTwrd		; total blocks
	Valc : elTwrd		; allocate blocks
	Vint : elTwrd		; interleave factor
	Vf01 : elTwrd		;
	Vmon : elTwrd		; monitor image block #
	Vf02 : elTwrd		;
				; bad block stuff
	Vsts : elTwrd		; single-density track/sector
	Vscy : elTwrd		; single-density cylinder 
	Vdts : elTwrd		; double-density track/sector
	Vdcy : elTwrd		; double-density cylinder 
  end

If 0
  type	xxTent
  is	Anam : [3] WORD		; rad50 name
	Vdat : WORD		; programmer/c number
	Vnfb : WORD		; unknown
	Vsta : WORD		; first block
	Vlen : WORD		; length in blocks
	Vtop : WORD		; last block of file (not end)
	Vprt : WORD		;
  end
End

  type	xxTent
  is	Anam : [3] elTwrd	; rad50 /filnamtyp/ -- zero for deleted file
	Vdat : elTwrd		; DOS date; bit-15 contiguous flag
	Vfre : elTwrd		; DOS next free byte
				; XXDP "ACT-11 logical end"
	Vsta : elTwrd		; first block
	Vlen : elTwrd		; file length in blocks
	Vlst : elTwrd		; last block
	Vflg : elTwrd		; DOS flags (below)
				; XXDP "ACT-11 Logical 52"
  end
				; Vdat
  type	xxTufd
  is	Vsuc : elTwrd		; logical block successor
	Aent : [28] xxTent	; upto 28 entries
	Af00 : [3] elTwrd	;
  end
	xxDAT_ := 0007777	; 12-bit creation date field
	xxRSV_ := 0070000	; reserved
	xxCTG_ := 0100000	; contiguous file
				; Vflg
	xxL52_ := 0177777	; XXDP "ACT-11 logical 52"
	xxPRT_ := 0000377	; DOS protection code
	xxUSG_ := 0037400	; DOS usage count
	xxLCK_ := 0140000	; DOS lock

  type	xxTmap
  is	Vsuc : elTwrd		; next logical block; zero terminated
	Vblk : elTwrd		; block number of this map
	Vsiz : elTwrd		; words in map -- always 60 decimal
	Vfst : elTwrd		; block number of first map block
	Amap : [60] elTwrd	; 960 block bitmap; 0=>free; 1=>in use
				; remainder of block is unused
  end

end header
end file
From John Wilson's PUTR.ASM

	comment	_

DOS/BATCH uses a link word in the first word of most kinds of blocks to point
at the next block in a chain, ending with a block whose link word is 0.
Contiguous files are the only exception I know of.  I don't know how BADB.SYS
works if there's more than one bad block, maybe the same file appears more than
once?  I can't find one that's >1 block long (it covers block 2 on a freshly
zeroed error-free RK05 for some reason).

Block 0 is the boot block
Block 1 (or 64. if DECtape) is the MFD1 (MFD home block):

+0	.word	mfd	;link to first block of MFD2 chain
+2	.word	?	;dunno, I've seen 1 and 5 here
			;XXDP+ docs say it's the interleave
			;(used as block allocation hint only)
+4	.word	map	;first block of bitmap
+6	.blkw	n	;complete list of blocks in bitmap (first same as +4)
			;0 after last one

Each MFD2 block (if there's more than one) has a link to the next block (or 0)
in the first word.  Starting at offset 2 there are as many four-word UFD
pointers as fit in the cluster:

+0	.word	uic	;user ID code (PPN), 0 for empty slot
+2	.word	ufd	;beginning of UFD chain (or 0 if not yet created)
+4	.word	size	;# words per UFD entry (normally 9.)
+6	.word	?	;??? seems to be 0 (XXDP+ doc agrees)

New XXDP+ disks combine MFD1 and MFD2 into one block (at device block #1):

+0	.word	0
+2	.word	ufd	;beginning of UFD chain
+4	.word	ufdlen	;# blocks in UFD chain
+6	.word	map	;beginning of bitmap chain
+10	.word	maplen	;# blocks in bitmap chain
+12	.word	mfd12	;"pointer to MFD 1/2" (isn't that this block???)
+14	.word	0
+16	.word	blksup	;number of supported blocks
+20	.word	blkpre	;number of preallocated blocks (reserved for MFD, UFD,
			;map)
+22	.word	intrlv	;interleave factor (block allocation hint)
+24	.word	0
+26	.word	monitr	;pointer to first block of monitor core image
+30	.word	0
+32	.word	trksec	;SD track,,sector of DEC STD 144 bad sector file
+34	.word	cyl	;SD cyl of " " " " " "
+36	.word	trksec	;DD track,,sector of DEC STD 144 bad sector file
+40	.word	cyl	;DD cyl of " " " " " "

Bitmap blocks look like this:

+0	.word	link	;link to next or 0
+2	.word	seq	;sequence # of this block within bitmap (starting at 1)
+4	.word	size	;# of valid words in this block
+6	.word	map	;first block of bitmap (so can always find start)
+10	.blkw	size	;bitmap words

Each UFD is a chain of linked blocks.  The first word is a link word as usual,
then starting at offset 2 there are 28. nine-word file entries:

+0	.rad50	/FIL/	;filename (3 zero words for empty slot)
+2	.rad50	/NAM/
+4	.rad50	/EXT/	;extension
+6	.word	date	;date ((year-1970.)*1000.+daywithinyear) in b14:0
			;b15 => contiguous file
+10	.word	?	;beats me ("ACT-11 logical end" in XXDP+ fiche)
+12	.word	stblk	;starting block of file data
+14	.word	len	;length of file (not trustworthy for contig files???)
+16	.word	endblk	;ending block of file data (can't we figure this out?)
			;(maybe it's here to help with extending?)
+20	.word	prot	;almost always 233, or 377 for BADB.SYS
			;"ACT-11 logical 52" in XXDP+ fiche)
_
