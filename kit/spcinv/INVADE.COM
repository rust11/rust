define spc ian
goto 'p1'
goto again
init:
delete spc:space.com
delete spc:space.dat
delete spc:space.sta
exit
test:
delete/symbol/all
set noedit
set nolog
set cli @spc:invade
again:
set def spc
run spc:invade
@spc:space
                                                                                                                                                                                                                                                                                   