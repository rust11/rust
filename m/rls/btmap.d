header	btmap - bitmap operations
;	type size : unsigned		;

  type	btTmap
  is	Vsiz : unsigned		; size in bits
	Parr : * BYTE		; 
  end

	btCLR := 0
	btSET := 1
	btTST := 2
	btZAP := 3

	bt_alc : (size) * btTmap
	bt_map : (*btTmap, size, int) int

end header
