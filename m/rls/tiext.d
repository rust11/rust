header	tiext - extended time functions
include rid:tidef

;;;	ti_str : (*tiTplx, *char) int	; plex to string
	ti_day : (*tiTplx, *char) int	; plex to day of week  string (mxLIN)
	ti_dat : (*tiTplx, *char) int	; plex to date string (mxLIN)
	ti_tim : (*tiTplx, *char) int	; plex to local time string (mxLIN)
	ti_doy : (*tiTplx) int		; plex to day-of-year
	ti_woy : (*tiTplx) int		; plex to week-of-year
	ti_lea : (*tiTplx) int		; plex to is_leap_year
	ti_mil : (*tiTcpu, *char) int	; value to millisecond string

end header
