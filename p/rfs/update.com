!	RFS:UPDATE.COM - Build RUST/XM features
!
!	@RFS:UPDATE [ALL|LIST|LINK]
!
@ops:up rfs rfb NONE 'P1' 'P2'
!mac$ := check$ ^1 rfs:^1.mac rfb:^1.obj build rfs:^1
!@ops:updatx 'P1' 'P2'
!!
!LOOP$:
!
mac$ featur!	must be first
mac$ batch
mac$ batchf
mac$ debug!	also builds DEBUGS
mac$ extern
!!!$ feaini!	unused
mac$ feapoo!	unused, but I think it works
!!!$ feapro!	obsolete
mac$ images
mac$ logger
mac$ mailer
mac$ plas
mac$ queue
mac$ queuex
mac$ real
mac$ revers
mac$ sdata
!!!$ shut.mas
!!!$ spodef
mac$ spool
mac$ spoolx
mac$ trace
!
done$
end$:
