v0 = 0
f_main [0] [0]
t0 = 10
loadaddr v0 t1
t1[0] = t0
t1 = t0 > x0
if t1 == x0 goto l0
a0 = 1
return
goto l1
l0:
a0 = x0
return
l1:
end f_main
