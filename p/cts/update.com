!;???;	CTS: fiwlk limbo
!	CTS:UPDATE.COM - Build CRT.OBJ library
!
!	@CTS:UPDATE [NOLOG] [ALL|LIST|LIBR|LATER]
!
!	@updhdr	- headers
!	@updcts - CTS: modules (mostly)
!	@updrls - RLS: modules
!	@updcop - CTS: text files (embedded below)
!	@updlib - library (LIB:CRT.OBJ)

@cts:updhdr!	update headers
!
loop$:
!
@cts:updcts!	update CTS: modules
@cts:updrls!	update RLS: modules
!
done$
LIBR:
log$ CRT.OBJ
@cts:updlib!	update library
!
!cts:updcop!	copy modules/library to LIB: (below)
!
cop$ := check$ ^1 ^1:^2 lib:^2 copy ^1:^2 lib:^2
cop$ cts crt.mac!	CRT.MAC macro front end (includes RUST.MAC)
cop$ cts rust.mac!	RUST.MAC macro front end
cop$ ctb crt.obj!	the library
!
END$:
end$
