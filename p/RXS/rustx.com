!	RUSTX.COM - build RUST/XM
!
set tt quiet
!@rxs:stb create only!			Create new STB
!					KER section
!build/log rxs:kda
!build/log rxs:kii
!build/log rxs:kco
!build/log rxs:kqu
!build/log rxs:kpo
!build/log rxs:kev
!build/log rxs:kve
!build/log rxs:kin
!build/log rxs:kte
!build/log rxs:kti
!!					MON section
!build/log rxs:mna
!build/log rxs:mio
!build/log rxs:mix
!build/log rxs:mch
!build/log rxs:mut
!build/log rxs:eve
!build/log rxs:ktv
!build/log rxs:kdh
!build/log rxs:kdv
!!
!build/log rxs:kerfre!				
!build/log rxs:kersec!			KER roundup
!!
!build/log rxs:reqfil!			REQ roundup
!!
!build/log rxs:reqsec!			REQ overlay
!build/log rxs:mep
!build/log rxs:rmi
!build/log rxs:rch
!build/log rxs:rio
!build/log rxs:rte
!build/log rxs:red
!build/log rxs:rcf
!build/log rxs:rim
!build/log rxs:rcl
!build/log rxs:reqend
!!
!build/log rxs:acpsec
!build/log rxs:acp
!build/log rxs:rac
!build/log rxs:rax
!build/log rxs:rsp
!build/log rxs:rt11a
!build/log rxs:rt11n
!build/log rxs:rt11s
!build/log rxs:rsi
!build/log rxs:mer
!build/log rxs:acpend
!!
!build/log rxs:syssec!			SYS overlay
!build/log rxs:sys
!build/log rxs:sda
!build/log rxs:smi
!build/log rxs:sut
!build/log rxs:syx
!!uild/log rxs:sna
!build/log rxs:sdp
!build/log rxs:scp
!build/log rxs:sbp
!build/log rxs:spr
!build/log rxs:sph
!build/log rxs:phd
!build/log rxs:sysend
!!
!build/log rxs:utlsec!			UTL overlay
!build/log rxs:utl!			UTL request dispatcher
!build/log rxs:rti!			Timer requests
!build/log rxs:dtt!			TT:
!build/log rxs:dvm!			VM:
!build/log rxs:dnl!			NL:
!build/log rxs:utx!			utilities
!build/log rxs:upo!			pool
!build/log rxs:sjo!			gtjb
!build/log rxs:udr!			drivers
!build/log rxs:rsh
!build/log rxs:rkm!			share-11, kmon
!build/log rxs:ucl!			CLI utilities
!build/log rxs:urt!			realtime requests
!build/log rxs:xev!			KEV external
!build/log rxs:xdh!			KDH external
!build/log rxs:sna!			logical names
!build/log rxs:rsf!			special functions
!!
!build/log rxs:envsec!			ENV overlay
!build/log rxs:env
build/log rxs:ere
build/log rxs:ede
build/log rxs:etx!			Environment stuff
build/log rxs:envend
!
build/log rxs:boofil!			BOO roundup
build/log rxs:boosec!			BOO overlay
build/log rxs:boo!			rxs:boo or rxs:bod
build/log rxs:bpr!			build process?
build/log rxs:bde!			build devices
build/log rxs:bvm!			build vm directory
build/log rxs:bpo!			build pool
build/log rxs:bke!			build kernel
build/log rxs:bda!			build data
build/log rxs:esb!			system build
build/log rxs:booend
!
build/log rxs:poosec!			POO section
build/log rxs:kdv!			Kernel development - patchs
build/log rxs:kdb!			Must be last - may be overwritten
@rxs:link
