header	wsmsg - windows message boxs

;	wmb_msg := MessageBox		; DLL routine
;	wmb_msg : (int, *char, *char, int) int
					;
	wmbNO	  := (-1)		; NO  lt 0
	wmbCANCEL := 0			; CAN eq 0
	wmbOK	  := 1			; OK  gt 0
	wmbYES	  := 2			; YES gt 0
	wmbABORT  := 3			;
	wmbRETRY  := 4			;
;	wmbIGNORE := 			;
					; box buttons
	wmbOK_	  := 0			; OK
	wmbOC_	  := 1			; OK	 CANCEL
	wmbARI_	  := 2			; ABORT  RETRY IGNORE
	wmbYNC_	  := 3			; YES NO CANCEL
	wmbYN_	  := 4			; YES NO
	wmbRC_	  := 5			; RETRY  CANCEL
					; box graphic
	wmbERROR_ := 16			; an error
	wmbQUERY_ := 32			; a query
	wmbWARN_  := 48			; a warning
	wmbINFO_  := 64			; info

end header
