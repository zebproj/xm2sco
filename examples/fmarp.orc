gisine ftgen 0, 0, 4096, 10, 1
instr 1	
ipch = cpspch(p4)
iamp = .2
imod = p5
;iamp = p5
kenv linsegr 0, 0.001, 1, 0.005, 0
a1 foscil iamp*kenv, ipch, 3, 5, 5*imod, gisine
outs a1, a1
endin
