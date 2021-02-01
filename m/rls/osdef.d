header	osdef - operating systems

;	Separate header for PDP-11

	osVsys	: int extern	; operating system
	osVimp	: int extern	; implementation
	osVhst	: int extern	; host system (if any)
	osVcpu	: int extern	; cpu class
	osVend	: int extern	; osKbig/osKlit endian

	osKunk	:= 0		; unknown
	osKbig	:= 1		; big endian
	osKlit	:= 2		; little endian
	osKvax	:= 3		; vax-11
	osKvms	:= 4		; VAX/VMS
	osKx86	:= 5		; intel xxx86
	osKdos	:= 6		; MS-DOS or PC-DOS
	osKw16	:= 7		; Windows 16-bit system
	osKwin	:= 8		; Windows implementation
	osKw32	:= 9		; Win32 32-bit system
	osKw95	:= 10		; Windows 95 implementation
	osKwnt	:= 11		; Windows NT implementation

	os_ini	: (void) int	; init system
	os_war	: (void) void	; register warning
	os_err	: (void) void	; register error
	os_fat	: (void) void	; register fatal error
	os_exi	: (void) int	; exit image
	os_idl	: (void) int	; execute idle loop
	os_wai	: (LONG) int	; wait n milliseconds
				; prompt for input
	os_prm	: (*void, *char, *char, size) int
				;
	os_del : (*char, *int) int ; delete file

If Win
	os_w95	: (void) int	; is Windows 95
	os_wnt	: (void) int	; is Windows NT
	os_dbg	: (void) int	; is Debug version (not retail)
End

end header
