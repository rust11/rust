!	IPS:UPDATE.COM - build and update IMPORT.SAV
!
@ops:up
tem$ mac$ ips ipb
cli$ ipb:import.sav 'P1' 'P2'
!
LOOP$:
mac$ improo
mac$ impcom
mac$ impcop
mac$ impacc
mac$ impods
mac$ imprta
mac$ imppar
mac$ imputl
mac$ impdat
mac$ imperr
mac$ impinf
DONE$
display "IMPORT.SAV"
link:
!@@ips:impinf
link ipb:impinf/prompt/execute:ipb:import/map:ipb:import/cross
ipb:improo,imppar
ipb:impcom,impcop
ipb:impacc,impods,imprta
ipb:imputl,impdat,imperr
//
^C
!set program ipb:import/ctrlz/nopath
END$:
end$
