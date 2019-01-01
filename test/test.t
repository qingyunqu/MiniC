v0 = malloc 20
f_main [0] [2]
	call f_getint
	t0 = a0
	t1 = 4
	t2 = t1 * x0
	loadaddr v0 t1
	t1 = t1 + t2
	t1[0] = t0
	call f_getint
	t0 = a0
	t1 = 4
	t2 = 1
	t3 = t1 * t2
	loadaddr v0 t1
	t1 = t1 + t3
	t1[0] = t0
	t0 = 1
	store t0 0
	t0 = x0
	store t0 1
l0:
	t0 = 1
	t1 =  - t0
	load 0 t0
	t2 = t0 > t1
	if t2 == x0 goto l1
	t0 = 4
	load 0 t1
	t2 = t0 * t1
	loadaddr v0 t0
	t0 = t0 + t2
	t1 = t0[0]
	load 1 t0
	t2 = t0 + t1
	t0 = t2
	store t0 1
	load 0 t0
	t1 = 1
	t2 = t0 - t1
	t0 = t2
	store t0 0
	goto l0
l1:
	load 1 a0
	call f_putint
	t0 = a0
	t1 = t0
	store t1 0
	load 1 a0
	return
end f_main
