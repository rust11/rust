file	rtdco - display RT-11 class object
include rid:rider
include rid:fidef
include rid:rtcla
include rid:stdef

  func	rt_dco
	spc : * char
	cla : * rtTcla
  is
	PUT("[%s] %o/%u. blocks\n", spc, cla->Vsiz, cla->Vsiz)
	PUT("Opened as: ", spc)
	PUT("Device ") if cla->Vflg & fcDEV_
	PUT("Directory ") if cla->Vflg & fcDIR_
	PUT("Container ") if cla->Vflg & fcCON_
	PUT("File ") if cla->Vflg & fcFIL_
	PUT("\n")

	PUT("Channel: ")
	PUT("Network ") if cla->Vflg & fcNET_
	PUT("Logical ") if cla->Vflg & fcVIR_
	PUT("System ") if cla->Vflg & fcSYS_
	PUT("Magtape ") if cla->Vflg & fcMAG_
	PUT("Cassette ") if cla->Vflg & fcCAS_
	PUT("Disk ") if cla->Vflg & fcDSK_
	PUT("Partition ") if cla->Vflg & fcPAR_
	PUT("Sub-Directory ") if cla->Vflg & fcSUB_
	PUT("Protected ") if cla->Vflg & fcPRO_
	PUT("\n")
  end
