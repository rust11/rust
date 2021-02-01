file	qumod - queue operations
include	rid:rider
include	rid:qudef

code	qu_slf - queue to self

  func	qu_slf
	que : * quTque
  is	PRE(que) = que
	SUC(que) = que
  end

code	qu_nul - test for nul queue element

  func	qu_nul
	que : * quTque
  is	reply PRE(que) eq SUC(que)
  end

code	qu_ins - insert queue element (before successor)

  func	qu_ins
	suc : * quTque
	new : * quTque
  is	pre : * quTque = PRE(suc)
	SUC(pre) = new
	PRE(new) = pre
	SUC(new) = suc
	PRE(suc) = new
  end

code	qu_rem - remove queue element

  func	qu_rem
	que : * quTque
	()  : * quTque
  is	pre : * quTque = PRE(que)
	suc : * quTque = SUC(que)
	SUC(pre) = suc
	PRE(suc) = pre
	qu_slf (que)
	reply que
  end
code	queues with queue header operations

  func	qu_emp
	hdr : * quTque
  is	reply PRE(hdr) eq SUC(hdr)
  end

  func	qu_psh
	hdr : * quTque
	new : * quTque
  is	qu_ins (new, SUC(hdr))
  end

  func	qu_app
	hdr : * quTque
	new : * quTque
  is	qu_ins (new, PRE(hdr))
  end

  func	qu_pop
	hdr : * quTque
	()  : * quTque
  is	fail if qu_emp (hdr)
	reply qu_rem (SUC(hdr))
  end
code	ordered queue insertion

  func	qu_pos
	hdr : * quTque
	new : * quTque
  is	nxt : * quTque = hdr
	pos : int = new->Vpos
	repeat
	   nxt = SUC(nxt)
	   quit if nxt eq hdr
	   next if pos le nxt->Vpos
	forever
	qu_ins (new, nxt)
  end


