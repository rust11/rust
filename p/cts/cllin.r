file	cllin - get initial command line
include rid:rider

;	cl_lin - don't prompt for a command
;
;	Get the initiating command
;	Fail indicates no command given
;	See rls:clwin.r for prototype

  func	cl_lin
	lin : * char
  is	reply cl_cmd (<>, lin)
  end
