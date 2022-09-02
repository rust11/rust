init vm:/noquery
copy sy:vm.sys vm:
copy sy:rt11fb.sys vm:
copy sy:swap.sys vm:
copy/boot vm:rt11fb vm:
copy sy:xx.sys vm:
copy sy:xxrt.sav vm:
copy sy:pip.sav vm:
copy sy:xxcpu.bic vm:


