file	btmap - bitmap operations
include	rid:rider
include	rid:btmap
include	rid:medef

  func	bt_alc
	siz : size		; size in bits
	()  : * btTmap
  is	map : * btTmap~
	map = me_acc (#btTmap)
	map->Vsiz = siz
	map->Parr = me_acc ((siz/8)+1); +1 to round up
	reply map
  end

  func	bt_map
	map : * btTmap
	bit : size
	opr : int
	()  : int
  is	arr : * BYTE~ = map->Parr
	byt : size~ = bit / 8
	flg : WORD~ = BIT(bit % 8)
	res : int
	fail if bit ge map->Vsiz
	res = arr[byt] & flg
	case opr
	of btCLR  arr[byt] &= ~flg
	of btSET  arr[byt] |= flg
;sic]	of btTST
	of btZAP  me_clr (arr, map->Vsiz/8)
	end case
PUT("opr=%o adr=%o ", opr, arr+byt)
PUT("bit=%o byt=%o flg=%o @byt=%o res=%o\n", bit, byt, flg, arr[byt], res)
	reply res
  end
