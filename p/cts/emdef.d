header	emdef - define RT-11 calls
Error Crt rtdef If !Crt
;nclude ctb:emdef

	em_loo (r0,chn,spc,seq)	:= em_375 (r0,(1<<8)|chn,spc,seq)
	em_ent (r0,ch,sp,ln,sq) := em_375 (r0,(2<<8)|ch,sp,ln,sq)
	em_del (r0,chn,spc)	:= em_375 (r0,(0<<8)|chn,spc)
	em_ren (r0,chn,old,new)	:= em_375 (r0,(4<<8)|chn,old,new)

	emSYN := 0		; .readw - synchronous I/O
	emPOL := 1		; .read  - polled I/O

	em_rea (r0,ch,bf,bl,wc) := em_375 (r0,(8<<8)|ch,bl,bf,wc,0)
	em_wri (r0,ch,bf,bl,wc)	:= em_375 (r0,(9<<8)|ch,bl,bf,wc,0)
	em_fun(r,ch,bf,bl,wc,f) := em_375 (r,(26<<8)|ch,bl,bf,wc,(f<<8)|255,0)

	em_abt (r0,chn)		:= em_374 (r0,(11<<8)|chn)
	em_clo (r0,chn)		:= em_374 (r0,(6<<8)|chn)
	em_pur (r0,chn)		:= em_374 (r0,(3<<8)|chn)
	em_wai (r0,chn)		:= em_374 (r0,(0<<8)|chn)

;	RT-11 V1 EMTs can't be generalised in an I/D environment

	rt_dst : (*char, *WORD) int	; device status
	rt_fet : (*char) *WORD		; fetch 
	rt_rel : (*WORD) void		; release

end header
