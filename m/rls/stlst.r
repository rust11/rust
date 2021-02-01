file	stlst - last character
include rid:rider
include rid:stdef

code	st_lst - look at last character

;	st_lst : (str : *char) => *char
;
;	reply str if *str eq		; null case
;	reply st_end (str) - 1		; reply last
;
;	if str[0]			; null case
;	   while str[1]			; string end
;	.. .. ++str			;
;	reply str			; reply last

  func	st_lst
	str : * char~			; string
	()  : * char			; at last character
  is	reply str if *str eq		; null string
	spin while *str++		; get to the end quickly
	reply str - 2			; backup to last character
  end
