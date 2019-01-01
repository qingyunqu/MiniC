var 20 T0
f_main [0]
var t0
t0 = call f_getint
var t1
t1 = 4 * 0
T0 [t1] = t0
var t2
t2 = call f_getint
var t3
t3 = 4 * 1
T0 [t3] = t2
var t4
t4 = call f_getint
var t5
t5 = 4 * 2
T0 [t5] = t4
var t6
t6 = call f_getint
var t7
t7 = 4 * 3
T0 [t7] = t6
var t8
t8 = call f_getint
var t9
t9 = 4 * 4
T0 [t9] = t8
var T1
T1 = 4
var T2
T2 = 0
l0:
var t10
t10 = T1 > 1
if t10 == 0 goto l1
var t11
var t12
var t13
t13 = 4 * T1
t12 = T0 [t13]
t11 = T2 + t12
T2 = t11
var t14
t14 = T1 - 1
T1 = t14
goto l0
l1:
var t15
param T2
t15 = call f_putint
T1 = t15
return T2
end f_main
