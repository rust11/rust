!	KPS:UPDATE.COM - build and update KPB:KEYPAD.SAV
!
@ops:up
def$ kps kpb
cli$ kpb:keypad.sav 'P1' 'P2'
loop$:
mac$ kphtm!	html
mac$ kpwrd!	word processing
mac$ kppos!	position
mac$ kpdis!	display server
mac$ kpins!	insert
mac$ kpfun!	virtual functions
mac$ kpdat!	data
mac$ kp100!	vt100/vt200 
mac$ kpgra!	graphic control
mac$ kproo!	root
mac$ kpbrk!	?
mac$ kpcom!	commands
mac$ kpter!	terminal input
mac$ kprec!	record structures
mac$ kpfil!	files
mac$ kptap!	tape editor
mac$ kprst!	RUST
mac$ kpsta!	status
mac$ kpcli!	cli
mac$ kpeng!	engine
mac$ kputl!	utilities
!
mac$ kpdel!	delete
mac$ kpsea!	search
mac$ kppas!	paste
mac$ kpcas!	case
mac$ kptxt!	text input
mac$ kpopt!	terminal output
mac$ kpvts!	vtxxx server
mac$ kpvtt!	vt tables
mac$ kpusr!
mac$ kphlp!	help
!
done$
display "KEYPAD.SAV"
@@kps:kpimg
!
link:
r link
kpb:keypad,kpb:keypad=/n//
kpb:kproo,kpdat,kpimg,kpeng,kpfun
kpb:kppos,kpins,kpdel,kppas,kpsea,kpcas
kpb:kpsta,kprst,kputl,kpter
kpb:kpdis,kpvts,kpvtt,kp100,kpgra/o:1
kpb:kpwrd,kpbrk,kpopt
kpb:kpcli,kpfil,kprec,kptap,kphtm/o:1
kpb:kphlp/o:1
kpb:kpcom/o:1
//
^C
!set program/notrace/nopath kpb:keypad
end$:
end$
