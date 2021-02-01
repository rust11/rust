header	rsmod - RSX module

  type	rsTisb
  is	Vsta : byte		; status
	Vmod : byte		;
	Vlen : WORD		;
  end

  type	rsTnmb
  is	Afid : [3] WORD		; file ID
	Afna : [5] WORD		; /filnametctyp/
	Aver : WORD		; version
	Vsta : WORD		; status
	Vnxt : WORD		; wildcards
	Adid : [3] WORD		; directory ID
	Adev : [2] char		; device name
	Vuni : WORD		; unit 
  end

end header
