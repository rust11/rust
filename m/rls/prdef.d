header	prdef - process control
include rid:rider.h
include rid:stdef.h
;nclude <windows.h>

  type	prTacc
  is	Pnam : * char
	Pcmd : * char
	Hprc : * void
	Hthr : * void
	Vsts : int
  end

	pr_acc : (void) * prTacc
	pr_opr : (*prTacc, int) int
	pr_cre : (*prTacc) int
	pr_cmd : (*char) int
	pr_exe : (*char) int
	pr_slp : (int) int

	prCRE := 0
	prWAI := 1
	prSTS := 2
	prTER := 3
	prACT := -1

	prPacc : * prTacc extern

	prIDL := 0
	prBLW := 1 
	prNOR := 2 
	prABV := 3 
	prHGH := 4
	prRTM := 5
	prBGD := 6
 	prFGD := 7
	thIDL := 8
	thLOW := 9
	thBLW := 10
	thNOR := 11
	thABV := 12
	thHGH := 13
	thRTM := 14
	thBGD := 15
	thFGD := 16
	
	pr_pri : (int) int

end header
