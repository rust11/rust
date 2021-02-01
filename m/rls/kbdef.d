header	kbdef - keyboard definitions
include	rid:rider

;	See codef.d for console stuff

  type	kbTord : WORD

	kbBUF	:= 128
	kbSYS_	:= BIT(0)	; 1
	kbVIR_	:= BIT(1)	; 2
	kbASC_	:= BIT(2)	; 4
	kbUNI_	:= BIT(3)	; 10
	kbENH_	:= BIT(4)	; 20
	kbCTL_	:= BIT(5)	; 40
	kbSHF_	:= BIT(6)	; 100
	kbALT_	:= BIT(7)	; 200
	kbPAD_	:= BIT(8)	; 400

  type	kbTcha
  is	Vflg : WORD
	Vord : kbTord
  end

  type	kbTkbd : forward
  type	kbTast : (*kbTkbd, *kbTcha, int) int	; keyboard ast actually

  type	kbTkbd
  is	Vflt : int				; filter flags
	Vflg : int				; state flags
	Vget : size
	Vput : size
	Lbuf : size
	Abuf : [kbBUF] kbTcha
	Asta : [256] BYTE
	Past : * kbTast				; keyboard input ast
  end

;	Windows event keyboard

	kb_att : (void) *kbTkbd			; attach keyboard
	kb_det : (void)				; detach keyboard
	kbWAI_ := BIT(12)			; wait for input
	kbPEE_ := BIT(13)			; peek only
	kbGET_ := 0				; placebo
	kb_get : (*kbTcha, int) int		; get from ws context ring

;	Stand-alone keyboard ring (kbrng)

	kb_alc : () * kbTkbd			; allocate a keyboard
	kb_can : (*kbTkbd) void			; cancel input
	kb_wri : (*kbTkbd, *kbTcha) int		; keyboard ring write
	kb_rea : (*kbTkbd, *kbTcha, int) int	; keyboard ring read

	kb_dsc : (*kbTcha, *char) int		; kbdsc - describe key

end header
end file
;	command keys

	kbCinv	:= 0		; invalid keystroke/ not a command
				;
	kbClbt	:= 1		; lbutton
	kbCrbt	:= 2		; rbutton
	kbCcan	:= 3		; cancel
	kbCmbt	:= 4		; mbutton
;	5,6,7
	kbCbsp	:= 8		; backspace
	kbCtab	:= 9		; tab
;	a,b
	kbCclr	:= 0xc		; clear
				;
	kbCesc	:= 		; escape
;	kbCtab	:=		; tab key
;	kbCrub	:=		; keyboard rubout
	kbCcap	:=		; caps lock
	kbCshf	:= 0x10		; shift
	kbCctl	:= 0x11		; control
	kbCalt	:= 0x12		; alt
	kbCprt	:=		; print-screen
	kbCscr	:=		; scroll lock
	kbCpau	:= 0x13		; pause
	kbKcap	:= 0x14

;	four key cursor set

	kbCcup	:= 1		; cursor up
	kbCcdn	:= 2		; cursor down
	kbCcrt	:= 3		; cursor right
	kbCclf	:= 4		; cursor left

;	six key keypult

	kbCua0	:= 5		; insert
	kbCua1	:= 6		; home
	kbCua2	:= 7		; pageup
	kbCub0	:= 8		; delete
	kbCub1	:= 9		; end
	kbCub2	:= 10		; pagedown

;	function keys

	kbCf0	:= 20
	kbCf1	:= 21
	kbCf2	:= 22
	kbCf3	:= 23
	kbCf4	:= 24
	kbCf5	:= 25
	kbCf6	:= 26
	kbCf7	:= 27
	kbCf8	:= 28
	kbCf9	:= 29
	kbCf10	:= 30
	kbCf11	:= 31
	kbCf12	:= 32
	kbCf13	:= 33
	kbCf14	:= 34
	kbCf15	:= 35
	kbCf16	:= 36
	kbCf17	:= 37
	kbCf18	:= 38
	kbCf19	:= 39
	kbCf20	:= 40

;	keypad keys
;
;	Double-wide and double-high are assigned to the 
;	first left-to-right, top-to-bottom member key.
				; top row
	kbCka0	:= 50		; num lock
	kbCka1	:= 51		; divide
	kbCka2	:= 52		; asterix
	kbCka3	:= 53		; minus
				; row 2
	kbCkb0	:= 54		; 7
	kbCkb1	:= 55		; 8
	kbCkb2	:= 56		; 9
	kbCkb3	:= 57		; +
				;
	kbCkc0	:= 58		; 4
	kbCkc1	:= 59		; 5
	kbCkc2	:= 60		; 6
	kbCkc3	:= 61		; unused
				;
	kbCkd0	:= 62		; 0
	kbCkd1	:= 63		; 1
	kbCkd2	:= 64		; 2
	kbCkd3	:= 65		; enter

	kbCke0	:= 66		; 0
	kbCke1	:= 67		; unused
	kbCke2	:= 68		; period
	kbCke3	:= 69		; unused

;	alt keys

	kbCatA	:= 70
	kbCatB	:= 71
	kbCatC	:= 72
	kbCatD	:= 73
	kbCatE	:= 74
	kbCatF	:= 75
	kbCatG	:= 76
	kbCatH	:= 77
	kbCatI	:= 78
	kbCatJ	:= 79
	kbCatK	:= 80
	kbCatL	:= 81
	kbCatM	:= 82
	kbCatN	:= 83
	kbCatO	:= 84
	kbCatP	:= 85
	kbCatQ	:= 86
	kbCatR	:= 87
	kbCatS	:= 88
	kbCatT	:= 89
	kbCatU	:= 90
	kbCatV	:= 91
	kbCatW	:= 92
	kbCatX	:= 93
	kbCatY	:= 94
	kbCatZ	:= 95

end header
