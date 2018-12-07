var T0
var 40 T1
f_f [2]
var t0
var t1
t1 = p0 + p1
param t1
t0 = call f_putint
T0 = t0
end f_f
f_main [0]
var t2
t2 = call f_getint
T0 = t2
var t3
t3 = T0 > 10
if t3 == 0 goto l0
return 1
l0:
var T2
var T3
T3 = 0
T2 = T3
l1:
var t4
t4 = T3 < T0
if t4 == 0 goto l2
var t5
t5 = call f_getint
var t6
t6 = 4 * T3
T1[t6] = t5
var t7
var t8
var t9
t9 = 4 * T3
t8 = T1[t9]
t7 = T2 + t8
T2 = t7
var t10
t10 = T3 + 1
T3 = t10
goto l1
l2:
var t11
param T2
t11 = call f_putint
T0 = t11
var t12
param T2
param T3
t12 = call f_f
T0 = t12
return 0
end f_main
