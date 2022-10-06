!	RXS:UPDATE.COM - Build RUST/XM
!
!	@RFS:UPDATE [ALL|LIST|LINK]
!
!mac$ := check$ ^1 rxs:^1.mac rxb:^1.obj build rxs:^1
!
!@ops:updatx 'P1' 'P2'
@ops:up rxs rxb rxs:rustx.sav 'P1' 'P2'
tem$ mac$ rxs rxb build
!					KER section
LOOP$:
mac$ kda
mac$ kii
mac$ kco
mac$ kqu
mac$ kpo
mac$ kev
mac$ kve
mac$ kin
mac$ kte
mac$ kti
!					MON section
mac$ mna
mac$ mio
mac$ mix
mac$ mch
mac$ mut
mac$ eve
mac$ ktv
mac$ kdh
mac$ kdv
!
mac$ kerfre!				
mac$ kersec!			KER roundup
!
mac$ reqfil!			REQ roundup
!
mac$ reqsec!			REQ overlay
mac$ mep
mac$ rmi
mac$ rch
mac$ rio
mac$ rte
mac$ red
mac$ rcf
mac$ rim
mac$ rcl
mac$ reqend
!
mac$ acpsec
mac$ acp
mac$ rac
mac$ rax
mac$ rsp
mac$ rt11a
mac$ rt11n
mac$ rt11s
mac$ rsi
mac$ mer
mac$ acpend
!
mac$ syssec!			SYS overlay
mac$ sys
mac$ sda
mac$ smi
mac$ sut
mac$ syx
mac$ sna
mac$ sdp
mac$ scp
mac$ sbp
mac$ spr
mac$ sph
mac$ phd
mac$ sysend
!
mac$ utlsec!			UTL overlay
mac$ utl!			UTL request dispatcher
mac$ rti!			Timer requests
mac$ dtt!			TT:
mac$ dvm!			VM:
mac$ dnl!			NL:
mac$ utx!			utilities
mac$ upo!			pool
mac$ sjo!			gtjb
mac$ udr!			drivers
mac$ rsh
mac$ rkm!			share-11, kmon
mac$ ucl!			CLI utilities
mac$ urt!			realtime requests
mac$ xev!			KEV external
mac$ xdh!			KDH external
mac$ sna!			logical names
mac$ rsf!			special functions
!
mac$ envsec!			ENV overlay
mac$ env
mac$ ere
mac$ ede
mac$ etx!			Environment stuff
mac$ envend
!
mac$ boofil!			BOO roundup
mac$ boosec!			BOO overlay
mac$ boo!			boo or bod
mac$ bpr!			build process?
mac$ bde!			build devices
mac$ bvm!			build vm directory
mac$ bpo!			build pool
mac$ bke!			build kernel
mac$ bda!			build data
mac$ esb!			system build
mac$ booend
!
mac$ poosec!			POO section
mac$ kdv!			Kernel development - patchs
mac$ kdb!			Must be last - may be overwritten

DONE$
LINK:
log$ RUSTX.SAV
@rxs:link
END$:
