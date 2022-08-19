file	funa - solve DECUS-C function pointer problem
include	rid:rider

;	%build
;	rider cus:fun/obj:cub:/nodelete
;	link cub:fun,lib:crt/bottom=2000/exe:cub:fun/map:cub:fun
;	%end


  type	fuTctx
  is	Vval : int
  end

  type	fuTfun : (*fuTctx) int
	fu_fun : fuTfun

  type	fuTitm
  is	Pfun : * (*fuTctx) int
  end

  init	fuIptr : fuTitm
;  is	fu_fun
;  end

	fu_dis : (*void)

code	start

  func	start
  is
	fu_dis (&fu_fun)
  end

  func	fu_dis
 	fun : * void~
  is	ptr : * (*fuTctx) int
a
	ptr = fun
	(*ptr)(<>)
  end

  func	fu_fun
	ctx : * fuTctx~
  is	PUT("Okay\n")
  end


end file

file	fun3 - solve DECUS-C function pointer problem
include	rid:rider

;	%build
;	rider cus:fun/obj:cub:/nodelete
;	link cub:fun,lib:crt/bottom=2000/exe:cub:fun/map:cub:fun
;	%end


;  type	dcTfun : (*dcTdcl) int	; DCL function
;
;	Pfun : * (*dcTdcl) int	;|function

  type	fuTctx
  is	Vval : int
  end

  type	fuTfun : (*fuTctx) int
	fu_fun : fuTfun

  type	fuTitm
  is	Pfun : * (*fuTctx) int
  end

  init	fuIptr : fuTitm
;  is	fu_fun
;  end

	fu_dis : (*void)

code	start

  func	start
  is
	fu_dis (&fu_fun)
  end

  func	fu_dis
 	fun : * void~
  is	ptr : * fuTitm = &fuIptr
b
	ptr->Pfun = fun
	(*ptr->Pfun)(<>)
  end

  func	fu_fun
	ctx : * fuTctx~
  is	PUT("okay\n")
  end


end file

file	fun - solve DECUS-C function pointer problem
include	rid:rider

;	%build
;	rider cus:fun/obj:cub:/nodelete
;	link cub:fun,lib:crt/bottom=2000/exe:cub:fun/map:cub:fun
;	%end

  type	cxTctx
  is	Vval : int
  end

  type	cxTfun : (*cxTctx) int
	cf_fun : cxTfun

code	start

	fu_dis : (*void)

  func	start
  is	cx_dis (&fu_fun)
  end

  type	cxTptr
  is	Pfun : * cxTfun
  end

  func	cx_dis
 	fun : * void
  is	ptr : cxTptr
	ptr.Pfun = fun
	(*ptr.Pfun)(<>)
  end

  func	fu_fun
	ctx : * fuTctx
  is	rt_bpt ()
  end


end file
file	fun - solve DECUS-C function pointer problem
include	rid:rider
include rid:vfdef

;	%build
;	rider cus:fun/obj:cub:/nodelete
;	link cub:fun,lib:crt/bottom=2000/exe:cub:fun/map:cub:fun
;	%end


;  type	dcTfun : (*dcTdcl) int	; DCL function
;
;	Pfun : * (*dcTdcl) int	;|function

  type	fuTfun : (*vfTobj, *vfTent)
	fu_fun : fuTfun

  type	fuTitm
  is	Pfun : * (*fuTctx) int
  end

  init	fuIptr : fuTitm
;  is	fu_fun
;  end

	fu_dis : (*void)

code	start

  func	start
  is
	fu_dis (&fu_fun)
  end

  func	fu_dis
 	fun : * void
  is	ptr : * fuTitm = &fuIptr
	ptr->Pfun = fun
	(*ptr->Pfun)(<>)
  end

  func	fu_fun
	ctx : * fuTctx
  is	rt_bpt ()
  end


end file
file	fun - solve DECUS-C function pointer problem
include	rid:rider

;	%build
;	rider cus:fun/obj:cub:/nodelete
;	link cub:fun,lib:crt/bottom=2000/exe:cub:fun/map:cub:fun
;	%end


;  type	dcTfun : (*dcTdcl) int	; DCL function
;
;	Pfun : * (*dcTdcl) int	;|function

  type	fuTctx
  is	Vval : int
  end

  type	fuTfun : (*fuTctx) int
	fu_fun : fuTfun

  type	fuTitm
  is	Pfun : * (*fuTctx) int
  end

  init	fuIptr : fuTitm
;  is	fu_fun
;  end

	fu_dis : (*void)

code	start

  func	start
  is
	fu_dis (&fu_fun)
  end

  func	fu_dis
 	fun : * void
  is	ptr : * fuTitm = &fuIptr
	ptr->Pfun = fun
	(*ptr->Pfun)(<>)
  end

  func	fu_fun
	ctx : * fuTctx
  is	rt_bpt ()
  end


end file
file	fun - solve DECUS-C function pointer problem
include	rid:rider

;	%build
;	rider cus:fun/obj:cub:/nodelete
;	link cub:fun,lib:crt/bottom=2000/exe:cub:fun/map:cub:fun
;	%end

  type	cxTctx
  is	Vval : int
  end

  type	cxTfun : (*cxTctx) int
	cf_fun : cxTfun

code	start

	fu_dis : (*void)

  func	start
  is	cx_dis (&fu_fun)
  end

  type	cxTptr
  is	Pfun : * cxTfun
  end

  func	cx_dis
 	fun : * void
  is	ptr : cxTptr
	ptr.Pfun = fun
	(*ptr.Pfun)(<>)
  end

  func	fu_fun
	ctx : * fuTctx
  is	rt_bpt ()
  end


end file
file	fun - solve DECUS-C function pointer problem
include	rid:rider

;	%build
;	rider cus:fun/obj:cub:/nodelete
;	link cub:fun,lib:crt/bottom=2000/exe:cub:fun/map:cub:fun
;	%end


  type	fuTctx
  is	Vval : int
  end

  type	fuTfun : (*fuTctx) int
	fu_fun : fuTfun

  type	fuTptr
  is	Pfun : * fuTfun
;  is	Pfun : * (*fuTctx) int
  end

  init	fuPind : * fuTfun = <>

	fu_dis : (*void)

code	start

  func	start
  is
	fu_dis (&fu_fun)
  end

  func	fu_dis
 	fun : * void
  is	ptr : fuTptr
;	ptr.Pfun = fun
;	(*ptr.Pfun)(<>)
	fuPind.Pfun = fun
	(*fuPind.Pfun)(<>)

  end

  func	fu_fun
	ctx : * fuTctx
  is	rt_bpt ()
  end


end file
file	fun - solve DECUS-C function pointer problem
include	rid:rider

;	%build
;	rider cus:fun/obj:cub:/nodelete
;	link cub:fun,lib:crt/bottom=2000/exe:cub:fun/map:cub:fun
;	%end


;  type	dcTfun : (*dcTdcl) int	; DCL function
;
;	Pfun : * (*dcTdcl) int	;|function

  type	fuTctx
  is	Vval : int
  end

  type	fuTfun : (*fuTctx) int
	fu_fun : fuTfun

  type	fuTitm
  is	Pfun : * (*fuTctx) int
  end

  init	fuIptr : fuTitm
;  is	fu_fun
;  end

	fu_dis : (*void)

code	start

  func	start
  is
	fu_dis (&fu_fun)
  end

  func	fu_dis
 	fun : * void
  is	ptr : * fuTitm = &fuIptr
	ptr->Pfun = fun
	(*ptr->Pfun)(<>)
  end

  func	fu_fun
	ctx : * fuTctx
  is	rt_bpt ()
  end


end file
;  type	dcTfun : (*dcTdcl) int	; DCL function
;
;	Pfun : * (*dcTdcl) int	;|function

  type	fuTctx
  is	Vval : int
  end

  type	fuTfun : (*fuTctx) int

	fu_fun : fuTfun

  type	fuTitm
  is	Vcnt : int
	Pfun : * (*fuTctx) int
  end

  init	fuIptr : fuTitm
  is	1, fu_fun
  end

	fu_dis : (*void)

code	start

  func	start
  is	ctx : * fuTctx = <>
	fun : * fuTitm = &fuIptr

	fu_dis (&fu_fun)
  end

  func	fu_dis
 	fun : * void
  is	ptr : * fuTitm = &fuIptr
	ptr->Pfun = fun
	(*ptr->Pfun)(<>)
  end

  func	fu_fun
	ctx : * fuTctx
  is	rt_bpt ()
  end


