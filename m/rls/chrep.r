file	chrep - replace characters in a string
include rid:rider
include rid:chdef

code	ch_rep - replace characters

;	Replace even model characters with odd model characters
;
;	ch_rep ("+-", "a + b") => "a - b"
;	ch_rep ("<*@.>_", "@<>") => ".*_"
;
;	Terminates if either an odd or even model character is zero

  proc	ch_rep 
	mod : * char~
	str : * char
  is	ptr : * char~
	while mod[0] && mod[1]
	   ptr = str
	   while *ptr
	      if *mod eq *ptr
	      .. *ptr = mod[1]
	      ++ptr
	   end
	   mod += 2
	end
  end
