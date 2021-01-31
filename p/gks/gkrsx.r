;	unused

file	rsx - test RSX features
include rid:rider

  type	loTfea
  is	Vcod : int
	Pstr : * char
  end

  init	loAfea : loTfea
  is	1, "22-bit"
	2, "Multi-user protection"
	3, "Executive 20k support"
	4, "Loadable drivers"
	5, "PLAS"
	6, "Dynamic checkpoint allocation"
	7, "I/O packet preallocation"
	8, "Extend Task directive"
	9, "LSI-11"
	10, "Parent/offspring tasking"
	11, "Full-duplex terminal"
	12, "X.25 CEX loaded"
	13, "Dynamic memory allocation"
	14, "Comm Exec loaded"
	15, "MCR exits after each command"
	16, "Logins disabled"
	17, "Kernel data space enabled"
	18, "Supervisor mode libraries"
	19, "Multiprocessing"
	20, "Event trace feature"
	21, "CPU accounting"
	22, "Shadow recording"
	23, "Secondary pools"
	24, "Secondary pool windows"
	25, "Separate directive partition"
	26, "Install, run, remove"
	27, "Group global event flags"
	28, "Receive/send data packets"
	29, "Alternate headers"
	30, "Round-robin scheduling"
	31, "Executive level disk swapping"
	32, "TCB event flag mask"
	33, "Spontaneous system crash"
	34, "XDT system crash"
	35, "EIS required"
	36, "Set System Time directive"
	37, "User data space"
	38, "Secondary pool prototype TCBs"
	39, "External task headers"
	40, "ASTs"
	41, "RSX-11S system"
	42, "Multiple CLIs"
	43, "Separate terminal driver pool"
	44, "Pool monitoring"
	45, "Watchdog timer"
	46, "RMS record locking"
	47, "Shuffler"
	0, <>
  end

  init	loAemt : [] WORD
  is	(2*256)+177		; FEAT$
	0			; feature number
  end
code	rsx features

  func	start
  is	cod : int
	fea : * loTfea = loAfea
	while fea->Vcod
	   loAcod[1] = fea->Vcod
	   if rs_emt (loAfea, 0)
	   .. PUT("%s\n", fea->Pstr)
	   ++fea
	end
	fine
  end


