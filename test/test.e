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
var T1
T1 = 1
var T2
T2 = 0
l0:
var t4
var t5
t5 = - 1
t4 = T1 > t5
if t4 == 0 goto l1
var t6
var t7
var t8
t8 = 4 * T1
t7 = T0 [t8]
t6 = T2 + t7
T2 = t6
var t9
t9 = T1 - 1
T1 = t9
goto l0
l1:
var t10
param T2
t10 = call f_putint
T1 = t10
return T2
end f_main
