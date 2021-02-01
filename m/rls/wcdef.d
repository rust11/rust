header	wcdef - client code definitions
If !&wsSVR
	wsCLI := 1

  type	wsTctx : void
  type	wsTevt : void			
  type	wsTcal : (*wsTevt) int
  type	wsTfnt : void
  type	wsThan : * void
  type	wsTdev : wsThan
  type	wsTfac : forward

include	rid:wgdef
End
end header
