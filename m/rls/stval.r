file	stval - scan number
include rid:rider

  func	st_val
	str : * char		; "1234"
	bas : int		; 8, 10 or 16
	val : * int	; opt.	; result value
	cnt : * int~	; opt.	; number of characters parsed
  is	scn : * char
	tmp : int = 0
	len : int = 0
	res : int

	case bas
	of 8   scn = "%o%n%*s"
	of 10  scn = "%d%n%*s"
	of 16  scn = "%h%n%*s"
	of other
	       fail
	end case
	fail if SCN(str, scn, &tmp, &len) lt 2
;	res = SCN(str, scn, &tmp, &len)
;	PUT("scn=[%s] cnt=%d len=%d tmp=%d\n", scn,res, len, tmp)
	*val = tmp if val
	*cnt = len if cnt
	fine
  end
