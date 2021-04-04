RUST\KIT\ETHER - Ethernet snippets.

Programming DEQNAs and DELQAs on the bare metal 
https://groups.google.com/g/alt.sys.pdp11/c/RTAzd5LGK6M

"Does anyone have any examples of doing card Setup, and packet
 Send and Receive for either of these two cards, sans OS (on 
 PDP11s or MicroVAXes)? Failing examples, any tips for getting 
 them to go that the manuals gloss over?"

I could never get the ethernet cards to work per the information
in the manuals (which wasn't all that unusual back in the 1980s).
Instead I found my own solutions via experimentation (aka hacking).
That said, these days I find it equally difficult to comprehend 
my own ethernet code, however, for what its worth I've copied 
some potentially useful sources to:

https://github.com/rust11/rust/tree/master/kit/ether 



NP.MAC - Bootstrap MOP Setup/Send/Receive 
NP.MAC is a skeleton RT-11 driver with an ethernet MOP bootstrap.
The trick here was to fit an ethernet boot into the less-than-256
words available for boots.


EG.MAC - DEQNA Setup/Send/Receive driver 
Buried beneath all the conditionals is an interrupt-driven RT-11
driver that slots into the NP.MAC skeleton driver.

EQ.MAC - Conditionals
LDE.MAC - Structure definitions 
Definitions for some of the structures used in EG.MAC and NP.MAC.
LDE is a source file extract from a generic macro library found
at RUST\P\SMS\.

NF.R
This is the Windows end of the NP.MAC MOP boot. I couldn't find 
the documentation for this back in the 1980's. NF.R is written
in my own language, Rider/C, however it has only one degree of
separation from plain C (including DECUS C). The source has 
debug code because WinPCap stopped working for me at some point.

QNB.MAC
This was my small app to read and store the DEQNA boot.


\EVS\*.MAR
Apropos nothing-in-particular here are the sources from a vastly
incomplete VAX project from many years ago which might have this
or that of interest. There's a debugger and reverse assembler of
sorts (BUG.MAR, REV.MAR). The definition files are located in
RUST\P\SMS\ED%.MAR.

