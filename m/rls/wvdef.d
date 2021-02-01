header	wvdef - wave file operations

	wvEOF	:= 0		; eof marker
	wvGEN	:= 1		; general
	wvMRK	:= 2		; marker
				;
	wvBAR_	:= BIT(0)	; barline
	wvTXT_	:= BIT(1)	; has text field

  type	wvTatr			; wave file attribute
  is	Psuc : * wvTatr		; successor
	Vtyp : int		; mark type
	Vflg : int		; flags
	Vbeg : size		; mark beginning
	Vsiz : size		; mark size 
	Pdat : * void		; related data
  end

;	wvBYT	:= 0		; byte stream
;	wvWRD	:= 1		; word stream
;	wvMON	:= 0		; mono
;	wvSTE	:= 2		; stereo
;
;	wvMBS	:= 0		; mono byte stream
;	wvMWS	:= 1		; mono word stream
;	wvSBS	:= 2		; stereo byte stream
;	wvSWS	:= 3		; stereo word stream
;
;	Modify a wave prototype by altering Vcnt, Vchn, Vrat and Vwid.
;	Call wv_nor () after any change.
;	Do not change Vtot, Vavg or Vpnt -- these are computed from the above.

  type	wvTwav
  is	Pdat : * char		; data area (past header)
	Vtot : size		; total size of data area (without padding)
				;
	Vcnt : size		; total number of data points
	Vchn : int	; 1,2	; number of channels (mono/stereo)
	Vrat : LONG	; 11k..	; sampling rate in hertz
	Vwid : int	; 1,2	; point width in bytes
				;
	Vbeg : size		; start of segment
	Vsiz : size		; size of segment
				;
	Vsta : int		; current state
	Vpos : size		; current position
				;
	Pspc : * char		; the filespec
;	Pmrk : * wvTmrk		; markers
;	Pann : * wvTann		; annotations
				;
	Phdr : * void		; header (private)
	Vhan : * void		; handle (private)
	Patr : * wvTatr		; attributes
	Vflg : int		; output flags
				;
	Vpnt : size		; point size (Vchn * Vwid)
	Vavg : size		; average bytes per second

;	Save area for other programs

	Vlft : size		; left marker
	Vrgt : size		; right marker
  end

  type	wvTseg			; wave segment
  is	Pwav : * wvTwav		;
	Vbeg : size		; beginning of segment
	Vsiz : size		; size of segment
  end

;	Wave functions

	wvSTP	:= 0			; stop
	wvPLY	:= 1			; play
	wvLOO	:= 2			; loop
	wvPAU	:= 3			; pause
	wvCON	:= 4			; continue
	wvREC	:= 5			; recording

	wvSEG_	:= BIT(1)		; segment (not all)
	wvFST_	:= BIT(2)		; first in loop
	wvLST_	:= BIT(3)		; last in loop
	wvLOO_	:= (wvFST_|wvLST_)	; loop

; 	Wave alignment flags

	wvCHN_	:= BIT(1)		; channels
	wvRAT_	:= BIT(3)		; rate
	wvWID_	:= BIT(2)		; byte/word

	wv_loa	: (*char, *char, *char) *wvTwav; load sound file
	wv_sto	: (*wvTwav, *char, *char) int  ; store sound file
	wv_ipt	: (*wvTwav, *char) int	; input atributes
	wv_opt	: (*wvTwav, *char) int	; output attributes

	wv_clo	: (*wvTwav) int		; deallocate wave components 
	wv_out  : (*wvTwav, int) int	; output wave
	wv_rec	: (*wvTwav, int) *wvTwav; record wave
					;
	wv_sta	: (*wvTwav) int		; get wave status
	wv_pos	: (*wvTwav) int		; get position
	wv_fun 	: (*wvTwav, int) int	; stop/pause/continue
	wv_ext	: (*wvTwav, size, size) int ; setup physical extent
					;
	wv_ply 	: (*char, int) int	; play sound file
					;
	wv_dup	: (*wvTwav) *wvTwav	; duplicate a wave
	wv_alc	: (*wvTwav, size) *wvTwav ; allocate wave
	wv_dlc	: (*wvTwav) int		; deallocate a wave
					; catenate upto 3 segments
 	wv_cat	: (*wvTwav, *wvTseg, *wvTseg, *wvTseg, int) *wvTwav
	wvLCI_  := BIT(0)		; left channel in
	wvRCI_  := BIT(1)		; right channel in
	wvLCO_  := BIT(2)		; left channel out
	wvRCO_  := BIT(3)		; right channel out

	wv_sho : (*wvTwav) void		; show
	wv_nor : (*wvTwav) 		; normalise
	wv_clr : (*wvTwav) void		; clear a wave


If WVDEF_LOCAL

	pragma	pack(2)		;
  type	wvThdr
  is	Arif : [4] char		; "RIFF"
	Vfsz : LONG		; file size
	Awav : [8] char		; "WAVEfmt "
	Vunk : LONG		; always 16???
	Vfmt : WORD		; format type (wvPCM)
	Vchn : WORD		; number of channels (1 or 2)
	Vrat : LONG		; rate -- samples per second (11025, 
	Vavg : LONG		; average bytes per second
	Valn : WORD		; block alignment/size of data
	Vwid : WORD		; width -- bits per sample (8 or 16)
	Adta : [4] char		; "data"
	Vdsz : LONG		; data size (fsz - #wvThdr)
  end

  type	wvTfil			; wave file
  is	Ihdr : wvThdr		;
	Adat : [1] BYTE		;
  end
	pragma	pack()

	wv_hdr	: (*wvTwav) int
;	wv_nor	: (*wvTwav) int
End

end header
