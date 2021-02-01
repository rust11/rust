header	grdef - graphics

  type	grTpnt			; windows POINT, POINTL
  is	x   : long		; x
	y   : long		; y
  end

  type	grTdim
  is	w   : long		; width
	h   : long		; height
  end

  type	grText
  is	b   : long		; beginning
	l   : long		; length
  end

  type	grTlim
  is	b   : long		; beginning
	e   : long		; end
  end

	grSAM	:= (-1)			; same colour
	grBLK	:= 0			; black
	grRED	:= 1			; red
	grGRN	:= 2			; green
	grORG	:= 3			; orange ~~~
	grBLU	:= 4			; blue
	grPUR	:= 5			; purple
	grWHI	:= 10			; white
	grGRY	:= 11			; grey
	grDRK	:= 12			; dark grey
	grLRD	:= 13			; light red
	grLGR	:= 14			; light green
	grYEL	:= 15			; yellow
	grLBL	:= 16			; light blue
	grMAU	:= 17			; mauve
					; ...
					; ...

	gr_ppl	: (*wsTevt, *long, *LONG, LONG) int

end header

end file
  type	grTdot			; POINTS
  is	x   : word
	y   : word
  end

  type	grTsiz			; SIZE, SIZEL
  is	x   : long
	y   : long
  end

  type	grTrec			; RECT and RECTL
  is	Vlft : long	
	Vtop : long
	Vrgt : long
	Vbot : long
  end

  type	grTbox
  is	Vlft : long
	Vtop : long
	Vwid : long
	Vhgt : long
  end
end header
