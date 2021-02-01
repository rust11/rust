header	vtdef - vt100 emulation
include rid:kbdef

	vtPipt : * char+
	vtAipt : [16] char+
	vtPopt : * char+
	vtAopt : [16] char+

	vt_mod : (int) int
	vt_ipt : (kbTcha) int
	vt_opt : (int) int

end header
