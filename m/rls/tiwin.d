
header	tiwin - windows time routines
include	rid:tidef
include	<windows.h>

	ti_fnp	: (*SYSTEMTIME, *tiTplx) void	; from nt plex to our plex
	ti_tnp	: (*tiTplx, *SYSTEMTIME) void	; to nt plex from our plex

end header
