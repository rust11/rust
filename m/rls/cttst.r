;	ct_whi - unused
;
;	initial letter of identifier
;	space/tab/newline/zero
file	cttst - character tests
include	rid:rider
include	rid:ctdef

code	ct_whi - check alphanumeric

  func	ct_whi
	cha : int
  is	fail if cha ne ' '
	reply cha eq '\t'
  end
end file
code	ct_aln - check alphanumeric

  func	ct_aln
	cha : int
  is	reply ctMtab(cha) & ctMaln	; a:z A:Z 0:9
  end

code	ct_alp - check alphabetic

  func	ct_alp
	cha : int
  is	reply ctMtab(cha) & ctMalp	; a:z A:Z
  end

code	ct_ctl - check control

  func	ct_ctl
	cha : int
  is	reply !(ctMtab(cha) & ctMprn)	; not printing
  end

code	ct_dig - check digit

  func	ct_dig
	cha : int
  is	reply ctMtab(cha) & ctMdig	; 0:9
  end

code	ct_ext - check extended character

  func	ct_ext
	cha : int
  is	reply ctMtab(cha) & ctMext	; $_
  end

code	ct_hex - check hex digit

  func	ct_hex
	cha : int
  is	reply ctMtab(cha) & ctMhex	; 0:9 a:f A:F
  end

code	ct_let - check letter

  func	ct_let
	cha : int
  is	reply ctMtab(cha) & ctMlet	; a:z A:Z
  end

code	ct_low - check lowercase

  func	ct_low
	cha : int
  is	reply ctMtab(cha) & ctMlow	; a:z
  end

code	ct_pun - check punctuation

  func	ct_pun
	cha : int
  is	reply ctMtab(cha) & ctMpun	; punctuation
  end

code	ct_spc - check whitespace

  func	ct_spc
	cha : int
  is	reply ctMtab(cha) & ctMspc	; space, tab, newline, bs, etc
  end

code	ct_upr - check uppercase

  func	ct_upr
	cha : int
  is	reply ctMtab(cha) & ctMupr	; A:Z
  end
