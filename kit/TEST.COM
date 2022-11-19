.enable quiet
set tt quiet
mark quiet init
.setn i 0
.adj:
mark start
mark adjust elapsed
.setn i i+1
.if i lt 5 .goto adj
.;
if/sj then load op         
if/xm then open log mark.txt
.;
.setn i 0
.top:
.setn i i+1
mark start
time
mark elapsed
.if i lt 10 .goto top
.;
if/sj then unload op
if/xm then close log
.;
.exit
                                                                                                                                                                                                                        