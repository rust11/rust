!	RESET.COM - Test MSCP timeouts
!
geek display ""
geek display "Issue CPU reset"
mark start
geek reset
mark
!
geek display ""
geek display "Issue RT-11 .hreset"
mark start
geek hreset
mark
!
geek display ""
geek display "Issue MSCP reset"
mark start
geek mscp
mark
set tt quiet
