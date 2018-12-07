v0 = 0
v1 = malloc 40
f_f [2] [0]
t0 = a0 + a1
a0 = t0
call f_putint
t0 = a0
t1 = t0
loadaddr v0 t2
t2[0] = t1
end f_f
f_main [0] [2]
call f_getint
t0 = a0
t1 = t0
loadaddr v0 t2
t2[0] = t1
t0 = 10
t2 = t1 > t0
if t2 == x0 goto l0
a0 = 1
return
l0:
t0 = x0
store t0 1
load 1 t0
t2 = t0
store t2 0
l1:
load 1 t0
load v0 t1
t2 = t0 < t1
if t2 == x0 goto l2
call f_getint
t0 = a0
t1 = 4
load 1 t2
t3 = t1 * t2
loadaddr v1 t1
t1 = t1 + t3
t1[0] = t0
t0 = 4
load 1 t1
t2 = t0 * t1
loadaddr v1 t0
t0 = t0 + t2
t1 = t0[0]
load 0 t0
t2 = t0 + t1
t0 = t2
store t0 0
load 1 t0
t1 = 1
t2 = t0 + t1
t0 = t2
store t0 1
goto l1
l2:
load 0 a0
call f_putint
t0 = a0
t1 = t0
loadaddr v0 t2
t2[0] = t1
load 0 a0
load 1 a1
call f_f
t0 = a0
t1 = t0
loadaddr v0 t2
t2[0] = t1
a0 = x0
return
end f_main
