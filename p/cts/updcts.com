!	CTS:UPDCTS - Update mostly CTS: modules
!
@ops:up cts ctb CRT.OBJ 'P1' 'P2'!	standard templates
tem$ ccc$ cts ctb!			DECUS-C template
rls$  := check$ ^1 rls:^1.r ctb:^1.obj rider rls:^1/nodelete/obj:ctb:^1
!
mlb$ crtmac!	build CRT.MLB
mac$ bseng!	block stream engine	bs$get etc
rid$ btmod!	RT-11 boot utilities
mac$ bttem!	RT-11 boot template	btAtem[]
mac$ cccmd!	setup & call main	cc_cmd()
mac$ ccexi!	image exit		cc_exi(sts)
mac$ ccd2a!	$$dtoa (decus-c)
mac$ ccfmt!	sprintf
mac$ ccfpr!	fprintf
mac$ ccini!	cl_cmd, cc_cmd, main	cc_ini
mac$ ccl2a!	$$ltoa
mac$ ccprf!	printf
mac$ ccprt!	doprnt
mac$ ccsav!	csv/cret 		cc.sta: jmp start
mac$ ccssc!	sscanf
mac$ ccscn!	doscan
mac$ ccstk!	relocate stack		cc_stk (len) ; in bytes
mac$ clcmd!	ccl/.gtlin		cl/co_cmd(prm,buf) int; cl_sin() int
mac$ coctc!	ctrl-c control		co_ctc (int) int
rid$ cllin!	get initial command	cl_lin(*buf) int
mac$ em374!	RT-11 emts		em_375(&r0,chn|cod) int
mac$ em375!	RT-11 emts		em_e74(&r0,chn|cod,...) int
mac$ emdon!	emt done 		em$don
mac$ fbbuf!	allocate file buffer	fb$buf
mac$ fbrea!	fileblock I/O		fb$rea/fb$wri/fb$buf
mac$ ficlo!	close file		fi_clo(*F,msg[,ext]) int
mac$ fidat!	file ops data
mac$ fidev!	device/channel data	
mac$ fidel!	delete file		fi_del(spc,msg) 
mac$ fierr!	get file error code	fi_err(*F) int
mac$ fiexs!	check file exists	fi_exs(spc,msg) int
mac$ fiflu!	flush file		fi_flu(*F) int
mac$ figch!	get character		fi_gch(*F) int
mac$ figet!	get line		fi_get(*F,*char,int) int
rid$ fiimg!	open image file		fi_img () * FILE
mac$ filen!	get open file length	fi_len(*F) size
mac$ fimis!	check file missing	fi_exs(spc,msg) int
mac$ fiopn!	open file		fi_opn(spc,mod,msg[,ext]) *F
mac$ fiopr!	file operation		fi$opr(...)
mac$ fichn	get file channel	fi$chn(*F) int
mac$ fipch!	put character		fi_pch(*F,char) int
mac$ fiprt!	protect file		fi_prt(*F,*msg)
mac$ fiput!	put line		fi_put(*F,*char)
mac$ firea!	read file		fi_rea(*F,buf,cnt) int
mac$ fipos!	get file position	fi_pos(*F) long
mac$ firen!	rename file		fi_ren(old,new,msg) int
mac$ firep!	report file messages	fi_rep(...)
mac$ fisee!	seek			fi_see(*F,long) int
mac$ fisiz!	get file length		fi_siz(*spc) size
mac$ fispc!	get file specification	fi_spc(*F) *char
rid$ fitim!	get/set file time	fi_gtm/fi_stm (...tiTval)
mac$ fiung!	fi_ung, unget		fi_ung (fil)
mac$ fiunp	unprotect file		fi_unp(*F,*msg)
mac$ fiwri!	write file		fi_wri(*F,buf,cnt) int
!!d$ fiwlk!	wildcard walk		
mac$ fizap!	purge all channels	me_zap()
mac$ immod!	init image 		im_ini(img)
mac$ imrep!	report message		im_rep(msg, obj)
mac$ imsav!	save/rest image context	im_sav(*ctx), im_rst(*ctx)
mac$ imsuc!	success/clear status	im_clr(), im_suc()
rid$ lnmod!	logical names		ln_def(log,equ),ln_und()...
mac$ meacc!	allocate/clear memory	me_acc(size) *void
mac$ mealc!	allocate memory		me_acc(size) *void
mac$ meclr!	clear memory		me_clr(*void, int) *void
mac$ mecmw!	compare words		me_cmw(*WORD,*WORD,cnt) int
rid$ mecop!	copy memory		me_cop(*void, *void, size) *void
mac$ medlc!	deallocate memory	me_dlc(*void)
mac$ meini!	init memory		me_ini() *void
mac$ memap!	alllocate without abort	me_map(size) *void
mac$ memax!	get maximum empty size	me_max(void) size
rid$ memov!	move memory		me_mov(*void, *void, size) *void
rid$ memnt!	memory maintenance	me_mnt(), me_val ()
mac$ mepee!	peek memory		me_pee(*void, *int, cnt) int
mac$ mepok!	poke memory		me_pok(*void, *int, cnt) int
mac$ meprb!	probe memory		me_prb(*void, int) int
mac$ mesav!	save/restore memory	me_sav(*meTctx) *void
mac$ mesig!	set/get signal routine	me_map(*void) *void
rid$ qdcvt!	quad int conversion	qd_lqs, qd_lqu, etc
rid$ qdmod!	quad int arithmetic	qd_tst, qd_add, etc
rid$ qdstr!	quad int strings	qd_str, qd_fmt, etc
ccc$ qsort1!	classic qsort
ccc$ qsort2!	classic qsort
rls$ rdmod!	RT-11 directory toolkit
rid$ rsclk!	RSX get time		rs_clk (*tiTval)
mac$ rsdet!	RSX detect RTX		rs_det ()
mac$ rsemt!	RSX EMT			rs_emt (*blk, *sts)
mac$ rsexi!	RTX exit to RSX		rs_exi()
rid$ rsidx!	RTX index file variablesrs_idx (*max,*fre)
rid$ rsint!	RTX interrupt on/of	rs_int (opr)
rid$ rsmap!	Get bitmap blocks	rs_map (*char, *long, *long) int 
mac$ rsspn!	RSX MCR command		rs_mcr (*cmd, *sts)i,rs_dcl(),rs_spn()
mac$ rster!	RSX terminal		rs_ati(), rs_dti()
rid$ rtbad!	RT-11 bad block kit
mac$ rtboo!	RT-11 boot		rt_boo (*char,*char,int,*WORD) *char
mac$ rtbpt!	issue bpt instruction	rt_bpt()
mac$ rtchn!	RT-11 chain		rt_chn (*rad50)
mac$ rtcla!	RT-11 file class	rt_cla(*F, *rtTcla) int
mac$ rtcsi!	RT-11 CSI decode	rt_csi(*csi, *lin) int
mac$ rtcst!	RT-11 channel status	rt_cst(*F,sts) int
rid$ rtdco	display file class
rid$ rtdrv!	Find/Open RT-11 driver 	rt_drv(*dev,*drv,>*spc,>*F) int
mac$ rtdst!	RT-11 device status	rt_dst(spc,*dst) int
rid$ rtera!	RT-11 block erase	rt_era(fil,blk,cnt,flg) int
mac$ rtfat!	get/set file attributes	rt_fat(spc,opr,off,*get,*set,*msg) int
mac$ rtfet!	fetch driver etc	rt_fet(spc,*adr) int
mac$ rtftm!	setup file time		rt_ftm(*rtTent, siz)
mac$ rtglf!	JSW gtlin flag		rt_flg(0 or 1)
mac$ rtgtm!	RUST get extended time	rt_gtm(*tim)
mac$ rtgvl!	RT-11 gval/pval		rt_gvl(off) int, rt_pvl(off,val)
mac$ rthtz!	get clock rate (hertz)	rt_htz() int
mac$ rtinf!	get/set file info 	rt_gxx (fil, *cur [new]) int
mac$ rtini!	process .INI 		No current C/Rider interface
mac$ rtlog!	RT-11 logical names	lt_def(log,equ),lt_und() etc
rid$ rtnat!	native time		nt_val(), nt_plx(), nt_cmp()
rid$ rtops!	Get op. sys. code	rt_ops () int
mac$ rtrea!	RT-11 read/write	rt_rea(fil, blk, buf, wct, don)
mac$ rtrel!	release driver		rt_rel()
mac$ rtprm!	RT-11 command prompt	rt_prm(*prm, *lin, flg) int
mac$ rtqry!	RT-11 Are you sure?	rt_qry(*prm) int
mac$ rtrea!	RT-11 read/write        rt_rea(fil,...) int
mac$ rtres!	.sreset			rt_res()
mac$ rtsav!	save/restore registers	call rt$sav, call rt$res
rid$ rtscn!	scan RT-11 directories	rt_scn(*scn,*spc,sel,*msg) int
mac$ rtsee!	block/byte seek		rt_see(*F,blk,byt) int
mac$ rtsox!	Set-On-Exit (.DEVICE)	rt_sox(adr)
mac$ rtspf!	RT-11 special function	rt_spf(fil,blk,buf,wct,fun,don)
mac$ rtstm!	RUST set extended time	rt_stm(*tim)
mac$ rtter!	check spec is terminal	rt_ter(*char) int
rid$ rttim!	RT-11 time utilities
mac$ rttin!	RT-11 terminal input	rt_tin (int, int) int
rid$ rttrn!	RT-11 block transfer	rt_wld(*ifl,*ofl,ibl,obl,cnt,flg) int
mac$ rttrp!	catch bus/cpu/mmu traps	tr$cat(), tr$res()
rid$ rtwld!	RT-11 wildcard search	rt_wld(*scn,*mod,*spc,*msg) int
mac$ rtxmm!	check for xm monitor	rt_xmm() int
mac$ rtxtc!	exit to dcl command	rt_xtc (*char) void
mac$ rxfmt!	format rad50 string	rx_fmt(*ch,*WORD,*ch) *char
mac$ rxpck!	pack rad50 word		rx_pck(*char,*WORD) *char
mac$ rxscn!	scan rad50 spec		rx_scn(*char,*WORD) *char
mac$ rxunp!	unpack rad50 word	rx_pck(*WORD,*char) *char
mac$ sthyp!	hyphenate word		st_hyp(*char)
rid$ timat!	timer math		ti_add(...)...
rid$ tipdp!	time conversion		ti_plx(*val,*plx), ti_val (*plx,*val)
rid$ tirng!	check time range	ti_rng(*plx,*plx) fine/fail
mac$ tiwai!	timed wait		ti_wai(LONG)
!id$ uxsys!	Unix system calls
!mac$ xmmap!	Map extended memory	xm$map, xm$res
