header	iodef - source/listing i/o
 
	io_ini	: (void) int		; init it all
	io_spc	: (int) *char		; return file spec
	io_lin	: (int) int		; return line number
	io_src	: (*char, *char) int	; open next source
	io_opn	: (int, *char, *char, *char) int
	io_clo	: (int) int		; close a file
	io_get	: (*char) int		; get a line
	io_put	: (*char) int		; put a line

;	File numbers

	ioClst := 10			; last include file
	ioCout := 10			; output file
	ioCtot := 13			; total files
	ioLspc := 32			; filespec size
	ioLlin := 134			; line length

end header
