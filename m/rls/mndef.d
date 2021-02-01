header	mndef - windows menu routines
include	rid:dfdef

	mnENB_	:= BIT(0)		; enabled == 1, disabled == 0
	mnGRY_	:= BIT(1)		; grey if not enabled
	mnCHK_	:= BIT(2)		; checked
	mnUNC_  := BIT(3)		; unchecked
	mnBMP_	:= BIT(4)		; bitmap entry
	mnHLT_  := BIT(5)		; hilite

	mn_beg	: (*char) int		; begin new menu
	mn_sim	: (int, *char) int	; add simple menu entry
	mn_com	: (int, *char, int) int	; add complex menu entry
	mn_but	: (int, *void, int) int	; add button menu entry
	mn_trg	: (int,*void,*void,int)int ;add trigger entry
	mn_skp	: (void) int		; skip menu item
	mn_sho	: (void) int		; show result menu
	mn_trk	: (evt : *wsTevt) int	; track menu

data	mnThis - menu history support

  type	mnThis
  is	Vbas : int			; menu base code
	Vcnt : int			; number of entries
	Atab : [1] *char		; the pointer array
  end

	mn_alc	: (int, int) *mnThis	; allocate history
	mn_dlc	: (*mnThis) void	; deallocate history
	mn_new	: (*mnThis, *char) void	; add new entry
	mn_dis	: (*mnThis) void	; display history
	mn_fil	: (*mnThis, int) int	; filter event
	mn_sel	: (*mnThis, int) *char	; select entry
	mn_enu	: (*mnThis, int) *char	; enumerate entries

	mn_loa	: (*mnThis, *dfTctx, *char) int  ; load definitions
	mn_sto	: (*mnThis, *dfTctx, *char) int  ; store definitions
	mn_win : () * void

;	loop	play	stop
;	oo	>>	!
;	in	mark	out
;	v	[]	^
;	left	expand	right
;	<	<>	>

; windows only
	mn_han	: (int) *void
	mnUP0	:= (0 << 16)
	mnUP1	:= (1 << 16)
	mnDN0	:= (2 << 16)
	mnDN1	:= (3 << 16)
	mnLF0	:= (4 << 16)
	mnLF1	:= (5 << 16)
	mnRG0	:= (6 << 16)
	mnRG1	:= (7 << 16)
	mnRD0	:= (8 << 16)
	mnRD1	:= (9 << 16)
	mnZO0	:= (10 << 16)
	mnZO1	:= (11 << 16)
	mnRS0	:= (12 << 16)
	mnRS1	:= (13 << 16)

 OBM_CLOSE           := 32754
 OBM_UPARROW         := 32753
 OBM_DNARROW         := 32752
 OBM_RGARROW         := 32751
 OBM_LFARROW         := 32750
 OBM_REDUCE          := 32749
 OBM_ZOOM            := 32748
 OBM_RESTORE         := 32747
 OBM_REDUCED         := 32746
 OBM_ZOOMD           := 32745
 OBM_RESTORED        := 32744
 OBM_UPARROWD        := 32743
 OBM_DNARROWD        := 32742
 OBM_RGARROWD        := 32741
 OBM_LFARROWD        := 32740
 OBM_MNARROW         := 32739
 OBM_COMBO           := 32738
 OBM_UPARROWI        := 32737
 OBM_DNARROWI        := 32736
 OBM_RGARROWI        := 32735
 OBM_LFARROWI        := 32734
 OBM_OLD_CLOSE       := 32767
 OBM_SIZE            := 32766
 OBM_OLD_UPARROW     := 32765
 OBM_OLD_DNARROW     := 32764
 OBM_OLD_RGARROW     := 32763
 OBM_OLD_LFARROW     := 32762
 OBM_BTSIZE          := 32761
 OBM_CHECK           := 32760
 OBM_CHECKBOXES      := 32759
 OBM_BTNCORNERS      := 32758
 OBM_OLD_REDUCE      := 32757
 OBM_OLD_ZOOM        := 32756
 OBM_OLD_RESTORE     := 32755
 OCR_NORMAL          := 32512
 OCR_IBEAM           := 32513
 OCR_WAIT            := 32514
 OCR_CROSS           := 32515
 OCR_UP              := 32516
 OCR_SIZE            := 32640
 OCR_ICON            := 32641
 OCR_SIZENWSE        := 32642
 OCR_SIZENESW        := 32643
 OCR_SIZEWE          := 32644
 OCR_SIZENS          := 32645
 OCR_SIZEALL         := 32646
 OCR_ICOCUR          := 32647
 OCR_NO              := 32648 /*not in win3.1 */
 OIC_SAMPLE          := 32512
 OIC_HAND            := 32513
 OIC_QUES            := 32514
 OIC_BANG            := 32515
 OIC_NOTE            := 32516
end header
