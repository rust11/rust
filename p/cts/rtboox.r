file	rtboo - generic RUST/RT-11 boot loader
include	rid:rider
include	rid:eldef
include	rid:btdef
include	rid:rmdef
include	rid:rtcst
include	rid:rtdev	; dst
include rid:rtcla	; file class

;	bo.xxx	
;	br.xxx	boot record
;	rm.xxx	rmon record
;	bt.xxx

  type	btTrad
  is	Pspc : * elTwrd
	Pdev : * elTwrd
	Pdrv : * elTwrd

	Aspc : [4] elTwrd
	Arad : [4] elTwrd	; rad50 translation
	Alog : [4] char		; logical device name
  end


  type	btTctx
  is
	Pimg : * elTwrd		; active image
	Pslf : * elTwrd		; self image, if any
	Vfor : int		; foreign
	Vslf : int		;
	Vidt : int		;
	Vrun : int		;
				;
	Pspc : * char		; "dev:file.typ"
	Pdef : * char		; default spec
	Plog : * char		; logical device name, untranslated
	Pphy : * char		; physical device name
	Pdrv : 


	Vops : int		; operating system
	Vhst : int		;
	Vval : int		; boot image validated

	Idst : rtTdst		; device status
	Icst : rtTcst		; channel status
	Icla : rtTcla		; file class

	Irad : btTrad
  end
	RAD := (ctx->Irad

code	bt_alc - allocate boot context

  func	bt_alc
  is	ctx : * btTctx
	ctx = me_acc (#btTctx)

	ctx-Pspc = ctx->Aspc	; fill in the pointers
	ctx->Pslf =		;

  end

code	bt_dlc - deallocate boot context

  func	bt_dlc
	ctx : * btTctx
  is	me_dlc (ctx)
  end
code	bt_loa - boot loader

	btSPC
	btAUT_	:= BIT(X)	; auto process antecedents

  func	bt_loa
	ctx : * btTctx
  is
	bt_spc (ctx) if FLG(SPC); translate device and file specs
	bt_img (ctx)		; get the image
	bt_drv (ctx)		; get the driver
	bt_pri (ctx)		; build the primary boot
	bt_sec (ctx)		; build the secondary boot
	bt_boo (ctx)		; do the physical boot
  end
code	bt_spc - process the file specification

  func	bt_spc
	ctx : * btTctx
  is

	if !ctx->Pspc			; no incoming spec
	   st_cop (ctx->Pdef, ctx->Pspc); use default
	   SET(DEF)			; using default
	end


  end
	