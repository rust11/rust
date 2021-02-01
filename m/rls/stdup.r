file	stdup - string duplicate
include	rid:rider
include	rid:stdef
include	rid:medef

code	st_dup - duplicate string

  func	st_dup 
	str : * char~			; string to duplicate
	()  : * char			; duplicated string
  is	dup : * char~			; duplicate
	reply <> if !str		; clone null pointer
	st_len (str) + 1		; required space
	dup = me_alc (that)		; get the space
	st_cop (str, dup)		; make a copy
	reply dup			; the duplicate
  end
