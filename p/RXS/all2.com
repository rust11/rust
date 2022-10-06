set tt quiet
open log all2
build/log rxs:rt11n
build/log rxs:rt11s
build/log rxs:rsi
build/log rxs:mer
build/log rxs:acpend
!!
build/log rxs:syssec!				SYS overlay
build/log rxs:sys
build/log rxs:sda
build/log rxs:smi
build/log rxs:sut
build/log rxs:syx
!!uild/log rxs:sna
build/log rxs:sdp
build/log rxs:scp
build/log rxs:sbp
build/log rxs:spr
build/log rxs:sph
build/log rxs:phd
build/log rxs:sysend
!!
build/log rxs:utlsec!				UTL overlay
build/log rxs:utl!				UTL request dispatcher
build/log rxs:rti!				Timer requests
build/log rxs:dtt!				TT:
build/log rxs:dvm!				VM:
build/log rxs:dnl!				NL:
build/log rxs:utx!				utilities
build/log rxs:upo!				pool
build/log rxs:sjo!				gtjb
build/log rxs:udr!				drivers
build/log rxs:rsh
build/log rxs:rkm!				share-11, kmon
build/log rxs:ucl!				CLI utilities
build/log rxs:urt!				realtime requests
build/log rxs:xev!				KEV external
build/log rxs:xdh!				KDH external
build/log rxs:sna!				logical names
build/log rxs:rsf!				special functions
!!
build/log rxs:envsec!				ENV overlay
build/log rxs:env
build/log rxs:ere
build/log rxs:ede
build/log rxs:etx!			Environment stuff
build/log rxs:envend
!!
!build/log rxs:boofil!				BOO roundup
!build/log rxs:boosec!				BOO overlay
!build/log rxs:boo!				rxs:boo or rxs:bod
!build/log rxs:bpr!				build process?
!build/log rxs:bde!				build devices
!build/log rxs:bvm!				build vm directory
!build/log rxs:bpo!				build pool
!build/log rxs:bke!				build kernel
!build/log rxs:bda!				build data
!build/log rxs:esb!				system build
!build/log rxs:booend
!
build/log rxs:poosec!				POO section
build/log rxs:kdv!				Kernel development - patchs
build/log rxs:kdb!				Must be last - may be overwritten
close log
