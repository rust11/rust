$ ! SHUTDOWN.COM -- Orderly system shutdown command procedure.
$ !
$ SET DEFAULT SYS$SYSTEM
$ SET NOON
$
$ @SYS$MANAGER:SYSHUTDWN
$
$ STOP VAMP_1
$
$ MCR INSTALL
$
$ DISMOUNT DMA0:
$ DISMOUNT DMA2:
$ DISMOUNT DMA3:
$ RUN SYS$SYSTEM:OPCCRASH
$ EXIT
                                                                                                                                                                                                                                                        