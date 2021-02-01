header	dddef -- tu58 dd: definitions

  type	ddTdat			; data packet
  is	Vtyp : BYTE
	Vcnt : BYTE
	Adat : [512] BYTE
  end

  type	ddTpkt			; control packet
  is	Vtyp : BYTE		; packet type
	Vcnt : BYTE		; data count
;	...........		;
	Vopr : BYTE		; operation
	Vsts : BYTE		; modifier or status (<0 => error)
	Vuni : BYTE		; device unit
	Vswi : BYTE		; switches
	Vseq : WORD		; sequence number (unused)
	Vbct : WORD		; byte count
	Vblk : WORD		; block number
;	Vsum = Vblk		; summary in END packets
	Vchk : WORD		; checksum
  end

	ddVER_ := BIT(0);  ->	; Vsts - Write-verify (low power read)
	ddSEG_ := BIT(7);  ->	; Vsts - 128-byte segment addressing
	ddMAI_ := BIT(4);  ->	; Vswi - maintenance mode
;	ddDDX  := 6584		; Vsum - DD: Extended (^rDDX)

;	Packet type

	ddDAT := 1	; <->	; data packet
	ddCTL := 2	; <->	; control packet
				;
	ddINI := 4	;  ->	; init command 
	ddBOO := 8	;  ->	; boot command
	ddCON := 16	; <-	; continue command
	ddXON := 17	;  ->	; XON command
	ddXOF := 19	;	; XOF command
				; extended codes
	ddNUL := 30	;  ->	; null segment
	ddLOO := 31	;  ->	; loop test

;	Opcodes

	ddNOP := 0	; ->	; Nop     
	ddRST := 1	; ->	; Reset   
	ddREA := 2	; ->	; Read
	ddWRI := 3	; ->	; Write
	ddPOS := 5	; ->	; Position
	ddDIA := 7	; ->	; Diagnose
	ddGST := 8	; nop	; Get Status
	ddSST := 9	; nop	; Set Status
	ddEND := 64	; <-	; end packet

;	Error codes

	ddSUC := 0		; success (1 is okay too)
	ddUNI := -8		; bad unit number
	ddPRT := -11		; write protected unit
	ddIOX := -17		; I/O error
	ddTRN := -1		; transmission error (not sent)

;	Extended server/client handshake

	ddSXT := 075224	; <-	; Vseq from server
	ddCXT := 013224	; ->	; Vseq response from client

end header
