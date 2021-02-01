header	eddef - ed definitions

	edPlin : * char extern		; line base pointer
	edPbod : * char extern		; line body
	edPdot : * char extern		; current pointer

	ed_ini	: (void) int
	ed_set	: (*char, *char) void
	ed_del	: (*char) int
	ed_eli	: (*char) int
	ed_chg	: (*char, *char) int
	ed_skp	: (*char) int
	ed_scn	: (*char) *char
	ed_sub	: (*char, *char, *char) *char
	ed_rst	: (*char) *char
	ed_rep	: (*char, *char) *char
	ed_fnd	: (*char) *char
	ed_exc	: (*char, *char, int) *char
	ed_tru	: (void) void
	ed_pre	: (*char) *char
	ed_app	: (*char) *char
	ed_gap	: (*char, *char) int
	ed_mor	: (void) int
	ed_lst	: (void) *char

	ed_loc	: (*char, *char) *char
end header
