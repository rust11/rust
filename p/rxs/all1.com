set tt quiet
open log all1
!	RUSTX.COM - build RUST
!
@rxs:stb create only!			Create new STB
!					KER section
build/log rxs:kda
build/log rxs:kii
build/log rxs:kco
build/log rxs:kqu
build/log rxs:kpo
build/log rxs:kev
build/log rxs:kve
build/log rxs:kin
build/log rxs:kte
build/log rxs:kti
!!					MON section
build/log rxs:mna
build/log rxs:mio
build/log rxs:mix
build/log rxs:mch
build/log rxs:mut
build/log rxs:eve
build/log rxs:ktv
build/log rxs:kdh
build/log rxs:kdv
!!
build/log rxs:kerfre!				
build/log rxs:kersec!				KER roundup
!!
build/log rxs:reqfil!				REQ roundup
!!
build/log rxs:reqsec!				REQ overlay
build/log rxs:mep
build/log rxs:rmi
build/log rxs:rch
build/log rxs:rio
build/log rxs:rte
build/log rxs:red
build/log rxs:rcf
build/log rxs:rim
build/log rxs:rcl
build/log rxs:reqend
!!
build/log rxs:acpsec
build/log rxs:acp
build/log rxs:rac
build/log rxs:rax
build/log rxs:rsp
build/log rxs:rt11a
close log
@rxs:all2
