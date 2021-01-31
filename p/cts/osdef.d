header	osdef

;	See SMS:LDO.MAC $OSDEF for full set of codes

	osRTJ := 020	; RT-11/SJ & RT-11 family
	osRTB := 021	; RT-11/FB (or similar)
	osRTM := 022	; RT-11/XM (or similar)

	osRSJ := 0326	; RUST/SJ & RUST family
	osRXM := 0324	; RUST/XM
			;
	osRBT := 0325	; RUST/BT (RUSTboot)

  type	rtTops
  is	Vfam : int	; o/s family
	Vcod : int	; SJ/FB/XM/BT
  end

	rt_ops : (*rtTops) int

end header
